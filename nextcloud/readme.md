```bash
mkdir secrets
touch secrets/mysql_root_pass
touch secrets/mysql_user_pass
mkdir app
mkdir app/config
mkdir app/data
mkdir mariadb
mkdir mariadb/config
mkdir mariadb/mysql-data
mkdir redis
mkdir redis/config
mkdir redis/redis-data
```

generate passwords and paste root_pass and user_pass files
```bash
openssl rand -base64 32
```

copy redis.conf file

deploy the bitch