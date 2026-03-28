# syntax=docker/dockerfile:1.7

# -------- Base Stage --------
# ✅ Use stable Alpine version
FROM node:20-alpine3.20 AS base

WORKDIR /app

# ✅ Install packages WITHOUT invalid --retry flag
# Network issues ke liye hum build-level retry use karenge (neeche dekhein)
RUN apk add --no-cache libc6-compat dumb-init \
 && addgroup -g 1001 -S nodejs \
 && adduser -S nextjs -u 1001 -G nodejs

# -------- Dependencies Stage --------
FROM base AS deps

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

# -------- Builder Stage --------
FROM base AS builder

COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY . .

RUN npm run build

# -------- Production Runner Stage --------
FROM node:20-alpine3.20 AS runner

# ✅ Runner mein sirf dumb-init (libc6-compat already builder se aajayega agar needed)
RUN apk add --no-cache dumb-init \
 && addgroup -g 1001 -S nodejs \
 && adduser -S nextjs -u 1001 -G nodejs

WORKDIR /app

ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME="0.0.0.0" \
    NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

# ✅ Health check with wget (Alpine compatible)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["node", "server.js"]