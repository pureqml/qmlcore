///root item
Item {
	property int scrollY;		///< scrolled page vertical offset value
	property int keyProcessDelay; ///< key pressed handling delay timeout in millisecnods
	property string language;	///< localisation language
	property System system: System { }					///< system info object
	property Location location: Location { }			///< web-page location object
	property Stylesheet stylesheet: Stylesheet { }		///< @private
	property string buildIdentifier; ///< @private

	property int virtualWidth: manifest.virtual.width;	///< virtual viewport width
	property int virtualHeight: manifest.virtual.height;///< virtual viewport height
	property real virtualScale: Math.min((system.resolutionWidth || width) / virtualWidth, (system.resolutionHeight || height) / virtualHeight);	///< @private

	signal message;	///< incoming postMessage

	signal keyDown; ///< key pressed
	signal keyUp; ///< key released

	visibleInView: false; //startup

	///@private
	constructor: {
		this.options = arguments[2]
		this.l10n = this.options.l10n || {}

		this._local['context'] = this
		this._context = this
		this._started = false
		this._completed = false
		this._processingActions = false
		this._delayedActions = []
		this._completedObjects = []
		this._stylesRegistered = {}
		this._asyncInvoker = $core.safeCall(this, [], function (ex) { log("async action failed:", ex, ex.stack) })

		this.backend = _globals._backend()

		this._init()
	}

	///@private
	function mangleClass(name) {
		return $manifest$html5$prefix + name
	}

	///@private
	function registerStyle(item, tag, cls) {
		cls = this.mangleClass(cls)
		var selector = cls? tag + '.' + cls: tag
		if (!(selector in this._stylesRegistered)) {
			item.registerStyle(this.stylesheet, selector)
			this._stylesRegistered[selector] = true
		}
	}

	///@private
	function createElement(tag, cls) {
		return this.backend.createElement(this, tag, cls)
	}

	///@private
	function _init() {
		log('Context: initializing...')
		new this.backend.init(this)
	}

	///@private
	function init() {
		this.__init()
		this.backend.initSystem(this.system)
	}

	///@private
	function __onCompleted(object) {
		this._completedObjects.push(object)
	}

	///@internal
	function scheduleComplete() {
		this.delayedAction('context:completed', this, this._processActions)
	}

	///@private
	function start(instance) {
		this.children.push(instance)
		instance.__init()
		log('Context: created instance')
		// log('Context: calling on completed')
		return instance;
	}

	///You must wrap your callback with this function if you pass callback to native function.
	function wrapNativeCallback(callback) {
		var ctx = this
		return function() {
			try {
				var r = callback.apply(this, arguments)
				ctx._processActions()
				return r
			} catch(ex) {
				ctx._processActions()
				throw ex
			}
		}
	}

	///@internal
	///generally you don't need to call it yourself
	///if you need to call it from native callback, use wrapNativeCallback method
	function _processActions() {
		if (!this._started || this._processingActions)
			return

		this._processingActions = true

		var invoker = this._asyncInvoker

		while (this._delayedActions.length || this._completedObjects.length) {
			var actions = this._delayedActions
			this._delayedActions = []
			for(var i = 0, n = actions.length; i < n; ++i)
				invoker(actions[i])

			var objects = this._completedObjects
			this._completedObjects = []
			for(var i = 0, n = objects.length; i < n; ++i) {
				var object = objects[i]
				try { object.__complete() }
				catch(ex) { log('onCompleted failed', ex, ex.stack)}
			}
		}

		this._processingActions = false
		this.backend.tick(this)
	}

	///@private
	function scheduleAction(action) {
		this._delayedActions.push(action)
	}

	///@private
	function delayedAction(name, self, method, delay) {
		if (!self._registerDelayedAction(name))
			return

		var callback = function() {
			self._cancelDelayedAction(name)
			method.call(self)
		}

		if (delay > 0) {
			setTimeout(this.wrapNativeCallback(callback), delay)
		} else if (delay === 0) {
			this.backend.requestAnimationFrame(this.wrapNativeCallback(callback))
		} else {
			this.scheduleAction(callback)
		}
	}

	/**@param text:string text that must be translated
	Returns input text translation*/
	function tr(text) {
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

	function qsTr() {
		return this.tr.apply(this, arguments)
	}

	function updateL10n(lang, data) {
		this.l10n[lang] = data
		var storage = this.__properties.language
		storage.callOnChanged(this, 'language', this.language, this.language)
	}

	function processKey(key, event) {
		var handlers = core.forEach(this, $core.Item.prototype._enqueueNextChildInFocusChain, [])
		var n = handlers.length
		for(var i = 0; i < n; ++i) {
			var handler = handlers[i]
			if (handler._processKey(key, event))
				return true
		}
		return false
	}

	///@private
	function run() {
		this.backend.run(this, this._run.bind(this))
	}

	///@private
	function _run() {
		log('Context: signalling layout')
		this.visibleInView = true
		this.newBoundingBox()
		log('Context: calling completed()')
		this._started = true
		this._processActions()
		this._completed = true
	}
}
