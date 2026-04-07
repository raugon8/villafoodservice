# Fase 1: build de Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release \
    --dart-define=API_URL=https://villafoodservice-production.up.railway.app \
    --dart-define=SUPABASE_URL=https://tvflsjhtybzwbqxciciv.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=sb_publishable_GTDvC1bJvbUYLpNz_2raKQ_SedJ_8lL

# Fase 2: servir con nginx adaptado al puerto de Railway
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]