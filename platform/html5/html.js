/*** @using { core.RAIIEventEmitter } **/

var Modernizr = window.Modernizr

exports.capabilities = {
	csstransforms3d: Modernizr.csstransforms3d,
	csstransforms: Modernizr.csstransforms,
	csstransitions: Modernizr.csstransitions,
	mouseEnterLeaveSupported: _globals.core.os != "netcast"
}

var imageCache = null

exports.createAddRule = function(style) {
	if(! (style.sheet || {}).insertRule) {
		var sheet = (style.styleSheet || style.sheet)
		return function(name, rules) {
			try {
				sheet.addRule(name, rules)
			} catch(e) {
				//log("AddRule failed:", e, ", sheet:", sheet, ", name:", name, ", rules:", rules) //trace?
				log("addRule failed on rule " + name)
			}
		}
	}
	else {
		var sheet = style.sheet
		return function(name, rules) {
			try {
				sheet.insertRule(name + '{' + rules + '}', sheet.cssRules.length)
			} catch(e) {
				//log("InsertRule failed:", e, ", sheet:", sheet, ", name:", name, ", rules:", rules) //trace?
				log("insertRule failed on rule " + name)
			}
		}
	}
}

var StyleCache = function() {
	this._cache = {}
}

var StyleCachePrototype = StyleCache.prototype
StyleCachePrototype.constructor = StyleCache

StyleCachePrototype.update = function(element, name, value) {
	//log('update', element._uniqueId, name, value)
	var cache = this._cache
	var id = element._uniqueId
	var entry = cache[id]
	if (entry !== undefined) {
		entry.data[name] = value
		++entry.size
	} else {
		var data = {}
		data[name] = value
		cache[id] = {data: data, element: element, size: 1}
	}
}

StyleCachePrototype.pop = function(element) {
	var id = element._uniqueId
	var data = this._cache[id]
	if (data === undefined)
		return

	delete this._cache[id]
	return data
}

StyleCachePrototype.apply = function() {
	var cache = this._cache
	this._cache = {}

	for(var id in cache) {
		var entry = cache[id]
		entry.element.updateStyle(entry)
	}
}

var StyleClassifier = function (prefix) {
	var style = document.createElement('style')
	style.type = 'text/css'
	document.head.appendChild(style)

	this.prefix = prefix + 'C-'
	this.style = style
	this.total = 0
	this.stats = {}
	this.classes = {}
	this.classes_total = 0
	this._addRule = exports.createAddRule(style)
}

var StyleClassifierPrototype = StyleClassifier.prototype
StyleClassifierPrototype.constructor = StyleClassifier

StyleClassifierPrototype.add = function(rule) {
	this.stats[rule] = (this.stats[rule] || 0) + 1
	++this.total
}

StyleClassifierPrototype.register = function(rules) {
	var rule = rules.join(';')
	var classes = this.classes
	var cls = classes[rule]
	if (cls !== undefined)
		return cls

	cls = classes[rule] = this.prefix + this.classes_total++
	this._addRule('.' + cls, rule)
	return cls
}

StyleClassifierPrototype.classify = function(rules) {
	var total = this.total
	if (total < 10) //fixme: initial population threshold
		return ''

	rules.sort() //mind vendor prefixes!
	var classified = []
	var hot = []
	var stats = this.stats
	rules.forEach(function(rule, idx) {
		var hits = stats[rule]
		var usage = hits / total
		if (usage > 0.05) { //fixme: usage threshold
			classified.push(rule)
			hot.push(idx)
		}
	})
	if (hot.length < 2)
		return ''
	hot.forEach(function(offset, idx) {
		rules.splice(offset - idx, 1)
	})
	return this.register(classified)
}

var _modernizrCache = {}
if (_globals.core.userAgent.toLowerCase().indexOf('webkit') >= 0)
	_modernizrCache['appearance'] = '-webkit-appearance'

