# syntax=docker/dockerfile:1.7
# hadolint ignore=DL3018  # ✅ Alpine packages ke liye is rule ko ignore karein

# -------- Base Stage --------
FROM node:20-alpine3.20 AS base

WORKDIR /app

# ✅ NO VERSION PINS - Latest stable packages use karein
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

# ✅ Verify standalone output
RUN test -f /app/.next/standalone/server.js || (echo "❌ standalone build failed" && exit 1)

# -------- Production Runner Stage --------
FROM node:20-alpine3.20 AS runner

# ✅ NO VERSION PINS here too
RUN apk add --no-cache dumb-init \
 && addgroup -g 1001 -S nodejs \
 && adduser -S nextjs -u 1001 -G nodejs

WORKDIR /app

ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME="0.0.0.0" \
    NEXT_TELEMETRY_DISABLED=1

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["node", "server.js"]