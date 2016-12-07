Item {
	property bool fullscreen;
	property int scrollY;
	property Stylesheet stylesheet: Stylesheet { }
	property System system: System { }
	property Location location: Location { }
	property string language;

	constructor: {
		this.options = arguments[2]
		this.l10n = this.options.l10n || {}

		this._local['context'] = this
		this._prefix = this.options.prefix
		this._context = this
		this._started = false
		this._completed = false
		this._completedHandlers = []
		this._delayedActions = []
		this._stylesRegistered = {}
	}

	function getClass(name) {
		return this._prefix + name
	}

	function registerStyle(item, tag) {
		if (!(tag in this._stylesRegistered)) {
			item.registerStyle(this.stylesheet, tag)
			this._stylesRegistered[tag] = true
		}
	}

	function createElement(tag) {
		var el = new _globals.html5.html.Element(this, document.createElement(tag))
		if (this._prefix) {
			el.addClass(this.getClass('core-item'))
		}
		return el
	}

	function init() {
		log('Context: initializing...')

		var options = this.options
		var prefix = this._prefix

		var divId = options.id

		if (prefix) {
			prefix += '-'
			//log('Context: using prefix', prefix)
		}

		var win = new _globals.html5.html.Window(this, window)
		this.window = win
		var w, h

		var html = _globals.html5.html
		var div = document.getElementById(divId)
		var topLevel = div === null
		if (!topLevel) {
			div = new html.Element(this, div)
			w = div.width()
			h = div.height()
			log('Context: found element by id, size: ' + w + 'x' + h)
			win.on('resize', function() { this.width = div.width(); this.height = div.height(); }.bind(this));
		} else {
			w = win.width();
			h = win.height();
			log("Context: window size: " + w + "x" + h);
			div = this.createElement('div')
			div.dom.id = divId //html specific
			win.on('resize', function() { this.width = win.width(); this.height = win.height(); }.bind(this));
			var body = html.getElement('body')
			body.append(div);
		}

		this.element = div
		this.width = w
		this.height = h
		this.style('visibility', 'hidden')

		win.on('scroll', function(event) { this.scrollY = win.scrollY(); }.bind(this));

		win.on('load', function() {
			log('Context: window.load. calling completed()')
			this._complete()
			this.style('visibility', 'visible')
		} .bind(this) );

		var self = this;

		var onFullscreenChanged = function(e) {
			var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
			self.fullscreen = state
		}
		'webkitfullscreenchange mozfullscreenchange fullscreenchange'.split(' ').forEach(function(name) {
			div.on(name, onFullscreenChanged)
		})

		win.on('keydown', function(event) { if (self._processKey(event)) event.preventDefault(); }.bind(this) ) //fixme: add html.Document instead
	}

	function _onCompleted(callback) {
		this._completedHandlers.push(callback);
	}

	function _update(name, value) {
		switch(name) {
			case 'fullscreen': if (value) this._enterFullscreenMode(); else this._exitFullscreenMode(); break
		}
		_globals.core.Item.prototype._update.apply(this, arguments)
	}

	function _enterFullscreenMode() { return window.Modernizr.prefixed('requestFullscreen', this.element.dom)() }
	function _exitFullscreenMode() { return window.Modernizr.prefixed('exitFullscreen', document)() }

	function _inFullscreenMode() {
		return !!window.Modernizr.prefixed('fullscreenElement', document)
	}

	function _complete() {
		if (!this._started || this._runningComplete)
			return

		this._completed = true
		this._runningComplete = true

		var invoker = _globals.core.safeCall([], function (ex) { log("onCompleted failed:", ex, ex.stack) })
		do {
			while(this._completedHandlers.length) {
				var ch = this._completedHandlers
				this._completedHandlers = []
				ch.forEach(invoker)
			}
			this._processActions()
		} while(this._completedHandlers.length)
		this._runningComplete = false
	}

	function start(instance) {
		var closure = {}
		instance.__create(closure)
		instance.__setup(closure)
		closure = undefined
		log('Context: started')
		this._started = true
		// log('Context: calling on completed')
		log('Context: signalling layout')
		this.boxChanged()
		log('Context: done')
		return instance;
	}

	function _processActions() {
		var invoker = _globals.core.safeCall([], function (ex) { log('exception in delayed action', ex, ex.stack) })
		while (this._delayedActions.length) {
			var actions = this._delayedActions
			this._delayedActions = []
			actions.forEach(invoker)
		}
		this._delayedTimeout = undefined
	}

	function scheduleAction(action) {
		this._delayedActions.push(action)
		if (this._completed && this._delayedTimeout === undefined) //do not schedule any processing before creation process ends
			this._delayedTimeout = setTimeout(this._processActions.bind(this), 0)
	}

	function qsTr(text) {
		var args = arguments
		var lang = this.language
		var messages = this.l10n[lang] || {}
		var contexts = messages[text] || {}
		for(var name in contexts) {
			text = contexts[name] //fixme: add context handling here
			break
		}
		return text.replace(/%(\d+)/, function(text, index) { return args[index] })
	}

}