var getPrefixedName = function(name) {
	var prefixedName = _modernizrCache[name]
	if (prefixedName === undefined)
		_modernizrCache[name] = prefixedName = window.Modernizr.prefixedCSS(name)
	return prefixedName
}

exports.getPrefixedName = getPrefixedName

var passiveListeners = ['touchstart', 'touchmove', 'touchend', 'wheel', 'mousewheel', 'scroll']
var passiveArg = Modernizr.passiveeventlisteners ? {passive: true} : false
var mouseTouchEvents = [
	'mousedown', 'mouseup', 'click', 'dblclick', 'mousemove',
	'mouseover', 'mousewheel', 'mouseout', 'contextmenu', 'mouseenter', 'mouseleave',
	'touchstart', 'touchmove', 'touchend', 'touchcancel'
]

var registerGenericListener = function(target) {
	var storage = target.__domEventListeners
	if (storage === undefined)
		storage = target.__domEventListeners = {}

	target.onListener('',
		function(name) {
			//log('registering generic event', name)
			var callback = storage[name] = target._context.wrapNativeCallback(function() {
				target.emitWithArgs(name, arguments)
			})

			var args = [name, callback]
			if (passiveListeners.indexOf(name) >= 0)
				args.push(passiveArg)

			if (mouseTouchEvents.indexOf(name) >= 0) {
				var n = target.__mouseTouchHandlerCount = ~~target.__mouseTouchHandlerCount + 1
				if (n === 1) {
					target.style('pointer-events', 'auto')
					target.style('touch-action', 'auto')
				}
			}

			target.dom.addEventListener.apply(target.dom, args)
		},
		function(name) {
			//log('removing generic event', name)
			if (mouseTouchEvents.indexOf(name) >= 0) {
				var n = target.__mouseTouchHandlerCount = ~~target.__mouseTouchHandlerCount - 1
				if (n <= 0) {
					target.style('pointer-events', 'none')
					target.style('touch-action', 'none')
				}
			}
			target.dom.removeEventListener(name, storage[name])
		}
	)
}

var _loadedStylesheets = {}

exports.loadExternalStylesheet = function(url) {
	if (!_loadedStylesheets[url]) {
		var link = document.createElement('link')
		link.setAttribute('rel', "stylesheet")
		link.setAttribute('href', url)
		document.head.appendChild(link)
		_loadedStylesheets[url] = true
	}
}

var lastId = 0

var nodesCache = {};

/**
 * @constructor
 */

function mangleClass(name) {
	return $manifest$html5$prefix + name
}

exports.Element = function(context, tag, cls) {
	if (typeof tag === 'string') {
		if (cls === undefined)
			cls = ''

		var key = tag + '.' + cls
		if (!nodesCache[key]) {
			var el = document.createElement(tag)
			if ($manifest$html5$prefix || cls)
				el.classList.add(mangleClass(cls))
			if ($manifest$html5$prefix && cls)
				el.classList.add(mangleClass('')) //base item style, fixme: pass array here?
			nodesCache[key] = el
		}
		this.dom = nodesCache[key].cloneNode(false);
	}
	else
		this.dom = tag

	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this._transitions = {}
	this._class = ''
	this._uniqueId = (++lastId).toString(36)
	this._firstChildIndex = 0

	registerGenericListener(this)
}

var ElementPrototype = exports.Element.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
ElementPrototype.constructor = exports.Element

ElementPrototype.addClass = function(cls) {
	this.dom.classList.add(cls)
}

ElementPrototype.appendChildren = function(children) {
	if (children.length > 0) {
		var fragment = document.createDocumentFragment()
		children.forEach(function(child) {
			fragment.appendChild(child)
		})
		this.dom.appendChild(fragment)
	}
}

ElementPrototype.removeChildren = function(ui) {
	var removedChildren = []

	var dom = this.dom
	ui.children.forEach(function(child) {
		var element = child.element
		if (element !== undefined) {
			var childNode = element.dom
			if (childNode.parentNode === dom) {
				dom.removeChild(childNode)
				removedChildren.push(childNode)
			}
		}
	})
	return removedChildren
}


