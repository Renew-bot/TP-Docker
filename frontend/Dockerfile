# ÉTAPE 1 : BUILD (Préparation des fichiers)

FROM node:18-alpine AS builder

WORKDIR /build

# Copier les fichiers statiques
COPY index.html .
COPY style.css .
COPY script.js .

# ÉTAPE 2 : PRODUCTION (Nginx)

FROM nginx:1.25-alpine

# Copier la configuration Nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers statiques depuis l'étape builder
COPY --from=builder /build /usr/share/nginx/html

# Créer un utilisateur non-root pour Nginx
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup && \
    chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

# Modifier la config pour écouter sur un port non privilégié
RUN sed -i 's/listen\s*80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# Passer à l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
