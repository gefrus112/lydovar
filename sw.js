// Lardovar service worker: no caching, so the site always loads fresh. It only makes the app installable.
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',e=>e.waitUntil(self.clients.claim()));
self.addEventListener('fetch',()=>{});
