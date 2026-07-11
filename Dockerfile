# Etapa 1: Compilar la app de Flutter
FROM ubuntu:22.04 AS build-env

# Instalar dependencias esenciales
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Descargar e instalar Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Cambiar al canal estable y verificar instalación
RUN flutter channel stable && flutter upgrade && flutter doctor

# Copiar los archivos del proyecto al contenedor
WORKDIR /app
COPY . .

# Compilar la aplicación para entorno Web en modo release
RUN flutter build web --release

# Etapa 2: Servir los archivos con Nginx
FROM nginx:alpine

# Copiar los archivos compilados desde la etapa anterior al directorio de Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exponer el puerto por defecto de Nginx
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]