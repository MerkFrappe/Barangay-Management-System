/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 292);
/******/ })
/************************************************************************/
/******/ ({

/***/ 292:
/***/ (function(module, exports) {

const secretLabelRegexp = 'xfilter'.split('').map(s => [ s, '\\d' ]).flat().join('');
const extensionId = localStorage.getItem('extensionID');

// `document.currentScript` resolves to this script element at parse time and is
// captured once; both monkeypatches dispatch on it, so the single listener in
// xhr.js:42 (`monkeypatched_xhr_${extensionId}`) handles both transports. The
// event name keeps the legacy `_xhr_` suffix to avoid touching the listener.
const eventEmitter = document.currentScript;

// 7.3.10 telemetry: per-capture-window request counters, read by the robot on a
// boilerplate-capture timeout to tell the four sub-causes apart (transport gap /
// no-fire / injection race / guard-reject). Each capture attempt opens a fresh
// tab, so a new script.js instance starts these at zero; the counts are
// naturally scoped to one capture window. Pushed to the robot over the same
// element-event channel the interceptor already uses, throttled so high-volume
// page traffic cannot flood the bridge. Counting only: no request is altered.
const stats = { reqXHR: 0, reqFetch: 0, reqBeacon: 0, reqOther: 0, totalRequestsSeen: 0 };

let lastStatsEmitAt = 0;

function emitStats(force) {
  const now = Date.now();

  if (! force && now - lastStatsEmitAt < 500) return;
  lastStatsEmitAt = now;

  const event = new CustomEvent(`monkeypatch_stats_${extensionId}`, { detail: Object.assign({}, stats) });

  eventEmitter.dispatchEvent(event);
}

function patchXHR() {
  const proxiedOpen = window.XMLHttpRequest.prototype.open;
  const proxiedSend = window.XMLHttpRequest.prototype.send;

  window.XMLHttpRequest.prototype.open = function(method, path) {
    this.__xfilter_meta__ = { method, path };
    return proxiedOpen.apply(this, [].slice.call(arguments));
  };
  window.XMLHttpRequest.prototype.send = function(data) {
    const { method, path } = this.__xfilter_meta__;
    const isGraphQL = method === 'POST' && path.indexOf('/api/graphql') === 0;
    const initiatedByXFilter = typeof data === 'string' && !! data.match(`/${secretLabelRegexp}/`);

    stats.totalRequestsSeen ++;

    if (isGraphQL && ! initiatedByXFilter) {
      stats.reqXHR ++;
      emitStats(true);

      this.addEventListener('readystatechange', function() {
        if (this.readyState === XMLHttpRequest.DONE && this.status === 200) {
          const event = new CustomEvent(`monkeypatched_xhr_${extensionId}`, { detail: { method, path, data, response: this.responseText } });

          eventEmitter.dispatchEvent(event);
        }
      });
    } else {
      emitStats(false);
    }

    return proxiedSend.apply(this, [].slice.call(arguments));
  };
}

// 7.3.7: mirror the XHR patch for fetch(). Modern Facebook routes a growing
// share of /api/graphql traffic through fetch; without this the captureTab
// times out because no XHR ever fires (Round 2 investigation, hypothesis H2).
// Dispatches the SAME custom event as the XHR path so the existing listener
// in xhr.js handles both transports through one channel. The 3s dedupe in
// interceptor.saveInterceptedBoilerplate absorbs double-fires.
function patchFetch() {
  if (typeof window.fetch !== 'function') return;
  const proxiedFetch = window.fetch;

  window.fetch = function(input, init) {
    // Resolve method, URL, and body from the polymorphic input. Match the XHR
    // guard exactly: only POST to /api/graphql*, body must be a string we can
    // sniff for the extension's secret label.
    let method = (init && init.method) || 'GET';

    let rawUrl;

    if (input && typeof input === 'object' && typeof input.url === 'string') {
      // Request object
      if (! (init && init.method)) method = input.method || 'GET';
      rawUrl = input.url;
    } else {
      rawUrl = String(input);
    }

    let pathOnly = rawUrl;

    try {
      const u = new URL(rawUrl, location.href);

      pathOnly = u.pathname + u.search;
    } catch (_e) { /* fall back to raw url string */ }

    const body = init && init.body !== undefined ? init.body : null;

    let bodyString = null;

    if (typeof body === 'string') bodyString = body;
    else if (typeof URLSearchParams !== 'undefined' && body instanceof URLSearchParams) bodyString = body.toString();

    const upperMethod = String(method).toUpperCase();
    const isGraphQL = upperMethod === 'POST' && typeof pathOnly === 'string' && pathOnly.indexOf('/api/graphql') === 0;
    const initiatedByXFilter = bodyString && !! bodyString.match(`/${secretLabelRegexp}/`);

    stats.totalRequestsSeen ++;

    const responsePromise = proxiedFetch.apply(this, arguments);

    if (isGraphQL && ! initiatedByXFilter) {
      stats.reqFetch ++;
      emitStats(true);

      // Fork the promise: observe in parallel via clone(); the caller's
      // returned promise is untouched so their body-consume path is intact.
      responsePromise.then(response => {
        if (! response || response.status !== 200) return;
        return response.clone().text().then(responseText => {
          const event = new CustomEvent(`monkeypatched_xhr_${extensionId}`, {
            detail: { method: upperMethod, path: pathOnly, data: bodyString || '', response: responseText },
          });

          eventEmitter.dispatchEvent(event);
        });
      }).catch(() => { /* best-effort observability; never break the caller's fetch */ });
    } else {
      emitStats(false);
    }

    return responsePromise;
  };
}

// 7.3.10 telemetry: count GraphQL requests sent via navigator.sendBeacon, a
// transport neither the XHR nor the fetch patch observes. Pure pass-through:
// it increments the counter, then forwards to the original and returns its value,
// so beacon behavior is byte-for-byte unchanged.
function patchBeacon() {
  if (! navigator || typeof navigator.sendBeacon !== 'function') return;

  const proxiedSendBeacon = navigator.sendBeacon;

  navigator.sendBeacon = function(url) {
    try {
      const u = new URL(String(url), location.href);

      if (u.pathname.indexOf('/api/graphql') === 0) {
        stats.reqBeacon ++;
        emitStats(true);
      }
    } catch (_e) { /* never let telemetry break a beacon */ }

    return proxiedSendBeacon.apply(navigator, arguments);
  };
}

patchXHR();
patchFetch();
patchBeacon();

// Emit one snapshot at install so the robot can distinguish "script.js never
// loaded / bridge broken" (no stats ever received) from "loaded but the page
// fired nothing" (a zeroed snapshot received).
emitStats(true);


/***/ })

/******/ });
//# sourceMappingURL=script.js.map