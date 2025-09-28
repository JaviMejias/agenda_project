# 🚀 PymeStock Base: Rails + Vite + Turbo + Stimulus + TailwindCSS

Este repositorio es una **base sólida para proyectos Ruby on Rails modernos**, lista para usar con:

- **Ruby:** 3.4.6
- **Rails:** 8.0.3
- **PostgreSQL** como base de datos
- **Vite** como asset pipeline
- **Turbo & Stimulus** para interactividad SPA-like
- **TailwindCSS v4** para estilos

Es ideal para iniciar proyectos nuevos sin configurar todo desde cero.

## 📦 Requerimientos

Asegúrate de tener instalados:

- **Ruby 3.4.6**
- **Rails 8.0.3**
- **PostgreSQL**
- **Node.js y Yarn o npm**

Verifica las versiones:

ruby -v
rails -v

## ⚙️ Instalación

1. Clona el repositorio:

git clone git@github.com:JaviMejias/rails-base-vite-tailwind.git
cd rails-base-vite-tailwind

2. Instala dependencias de Ruby:

bundle install

3. Instala dependencias de Node:

yarn install
# o npm install

4. Configura la base de datos:

rails db:create
rails db:migrate

## ▶️ Ejecución en desarrollo

Levanta Rails y Vite con hot reload:

npm run dev

Rails estará en [http://localhost:3000](http://localhost:3000)

## ▶️ Alternativa: correr por separado cada uno debe ir en una consola y correr al mismo tiempo:

bin/rails s
bin/vite dev

## 📁 Estructura destacada


app/frontend
├── entrypoints
│   ├── application.css
│   └── application.js
├── javascript
│   ├── application.js
│   └── controllers
│       ├── application.js
│       ├── hello_controller.js
│       └── index.js
└── stylesheets
    └── application.tailwind.css


## 🛠 Características incluidas

- Devise (login/registro)
- Formularios con TailwindCSS y animaciones
- Font Awesome Free
- Hot reload Vite para CSS y JS
- Preparado para PostgreSQL y Ruby 3.4+

