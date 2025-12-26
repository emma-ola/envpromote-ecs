# Build stage - install dependencies
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev --quiet

# Production stage - minimal runtime image
FROM node:20-alpine

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy package files and source code
COPY package*.json ./
COPY src ./src

# Change ownership to node user
RUN chown -R node:node /app

# Expose application port
EXPOSE 3000

# Run as non-root user for security
USER node

# Use direct node invocation for faster startup
CMD ["node", "src/index.js"]
