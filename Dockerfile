FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
# Cloud Run ignores EXPOSE, but it's good for documentation
EXPOSE 8080
# Use the array format for CMD
CMD ["node", "index.js"]