ElementPrototype.setHtml = function(html, component) {
	var dom = this.dom
	var children
	if (component !== undefined)
		children = this.removeChildren(component)
	else
		children = []
	dom.innerHTML = html
	this.appendChildren(children)
}

ElementPrototype.width = function() {
	this.updateStyle()
	return this.dom.clientWidth
}

ElementPrototype.height = function() {
	this.updateStyle()
	return this.dom.clientHeight
}

ElementPrototype.fullWidth = function() {
	this.updateStyle()
	return this.dom.scrollWidth
}

ElementPrototype.fullHeight = function() {
	this.updateStyle()
	return this.dom.scrollHeight
}

var overflowStyles = ['overflow', 'overflow-x', 'overflow-y']

ElementPrototype.style = function(name, style) {
	var cache = this._context._styleCache
	if (style !== undefined) {
		cache.update(this, name, style)
		if (overflowStyles.indexOf(name) >= 0) {
			cache.update(this, 'pointer-events', 'auto')
			cache.update(this, 'touch-action', 'auto')
		}
	} else if (typeof name === 'object') { //style({ }) assignment
		for(var k in name) {
			if (overflowStyles.indexOf(name) >= 0) {
				cache.update(this, 'pointer-events', 'auto')
				cache.update(this, 'touch-action', 'auto')
			}
			cache.update(this, k, name[k])
		}
	}
	else
		throw new Error('cache is write-only')
}

ElementPrototype.setAttribute = function(name, value) {
	return this.dom.setAttribute(name, value)
}

ElementPrototype.getAttribute = function(name) {
	return this.dom.getAttribute(name)
}

ElementPrototype.removeAttribute = function(name, value) {
	return this.dom.removeAttribute(name, value)
}


ElementPrototype.setProperty = function(name, value) {
	return this.dom[name] = value
}

ElementPrototype.getProperty = function(name) {
	return this.dom[name]
}

/** @const */
var cssUnits = {
	'left': 'px',
	'top': 'px',
	'width': 'px',
	'height': 'px',

	'border-radius': 'px',
	'border-width': 'px',

	'margin-left': 'px',
	'margin-top': 'px',
	'margin-right': 'px',
	'margin-bottom': 'px',

	'padding-left': 'px',
	'padding-top': 'px',
	'padding-right': 'px',
	'padding-bottom': 'px',
	'padding': 'px'
}

ElementPrototype.forceLayout = function() {
	this.updateStyle()
	return this.dom.offsetWidth | this.dom.offsetHeight
}

ElementPrototype.updateStyle = function(updated) {
	var element = this.dom
	if (!element)
		return

	if (updated === undefined) {
		updated = this._context._styleCache.pop(this)
		if (updated === undefined) //no update at all
			return
	}

	var styles = updated.data
	var elementStyle = element.style

	//fixme: classifier is currently broken, restore rules processor
	//var rules = []
	for(var name in styles) {
		var value = styles[name]
		//log('updateStyle', this._uniqueId, name, value)

		var prefixedName = getPrefixedName(name)
		var ruleName = prefixedName !== false? prefixedName: name
		if (value instanceof _globals.core.Color)
			value = value.rgba()
		else if (Array.isArray(value))
			value = value.join(',')

		if (typeof value === 'number') {
			var unit = cssUnits[name]
			if (unit !== undefined) {
				value += unit
			}
		}

		elementStyle[ruleName] = value
	}
/*
	var cache = this._context._styleClassifier
	var cls = cache? cache.classify(rules): ''
	if (cls !== this._class) {
		var classList = element.classList
		if (this._class !== '')
			classList.remove(this._class)
		this._class = cls
		if (cls !== '')
			classList.add(cls)
	}
*/
}

ElementPrototype.append = function(el) {
	this.dom.appendChild((el instanceof exports.Element)? el.dom: el)
}

