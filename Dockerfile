# Stage 1: Build the application
FROM node:16-bullseye AS builder

WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 1000000
COPY . .
RUN yarn build

# Stage 2: Production image
FROM node:16-bullseye-slim

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libxss1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/package.json /app/yarn.lock ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.js ./next.config.js

ENV NODE_ENV=production
EXPOSE 3000
CMD ["yarn", "start"]