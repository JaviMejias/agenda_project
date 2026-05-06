# 🗺️ Hoja de Ruta - Proyecto Agenda

Este documento detalla el progreso actual del proyecto y los próximos pasos.

## 🟢 Completado

### 🚀 Infraestructura & Versiones (¡NUEVO!)
- **Salto Tecnológico:** Actualización a **Ruby 3.4.6** (Prism/JIT) y **Rails 8.1.3** (Soporte nativo PWA).
- **PWA (Progressive Web App):** Instalable en móviles y escritorio con manifiesto personalizado e iconos.
- **Modo Offline:** Implementación de Service Worker con estrategia *Network-First* para carga instantánea y soporte sin señal.
- **App Feel:** Optimización de Viewport para móviles (bloqueo de zoom y scroll horizontal) para sensación de app nativa.

### 📅 Agenda Profesional (Dashboard Rediseñado)
- **Split-Screen Layout:** Diseño de dos columnas (Calendario + Lista lateral) para una visión 360°.
- **Lista Lateral Inteligente:** Actualización reactiva mediante Turbo Frames sincronizada con el movimiento del calendario.
- **Filtrado Lógico:** Eliminación de "días fantasma" (solo se ven reservas del periodo actual: mes, semana o día).
- **Visualización Adaptativa:** Muestra de horas automática en vistas de semana/día para mayor precisión operativa.
- **Integridad de Datos:** Bloqueo de reservas pasadas y protección total de reservas canceladas (inamovibles).
- **Recordatorios Automáticos (¡NUEVO!):** Sistema de alertas programadas 24h antes del inicio de la reserva mediante **Solid Queue** y correos electrónicos automáticos.

### 📊 Dashboard & Reportes
- Resumen de estadísticas (Reservas, ingresos, propiedades).
- Gráfico dinámico de ocupación mensual (Chart.js).
- Listado de actividad reciente.
- Reporte detallado de "Pérdidas por Bloqueo" (mantenimiento).
- Generación de reportes en Excel y PDF con filtros dinámicos.

### 🏠 Gestión de Propiedades
- CRUD completo con Active Storage y galería de imágenes.
- Buscador instantáneo con overlay de carga.
- Selector de colores avanzado para personalización visual del calendario.

### 🔐 Usuarios & Seguridad
- Sistema de autenticación Devise con rediseño Premium.
- Autorización basada en roles (Admin / Normal) con Pundit.
- Trazabilidad total (quién creó/editó cada reserva).

### 👥 Gestión de Clientes
- Base de datos centralizada con validación automática de RUT chileno.
- Historial de reservas paginado con Turbo Frames.

### 💬 Notificaciones Interactivas (¡NUEVO!)
- **Confirmación Vía Email:** Botones "Aceptar" y "Rechazar" en el correo de reserva que permiten al cliente gestionar su estado sin iniciar sesión.
- **Seguridad por Token:** Implementación de tokens únicos (`has_secure_token`) con expiración de 24 horas para acciones públicas seguras.
- **Feedback Estético:** Páginas de aterrizaje con diseño premium y optimizado para móviles para confirmar/rechazar reservas.
- **Flujo Inteligente:** Supresión de correos redundantes tras la interacción del cliente para una experiencia más limpia.

---

## 🟡 Próximos Pasos (Sugeridos)

1. **📱 Notificaciones Avanzadas**:
   - **Integración WhatsApp:** API de WhatsApp para confirmaciones y recordatorios automáticos usando los mismos tokens de seguridad.
   - **SMS de Respaldo:** Notificaciones vía mensaje de texto para clientes sin acceso a internet o correo.

2. **💰 Gestión Financiera**:
   - Control detallado de abonos y saldos pendientes por reserva.
   - Registro de gastos operativos para cálculo de utilidad neta real en reportes.
   - Integración de pasarela de pagos para automatizar confirmaciones.

3. **🗓️ Sincronización & Apertura**:
   - Sincronización vía iCal con calendarios externos (Google, Airbnb, Booking).
   - Portal o link público de disponibilidad para permitir auto-reservas de clientes.

4. **🔧 Gestión Operativa**:
   - Sistema de tareas (limpieza/mantenimiento) vinculado al flujo de reservas.
   - Gestión de bloqueos recurrentes para mantenimientos preventivos.

---
*Última actualización: 05 de Mayo, 2026 - 18:25*