ElementPrototype.prepend = function(el) {
	this.dom.insertBefore((el instanceof exports.Element)? el.dom: el, this.dom.childNodes[0])
}

ElementPrototype.discard = function() {
	_globals.core.RAIIEventEmitter.prototype.discard.apply(this)
	this.remove()
}

ElementPrototype.remove = function() {
	var dom = this.dom
	if (dom.parentNode)
		dom.parentNode.removeChild(dom)
}

ElementPrototype.focus = function() {
	var dom = this.dom
	dom.focus()
}

ElementPrototype.blur = function() {
	this.dom.blur()
}

ElementPrototype.getScrollX = function() {
	return this.dom.scrollLeft
}

ElementPrototype.getScrollY = function() {
	return this.dom.scrollTop
}

ElementPrototype.setScrollX = function(x) {
	var dom = this.dom
	setTimeout(function() { dom.scrollLeft = x }, 1)
}

ElementPrototype.setScrollY = function(y) {
	var dom = this.dom
	setTimeout(function() { dom.scrollTop = y }, 1)
}

exports.Document = function(context, dom) {
	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this.dom = dom

	registerGenericListener(this)
}

var DocumentPrototype = exports.Document.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
DocumentPrototype.constructor = exports.Document

exports.Window = function(context, dom) {
	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this.dom = dom

	registerGenericListener(this)
}

var WindowPrototype = exports.Window.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
WindowPrototype.constructor = exports.Window

WindowPrototype.width = function() {
	return this.dom.innerWidth
}

WindowPrototype.height = function() {
	return this.dom.innerHeight
}

WindowPrototype.scrollY = function() {
	return this.dom.scrollY
}

WindowPrototype.style = function() { /* ignoring style on window */ }

exports.getElement = function(ctx, tag) {
	var tags = document.getElementsByTagName(tag)
	if (tags.length != 1)
		throw new Error('no tag ' + tag + '/multiple tags')
	return new exports.Element(ctx, tags[0])
}

exports.init = function(ctx) {
	imageCache = new _globals.html5.cache.Cache(loadImage)

	ctx._styleCache = new StyleCache()
	var options = ctx.options
	var prefix = ctx._prefix
	var divId = options.id
	var tag = options.tag || 'div'

	if (prefix) {
		prefix += '-'
		log('Context: using prefix', prefix)
	}

	var doc = new _globals.html5.html.Document(ctx, document)
	ctx.document = doc

	var win = new _globals.html5.html.Window(ctx, window)
	ctx.window = win
	var w, h

	var html = exports
	var div = document.getElementById(divId)
	var topLevel = div === null
	if (!topLevel) {
		div = new html.Element(ctx, div)
		w = div.width()
		h = div.height()
		log('Context: found element by id, size: ' + w + 'x' + h)
		win.on('resize', ctx.wrapNativeCallback(function() { ctx.width = div.width(); ctx.height = div.height(); }));
	} else {
		w = win.width() + 1;
		h = win.height() + 1;
		log("Context: window size: " + w + "x" + h);
		div = html.createElement(ctx, tag)
		div.dom.id = divId
		win.on('resize', ctx.wrapNativeCallback(function() { ctx.width = win.width() + 1; ctx.height = win.height() + 1; }));
		var body = html.getElement(ctx, 'body')
		body.append(div);
	}

	if (Modernizr.canvastext) {
		ctx._textCanvas = html.createElement(ctx, 'canvas')
		ctx._textCanvas.style('width', 0)
		ctx._textCanvas.style('height', 0)
		div.append(ctx._textCanvas)
		ctx._textCanvasContext = ('getContext' in ctx._textCanvas.dom)? ctx._textCanvas.dom.getContext('2d'): null
	} else {
		ctx._textCanvasContext = null
	}

	ctx.element = div
	ctx.width = w
	ctx.height = h

	win.on('scroll', ctx.wrapNativeCallback(function() { ctx.scrollY = win.scrollY(); }));

	var onFullscreenChanged = function(e) {
		var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
		log('fullscreen change event:', state)
		ctx.fullscreen = state
	}

	new Array('webkitfullscreenchange', 'mozfullscreenchange', 'fullscreenchange', 'MSFullscreenChange').forEach(function(name) {
		div.on(name, onFullscreenChanged, true)
	})

	var translateKey = function(event) {
		var keyCode = event.which || event.keyCode
		var key = $core.keyCodes[keyCode]
		if (key === undefined && event.code) {
			key = event.code
		}
		return key
	}

	win.on('keydown', ctx.wrapNativeCallback(function(event) {
		var key = translateKey(event)
		if (key !== undefined) {
			ctx.keyDown(key)
			if (ctx.processKey(key, event))
				event.preventDefault()
		} else {
			log("unhandled keydown : [" + event.charCode + " " + event.keyCode + " " + event.which + " " + event.key + " " + event.code + " " + event.location + "]", event)
		}

	}))
	win.on('keyup', ctx.wrapNativeCallback(function(event) {
		var key = translateKey(event)
		if (key !== undefined) {
			ctx.keyUp(key)
		}
	}))
	//fixme: add html.Document instead
	win.on('orientationchange', ctx.wrapNativeCallback(function() {
		log('orientation changed event')
		ctx.system.screenWidth = window.screen.width
		ctx.system.screenHeight = window.screen.height
	}))

	ctx._styleClassifier = $manifest$cssAutoClassificator? new StyleClassifier(ctx._prefix): null; //broken beyond repair
}


