///root item
Item {
	property int scrollY;		///< scrolled page vertical offset value
	property int keyProcessDelay; ///< key pressed handling delay timeout in millisecnods
	property bool fullscreen;	///< fullscreen mode enabled / disabled
	property string language;	///< localisation language
	property System system: System { }					///< system info object
	property Location location: Location { }			///< web-page location object
	property Stylesheet stylesheet: Stylesheet { }		///< @private
	property Orientation orientation: Orientation { }	///< screen orientation object
	property string buildIdentifier; ///< @private

	visibleInView: false; //startup

	///@private
	constructor: {
		this.options = arguments[2]
		this.l10n = this.options.l10n || {}

		this._local['context'] = this
		this._prefix = this.options.prefix
		this._context = this
		this._started = false
		this._completed = false
		this._processingActions = false
		this._delayedActions = [[], []]
		this._stylesRegistered = {}
		this._asyncInvoker = _globals.core.safeCall(this, [], function (ex) { log("async action failed:", ex, ex.stack) })

		this.backend = _globals._backend()
	}

	///@private
	function getClass(name) {
		return this._prefix + name
	}

	///@private
	function registerStyle(item, tag, cls) {
		if (!(tag + cls in this._stylesRegistered)) {
			item.registerStyle(this.stylesheet, tag, cls)
			this._stylesRegistered[tag + cls] = true
		}
	}

	///@private
	function createElement(tag, cls) {
		var el = this.backend.createElement(this, tag, cls)
		if (cls) {
			el.addClass(cls)
		}
		return el
	}

	///@private
	function init() {
		log('Context: initializing...')
		new this.backend.init(this)
		var invoker = _globals.core.safeCall(null, [], function (ex) { log("prototype constructor failed:", ex, ex.stack) })
		__prototype$ctors.forEach(invoker)
		__prototype$ctors = undefined
	}

	///@private
	function _onCompleted(callback) {
		this.scheduleAction(callback)
	}

	onFullscreenChanged: { if (value) this.backend.enterFullscreenMode(this.element); else this.backend.exitFullscreenMode(); }

	///@private
	function _complete() {
		this._processActions()
	}

	///@private
	function start(instance) {
		var closure = {}
		this.children.push(instance)
		instance.__create(closure)
		instance.__setup(closure)
		closure = undefined
		log('Context: created instance')
		// log('Context: calling on completed')
		return instance;
	}

	///@private
	function _processActions() {
		if (!this._started || this._processingActions)
			return

		this._processingActions = true

		var invoker = this._asyncInvoker
		var delayedActions = this._delayedActions
		var empty = false
		var maxLevels = delayedActions.length //must not have changed

		while(!empty) {
			for(var level = 0; level < maxLevels; ++level) {
				var levelActions = delayedActions[level]
				while (levelActions.length) {
					//log('actions', level, levelActions.length)
					var actions = levelActions.splice(0, levelActions.length)
					for(var i = 0, n = actions.length; i < n; ++i)
						invoker(actions[i])
				}
			}

			empty = true
			for(var level = 0; level < maxLevels; ++level) {
				var levelActions = delayedActions[level]
				if (levelActions.length !== 0)
					empty = false
			}
		}

		this._processingActions = false
		this.backend.tick(this)
	}

	///@private
	function scheduleAction(action, priority) {
		this._delayedActions[priority !== undefined? priority: 0].push(action)
	}

	///@private
	function delayedAction(prefix, self, method) {
		var name = '__delayed_' + prefix
		if (self[name] === true)
			return

		self[name] = true
		this.scheduleAction(function() {
			self[name] = false
			method.call(self)
		})
	}

	/**@param text:string text that must be translated
	Returns input text translation*/
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

	///@private
	function run() {
		this.backend.run(this, this._run.bind(this))
	}

	///@private
	function _run() {
		log('Context: signalling layout')
		this.visibleInView = true
		this.boxChanged()
		log('Context: calling completed()')
		this._started = true
		this._complete()
		this._completed = true
	}
}
