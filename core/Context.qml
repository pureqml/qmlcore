Item {
	property bool fullscreen;
	property int scrollY;
	property string hash;
	property System system: System { }

	constructor: {
		this._started = false
		this._completedHandlers = []
		this._delayedActions = []
	}

	function init(html) {
		log('Context: initializing...')
		this._local['context'] = this;

		var win = $(window);
		var w = win.width();
		var h = win.height();
		log("Context: window size: " + w + "x" + h);

		var body = $('body');
		var div = $(html);
		div.css('visibility', 'hidden');
		body.append(div);
		var userSelect = window.Modernizr.prefixedCSS('user-select') + ": none; "
		$('head').append($("<style>" +
			"body { overflow-x: hidden; }" +
			"div#context { position: absolute; left: 0px; top: 0px; } " +
			"div.text { width: auto; height: auto} " +
			"div " + "{ position: absolute; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px; } " +
			"input { position: absolute; } " +
			"img { position: absolute; -webkit-touch-callout: none; " + userSelect + " } " +
			"</style>"
		));

		this.element = div
		this.width = w;
		this.height = h;

		win.on('resize', function() { this.width = win.width(); this.height = win.height(); }.bind(this));
		win.on('scroll', function(event) { this.scrollY = win.scrollTop(); }.bind(this));
		win.on('hashchange', function(event) { this.hash = window.location.hash; }.bind(this));

		win.on('load', function() {
			log('Context: window.load. calling completed()')
			this._complete()
			div.css('visibility', 'visible')
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

		var invoker = qml.core.safeCall([], function (ex) { log("onCompleted failed:", ex, ex.stack) })
		while(this._completedHandlers.length) {
			var ch = this._completedHandlers
			this._completedHandlers = []
			ch.forEach(invoker)
		}
	}

	function start(name) {
		console.log('Context: starting')
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
		console.log('Context: creating instance')
		var instance = Object.create(proto.prototype);
		console.log('Context: calling ctor')
		proto.apply(instance, [this]);
		console.log('Context: started')
		this._started = true
		// console.log('Context: calling on completed')
		console.log('Context: signalling layout')
		this.boxChanged()
		console.log('Context: done')
		return instance;
	}

	function _processActions() {
		var invoker = qml.core.safeCall([], function (ex) { log('exception in delayed action', ex) })
		while (this._delayedActions.length) {
			var next = this._delayedActions.shift()
			invoker(next)
		}
		this._delayedTimeout = undefined
	}

	function scheduleAction(action) {
		var da = this._delayedActions
		this._delayedActions.push(action)
		if (this._delayedTimeout === undefined)
			this._delayedTimeout = setTimeout(this._processActions.bind(this), 0)
	}

	function qsTr(text) {
		var args = arguments
		return text.replace(/%(\d+)/, function(text, index) { return args[index] })
	}

}
