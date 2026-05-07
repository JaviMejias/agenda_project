# 🗺️ Hoja de Ruta - Proyecto Agenda

Este documento detalla el progreso actual del proyecto y los próximos pasos.

## 🟢 Completado

### 🚀 Infraestructura & Estabilización (¡NUEVO!)
- **Salto Tecnológico:** Actualización a **Ruby 3.4.6** (Prism/JIT) y **Rails 8.1.3** (Soporte nativo PWA).
- **Turbo Morphing:** Implementación de refrescos por morphing global (`refreshes_with method: :morph`) para transiciones ultra fluidas sin parpadeos.
- **Navegación Inteligente:** Sistema de memoria de origen que permite volver automáticamente a la ficha de propiedad, agenda global o listado según de dónde venga el usuario.
- **PWA (Progressive Web App):** Instalable en móviles y escritorio con manifiesto personalizado e iconos.
- **Modo Offline:** Implementación de Service Worker con estrategia *Network-First* para carga instantánea y soporte sin señal.

### 🔍 Productividad & Búsqueda (¡NUEVO!)
- **Omnibar (Cmd+K):** Buscador global inteligente estilo "Command Palette" para acceso instantáneo a Clientes, Propiedades, Reservas y Usuarios.
- **Filtros de Seguridad:** Búsqueda de usuarios restringida exclusivamente a administradores dentro de la Omnibar.
- **Navegación por Teclado:** Control total del buscador mediante flechas y Enter para máxima velocidad operativa.

### 🎨 Experiencia de Usuario & Aesthetica (¡NUEVO!)
- **Temas de 3 Estados:** Selector dinámico (Claro, Oscuro o Sistema) con detección en tiempo real de las preferencias del sistema operativo.
- **Feedback Auditivo:** Sistema de sonidos sintetizados diferenciados (Éxito vs Alerta) que mejora la percepción de las acciones del usuario.
- **App Feel:** Optimización de Viewport para móviles (bloqueo de zoom y scroll horizontal) para sensación de app nativa.
- **Micro-interacciones:** Animaciones suaves en modales, transiciones de temas y barras de progreso de Turbo.

### 📅 Agenda Profesional (Dashboard Rediseñado)
- **Split-Screen Layout:** Diseño de dos columnas (Calendario + Lista lateral) para una visión 360°.
- **Lista Lateral Inteligente:** Actualización reactiva mediante Turbo Frames sincronizada con el movimiento del calendario.
- **Filtrado Lógico:** Eliminación de "días fantasma" (solo se ven reservas del periodo actual: mes, semana o día).
- **Integridad de Datos:** Bloqueo de reservas pasadas y protección total de reservas canceladas (inamovibles).
- **Recordatorios Automáticos:** Sistema de alertas programadas 24h antes del inicio de la reserva mediante **Solid Queue**.

### 📊 Dashboard & Reportes
- Resumen de estadísticas (Reservas, ingresos, propiedades).
- Gráfico dinámico de ocupación mensual (Chart.js).
- Reporte detallado de "Pérdidas por Bloqueo" (mantenimiento).
- Generación de reportes en Excel y PDF con filtros dinámicos.

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
*Última actualización: 07 de Mayo, 2026 - 13:00 (Sesión de Estabilización y UX)*
