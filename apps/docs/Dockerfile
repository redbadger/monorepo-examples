FROM node:16-alpine AS builder
RUN apk update
# Set working directory
WORKDIR /app
RUN corepack enable
COPY . .
RUN pnpm --package=turbo dlx turbo prune --scope=docs --docker
# See https://github.com/vercel/turborepo/issues/1997#issuecomment-1271372326
RUN rm -rf /app/out/full/*/*/node_modules

# Add lockfile and package.json's of isolated subworkspace
FROM node:16-alpine AS installer
RUN apk update
RUN corepack enable
WORKDIR /app

# First install the dependencies (as they change less often)
COPY .gitignore .gitignore
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm install

# Build the project
COPY turbo.json turbo.json
COPY --from=builder /app/out/full/ .
RUN pnpm --mount=type=secret,id=turbo-team --mount=type=secret,id=turbo-token turbo run build --filter=docs...
RUN pnpm --mount=type=secret,id=turbo-team --mount=type=secret,id=turbo-token turbo run lint --filter=docs
RUN pnpm --mount=type=secret,id=turbo-team --mount=type=secret,id=turbo-token turbo run test --filter=docs

FROM node:16-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Automatically leverage output traces to reduce image size 
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/apps/docs/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/apps/docs/.next/static ./.next/static

CMD node apps/docs/server.js