//fixme: this is sorta hack, generalize that across other backends
exports.initSystem = function(system) {
	var context = system._context
	var win = context.window

	win.on('focus', context.wrapNativeCallback(function() { system.pageActive = true }))
	win.on('blur', context.wrapNativeCallback(function() { system.pageActive = false }))

	system.screenWidth = window.screen.width
	system.screenHeight = window.screen.height
}

exports.createElement = function(ctx, tag, cls) {
	return new exports.Element(ctx, tag, cls)
}

exports.initRectangle = function(rect) {
}

var failImage = function(image) {
	image._onError()
	image._context._processActions()
}

var loadImage = function(url, callback) {
	var tmp = new Image()

	tmp.onerror = function() {
		tmp.onload = null
		tmp.onerror = null
		callback(null)
	}

	tmp.onload = function() {
		tmp.onload = null
		tmp.onerror = null
		callback({ width: tmp.naturalWidth, height: tmp.naturalHeight })
	}
	tmp.src = url
}

exports.initImage = function(image) {
}

exports.loadImage = function(image, callback) {
	if (image.source.indexOf('?') < 0) {
		imageCache.get(image.source, callback)
	} else {
		loadImage(image.source, callback)
	}
}

exports.initText = function(text) {
}

var layoutTextSetStyle = function(text, style) {
	switch(text.verticalAlignment) {
		case text.AlignTop:		text._topPadding = 0; break
		case text.AlignBottom:	text._topPadding = text.height - text.paintedHeight; break
		case text.AlignVCenter:	text._topPadding = (text.height - text.paintedHeight) / 2; break
	}
	style['padding-top'] = text._topPadding
	style['height'] = text.height - text._topPadding
	text.element.style(style)
}

exports.setText = function(text, html) {
	text.element.setHtml(html, text)
}

