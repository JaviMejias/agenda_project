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
- **UI Premium:** Refactorización de barras de navegación, corrección de contrastes en modo claro, sombras dinámicas y mejoras responsivas.
- **Feedback Auditivo:** Sistema de sonidos sintetizados diferenciados (Éxito vs Alerta) que mejora la percepción de las acciones del usuario.
- **App Feel:** Optimización de Viewport para móviles (bloqueo de zoom y scroll horizontal) para sensación de app nativa.
- **Micro-interacciones:** Animaciones suaves en modales, transiciones de temas, menúes desplegables y barras de progreso de Turbo.

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

### 🛠️ Estabilización & Calidad de Código (Mayo 2026)
- **Docker Ready-to-Run:** Refactorización del `entrypoint` para automatizar migraciones y preparación de base de datos en cualquier entorno (Windows/WSL/Linux).
- **Seguridad ActiveRecord:** Refactorización de consultas SQL crudas a lenguaje ActiveRecord para prevenir inyecciones SQL y mejorar la mantenibilidad.
- **Workflow de Reservas:** Corrección crítica del desfase de fechas en FullCalendar (+1 día) y persistencia robusta de estados.
- **Notificaciones Proactivas:** Implementación de callbacks en el modelo de Reservas para disparar alertas cuando cambian datos críticos del cliente o horarios.
- **Limpieza RuboCop:** Eliminación de deuda técnica de estilo y espacios en blanco para mantener un estándar de código profesional.
- **Estandarización de Interfaz (¡NUEVO!):** Implementación de componentes compartidos (`back_button`, `empty_state`, `loading_state`) para una UI consistente y mantenible.
- **Confirmación Pública (¡NUEVO!):** Corrección del flujo de confirmación/rechazo por parte del cliente mediante tokens seguros, reparando el acceso a métodos privados en el modelo.

### 🏢 Portal de Clientes & Autogestión (¡NUEVO!)
- **Usuarios Tipo Cliente:** Creación de rol externo que permite a los clientes gestionar sus propias reservas.
- **Registro Extendido:** Incorporación de RUT y teléfono en el registro de usuarios con validaciones nativas.
- **Reservas Públicas:** Flujo para crear reservas tanto para usuarios logueados como visitantes anónimos.
- **Portal de Pagos:** Interfaz dedicada para que los clientes adjunten y envíen sus comprobantes (vouchers) de transferencia.
- **Validación Administrativa:** Sistema financiero para que los administradores revisen, aprueben o rechacen los comprobantes subidos por los clientes.

### 🏛️ Arquitectura & Escalabilidad (¡NUEVO!)
- **Separación de Responsabilidades (Service Objects):** Lógica compleja de negocio extraída de los modelos hacia objetos de servicio (`ConfirmService`, `RejectService`).
- **Refactorización MVC:** Limpieza de código HTML y clases CSS incrustadas en modelos y validaciones, delegándolos a Helpers dedicados de presentación.
- **Optimización de Consultas (N+1):** Precarga inteligente (`.includes`) de transacciones en vistas de lista y calendario para evitar saturación de la base de datos.
- **Herramientas DevTools:** Integración de `bullet` para monitoreo de consultas en tiempo real y `annotate` para documentación automática de modelos.

### 💰 Gestión Financiera & Facturación (¡NUEVO!)
- **Recibos PDF:** Generación automática de comprobantes de pago (vouchers en PDF) actualizados en tiempo real según el estado de la reserva.
- **Control de Abonos:** Registro de pagos parciales, saldos pendientes y validación de transacciones (aprobadas/rechazadas).
- **Pasarela de Pagos Webpay:** Integración oficial con Transbank para pagos en línea y automatización de comisiones como gastos operativos.
- **Gastos Operativos:** Registro de facturas de luz, agua, mantenimiento y otros (tabla `expenses`) vinculados a cada propiedad para cálculo de rentabilidad.

### 📋 Trazabilidad & Gestión Operativa (¡NUEVO!)
- **Auditoría (Timeline):** Registro histórico de cambios (quién cambió el estado de la reserva y cuándo) para tener trazabilidad completa.

### 👤 CRM & Fidelización (¡NUEVO!)
- **Perfil 360° del Cliente:** Historial de estancias e ingresos totales generados (LTV) implementados en el dashboard del cliente.
- **Etiquetado Inteligente:** Segmentación de clientes mediante tags visuales (VIP, Recurrente, Conflictivo) integrados con traducciones I18n.
- **Notas Privadas:** Área segura para registro de comportamientos y preferencias internas.

---

## 🟡 Próximos Pasos (Sugeridos)

1. **🔧 Gestión Operativa & Checklists**:
   - **Checklists de Entrada/Salida:** Listas de tareas dinámicas (Limpieza, Llaves, Inventario) vinculadas al flujo de la reserva.
   - **Gestión de Incidencias:** Reporte de roturas o problemas técnicos encontrados durante la estancia.

2. **📑 Gestión Documental**:
   - **Almacenamiento Seguro:** Subida de fotos de contratos firmados, documentos de identidad o fotos del estado de la propiedad antes/después.

---
*Última actualización: 23 de Mayo, 2026 - Actualización de Webpay, Timeline y Mejoras de UI*
