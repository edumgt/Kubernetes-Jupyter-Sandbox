FROM harbor.local/data-platform/platform-node:22.22.0-bookworm-slim AS build

WORKDIR /app

ARG NPM_REGISTRY
ARG NPM_AUTH_B64

COPY package.json .
RUN if [ -n "${NPM_REGISTRY:-}" ]; then \
      npm config set registry "${NPM_REGISTRY}"; \
      npm config set always-auth true; \
      if [ -n "${NPM_AUTH_B64:-}" ]; then \
        registry_scope="$(printf '%s' "${NPM_REGISTRY}" | sed -e 's#^https\?://##' -e 's#/*$##')"; \
        npm config set "//${registry_scope}/:_auth" "${NPM_AUTH_B64}"; \
      fi; \
    fi \
 && npm install

COPY . .

ARG VITE_API_BASE_URL=
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

RUN npm run build

FROM harbor.local/data-platform/platform-nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
