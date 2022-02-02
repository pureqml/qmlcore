var CACHE_NAME = 'pureqml-cache-v1';
var urlsToCache = {{ installed_files | tojson }};
urlsToCache.push('/')

self.addEventListener('install', function(event) {
	event.waitUntil(
	caches.open(CACHE_NAME)
		.then(function(cache) {
		console.log('Opened cache, adding cached urls: ' + urlsToCache.length);
		return cache.addAll(urlsToCache);
		})
	);
});

self.addEventListener('fetch', function(event) {
	event.respondWith(
		caches.match(event.request)
		.then(function(response) {
			if (response) {
				return response;
			}

			return fetch(event.request, {credentials: 'include'}).then(
			function(response) {
				if(!response || response.status !== 200 || response.type !== 'basic') {
					return response;
				}

				var responseToCache = response.clone();

				caches.open(CACHE_NAME)
				.then(function(cache) {
					cache.put(event.request, responseToCache);
				});

				return response;
			});
		})
	);
});
