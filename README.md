# Symfony based project development docker config

You can use this docker configuration to develop Symfony 6 based projects.

This configuration is a skeleton, which means you need to finish based on your needs.
Some parts may be unnecessary for you or you want to add additional things.

## It contains the following docker-compose containers

* PHP 8.2 configuration (web)
* Nginx configuration (nginx)
* PostgreSQL configuration (database) for dev and test environment
* Mailcatcher

## Usage 

* Install Docker and Docker Compose
* Make your own `docker-compose.override.yml` file to configure your environment based on your needs
* Replace in `docker-compose.override.yml`:
    * `<path-to-your-local-vendor>` to absolute url of your /vendor directory in your host computer
    * port where you want to reach your site (default: localhost:8082)
* Change database environment variables in `docker/database/database.env`
* Run `docker compose build`
* Run `docker compose up -d`

## Enter to a container

* Run `docker-compose exec <container-name> /bin/bash` 

## Named volumes

```
dev-database-data: It keeps your data even if use `docker-compose down` in dev environment
test-database-data: It keeps your data even if use `docker-compose down` in test environment
built-vendor: For synchronize vendor (built by composer) to your local (host) environment 
```

## Symfony environment variables

#### .env

```
DATABASE_URL=postgresql://developer:asdasd@database-dev:5432/database?serverVersion=12&charset=utf8
MAILER_DSN=smtp://mailcatcher:1025
```
#### .env.test

```
DATABASE_URL=postgresql://developer:asdasd@database-test:5433/database?serverVersion=12&charset=utf8
```

## Additional info

- To destroy named volume (database, build-vendor) run: `docker-compose down --volumes`

## Contribution

If you would like to contribute, you can do it if you create a new issue or make a pull request instantly.
In both cases please provide a short description of what you want to achieve.