# Fase 1: build de Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release \
    --dart-define=API_URL=https://villafoodservice-production.up.railway.app \
    --dart-define=SUPABASE_URL=https://tvflsjhtybzwbqxciciv.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2Zmxzamh0eWJ6d2JxeGNpY2l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3OTc0NTcsImV4cCI6MjA4ODM3MzQ1N30.qgF21dBh9K-lh8gUlPJAwqR_L0Rv3RExCDNVdu_-Lt0

# Fase 2: servir con nginx adaptado al puerto de Railway
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]