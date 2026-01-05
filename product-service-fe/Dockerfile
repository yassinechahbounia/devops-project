# Stage 1: Build
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build -- --configuration production

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

# Install envsubst (comes with gettext)
RUN apk add --no-cache gettext

COPY --from=build /app/dist/product-service-fe/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create a shell script to replace variables and start Nginx
RUN echo '#!/bin/sh' > /docker-entrypoint.d/40-env-subst.sh && \
    echo 'envsubst < /usr/share/nginx/html/assets/env.template.js > /usr/share/nginx/html/assets/env.js' >> /docker-entrypoint.d/40-env-subst.sh && \
    chmod +x /docker-entrypoint.d/40-env-subst.sh

EXPOSE 80