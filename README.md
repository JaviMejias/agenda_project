# 📅 Agenda Project: Sistema de Gestión de Reservas

[![Ruby Version](https://img.shields.io/badge/Ruby-3.4.6-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/Rails-8.1.3-red.svg)](https://rubyonrails.org/)
[![TailwindCSS](https://img.shields.io/badge/TailwindCSS-v4-38B2AC.svg)](https://tailwindcss.com/)

Una solución integral y moderna para la gestión de propiedades y reservas, diseñada con un enfoque en la experiencia del usuario (UX) premium y rendimiento excepcional. Este proyecto ha evolucionado de una base técnica a una **PWA (Progressive Web App)** completa.

---

## ✨ Características Principales

### 📱 Experiencia PWA & Mobile-First
- **Instalación Nativa:** Listo para instalar en dispositivos móviles y escritorio.
- **Modo Offline (Consulta):** Gracias a Service Workers, las secciones visitadas permanecen disponibles para consulta rápida incluso sin conexión.
- **Rendimiento Instantáneo:** Estrategia de caché que elimina los tiempos de espera al navegar por la interfaz principal.

### 🗓️ Agenda Profesional
- **Dashboard Dual:** Vista dividida con calendario dinámico y lista lateral reactiva.
- **Turbo-Powered:** Actualizaciones instantáneas sin recargar la página usando Turbo Frames y Streams.
- **Lógica de Negocio Avanzada:** Protección contra reservas pasadas y gestión estricta de estados (Pendiente, Confirmada, Cancelada).

### 💬 Notificaciones Interactivas (Smart Flow)
- **Gestión vía Email:** Los clientes pueden confirmar o rechazar reservas directamente desde su correo electrónico con un solo clic.
- **Tokens de Seguridad:** Enlaces temporales y seguros (`has_secure_token`) con expiración de 24 horas.
- **Automatización:** Recordatorios automáticos programados 24 horas antes mediante **Solid Queue**.

### 📊 Reportes & Gestión
- **Exportación Premium:** Generación de reportes detallados en **PDF** y **Excel**.
- **Estadísticas en Tiempo Real:** Gráficos de ocupación e ingresos integrados.
- **Gestión de Propiedades:** Sistema CRUD completo con galería de imágenes (Active Storage).

---

## 🚀 Stack Tecnológico

- **Core:** Ruby 3.4.6 | Rails 8.1.3
- **Base de Datos:** PostgreSQL
- **Asset Pipeline:** Vite Ruby
- **Estilos:** TailwindCSS v4
- **Interactividad:** Hotwire (Turbo & Stimulus)
- **Background Jobs:** Solid Queue
- **Autenticación:** Devise + Pundit (Roles: Admin / Usuario)

---

## 🛠️ Instalación y Configuración

Puedes elegir entre una instalación local tradicional o utilizar Docker para un entorno aislado y rápido.

### Opción A: Instalación con Docker (Recomendado)
Ideal para empezar rápidamente sin preocuparse por las versiones de Ruby o Node.

```bash
# 1. Construir las imágenes
docker compose build

# 2. Levantar los servicios
docker compose up -d

# 3. Preparar la base de datos (solo la primera vez)
docker compose exec web bin/rails db:prepare db:seed
```
La aplicación estará disponible en `http://localhost:3000`.

### Opción B: Instalación Local
Requiere tener instalados los lenguajes y servicios en tu máquina.

**Requisitos:**
- Ruby 3.4.6
- PostgreSQL 16+
- Node.js (v20+) & Yarn/npm

**Pasos:**
```bash
# Instalar dependencias
bundle install
npm install

# Preparar base de datos
bin/rails db:prepare db:seed

# Ejecutar el entorno de desarrollo (Rails + Vite + Solid Queue)
npm run dev
```

---

## 📁 Estructura del Proyecto

El frontend moderno se organiza en `app/frontend`:
```text
app/frontend
├── entrypoints     # Puntos de entrada para Vite
├── javascript      # Controladores Stimulus y lógica JS
└── stylesheets     # TailwindCSS v4 y estilos globales
```

---

## 🗺️ Hoja de Ruta (Roadmap)
Para conocer los próximos pasos y el progreso detallado, consulta el archivo [ROADMAP.md](ROADMAP.md).

---

## 📄 Licencia
Este proyecto es de uso privado. Todos los derechos reservados.

