FROM node:16
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 7100
CMD ["npm","start"]