exports.layoutText = function(text) {
	var ctx = text._context
	var textCanvasContext = ctx._textCanvasContext
	var wrap = text.wrapMode !== _globals.core.Text.NoWrap
	var element = text.element

	var dom = element.dom

	var isHtml = text.textFormat === text.Html || text.text.search(/[\<\&]/) >= 0 //dubious check

	if (!wrap && textCanvasContext !== null && !isHtml) {
		var font = text.font
		var fontSize
		if (font.pointSize)
			fontSize = Math.round(font.pointSize * 96 / 72)
		else
			fontSize = font.pixelSize
		//log('fontSize = ', fontSize)

		textCanvasContext.font = fontSize + 'px ' + font.family

		//log('font from canvas:', textCanvasContext.font, font.family, font.pixelSize, font.pointSize, fontSize)
		var metrics = textCanvasContext.measureText(text.text)
		text.paintedWidth = metrics.width
		text.paintedHeight = fontSize * font.lineHeight
		//log('layoutText', text.text, text.paintedWidth, text.paintedHeight)
		layoutTextSetStyle(text, {})
		return
	}
	var removedChildren = element.removeChildren(text)

	if (!wrap)
		text.element.style({ width: 'auto', height: 'auto', 'padding-top': 0 }) //no need to reset it to width, it's already there
	else
		text.element.style({ 'height': 'auto', 'padding-top': 0})

	//this is the source of rounding error. For instance you have 186.3px wide text, this sets width to 186px and causes wrapping
	/*
		https://github.com/pureqml/qmlcore/issues/176

		A few consequent text layouts may result in different results,
		probably as a result of some randomisation and/or rounding errors.
		This ends with +1 -1 +1 -1 infinite loop of updates.

		Ignore all updates which subtract 1 from paintedWidth/Height
	*/
	var w = element.fullWidth() + 1, h = element.fullHeight() + 1
	if (w + 1 !== text.paintedWidth)
		text.paintedWidth = w
	if (h + 1 !== text.paintedHeight)
		text.paintedHeight = h

	var style
	if (!wrap)
		//restore original width value (see 'if' above), we're not passing 'height' as it's explicitly set by layoutTextSetStyles
		style = { 'width': text.width }
	else
		style = { }

	layoutTextSetStyle(text, style)
	element.appendChildren(removedChildren)
}

exports.run = function(ctx, onloadCallback) {
	ctx.window.on('message', function(event) {
		log('Context: received message from ' + event.origin, event)
		ctx.message(event)
	})
	ctx.window.on($manifest$expectRunContextEvent ? 'runContext' : 'load', function() {
		onloadCallback()
	})
}

exports.tick = function(ctx) {
	//log('tick')
	ctx._styleCache.apply()
}

///@private
var setTransition = function(component, name, animation) {
	var html5 = exports
	var transition = {
		property: html5.getPrefixedName('transition-property'),
		delay: html5.getPrefixedName('transition-delay'),
		duration: html5.getPrefixedName('transition-duration'),
		timing: html5.getPrefixedName('transition-timing-function')
	}
	var element = component.element
	element.forceLayout() //flush styles before setting transition

	name = html5.getPrefixedName(name) || name //replace transform: <prefix>rotate hack

	var transitions = element._transitions
	var property	= transitions[transition.property] || []
	var duration	= transitions[transition.duration] || []
	var timing		= transitions[transition.timing] || []
	var delay		= transitions[transition.delay] || []

	var idx = property.indexOf(name)
	if (idx === -1) { //if property not set
		if (animation) {
			property.push(name)
			duration.push(animation.duration + 'ms')
			timing.push(animation.easing)
			delay.push(animation.delay + 'ms')
		}
	} else { //property already set, adjust the params
		if (animation && animation.active()) {
			duration[idx] = animation.duration + 'ms'
			timing[idx] = animation.easing
			delay[idx] = animation.delay + 'ms'
		} else {
			property.splice(idx, 1)
			duration.splice(idx, 1)
			timing.splice(idx, 1)
			delay.splice(idx, 1)
		}
	}

	transitions[transition.property] = property
	transitions[transition.duration] = duration
	transitions[transition.timing] = timing
	transitions[transition.delay] = delay

	//FIXME: orsay animation is not working without this shit =(
	if (component._context.system.os === 'orsay' || component._context.system.os === 'netcast') {
		transitions["transition-property"] = property
		transitions["transition-duration"] = duration
		transitions["transition-delay"] = delay
		transitions["transition-timing-function"] = timing
	}
	component.style(transitions)
	return true
}

