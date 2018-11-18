#Docker container to store the nginx instance. Is also responcible for building the package

# Create the container from the alpine linux image
FROM alpine:3.7

# Add nginx and nodejs
RUN apk add --update nginx nodejs

# Create the directories we will need
RUN mkdir -p /tmp/nginx/dashboard
RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/www/html

# Copy the respective nginx configuration files
COPY nginx_config/nginx.conf /etc/nginx/nginx.conf
COPY nginx_config/default.conf /etc/nginx/conf.d/default.conf

# Set the directory we want to run the next commands for
WORKDIR /tmp/nginx/dashboard
# Copy our source code into the container
COPY . .

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN rm -rf node_modules

RUN rm package-lock.json

RUN npm rebuild node-sass

# Install the dependencies, can be commented out if you're running the same node version
RUN npm install

# run webpack and the vue-loader
RUN npm run build

# copy the built app to our served directory
RUN cp -r dist/* /var/www/html

# make all files belong to the nginx user
RUN chown nginx:nginx /var/www/html

# start nginx and keep the process from backgrounding and the container from quitting
CMD ["nginx", "-g", "daemon off;"]