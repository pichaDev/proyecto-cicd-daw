# 1. Imagen base ligera orientada a producción (reduce el tamaño de ~1GB a unos 180MB)
FROM node:18-alpine

# 2. Directorio de trabajo aislado dentro del contenedor
WORKDIR /app

# 3. Copia de manifiestos de dependencias ANTES del código fuente.
# Si los paquetes no cambian, Docker reutiliza esta capa de la caché y evita hacer 'npm install' de nuevo.
COPY package*.json ./

# 4. Instalación exclusiva de dependencias de ejecución, omitiendo las de desarrollo
RUN npm install --only=production

# 5. Copia del resto del código fuente de la aplicación
COPY . .

# 6. Documentación del puerto en el que escucha el proceso interno
EXPOSE 80

# 7. Comando de ejecución en formato JSON (Exec Form) para una correcta propagación de señales del sistema
CMD ["node", "index.js"]
