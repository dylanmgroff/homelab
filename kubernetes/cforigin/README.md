#+TITLE: Origin CA Issuer

Origin CA Issuer is a [[https://github.com/cert-manager/cert-manager][cert-manager]] CertificateRequest controller for Cloudflare's [[https://developers.cloudflare.com/ssl/origin-configuration/origin-ca][Origin CA]] feature.

** Getting Started
*** Prerequisites

- Kubernetes: releases with [[https://endoflife.date/kubernetes][maintenance support]]
- cert-manager: releases under [[https://endoflife.date/cert-manager][upstream support]], which can be installed following upstream's [[https://cert-manager.io/docs/installation/][documentation]].

You must also have permissions in the Kubernetes cluster to create Custom Resource Definitions.

*** Installing Origin CA Issuer
First, we need to install the Custom Resource Definitions for the Origin CA Issuer.

```
kubectl apply -f deploy/crds
```

Then install the RBAC rules, which will allow the Origin CA Issuer to operate with OriginIssuer and CertificateRequest resources

```
kubectl apply -f deploy/rbac
```

Then install the controller, which will process Certificate Requests created by cert-manager.

```
kubectl apply -f deploy/manifests
```

By default the Origin CA Issuer will be deployed in the =origin-ca-issuer= namespace.

```
$ kubectl get -n origin-ca-issuer pod
NAME                                READY   STATUS      RESTARTS    AGE
pod/origin-ca-issuer-1234568-abcdw  1/1     Running     0           1m
```

*** Adding an OriginIssuer
**** API Token
Origin CA Issuer can use an API token that contains the "Zone / SSL and Certificates / Edit" permission, which can be scoped to specific accounts or zones. Both [[https://developers.cloudflare.com/fundamentals/api/get-started/create-token/][user API tokens]] and [[https://developers.cloudflare.com/fundamentals/api/get-started/account-owned-tokens/][Account owned tokens]] are supported.

``` :file ./deploy/example/cfapi-token.secret.yaml :results silent file :exports code
kubectl create secret generic \
    --dry-run \
    -n default cfapi-token \
    --from-literal key=cfapi-token -oyaml
```

Then create an OriginIssuer referencing the secret created above.

#+BEGIN_SRC yaml :tangle ./deploy/example/api-token.issuer.yaml :comments link
apiVersion: cert-manager.k8s.cloudflare.com/v1
kind: OriginIssuer
metadata:
  name: prod-issuer
  namespace: default
spec:
  requestType: OriginECC
  auth:
    tokenRef:
      name: cfapi-token
      key: key
```

#+BEGIN_EXAMPLE
$ kubectl apply -f api-token.secret.yaml -f issuer.yaml
originissuer.cert-manager.k8s.cloudflare.com/prod-issuer created
secret/cfapi-token created
#+END_EXAMPLE

The status conditions of the OriginIssuer resource will be updated once the Origin CA Issuer is ready.

#+BEGIN_EXAMPLE
$ kubectl get originissuer.cert-manager.k8s.cloudflare.com prod-issuer -o json | jq .status.conditions
[
  {
    "lastTransitionTime": "2020-10-07T00:05:00Z",
    "message": "OriginIssuer verified an ready to sign certificates",
    "reason": "Verified",
    "status": "True",
    "type": "Ready"
  }
]
#+END_EXAMPLE

**** Origin CA Service Key
The [[https://developers.cloudflare.com/fundamentals/api/get-started/ca-keys/][Origin CA Key]] is supported but discouraged in favor of API tokens. This key will begin with "v1.0-" and is different from the legacy "Global API Key".

``` :file ./deploy/example/service-key.secret.yaml :results silent file :exports code
kubectl create secret generic \
    --dry-run \
    -n default service-key \
    --from-literal key=v1.0-FFFFFFF-FFFFFFFF -oyaml
```

Then create an OriginIssuer referencing the secret created above.

#+BEGIN_SRC yaml :tangle ./deploy/example/service-key.issuer.yaml :comments link
apiVersion: cert-manager.k8s.cloudflare.com/v1
kind: OriginIssuer
metadata:
  name: prod-issuer
  namespace: default
spec:
  requestType: OriginECC
  auth:
    serviceKeyRef:
      name: service-key
      key: key
```

#+BEGIN_EXAMPLE
$ kubectl apply -f service-key.secret.yaml -f issuer.yaml
originissuer.cert-manager.k8s.cloudflare.com/prod-issuer created
secret/service-key created
#+END_EXAMPLE

The status conditions of the OriginIssuer resource will be updated once the Origin CA Issuer is ready.

#+BEGIN_EXAMPLE
$ kubectl get originissuer.cert-manager.k8s.cloudflare.com prod-issuer -o json | jq .status.conditions
[
  {
    "lastTransitionTime": "2020-10-07T00:05:00Z",
    "message": "OriginIssuer verified an ready to sign certificates",
    "reason": "Verified",
    "status": "True",
    "type": "Ready"
  }
]
#+END_EXAMPLE

*** Creating our first certificate

We can create a cert-manager managed certificate, which will be automatically rotated by cert-manager before expiration.

#+BEGIN_SRC yaml :tangle ./deploy/example/certificate.yaml :comments link
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: default
spec:
  # The secret name where cert-manager should store the signed certificate
  secretName: example-com-tls
  dnsNames:
    - example.com
  # Duration of the certificate
  duration: 168h
  # Renew a day before the certificate expiration
  renewBefore: 24h
  # Reference the Origin CA Issuer you created above, which must be in the same namespace.
  issuerRef:
    group: cert-manager.k8s.cloudflare.com
    kind: OriginIssuer
    name: prod-issuer
```

Note that the Origin CA API has stricter limitations than the Certificate object. For example, DNS SANs must be used, IP addresses are not allowed, and further restrictions on wildcards. See the Origin CA documentation for further details.

** Ingress Certificate
You can use cert-manager's support for [[https://cert-manager.io/docs/usage/ingress/][Securing Ingress Resources]] along with the Origin CA Issuer to automatically create and renew certificates for Ingress resources, without needing to create a Certificate resource manually.

#+BEGIN_SRC yaml :tangle ./deploy/example/ingress.yaml :comments link
apiVersion: networking/v1
kind: Ingress
metadata:
  annotations:
    # Reference the Origin CA Issuer you created above, which must be in the same namespace.
    cert-manager.io/issuer: prod-issuer
    cert-manager.io/issuer-kind: OriginIssuer
    cert-manager.io/issuer-group: cert-manager.k8s.cloudflare.com
  name: example
  namespace: default
spec:
  rules:
    - host: example.com
      http:
        paths:
         - pathType: Prefix
           path: /
           backend:
              service:
                name: examplesvc
                port:
                  number: 80
  tls:
    # specifying a host in the TLS section will tell cert-manager what
    # DNS SANs should be on the created certificate.
    - hosts:
        - example.com
      # cert-manager will create this secret
      secretName: example-tls
```

You may need additional annotations or =spec= fields for your specific Ingress controller.

** Disable Approval Check
The Origin Issuer will wait for CertificateRequests to have an [[https://cert-manager.io/docs/concepts/certificaterequest/#approval][approved condition set]] before signing. If using an older version of cert-manager (pre-v1.3), you can disable this check by supplying the command line flag =--disable-approved-check= to the Issuer Deployment.
