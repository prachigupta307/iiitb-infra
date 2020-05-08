# we are using multistage docker build for deploying pre reg UI.
# stage 1:
FROM node:12.7-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

# stage 2:
FROM nginx:1.17.1-alpine
COPY --from=build app/dist/pre-registration /usr/share/nginx/html
