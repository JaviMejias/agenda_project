// Service Worker para Agenda Pro
const CACHE_NAME = "agenda-pro-v1";
const OFFLINE_ASSETS = [
  "/",               // Cachear la raíz
  "/manifest",       // El manifiesto corregido
  "/icon.png"        // El icono
];

// Instalación: Guardar activos críticos
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      // Usamos addAll pero con un catch para que no rompa todo si falla un archivo
      return cache.addAll(OFFLINE_ASSETS).catch(err => console.log("Error en cache.addAll", err));
    })
  );
  self.skipWaiting();
});

// Activación
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    })
  );
  return self.clients.claim();
});

// Estrategia: Network First con fallback a Cache
self.addEventListener("fetch", (event) => {
  // Solo interceptar peticiones GET
  if (event.request.method !== "GET") return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Si la respuesta es buena, la guardamos en cache
        if (response && response.status === 200 && response.type === 'basic') {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        }
        return response;
      })
      .catch(() => {
        // Si falla la red, buscamos en cache
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) return cachedResponse;
          
          // Si ni siquiera está en cache y es una página, podrías mostrar una página offline genérica
          if (event.request.mode === "navigate") {
            return caches.match("/");
          }
        });
      })
  );
});
