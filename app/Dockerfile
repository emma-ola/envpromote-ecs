FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package.json ./
RUN npm install --omit=dev

# Copy source
COPY src ./src
COPY tests ./tests

EXPOSE 3000

CMD ["npm", "start"]
