'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/AssetManifest.bin": "d8374002f4832aaeee0d96a9499c306c",
"assets/fonts/MaterialIcons-Regular.otf": "757afa3c3002256e9d4207cf21ee2021",
"assets/AssetManifest.json": "6e108e9a38b7a614d72054b585aee7a7",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/assets/images/vehicles/taxi.png": "47bd17c07a6e411e6964998aa9dc8f73",
"assets/assets/images/vehicles/bicycle.png": "8205a323a97e609304eb1efa76074ec4",
"assets/assets/images/vehicles/rocket.png": "aafb3a24b4ad7c5585a018714b21bbbe",
"assets/assets/images/vehicles/airplane.png": "2eaecee05714b65710d84642b515986e",
"assets/assets/images/vehicles/car.png": "524d7ea7891367c720d70a85e4558698",
"assets/assets/images/objects/key.png": "39d0e63eeb490a4cf79aebccca8305aa",
"assets/assets/images/objects/pencil.png": "00b2060e0ca9c0da134ccc01a7bc4027",
"assets/assets/images/objects/spoon.png": "86865c22ffb789b6565f8a4ab82076bf",
"assets/assets/images/objects/clock.png": "7923cc08d6aaa7e47c95ae99d5bddff9",
"assets/assets/images/objects/fork.png": "c7fa74c2ccb533c04a6ce34f2611c75e",
"assets/assets/images/objects/calendar.png": "075ecc60c6f8d787a90fca1a88bb476f",
"assets/assets/images/objects/kettle.png": "708e58b1516300cbb6ddeb18de51cafe",
"assets/assets/images/objects/cup.png": "cd6f39f5594e49b695991af85bb0b813",
"assets/assets/images/objects/sofa.png": "8e6eb1c0a0e82dfd59591604bd78b3e3",
"assets/assets/images/objects/umbrella.png": "eeadf430da60fc2350f2a96c3f8a6c02",
"assets/assets/images/animals/frog.png": "7a900c926d239d4fe015f5c6c56b4a57",
"assets/assets/images/animals/deer.png": "6e61cac9d8e1a446eb4c9e41fdad93fe",
"assets/assets/images/animals/turtle.png": "87c1c753d9c665dbc1bc14447d3fb044",
"assets/assets/images/animals/horse.png": "d02c661532ba610756b1ce4144374500",
"assets/assets/images/animals/elephant.png": "81513c7e44940f465b58e809f15aae63",
"assets/assets/images/animals/cat.png": "11e23b9c86a36be1a802583ad85ca661",
"assets/assets/images/animals/mouse.png": "8393c411b0de0f92f1b3c2a459863f46",
"assets/assets/images/animals/dog.png": "70f84d7a494a3dd59616a0be4a5bd5b1",
"assets/assets/images/animals/crab.png": "5240b2b0dc65a02428da7ad78fec83d0",
"assets/assets/images/animals/fox.png": "e7de86798af52446dc16078259d77c81",
"assets/assets/images/animals/koala.png": "e72c6e2d99fc51ba77219c69061248c8",
"assets/assets/images/animals/giraffe.png": "73f014dec515b92c87bbb8140e5f384b",
"assets/assets/images/animals/hippo.png": "732e0455a0e3408182f1728852f92857",
"assets/assets/images/animals/hedgehog.png": "4e16f1630ccac302a7d9f85758bad9f5",
"assets/assets/images/animals/chicken.png": "fb87d331915f0305ffedf484867515d6",
"assets/assets/images/animals/dolphin.png": "c48b2fd3834c7180bd0fd2c6cbc68514",
"assets/assets/images/animals/pig.png": "48d440e77de1116e1ee2ab63e086fceb",
"assets/assets/images/animals/penguin.png": "c94b846c1386744290916a21b8902b04",
"assets/assets/images/animals/zebra.png": "9c25ea4859359ea949eb62707704cfcf",
"assets/assets/images/animals/sloth.png": "3614bf3d04573b63b8623c0de5e53a18",
"assets/assets/images/animals/chick.png": "2fb0c0aca7761cdc1323061911387da1",
"assets/assets/images/animals/panda.png": "b5a53c7c015204ad8cc815e9bb73499f",
"assets/assets/images/animals/lion.png": "f5e4063e446c05d96cbc6be89e292505",
"assets/assets/images/animals/rabbit.png": "bf9427e76ae9aeb370f1466fefc525db",
"assets/assets/images/animals/ear.png": "2c1d00fc364c96f3eda65b23869bb2c2",
"assets/assets/images/animals/whale.png": "9c71df7f4b576a2e3c5c91bb180deea5",
"assets/assets/images/animals/monkey.png": "7a3f5b40080918596911f8353496c185",
"assets/assets/images/fruits/watermelon.png": "4c3baa183b338519379a2783f54d00fe",
"assets/assets/images/fruits/kiwi.png": "acac7e57bf01922669d18434c54dae8c",
"assets/assets/images/fruits/mango.png": "5d200bb6d6fd3ec01a93e58d2985e695",
"assets/assets/images/fruits/cherry.png": "5cffb83372058b06ef1ed4260402e41d",
"assets/assets/images/fruits/grape.png": "39eed7e6ab43de8be1d377e86570f824",
"assets/assets/images/fruits/strawberry.png": "a248eab414688b62df443b7f22125c86",
"assets/assets/images/fruits/lemon.png": "1a3930a1f8b19b25b43ce1b4d28cd8d3",
"assets/assets/images/fruits/apple.png": "2a953babcf295a4f415e4ff82bf4d452",
"assets/assets/images/fruits/pineapple.png": "0ed92f66b5b47bd24cce1d205e1ae9e6",
"assets/assets/images/fruits/tangerine.png": "445718e3bf9c6d4e7daf4fe00128ee32",
"assets/assets/images/fruits/blueberry.png": "753dafb8c0a6f222958f81f535935802",
"assets/assets/images/fruits/peach.png": "269846c01a3ded14470c3180b5ff37ff",
"assets/assets/images/fruits/banana.png": "2331d376ed9a532e7222f2760688722e",
"assets/NOTICES": "35b9e01f9cab84b55d2b54f03c9b8222",
"assets/AssetManifest.bin.json": "bad0b5cd113fb15ffefd783746e7c321",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"manifest.json": "9a66f02ea198fbbb712b97f0d85d9ae9",
"index.html": "ff0030a1264e5def23514da9e38fe8d8",
"/": "ff0030a1264e5def23514da9e38fe8d8",
"version.json": "a8e17d1232e7fb888added0f3dc9e8df",
"flutter_bootstrap.js": "5a1cfaab99364216e6dc6d0245174077",
"main.dart.js": "2f0152febe65280e96a1f725ade6cc04",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
