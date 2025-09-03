// Service Worker für Offline-Funktionalität
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('3d-druck-katalog-v1').then((cache) => {
      return cache.addAll([
        '/',
        '/index.html',
        '/main.dart.js',
        '/favicon.png',
        '/icons/Icon-192.png',
        '/icons/Icon-512.png',
        '/icons/Icon-maskable-192.png',
        '/icons/Icon-maskable-512.png',
        '/manifest.json',
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request).then((response) => {
        // Cache dynamische Anfragen für Offline-Zugriff
        if (response.status === 200) {
          const responseClone = response.clone();
          caches.open('3d-druck-katalog-v1').then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      });
    }).catch(() => {
      // Fallback für Offline-Zustand
      if (event.request.url.indexOf('/api/') !== -1) {
        return new Response(JSON.stringify({
          error: 'Sie sind offline. Bitte überprüfen Sie Ihre Internetverbindung.'
        }), {
          headers: {'Content-Type': 'application/json'}
        });
      }
    })
  );
});
