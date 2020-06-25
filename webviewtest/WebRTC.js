var exec_id = 0;
function exec(success, failure, ...) {
  // store the callbacks for later
  if (typeof success == 'function' || typeof failure == 'function') {
    exec_id++;
    exec_callbacks[exec_id] = { success: success, failure: failure };
    var commandId = exec_id;
  }
  webkit.messageHandlers.callbackHandler.postMessage({id: commandId, args: ...})
}

// the native code calls this directly with the same commandId, so the callbacks can be performed and released
function callback(opts) {
  if (opts.status == "success") {
    if (typeof exec_callbacks[opts.id].success == 'function') exec_callbacks[opts.id].success(opts.args);
  } else {
    if (typeof exec_callbacks[opts.id].failure == 'function') exec_callbacks[opts.id].failure(opts.args);
  }
  // some WebRTC functions invoke the callbacks multiple times
  // the native Cordova plugin uses setKeepCallbackAs(true)
  if (!opts.keepalive) delete exec_callbacks[opts.id];
}

(function() {
  if (!window.navigator) window.navigator = {};
  window.navigator.getUserMedia = function() {
    webkit.messageHandlers.callbackHandler.postMessage(arguments);
  }
})();
