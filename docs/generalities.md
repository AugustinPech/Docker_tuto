# vocabulary
## an image
a docker image contains the strict minimum space and services to run a service.

an image is used into a container to run the service.

## a container

## a volume
is a path on a physical drive that can be used in one or more containers
## a network
containers can coexist in a network to make the application work

the docker compose file manage the interaction between containers in the app.
# functionalities
## commands
### get informations
```bash
    docker ps
    docker ps -a
    docker images
```
### actions
#### images and containers actions
```bash
    docker pull
    docker build
    docker run
    docker stop
    docker rm 
    docker rm -f
```
#### actions inside a container
```bash
    docker exec -ti bob sh -c ls -al
```
# tutorial 
[ressources](https://docs.docker.com/get-started/02_our_app/) of the offical docker doc
## Containerize an application
### build the image
1. create a docker file :
```bash
    cd /path/to/app
    touch Dockerfile
    nano Dockerfile
```
2. seed the docker file :

    the example shows the dockerfile of an app running on node.js
    ```dockerfile
    # syntax=docker/dockerfile:1

    FROM node:18-alpine # base image
    WORKDIR /app # WD inside the image
    COPY . . # copy cwd in the wd in docker (pwd > /target/app)
    RUN yarn install --production # install production "dependencies" from package.js but not "devDependencies"
    CMD ["node", "src/index.js"] # runs the command node src/index.js
    EXPOSE 3000 # listening port of the image
    ```

3. build the image
    ```bash
    docker build -t app . # docker builds an application tagged (named) as "app", using the Dockerfile in the cwd (path = .)
    ```

### run an image
the command : 
```bash
    docker run -d -p 127.0.0.1:3000:3000 app
```
runs the image named `app` in a `-d` detached mode.

the `-p` flag stands for `--publish`, it creates a port mapping between `127.0.0.1:3000` (localhost port 3000) and the port `:3000` of the image