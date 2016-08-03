Item {
	property bool fullscreen;
	property int scrollY;
	property string hash;
	property System system: System { }

	constructor: {
		this._started = false
		this._completed = false
		this._modernizrCache = {}
		this._completedHandlers = []
		this._delayedActions = []
	}

	function init(options) {
		log('Context: initializing...')
		this._local['context'] = this

		var prefix = options.prefix
		var divId = options.id

		if (prefix) {
			prefix += '-'
			//log('Context: using prefix', prefix)
		}
		this._prefix = prefix

		var win = $(window)
		var w, h

		var div = document.getElementById(divId)
		if (div !== null) {
			div = $(div)
			w = div.width()
			h = div.height()
			log('Context: found element by id, size: ' + w + 'x' + h)
			win.on('resize', function() { this.width = div.width(); this.height = div.height(); }.bind(this));
		} else {
			w = win.width();
			h = win.height();
			log("Context: window size: " + w + "x" + h);
			div = $('<div id="' + divId + '"></div>')
			win.on('resize', function() { this.width = win.width(); this.height = win.height(); }.bind(this));
			$('body').append(div);
		}

		var userSelect = window.Modernizr.prefixedCSS('user-select') + ": none; "
		var mangleRule = function() {
			if (prefix)
				return prefix
		}

		$('head').append($("<style>" +
			"div#" + divId + " { position: absolute; visibility: inherit; left: 0px; top: 0px; } " +
			"div.text { width: auto; height: auto; visibility: inherit; } " +
			"body { overflow-x: hidden; }" +
			"div " + "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; } " +
			"a " + "{ position: absolute; visibility: inherit; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; } " +
			"textarea { position: absolute; visibility: inherit; } " +
			"input { position: absolute; visibility: inherit; } " +
			"img { position: absolute; visibility: inherit; -webkit-touch-callout: none; " + userSelect + " } " +
			"</style>"
		));

		this.element = div
		this.width = w
		this.height = h
		this.style('visibility', 'hidden')

		win.on('scroll', function(event) { this.scrollY = win.scrollTop(); }.bind(this));
		win.on('hashchange', function(event) { this.hash = window.location.hash; }.bind(this));

		win.on('load', function() {
			log('Context: window.load. calling completed()')
			this._complete()
			this.style('visibility', 'visible')
		} .bind(this) );

		var self = this;
		div.bind('webkitfullscreenchange mozfullscreenchange fullscreenchange', function(e) {
			var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
			self.fullscreen = state
		});
		$(document).keydown(function(event) { if (self._processKey(event)) event.preventDefault(); } );
	}

	function _onCompleted(callback) {
		this._completedHandlers.push(callback);
	}

	function _update(name, value) {
		switch(name) {
			case 'fullscreen': if (value) this._enterFullscreenMode(); else this._exitFullscreenMode(); break
		}
		qml.core.Item.prototype._update.apply(this, arguments)
	}

	function _enterFullscreenMode() { return window.Modernizr.prefixed('requestFullscreen', this.element.get(0))() }
	function _exitFullscreenMode() { return window.Modernizr.prefixed('exitFullscreen', document)() }

	function _inFullscreenMode() {
		return !!window.Modernizr.prefixed('fullscreenElement', document)
	}

	function _complete() {
		if (!this._started)
			return

		this._completed = true

		var invoker = qml.core.safeCall([], function (ex) { log("onCompleted failed:", ex, ex.stack) })
		do {
			while(this._completedHandlers.length) {
				var ch = this._completedHandlers
				this._completedHandlers = []
				ch.forEach(invoker)
			}
			this._processActions()
		} while(this._completedHandlers.length)
	}

	function start(name) {
		log('Context: starting')
		var proto;
		if (typeof name == 'string') {
			//log('creating component...', name);
			var path = name.split('.');
			proto = exports;
			for (var i = 0; i < path.length; ++i)
				proto = proto[path[i]]
		}
		else
			proto = name;
		log('Context: creating instance')
		var instance = Object.create(proto.prototype);
		log('Context: calling ctor')
		proto.apply(instance, [this]);
		log('Context: started')
		this._started = true
		// log('Context: calling on completed')
		log('Context: signalling layout')
		this.boxChanged()
		log('Context: done')
		return instance;
	}

	function _processActions() {
		var invoker = qml.core.safeCall([], function (ex) { log('exception in delayed action', ex) })
		while (this._delayedActions.length) {
			var actions = this._delayedActions
			this._delayedActions = []
			actions.forEach(invoker)
		}
		this._delayedTimeout = undefined
	}

	function getPrefixedName(name) {
		var prefixedName = this._modernizrCache[name]
		if (prefixedName === undefined)
			this._modernizrCache[name] = prefixedName = window.Modernizr.prefixedCSS(name)
		return prefixedName
	}

	function scheduleAction(action) {
		this._delayedActions.push(action)
		if (this._completed && this._delayedTimeout === undefined) //do not schedule any processing before creation process ends
			this._delayedTimeout = setTimeout(this._processActions.bind(this), 0)
	}

	function qsTr(text) {
		var args = arguments
		return text.replace(/%(\d+)/, function(text, index) { return args[index] })
	}

}
