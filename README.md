# Symfony based project development docker config

You can use this docker configuration for develop Symfony 5 based projects.  

## It contains docker-compose containers

* PHP configuration (web)
* Nginx configuration (nginx)
* PostgreSQL configuration (database)

## Usage 

* Install Docker and Docker Compose
* Make your own `docker-compose.override.yml` file to configure your environment based on your needs
* Replace in `docker-compose.override.yml`:
    * `<path-to-your-local-vendor>` to absolute url of your /vendor directory in your host computer
    * port where you want to reach your site (default: localhost:8082)
* Change database environment variables in `docker/database/database.env`  
* Run `docker-compose build`
* Run `docker-compose up -d`

## Enter to a container

* Run `docker-compose exec <container-name> /bin/bash` 

## Named volumes

* database-data: It keeps your data even if use `docker-compose down`
* built-vendor: For synchronize vendor (built by composer) to your local (host) environment 

## Additional info

- To destroy named volume (database, build-vendor) run: `docker-compose down --volumes`