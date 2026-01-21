# -------- Base --------
FROM node:20-alpine AS base
# hadolint ignore=DL3018
RUN apk add --no-cache libc6-compat
WORKDIR /app

# -------- Dependencies --------
FROM base AS deps
COPY package*.json ./
RUN npm ci --omit=dev

# -------- Builder --------
FROM base AS builder
WORKDIR /app
COPY package*.json ./
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# -------- Runner (Production) --------
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs

# ✅ ONLY required files
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000

# CMD ["npm", "run"]
