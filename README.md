# 🚀 Pipeline de CI/CD Automatizado con GitHub Actions, Docker Hub y AWS EC2

Este repositorio contiene el código fuente y la configuración de infraestructura para el despliegue automatizado de una API en Node.js/Express. El proyecto implementa un flujo completo de Integración Continua (CI) y Despliegue Continuo (CD) diseñado para el entorno de prácticas de AWS Academy Learner Lab.

---

## 📐 Esquema de la Arquitectura

El flujo de trabajo automatizado sigue el siguiente ciclo de vida ante cualquier cambio en el código:

1. **Push en Local** — El desarrollador realiza modificaciones en el código local y ejecuta `git push` hacia la rama `main`.

2. **Orquestación (CI Job)** — GitHub Actions levanta un Runner virtualizado limpio (Ubuntu). Descarga el código, se autentica de forma segura en Docker Hub y compila el Dockerfile optimizando las capas de caché.

3. **Registro (Docker Hub)** — La imagen compilada se publica en Docker Hub con dos etiquetas: `latest` (para producción) y la versión única del commit para auditoría y trazabilidad.

4. **Despliegue (CD Job)** — Tras finalizar con éxito la fase de CI, un segundo trabajo abre un túnel SSH seguro hacia la IP Elástica de la instancia AWS EC2, detiene el contenedor antiguo en caliente, descarga la nueva imagen y la levanta en el puerto 80.

5. **Validación (Health-Check)** — El pipeline ejecuta un test automático con `curl --fail` para verificar que el servidor responde correctamente. Si falla, el pipeline se tiñe de rojo.

---

## 🛠️ Tecnologías Utilizadas

| Componente | Tecnología |
|---|---|
| **Backend** | Node.js v18 & Express |
| **Contenedorización** | Docker (imagen base `node:18-alpine`) |
| **Automatización** | GitHub Actions (YAML) |
| **Registro de Imágenes** | Docker Hub |
| **Infraestructura Cloud** | AWS EC2 (Ubuntu 24.04 LTS) con IP Elástica |

---

## 💻 Ejecución y Pruebas en Entorno Local

Si deseas clonar este proyecto y probar el contenedor de forma aislada en tu máquina local sin interactuar con los servidores de AWS, ejecuta los siguientes comandos en tu terminal:

### 1. Clonar el repositorio e instalar dependencias

```bash
git clone https://github.com/pichaDev/proyecto-cicd-daw.git
cd proyecto-cicd-daw
npm install
```

### 2. Construir la imagen de Docker localmente

```bash
docker build -t mi-app-web:local .
```

### 3. Levantar el contenedor

```bash
docker run -d -p 8080:80 --name contenedor-local mi-app-web:local
```

Abre tu navegador en **http://localhost:8080** para verificar su funcionamiento.

---

## 🔒 Gestión de Seguridad y Variables de Entorno (Secrets)

Para cumplir estrictamente con las directivas de seguridad, el archivo de configuración del despliegue no contiene ninguna credencial en texto plano. Todos los valores sensibles se inyectan dinámicamente mediante **GitHub Repository Secrets**:

| Secret | Descripción |
|---|---|
| `DOCKER_HUB_USERNAME` | Nombre de usuario en Docker Hub |
| `DOCKER_HUB_TOKEN` | Personal Access Token (PAT) con permisos de lectura y escritura |
| `EC2_HOST` | Dirección IP Elástica pública de la instancia AWS EC2 |
| `EC2_USERNAME` | Usuario administrador del sistema operativo (`ubuntu`) |
| `EC2_SSH_KEY` | Contenido íntegro de la clave privada de seguridad (`.pem`) |

---

## ⚠️ Resolución de Incidencias en Producción

Durante el aprovisionamiento del entorno en la instancia AWS EC2, se identificó un conflicto en el puerto 80, ya que el sistema operativo de AWS Academy levantaba por defecto un servicio tradicional de Apache2 que bloqueaba la escucha de red.

La incidencia se resolvió purgado por completo el software preinstalado mediante acceso SSH antes de activar el contenedor definitivo de Docker:

```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo apt purge apache2 -y
sudo apt autoremove -y
```

Adicionalmente, se configuraron los privilegios del socket de Unix para permitir que el pipeline interactúe con el demonio de Docker de manera desatendida:

```bash
sudo usermod -aG docker ubuntu
```

