# Agenda Project

[![Ruby Version](https://img.shields.io/badge/Ruby-3.4.6-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/Rails-8.1.3-red.svg)](https://rubyonrails.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-38B2AC.svg)](https://tailwindcss.com/)

Plataforma integral para publicar propiedades, administrar reservas y operar sus pagos, clientes, gastos e incidencias. Incluye un portal público de autogestión, agenda interna, notificaciones en tiempo real, reportes y una PWA instalable.

## Alcance funcional

### Portal público y autogestión

- Catálogo público de propiedades con búsqueda, filtros, galería y disponibilidad en calendario.
- Solicitud de reservas por día o por hora, tanto para visitantes como para clientes registrados.
- Prevención de fechas pasadas y reservas solapadas; las solicitudes pendientes vencidas dejan de bloquear disponibilidad después de 24 horas.
- Consulta de una reserva mediante su código seguro y portal `Mis reservas` para usuarios con rol cliente.
- Confirmación o rechazo desde enlaces enviados por correo. Estas acciones caducan 24 horas después de entrar en estado pendiente.
- Descarga del comprobante de reserva en PDF.

### Pagos y Webpay

- Registro de abonos y reembolsos mediante transferencia, efectivo, tarjeta u otros medios.
- Cálculo de total pagado, saldo pendiente y estado financiero de cada reserva.
- Carga de comprobantes de transferencia por parte del cliente.
- Revisión administrativa de comprobantes, con estados pendiente, aprobado y rechazado.
- Cuentas bancarias configurables por empresa para mostrar instrucciones de transferencia.
- Integración con Transbank Webpay Plus mediante `transbank-sdk`.
- Confirmación automática de la reserva después de un pago Webpay autorizado.
- Registro automático de la comisión estimada de Transbank como gasto operativo.

Webpay se habilita por empresa. En producción usa el código de comercio y la API key guardados en la empresa; en otros entornos, o si faltan credenciales de producción, utiliza el ambiente de integración de Transbank.

### Gestión interna

- Agenda global con FullCalendar y vistas por mes, semana y día.
- Estados de reserva: pendiente, confirmada, cancelada y bloqueada por mantenimiento.
- Tarifas por día o por hora y cálculo automático del precio total.
- Empresas, propiedades, galerías de imágenes y asociación de propiedades a empresas.
- CRM de clientes con RUT, contacto, etiquetas, notas privadas, historial y gasto acumulado.
- Tareas operativas por reserva: check-in, check-out, limpieza y tareas libres.
- Incidencias por propiedad, opcionalmente vinculadas a una reserva, con severidad, estado y fotografía.
- Gastos operativos categorizados y respaldos adjuntos.
- Historial de auditoría para cambios de reservas y pagos.
- Omnibar global mediante `Cmd/Ctrl + K` para buscar clientes, propiedades, reservas y, para administradores, usuarios.

### Notificaciones, correo y tiempo real

- Notificaciones internas cuando un cliente confirma o rechaza una reserva, o carga/actualiza un comprobante.
- Actualización en vivo del listado, contador y señal de notificaciones mediante Turbo Streams y Action Cable.
- Actualización en vivo de tareas operativas.
- Correos de solicitud, confirmación, cancelación y recordatorio.
- Comprobante PDF adjunto al correo de confirmación.
- Recordatorios programados 24 horas antes de reservas confirmadas mediante Solid Queue.

### Dashboard y reportes

- Indicadores de ingresos confirmados y proyectados, caja real, gastos y próximos ingresos.
- Gráficos por propiedad y evolución mensual con Chart.js.
- Ocupación, rentabilidad y pérdidas asociadas a bloqueos.
- Filtros por fechas y empresa.
- Exportaciones de reportes en PDF y Excel.
- Exportación del listado de reservas en PDF y Excel.

### Experiencia de usuario

- PWA instalable con manifiesto y Service Worker.
- Interfaz responsive con temas claro, oscuro y según el sistema.
- Navegación acelerada con Turbo, controladores Stimulus y feedback visual/sonoro.
- Componentes interactivos como selectores, datepickers, modales, carruseles y gráficos.

## Roles y acceso

| Rol | Acceso principal |
| --- | --- |
| `admin` | Dashboard, reportes, empresas, propiedades, usuarios, auditoría y toda la operación. |
| `normal` | Agenda y operación diaria de reservas, clientes, pagos, gastos y propiedades permitidas. |
| `client` | Catálogo público y portal de sus propias reservas; no accede al área administrativa. |
| Visitante | Catálogo, disponibilidad, creación y consulta de reservas mediante código seguro. |

La autenticación está implementada con Devise y la autorización del área interna con Pundit.

## Stack tecnológico

- Ruby 3.4.6 y Rails 8.1.3.
- PostgreSQL 16.
- Vite Ruby, Tailwind CSS 4, Hotwire (Turbo y Stimulus).
- FullCalendar, Chart.js, Flatpickr, Tom Select, SweetAlert2 y Font Awesome.
- Solid Queue para trabajos en segundo plano, Solid Cable para WebSockets en producción y Solid Cache para caché.
- Active Storage con disco local en desarrollo y almacenamiento S3-compatible (Tigris) por defecto en producción.
- Devise, Pundit y Pagy.
- Wicked PDF y caxlsx para documentos PDF y Excel.
- Transbank SDK para Webpay Plus.
- Minitest, Capybara y Selenium para pruebas.

## Requisitos

Para desarrollo local:

- Ruby 3.4.6.
- PostgreSQL 16 o compatible.
- Node.js 20 o superior; el repositorio fija Node 24.15.0 en `.node-version`.
- npm.
- Dependencias del sistema para PostgreSQL, libvips/ImageMagick y generación PDF.

También se puede ejecutar con Docker y Docker Compose sin instalar Ruby, Node ni PostgreSQL localmente.

## Instalación con Docker

El archivo `docker-compose.yml` levanta PostgreSQL, Rails, Vite y un worker de Solid Queue.

```bash
docker compose build
docker compose up -d db
docker compose run --rm web bin/rails db:prepare db:seed
docker compose up
```

La aplicación queda disponible en <http://localhost:3000> y Vite en el puerto `5173`.

Para detener el entorno:

```bash
docker compose down
```

Los datos de PostgreSQL y las gems instaladas se conservan en volúmenes Docker. No uses `docker compose down -v` si quieres conservarlos.

## Instalación local

Con PostgreSQL iniciado y un usuario local con permisos para crear bases de datos:

```bash
bundle install
npm install
bin/rails db:prepare
bin/rails db:seed
npm run dev
```

`npm run dev` usa `Procfile.dev` para iniciar simultáneamente Rails, Vite y el worker de Solid Queue. También puedes usar `bin/setup`, que instala las dependencias Ruby, prepara la base de datos y arranca el entorno.

La configuración local espera las bases `agenda_project_development` y `agenda_project_test`. Puedes reemplazarla definiendo `DATABASE_URL`.

### Datos iniciales

`bin/rails db:seed` crea dos usuarios de demostración:

| Rol | Correo | Contraseña |
| --- | --- | --- |
| Administrador | `admin@agenda.cl` | `password123` |
| Operador | `usuario@agenda.cl` | `password123` |

Estas credenciales son solo para desarrollo. Deben cambiarse o eliminarse antes de exponer una instalación.

## Configuración de servicios

### Correo

En desarrollo, los correos se abren localmente con Letter Opener. En producción debes configurar un método de entrega SMTP en `config/environments/production.rb` y ajustar `default_url_options` al dominio real; sin ello, los correos y enlaces de confirmación no se enviarán correctamente.

El worker de Solid Queue debe estar activo para correos asíncronos, procesamiento de imágenes y recordatorios.

### Webpay

1. Crea o edita una empresa desde el área administrativa.
2. Activa Webpay para la empresa.
3. Asocia las propiedades correspondientes.
4. En producción, configura el código de comercio y la API key de Transbank en la empresa.

Si Webpay no está activo, el portal ofrece el flujo manual con cuentas bancarias y carga de comprobantes. Las credenciales de Webpay son sensibles: limita el acceso administrativo y protégelas también a nivel de infraestructura y respaldos.

### Active Storage

Desarrollo usa el directorio `storage/`. Producción usa el servicio definido por `STORAGE_SERVICE`, cuyo valor predeterminado es `tigris`.

Para Tigris u otro endpoint compatible con S3 se requieren:

```text
STORAGE_SERVICE=tigris
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_ENDPOINT_URL_S3=...
BUCKET_NAME=...
```

Para una instalación Docker con archivos persistentes locales puedes usar `STORAGE_SERVICE=local` y montar `/rails/storage`, como muestra `docker-compose.prod.yml`.

### Variables de producción

| Variable | Propósito |
| --- | --- |
| `RAILS_MASTER_KEY` | Descifra las credenciales de Rails. |
| `DATABASE_URL` | Conexión PostgreSQL de producción. |
| `STORAGE_SERVICE` | Servicio Active Storage: `tigris` o `local`. |
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ENDPOINT_URL_S3`, `BUCKET_NAME` | Acceso al almacenamiento S3-compatible. |
| `SOLID_QUEUE_IN_PUMA` | Ejecuta Solid Queue dentro de Puma en despliegues de un solo servidor. |
| `JOB_CONCURRENCY` | Cantidad de procesos de Solid Queue. |
| `FORCE_SSL` | Activa SSL forzado; por defecto `true` en producción. |
| `ACTION_CABLE_DISABLE_FORGERY_PROTECTION` | Permite WebSockets sin validación estricta de origen cuando la infraestructura lo requiere. |
| `RAILS_LOG_LEVEL` | Nivel de logs, por defecto `info`. |

## Comandos útiles

```bash
# Ejecutar todas las pruebas
bin/rails test

# Ejecutar pruebas de sistema
bin/rails test:system

# Analizar estilo
bin/rubocop

# Analizar vulnerabilidades comunes de Rails
bin/brakeman

# Construir los assets del frontend
npm run build

# Procesar trabajos sin usar Procfile.dev
bin/jobs
```

Las pruebas requieren que PostgreSQL esté disponible y que la base de test pueda crearse/prepararse.

## Arquitectura del proyecto

```text
app/
├── controllers/
│   └── public/                 # Catálogo, reservas y portal público
├── frontend/
│   ├── entrypoints/            # Entradas de Vite
│   ├── javascript/controllers/ # Controladores Stimulus
│   └── stylesheets/            # Tailwind y estilos globales
├── jobs/                       # Recordatorios y variantes de imágenes
├── mailers/                    # Comunicaciones de reservas
├── models/                     # Dominio y callbacks transaccionales
├── policies/                   # Autorización Pundit
├── services/                   # Estadísticas, estados de reserva y Webpay
└── views/                      # Área interna, portal público y exportaciones
```

Entidades centrales:

```text
User
├── Company ── BankAccount
├── Property ── Expense / Incident
├── Client
└── Reservation
    ├── Payment
    ├── ReservationAudit
    ├── OperationalTask
    └── Incident (opcional)
```

## Reglas de negocio relevantes

- Las reservas reales no se eliminan: se cancelan para conservar trazabilidad. Solo los bloqueos pueden eliminarse.
- Una reserva cancelada queda inmutable.
- Cambiar las fechas de una reserva confirmada la devuelve a estado pendiente.
- Los pagos en efectivo o tarjeta se aprueban automáticamente; las transferencias quedan sujetas a revisión.
- Los importes aprobados consideran abonos menos reembolsos.
- El calendario ignora solicitudes pendientes cuya espera supera 24 horas.
- La aplicación opera en la zona horaria `Santiago`.

## Despliegue

El repositorio incluye:

- `Dockerfile` multi-stage para la imagen de producción.
- `docker-compose.prod.yml` como ejemplo con PostgreSQL y almacenamiento persistente local.
- Configuración base de Kamal en `config/deploy.yml`, que contiene hosts e imagen de ejemplo y debe personalizarse.
- Endpoint de salud en `/up`.

Antes de desplegar, configura el dominio real de Action Mailer, SMTP, credenciales, almacenamiento, PostgreSQL, Webpay y una estrategia de respaldo. Ejecuta `bin/rails db:prepare` como tarea de despliegue: el entrypoint actual inicia el comando solicitado, pero no prepara automáticamente la base de datos.

## Roadmap

El historial funcional y los próximos pasos están en [ROADMAP.md](ROADMAP.md).

## Licencia

Proyecto de uso privado. Todos los derechos reservados.
