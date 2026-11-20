# Unprivileged Nginx runs as non-root and listens on 8080, which Cloud Run expects.
# Check Docker Hub for the latest stable tag.
FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
# Static files are also baked in so Nginx can serve /static/ locally and as a fallback.
COPY app/public /var/www/html/public