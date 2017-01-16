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

		//fixme: move it somewhere in platform/xxxx
		switch(_globals._backend)
		{
		case 'html5':	this.backend = _globals.html.html5
		case 'pure':	this.backend = _globals.pure.backend
		}
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
		var el = new this.backend.Element(this, tag)
		if (this._prefix) {
			el.addClass(this.getClass('core-item'))
		}
		return el
	}

	function init() {
		log('Context: initializing...')
		new this.backend.Backend(this)
	}

	function _onCompleted(callback) {
		this._completedHandlers.push(callback);
	}

	function _update(name, value) {
		switch(name) {
			case 'fullscreen': if (value) this.backend.enterFullscreenMode(this.element); else this.backend.exitFullscreenMode(); break
		}
		_globals.core.Item.prototype._update.apply(this, arguments)
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
