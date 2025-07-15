# Homelab
## Let's gooooo
I'm kicking off the metamorphasis of my homelab. To date I've been running docker on a single appliance. It's worked well but I've run into the limitations associated with a single appliance, i.e. resiliancy. An individual service run inside a single container has a single point of failure. Containers going down for one reason or another has bummed me out.

A particularly painfull container to crash is my password manager. If the appliance running my docker containers goes offline so does my password manager. Getting the appliance back online often requires said passwords. I've bridged the issue by moving the password manager to a Digital Ocean droplet.

Hosted compute is great for scalability and flexibility, but it's expensive. The services I'm running don't require many resources and so it is more cost effective to run on my own hardware. Plus, it's a great learning opportunity.