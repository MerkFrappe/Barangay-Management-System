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
/******/ 	return __webpack_require__(__webpack_require__.s = 399);
/******/ })
/************************************************************************/
/******/ ({

/***/ 399:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
// ESM COMPAT FLAG
__webpack_require__.r(__webpack_exports__);

// CONCATENATED MODULE: ./src/utils-content.js

const IDENTIFY_MSG = 'idenify_content_tab_id';

function askBackground() {
  return new Promise(resolve => {
    chrome.runtime.sendMessage({ type: IDENTIFY_MSG }, function({ tabId, cachebuster }) {
      resolve({ tabId, cachebuster });
    });
  });
}

function injectScript(name, { cachebuster, tabId } = {}) {
  const runtimeManifest = chrome.runtime.getManifest();
  const script = document.createElement('script');

  script.id = `app_friendfilter_io_robot_${name}`;
  script.type = 'text/javascript';
  script.setAttribute('defer', '');

  script.src = chrome.runtime.getURL(`${name}.js?cachebuster=${cachebuster}`);
  script.dataset.extension_id = chrome.runtime.id;
  script.dataset.extension_name = "FriendFilter";
  script.dataset.extension_version = runtimeManifest.version;
  script.dataset.app_url = "https://app.friendfilter.io/";
  script.dataset.api_url = "https://api.friendfilter.io/v1/";
  script.dataset.installed_manually = ! runtimeManifest.update_url;

  if (tabId) {
    script.dataset.tab_id = tabId;
  }

  const ONE_MINUTE = 60;

  script.onerror = function() {
    console.error(`Unable to load FriendFilter extension, retry in ${ONE_MINUTE} seconds`);

    script.remove();
    setTimeout(() => {
      console.info('Trying to reload FriendFilter extension');

      injectScript(name, { cachebuster, tabId });
    }, ONE_MINUTE * 1000);
  };

  document.getElementsByTagName('head')[0].appendChild(script);
}

function injectContentScript({ cachebuster, tabId }) {
  injectScript('robot-content', { cachebuster, tabId });
}

// CONCATENATED MODULE: ./src/content.js


(async() => {
  const { tabId, cachebuster } = await askBackground();

  localStorage.setItem('extensionID', chrome.runtime.id);

  injectContentScript({ cachebuster, tabId });
})();


/***/ })

/******/ });
//# sourceMappingURL=content.js.map