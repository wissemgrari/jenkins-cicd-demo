FROM node:20-alpine

WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY . .

# Expose the port
EXPOSE 3000

# Start the application
CMD ["node", "src/index.js"]