/*** @used { core.RAIIEventEmitter } **/

exports.createAddRule = function(style) {
	if(! (style.sheet || {}).insertRule) {
		var sheet = (style.styleSheet || style.sheet)
		return function(name, rules) { sheet.addRule(name, rules) }
	}
	else {
		var sheet = style.sheet
		return function(name, rules) { sheet.insertRule(name + '{' + rules + '}', sheet.cssRules.length) }
	}
}

var StyleCache = function (prefix) {
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
var StyleCachePrototype = StyleCache.prototype

StyleCachePrototype.constructor = StyleCache

StyleCachePrototype.add = function(rule) {
	this.stats[rule] = (this.stats[rule] || 0) + 1
	++this.total
}

StyleCachePrototype.register = function(rules) {
	var rule = rules.join(';')
	var classes = this.classes
	var cls = classes[rule]
	if (cls !== undefined)
		return cls

	var cls = classes[rule] = this.prefix + this.classes_total++
	this._addRule('.' + cls, rule)
	return cls
}

StyleCachePrototype.classify = function(rules) {
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
if (navigator.userAgent.toLowerCase().indexOf('webkit') >= 0)
	_modernizrCache['appearance'] = '-webkit-appearance'

var getPrefixedName = function(name) {
	var prefixedName = _modernizrCache[name]
	if (prefixedName === undefined)
		_modernizrCache[name] = prefixedName = window.Modernizr.prefixedCSS(name)
	return prefixedName
}

exports.getPrefixedName = getPrefixedName

var registerGenericListener = function(target) {
	var prefix = '_domEventHandler_'
	target.onListener('',
		function(name) {
			//log('registering generic event', name)
			var pname = prefix + name
			var callback = target[pname] = function() {
				COPY_ARGS(args, 0)
				target.emitWithArgs(name, args)
			}
			target.dom.addEventListener(name, callback)
		},
		function(name) {
			//log('removing generic event', name)
			var pname = prefix + name
			target.dom.removeEventListener(name, target[pname])
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

exports.autoClassify = false

/**
 * @constructor
 */

exports.Element = function(context, tag) {
	if (typeof tag === 'string')
		this.dom = document.createElement(tag)
	else
		this.dom = tag

	if (exports.autoClassify) {
		if (!context._styleCache)
			context._styleCache = new StyleCache(context._prefix)
	} else
		context._styleCache = null

	_globals.core.RAIIEventEmitter.apply(this)
	this._context = context
	this._fragment = []
	this._styles = {}
	this._class = ''

	registerGenericListener(this)
}

var ElementPrototype = exports.Element.prototype = Object.create(_globals.core.RAIIEventEmitter.prototype)
ElementPrototype.constructor = exports.Element

ElementPrototype.addClass = function(cls) {
	this.dom.classList.add(cls)
}

ElementPrototype.setHtml = function(html) {
	var dom = this.dom
	this._fragment.forEach(function(node) { dom.removeChild(node) })
	this._fragment = []

	if (html === '')
		return

	var fragment = document.createDocumentFragment()
	var temp = document.createElement('div')

	temp.innerHTML = html
	while (temp.firstChild) {
		this._fragment.push(temp.firstChild)
		fragment.appendChild(temp.firstChild)
	}
	dom.appendChild(fragment)
	return dom.children
}

ElementPrototype.width = function() {
	return this.dom.clientWidth
}

ElementPrototype.height = function() {
	return this.dom.clientHeight
}

ElementPrototype.fullWidth = function() {
	return this.dom.scrollWidth
}

ElementPrototype.fullHeight = function() {
	return this.dom.scrollHeight
}

ElementPrototype.style = function(name, style) {
	if (style !== undefined) {
		if (style !== '') //fixme: replace it with explicit 'undefined' syntax
			this._styles[name] = style
		else
			delete this._styles[name]
		this.updateStyle()
	} else if (name instanceof Object) { //style({ }) assignment
		for(var k in name) {
			var value = name[k]
			if (value !== '') //fixme: replace it with explicit 'undefined' syntax
				this._styles[k] = value
			else
				delete this._styles[k]
		}
		this.updateStyle()
	}
	else
		return this._styles[name]
}

ElementPrototype.setAttribute = function(name, value) {
	this.dom.setAttribute(name, value)
}

ElementPrototype.updateStyle = function() {
	var element = this.dom
	if (!element)
		return

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
		'padding-bottom': 'px'
	}

	var cache = this._context._styleCache
	var rules = []
	for(var name in this._styles) {
		var value = this._styles[name]

		var prefixedName = getPrefixedName(name)
		var ruleName = prefixedName !== false? prefixedName: name
		if (Array.isArray(value))
			value = value.join(',')

		var unit = (typeof value === 'number')? cssUnits[name] || '': ''
		value += unit

		//var prefixedValue = window.Modernizr.prefixedCSSValue(name, value)
		//var prefixedValue = value
		var rule = ruleName + ':' + value //+ (prefixedValue !== false? prefixedValue: value)

		if (cache)
			cache.add(rule)

		rules.push(rule)
	}
	var cls = cache? cache.classify(rules): ''
	if (cls !== this._class) {
		var classList = element.classList
		if (this._class !== '')
			classList.remove(this._class)
		this._class = cls
		if (cls !== '')
			classList.add(cls)
	}
	this.dom.setAttribute('style', rules.join(';'))
}

ElementPrototype.append = function(el) {
	this.dom.appendChild((el instanceof exports.Element)? el.dom: el)
}

ElementPrototype.discard = function() {
	_globals.core.RAIIEventEmitter.prototype.discard.apply(this)
	this.remove()
}

ElementPrototype.remove = function() {
	var dom = this.dom
	dom.parentNode.removeChild(dom)
}

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

exports.getElement = function(tag) {
	var tags = document.getElementsByTagName(tag)
	if (tags.length != 1)
		throw new Error('no tag ' + tag + '/multiple tags')
	return new exports.Element(this, tags[0])
}

exports.init = function(ctx) {
	var options = ctx.options
	var prefix = ctx._prefix

	var divId = options.id

	if (prefix) {
		prefix += '-'
		log('Context: using prefix', prefix)
	}

	var win = new _globals.html5.html.Window(this, window)
	ctx.window = win
	var w, h

	var html = exports
	var div = document.getElementById(divId)
	var topLevel = div === null
	if (!topLevel) {
		div = new html.Element(this, div)
		w = div.width()
		h = div.height()
		log('Context: found element by id, size: ' + w + 'x' + h)
		win.on('resize', function() { ctx.width = div.width(); ctx.height = div.height(); });
	} else {
		w = win.width();
		h = win.height();
		log("Context: window size: " + w + "x" + h);
		div = ctx.createElement('div')
		div.dom.id = divId //html specific
		win.on('resize', function() { ctx.width = win.width(); ctx.height = win.height(); });
		var body = html.getElement('body')
		body.append(div);
	}

	ctx.element = div
	ctx.width = w
	ctx.height = h
	ctx.style('visibility', 'hidden')

	win.on('scroll', function(event) { ctx.scrollY = win.scrollY(); });

	win.on('load', function() { ctx._run() })

	var onFullscreenChanged = function(e) {
		var state = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen;
		ctx.fullscreen = state
	}
	'webkitfullscreenchange mozfullscreenchange fullscreenchange'.split(' ').forEach(function(name) {
		div.on(name, onFullscreenChanged)
	})

	win.on('keydown', function(event) { if (ctx._processKey(event)) event.preventDefault(); } ) //fixme: add html.Document instead

	var system = ctx.system
	//fixme: port to event listener?
	window.onfocus = function() { system.pageActive = true }
	window.onblur = function() { system.pageActive = false }

	ctx.screenWidth = window.screen.width
	ctx.screenHeight = window.screen.height
}

exports.createElement = function(ctx, tag) {
	return new exports.Element(ctx, tag)
}

exports.initImage = function(image) {
	var tmp = new Image()
	image._image = tmp
	image._image.onerror = image._onError.bind(image)

	image._image.onload = function() {
		var natW = tmp.naturalWidth, natH = tmp.naturalHeight
		image.paintedWidth = tmp.naturalWidth
		image.paintedHeight = tmp.naturalHeight

		var style = {'background-image': 'url(' + image.source + ')'}
		switch(image.fillMode) {
			case image.Stretch:
				style['background-repeat'] = 'no-repeat'
				style['background-size'] = '100% 100%'
				break;
			case image.TileVertically:
				style['background-repeat'] = 'repeat-y'
				style['background-size'] = '100%'
				break;
			case image.TileHorizontally:
				style['background-repeat'] = 'repeat-x'
				style['background-size'] = natW + 'px 100%'
				break;
			case image.Tile:
				style['background-repeat'] = 'repeat-y repeat-x'
				style['background-size'] = 'auto'
				break;
			case image.PreserveAspectCrop:
				style['background-repeat'] = 'no-repeat'
				style['background-position'] = 'center'
				style['background-size'] = 'cover'
				break;
			case image.Pad:
				style['background-repeat'] = 'no-repeat'
				style['background-position'] = '0% 0%'
				style['background-size'] = 'auto'
				break;
			case image.PreserveAspectFit:
				style['background-repeat'] = 'no-repeat'
				style['background-position'] = 'center'
				style['background-size'] = 'contain'
				var w = image.width, h = image.height
				var srcRatio = natW / natH, targetRatio = w / h
				if (srcRatio > targetRatio) { // img width aligned with target width
					image.paintedWidth = w;
					image.paintedHeight = w / srcRatio;
				} else {
					image.paintedHeight = h;
					image.paintedWidth = h * srcRatio;
				}
				break;
		}
		image.style(style)

		if (!image.width)
			image.width = image.paintedWidth
		if (!image.height)
			image.height = image.paintedHeight
		image.status = Image.Ready
	}
}

exports.loadImage = function(image) {
	image._image.src = image.source
}

exports.initText = function(text) {
	text.element.addClass(text._context.getClass('text'))
}

exports.layoutText = function(text) {
	var wrap = text.wrapMode != Text.NoWrap
	if (!wrap)
		text.style({ width: 'auto', height: 'auto', 'padding-top': 0 }) //no need to reset it to width, it's already there
	else
		text.style({ 'height': 'auto', 'padding-top': 0})

	text.paintedWidth = text.element.fullWidth()
	text.paintedHeight = text.element.fullHeight()

	var style
	if (!wrap)
		style = { width: text.width, height: text.height }
	else
		style = {'height': text.height }

	switch(text.verticalAlignment) {
		case text.AlignTop:		text._topPadding = 0; break
		case text.AlignBottom:	text._topPadding = text.height - text.paintedHeight; break
		case text.AlignVCenter:	text._topPadding = (text.height - text.paintedHeight) / 2; break
	}
	style['padding-top'] = text._topPadding
	style['height'] = text.height - text._topPadding
	text.style(style)
}

exports.run = function() { }

var Modernizr = window.Modernizr

exports.capabilities = {
	csstransforms3d: Modernizr.csstransforms3d,
	csstransforms: Modernizr.csstransforms,
	csstransitions: Modernizr.csstransitions
}

exports.requestAnimationFrame = Modernizr.prefixed('requestAnimationFrame', window)	|| function(callback) { return setTimeout(callback, 0) }
exports.cancelAnimationFrame = Modernizr.prefixed('cancelAnimationFrame', window)	|| function(id) { return clearTimeout(id) }

exports.enterFullscreenMode = function(el) { return Modernizr.prefixed('requestFullscreen', el.dom)() }
exports.exitFullscreenMode = function() { return window.Modernizr.prefixed('exitFullscreen', document)() }
exports.inFullscreenMode = function () { return !!window.Modernizr.prefixed('fullscreenElement', document) }
