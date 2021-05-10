# README

This README would normally document whatever steps are necessary to get the
application up and running.

To run it locally as development environment, create a .env file at root path and put inside the following code:
```
BUNDLER_VERSION=2.2.15
# To find your user id, run id -u
APP_USER_ID=1000
# To find your user group, run id -g
APP_GROUP_ID=1000
```

Create you own secret keys using the following commands (at the first time you run it will create credentials/development.key) don't commit it:
```
docker-compose run app rails credentials:edit --environment  development
```

Edit variables and secrets into development environment command:
```
docker-compose run app rails credentials:edit --environment development
```
Example of variable, database url:

```
# aws:
#   access_key_id: 123
#   secret_access_key: 345

sidekiq:
  password: bonus12345

database:
  url: postgres://postgres:bonus12345@db:5432/projetobonus

redis:
  url: redis://redis:6379/0

smtp:
  default_from: samuel.faeng+noreply@gmail.com
```

To use rails console, run:
```
docker-compose run app rails c
```

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
