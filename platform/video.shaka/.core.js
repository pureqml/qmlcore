shaka.polyfill.installAll();
if (shaka.Player.isBrowserSupported()) {
    _globals.core.__videoBackends.shaka = function() { return _globals.video.shaka.backend }
}
