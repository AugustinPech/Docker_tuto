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
#### on containers
```bash
    docker ps
    docker ps -a
```
#### on images
```bash
    docker images
    docker image ls
```
#### on volumes
```bash
    docker volume inspect volumeName
```
### actions
#### images and containers actions
```bash
    docker pull app
    docker build app
    docker run app
    docker stop app
    docker rm app
    docker rm -f app # stop + remove
```
```bash
    docker tag app user/app # rename
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
    ```bash
    # syntax=docker/dockerfile:1
    FROM node:18-alpine # base image
    WORKDIR /app # WD inside the image
    COPY . . # copy cwd in the wd in docker (pwd > /target/app)
    RUN yarn install --production # install production "dependencies" from package.js but not "devDependencies"
    CMD ["node", "src/index.js"] # runs the command node src/index.js
    EXPOSE 3000 # listening port of the image
    ```
    this example shows the dockerfile of a python flask app 
    ```bash
    FROM python:3.9-alpine # base image
    COPY requirements.txt requirements.txt # copy the file containing the list a necessary installation
    RUN pip install -r requirements.txt # pip install each element
    COPY . /microblog # copy the current directory in the container
    WORKDIR /microblog # set WD
    RUN chmod a+x boot.sh # boot.sh is executable
    ENV FLASK_APP microblog.py
    ENV CONTEXT PROD
    ENTRYPOINT ["./boot.sh"] # the boot script runs on container run
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
## Update the app
1. make a modification 
2. rebuild
    ```bash
    # make any modification then
    docker build -t app . # docker rebuilds the application with current files in path='.' 
    ```
3. stop the old container
    ```bash
        docker ps # to see all the containers running
        docker ps | grep -i app # if you have a lot of containers
        docker stop app # stops the application which name containes app
        docker ps -a # shows all containers including shut down owns
        docker rm app # removes the container which name containes app
    ```
    or
    ```bash
        docker ps # to see all the containers running
        docker ps | grep -i app # if you have a lot of containers
        docker rm -f app # stops and removes in a single command
    ```
4. rerun
    ```bash
        docker run -d -p 127.0.0.1:3000:3000 app
    ```
## Share the app
to share a docker image of an application you can post it on [DockerHub](https://hub.docker.com/)
1. create a repo :
    name should be the same as you local image
2. log in
    create an access token
    ```bash
        docker login  -u userName
    ```
    use the token as password
3. push the image
    ```bash
    docker push userName/app
    ```
## persist DB
to make persistent content in the container :
1. create a volume
    ```bash
        docker volume create volumeName
    ```
2. check if the container is up (shouldn't be)
3. two solutions :
    1. mount a named volume 
        ```bash
            docker run -d -p 127.0.0.1:3000:3000 --mount type=volume,src=volumeName,target=/path/in/container/ app
        ```
    2. mount a binded volume
        ```bash
            docker run -d -p 127.0.0.1:3000:3000 --mount type=bind,src=/path/on/host,target=/path/in/container/ app
        ```
    the mounted volume is a directory shared between the host and the container. If it is a **Named volume** docker chooses the host location.
4. you can get informations on your new volume by running :
    ```bash
        docker volume inspect volumeName
    ```
## multi-container app
a multi-container app uses a container network. The containers running in the same network can talk to each other.
### asign the network to the container
1. create the network
    ```bash
        docker network create myNet
    ```
2. create the container in the network
    ```bash
        docker run -d \ # detached
            --name=mysql \ # name the container
            --network myNet \ # name of the network
            --network-alias mysql \ # alias of the container on the network
            -v todo-mysql-data:/var/lib/mysql \ # mount volumle named todo-mysql-data on /var/lib/mysql in the container
            -e MYSQL_ROOT_PASSWORD=secret \ # passwd to mysql
            -e MYSQL_DATABASE=todos \ # DB name
            mysql:8.0 # image to run in the container
    ```
3. run the app :
    ```bash
        docker run -dp 127.0.0.1:3000:3000 \
            -w /app -v "$(pwd):/app" \
            --network myNet \
            -e MYSQL_HOST=mysql \ # name of the "mysql server" (here it is the mysql container)
            -e MYSQL_USER=root \
            -e MYSQL_PASSWORD=secret \
            -e MYSQL_DB=todos \
            node:18-alpine \
            sh -c "yarn install && yarn run dev"
    ```
### troubleshooting network
the nicolaka/netshoot container contains a lot of tools that are useful for troubleshooting or debugging networking issues.
```bahs
    docker run -it --network myNet nicolaka/netshoot
```
you can use network command in this container to get informations about containers in the network

### with docker-compose.yml
the docker compose.yaml file is a way to simplify the syntaxe.
the file contains a list of services defined like in the example below :
```bash
services:
  app: # 1st service
    image: node:18-alpine # image, name and network alias
    command: sh -c "yarn install && yarn run dev" # cmd runned automatically on the docker run cmd
    ports: # publishing port
      - 127.0.0.1:3000:3000
    working_dir: /app # WD in the container
    volumes: # current volume on host is mounted as a binded volume on /app inside the container
      - ./:/app
    environment: # env variables for the connection to mysql
      MYSQL_HOST: mysql
      MYSQL_USER: root
      MYSQL_PASSWORD: secret
      MYSQL_DB: myDB
    networks:
      - myNet

  mysql: # 2nd service
    image: mysql:8.0
    volumes:
      - app-mysql-data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: myDB
    networks:
      - myNet
volumes:
  app-mysql-data:
```

```bash
docker compose up
docker compose down
```

#### override
?? to search for
#### multistage builds
you can stucture your Dockerfile with multiple `FROM image` closes. like in the example : 
```bash
FROM golang:1.21 as build # image is loaded with an alias
WORKDIR /src
COPY ./main.go /src
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /bin/hello /src/main.go

FROM scratch
COPY --from=build /bin/hello /bin/hello # from the previous image (refered with it's alias) : copies the compiled file 
#COPY --from=0 /bin/hello /bin/hello # same without alias : from image number 0
CMD ["/bin/hello"]
```