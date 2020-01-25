_globals._backend = function() { return _globals.pure.femto.backend }
_globals.core.__deviceBackend = function() { return _globals.pure.femto.device }
_globals.core.__locationBackend = function() { return _globals.pure.femto.location }
_globals.core.__videoBackends.femto = function() { return _globals.pure.femto.video }
_globals.core.__localStorageBackend = function() { return _globals.pure.femto.storage }

_globals.core.os = 'android'
_globals.core.browser = 'PureQML'
