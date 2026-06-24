FROM node:latest

RUN apt-get update && apt-get install -y gnucobol

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "index.js"] 