var cssMappings = {
	width: 'width', height: 'height',
	x: 'left', y: 'top', viewX: 'left', viewY: 'top',
	opacity: 'opacity',
	border: 'border',
	radius: 'border-radius',
	rotate: 'transform',
	boxshadow: 'box-shadow',
	transform: 'transform',
	visible: 'visibility', visibleInView: 'visibility',
	background: 'background',
	color: 'color',
	backgroundImage: 'background-image',
	font: 'font'
}

///@private tries to set animation on name using css transitions, returns true on success
exports.setAnimation = function (component, name, animation) {
	if (!exports.capabilities.csstransitions || $manifest$cssDisableTransitions || (animation && !animation.cssTransition))
		return false

	var css = cssMappings[name]
	return css !== undefined? setTransition(component, css, animation): false
}

exports.requestAnimationFrame = Modernizr.prefixed('requestAnimationFrame', window)	|| function(callback) { return setTimeout(callback, 0) }
exports.cancelAnimationFrame = Modernizr.prefixed('cancelAnimationFrame', window)	|| function(id) { return clearTimeout(id) }

exports.enterFullscreenMode = function(el) {
	try {
		return Modernizr.prefixed('requestFullscreen', el.dom)()
	} catch(ex) {
		log('enterFullscreenMode failed', ex)
	}
}
exports.exitFullscreenMode = function() {
	try {
		return window.Modernizr.prefixed('exitFullscreen', document)()
	} catch(ex) {
		log('exitFullscreenMode failed', ex)
	}
}
exports.inFullscreenMode = function () { return !!window.Modernizr.prefixed('fullscreenElement', document) }

exports.ajax = function(ui, request) {
	var url = request.url
	var error = request.error,
		headers = request.headers,
		done = request.done,
		settings = request.settings

	var xhr = new XMLHttpRequest()

	if (request.responseType != undefined)
		xhr.responseType = request.responseType
	if (request.withCredentials !== undefined)
		xhr.withCredentials = request.withCredentials

	if (error)
		xhr.addEventListener('error', error)

	if (done)
		xhr.addEventListener('load', done)

	xhr.open(request.method || 'GET', url);

	for (var i in settings)
		xhr[i] = settings[i]

	for (var i in headers)
		xhr.setRequestHeader(i, headers[i])

	if (request.data)
		xhr.send(request.data)
	else
		xhr.send()
}

exports.fingerprint = function(ctx, fingerprint) {
	var html = exports
	try {
		var fcanvas = html.createElement(ctx, 'canvas')
		var w = 2000, h = 32
		fcanvas.dom.width = w
		fcanvas.dom.height = h
		var txt = "ABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789 abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ –—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвгд ∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა"
		var fctx = fcanvas.dom.getContext('2d')
		fctx.textBaseline = "top";
		fctx.font = "20px 'Arial'";
		fctx.textBaseline = "alphabetic";
		fctx.fillStyle = "#fedcba";
		fctx.fillRect(0, 0, w, h);
		fctx.fillStyle = "#12345678";
		fctx.fillText(txt, 1.5, 23.5, w);
		fctx.font = "19.5px 'Arial'";
		fctx.fillStyle = "#789abcde";
		fctx.fillText(txt, 1, 22, w);
		fingerprint.update(fcanvas.dom.toDataURL())
	} catch(ex) {
		log('canvas test failed: ' + ex)
	}
	try { fingerprint.update(window.navigator.userAgent) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.plugins) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.mimeTypes) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.language) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.platform) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.product) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.productSub) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.vendorSub) } catch (ex) { log(ex) }
	try { fingerprint.update(window.navigator.hardwareConcurrency) } catch (ex) { log(ex) }

	try { fingerprint.update(window.screen.availWidth) } catch (ex) { log(ex) }
	try { fingerprint.update(window.screen.availHeight) } catch (ex) { log(ex) }
	try { fingerprint.update(window.screen.colorDepth) } catch (ex) { log(ex) }
}
