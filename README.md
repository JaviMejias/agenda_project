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

\`\`\`bash
ruby -v
rails -v
\`\`\`

## ⚙️ Instalación

1. Clona el repositorio:

\`\`\`bash
git clone git@github.com:TU_USUARIO/rails-base-vite-tailwind.git
cd rails-base-vite-tailwind
\`\`\`

2. Instala dependencias de Ruby:

\`\`\`bash
bundle install
\`\`\`

3. Instala dependencias de Node:

\`\`\`bash
yarn install
# o npm install
\`\`\`

4. Configura la base de datos:

\`\`\`bash
rails db:create
rails db:migrate
\`\`\`

## ▶️ Ejecución en desarrollo

Levanta Rails y Vite con hot reload:

\`\`\`bash
npm run dev
\`\`\`

Rails estará en [http://localhost:3000](http://localhost:3000)

> Alternativa: correr por separado:
>
> \`\`\`bash
> bin/rails s
> bin/vite dev
> \`\`\`

## 📁 Estructura destacada

\`\`\`
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
\`\`\`

## 🛠 Características incluidas

- Devise (login/registro)
- Formularios con TailwindCSS y animaciones
- Font Awesome Free
- Hot reload Vite para CSS y JS
- Preparado para PostgreSQL y Ruby 3.4+

## 🔐 Seguridad

- Archivos sensibles **no incluidos**: `config/master.key`, `.env`, credentials
- `.gitignore` ya configura Rails y Node

## 📌 Uso como boilerplate

1. Clona esta base para un nuevo proyecto
2. Cambia el remote:

\`\`\`bash
git remote remove origin
git remote add origin git@github.com:TU_USUARIO/nuevo-proyecto.git
git push -u origin main
\`\`\`

3. Instala dependencias y DB como arriba

## 📖 Notas finales

- Base lista para iniciar proyectos Rails modernos
- Incluye Turbo + Stimulus + Tailwind + Vite
- Perfecta para clonar y empezar un proyecto sin configurar nada

EOF
