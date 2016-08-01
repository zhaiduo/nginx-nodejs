## Introduction
This is a Dockerfile to build a container image for nginx and nodeJS, with the ability to push and pull website code to and from git. There is also support for lets encrypt SSL support.

### Git repository
The source files for this project can be found here: [https://github.com/ngineered/nginx-nodejs](https://github.com/ngineered/nginx-nodejs)

If you have any improvements please submit a pull request.
### Docker hub repository
The Docker hub build can be found here: [https://registry.hub.docker.com/u/richarvey/nginx-nodejs/](https://registry.hub.docker.com/u/richarvey/nginx-nodejs/)
## Versions
| Tag | Nginx | nodeJS | Alpine |
|-----|-------|-----|--------|
| latest | 1.10.1 | 4.4.4 | 3.4 |

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/ngineered/nginx-nodejs.git
docker build -t nginx-nodejs:latest .
```
## Pulling from Docker Hub
Pull the image from docker hub rather than downloading the git repo. This prevents you having to build the image on every docker host:
```
docker pull richarvey/nginx-nodejs:latest
```
## Running
To simply run the container:
```
sudo docker run -d richarvey/nginx-nodejs
```
You can then browse to ```http://<DOCKER_HOST>``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` command to get the IP address.
### Installing NPM Components
To install component for you node application to run simply include a ```packages.json``` file in the root of your application. The container will then install the components on start.
### Starting your application
At the moment the container looks for ```server.js``` in your web root and executes that. Nginx is expecting your application to listen on port ```3000```. In future versions you'll be able to configure this.
### Available Configuration Parameters
The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

 - **GIT_REPO** : URL to the repository containing your source code
 - **GIT_BRANCH** : Select a specific branch (optional)
 - **GIT_EMAIL** : Set your email for code pushing (required for git to work)
 - **GIT_NAME** : Set your name for code pushing (required for git to work)
 - **SSH_KEY** : Private SSH deploy key for your repository base64 encoded (requires write permissions for pushing)
 - **WEBROOT** : Change the default webroot directory from `/var/www/html` to your own setting
 - **HIDE_NGINX_HEADERS** : Disable by setting to 0, default behavior is to hide nginx version in headers
 - **DOMAIN** : Set domain name for Lets Encrypt scripts

### Dynamically Pulling code from git
One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

**Note:** You need to have your SSH key that you use with git to enable the deployment. I recommend using a special deploy key per project to minimise the risk.

### Preparing your SSH key
The container expects you pass it the __SSH_KEY__ variable with a **base64** encoded private key. First generate your key and then make sure to add it to github and give it write permissions if you want to be able to push code back out the container. Then run:
```
base64 -w 0 /path_to_your_key
```
**Note:** Copy the output be careful not to copy your prompt

To run the container and pull code simply specify the GIT_REPO URL including *git@* and then make sure you have also supplied your base64 version of your ssh deploy key:
```
sudo docker run -d -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' richarvey/nginx-nodejs
```
To pull a repository and specify a branch add the GIT_BRANCH environment variable:
```
sudo docker run -d -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -e 'GIT_BRANCH=stage' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' richarvey/nginx-nodejs
```
### Enabling SSL or Special Nginx Configs
You can either map a local folder containing your configs  to /etc/nginx or we recommend editing the files within __conf__ directory that are in the git repo, and then rebuilding the base image.

### Lets Encrypt support (Experimental)
#### Setup
You can use Lets Encrypt to secure your container. Make sure you start the container ```DOMAIN, GIT_EMAIL``` and ```WEBROOT``` variables to enable this to work. Then run:
```
sudo docker exec -t <CONTAINER_NAME> /usr/bin/letsencrypt-setup
```
Ensure your container is accessible on the ```DOMAIN``` you supply in order for this to work
#### Renewal
Lets Encrypt certs expire every 90 days, to renew simply run:
```
sudo docker exec -t <CONTAINER_NAME> /usr/bin/letsencrypt-renew
```
## Special Git Features
You'll need some extra ENV vars to enable this feature. These are ```GIT_EMAIL``` and ```GIT_NAME```. This allows git to be set up correctly and allow the following commands to work.
### Push code to Git
To push code changes made within the container back to git simply run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/push
```
### Pull code from Git (Refresh)
In order to refresh the code in a container and pull newer code form git simply run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/pull
```
## Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```
