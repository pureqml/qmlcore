Object {
	property int x;
	property int y;
	property int z;
	property int width;
	property int height;
	property real radius;
	property bool clip;
	property real rotate;

	property bool focus;
	property bool activeFocus;
	property Item focusedChild;

	property bool visible: true;
	property bool recursiveVisible: true;
	property real opacity: 1;

	property Anchors anchors: Anchors { }
	property Effects effects: Effects { }

	property AnchorLine left: AnchorLine	{ boxIndex: 0; }
	property AnchorLine top: AnchorLine		{ boxIndex: 1; }
	property AnchorLine right: AnchorLine	{ boxIndex: 2; }
	property AnchorLine bottom: AnchorLine	{ boxIndex: 3; }

	property AnchorLine horizontalCenter:	AnchorLine	{ boxIndex: 4; }
	property AnchorLine verticalCenter:		AnchorLine	{ boxIndex: 5; }

	//do not use, view internal
	signal boxChanged;
	property int viewX;
	property int viewY;

	constructor: {
		if (this.parent) {
			if (this.element)
				throw "double ctor call"

			this.element = this.getContext().createElement('div')
			this.parent.element.append(this.element)
			var self = this
			var updateVisibility = function(value) {
				self._recursiveVisible = value
				self._updateVisibility()
			}
			updateVisibility(this.parent.recursiveVisible)
			this.parent.onChanged('recursiveVisible', updateVisibility)
		} //no parent == top level element, skip
	}

	function toScreen() {
		var item = this
		var x = 0, y = 0
		var w = this.width, h = this.height
		while(item) {
			x += item.x
			y += item.y
			if ('view' in item) {
				x += item.viewX + item.view.content.x
				y += item.viewY + item.view.content.y
			}
			item = item.parent
		}
		return [x, y, x + w, y + h, x + w / 2, y + h / 2];
	}

	function _updateAnimation(name, animation) {
		if (!window.Modernizr.csstransitions || (animation && !animation.cssTransition))
			return false

		var css = this._mapCSSAttribute(name)

		if (css !== undefined) {
			if (!animation)
				throw "resetting transition was not implemented"

			animation._target = name
			return this.setTransition(css, animation)
		} else {
			return false
		}
	}

	function setAnimation (name, animation) {
		if (!this._updateAnimation(name, animation))
			qml.core.Object.prototype.setAnimation.apply(this, arguments);
	}


	function style(name, style) {
		var element = this.element
		if (element)
			element.style(name, style)
		else
			log('WARNING: style skipped:', name, style)
	}

	function addChild (child) {
		qml.core.Object.prototype.addChild.apply(this, arguments)
		if (child._tryFocus())
			child._propagateFocusToParents()
	}

	function _mapCSSAttribute (name) {
		return {width: 'width', height: 'height', x: 'left', y: 'top', viewX: 'left', viewY: 'top', opacity: 'opacity', radius: 'border-radius', rotate: 'transform', boxshadow: 'box-shadow', translateX: 'transform', visible: 'visibility'}[name]
	}

	function _update (name, value) {
		switch(name) {
			case 'width':
				this.style('width', value)
				this.boxChanged()
				break;

			case 'height':
				this.style('height', value);
				this.boxChanged()
				break;

			case 'x':
			case 'viewX':
				var x = this.x + this.viewX
				this.style('left', x);
				this.boxChanged()
				break;

			case 'y':
			case 'viewY':
				var y = this.y + this.viewY
				this.style('top', y);
				this.boxChanged()
				break;

			case 'opacity': if (this.element) this.style('opacity', value); break;
			case 'visible': if (this.element) this.style('visibility', value? 'inherit': 'hidden'); break;
			case 'z':		this.style('z-index', value); break;
			case 'radius':	this.style('border-radius', value); break;
			case 'translateX':	this.style('transform', 'translate3d(' + value + 'px, 0px, 0px)'); break;
			case 'clip':	this.style('overflow', value? 'hidden': 'visible'); break;
			case 'rotate':	this.style('transform', 'rotate(' + value + 'deg)'); break
		}
		qml.core.Object.prototype._update.apply(this, arguments);
	}

	function _updateVisibility () {
		var visible = ('visible' in this)? this.visible: true
		this.recursiveVisible = this._recursiveVisible && this.visible
		if (!visible && this.parent)
			this.parent._tryFocus() //try repair local focus on visibility changed
	}

	function forceActiveFocus () {
		var item = this;
		while(item.parent) {
			item.parent._focusChild(item);
			item = item.parent;
		}
	}

	function _tryFocus () {
		if (!this.visible)
			return false

		if (this.focusedChild && this.focusedChild._tryFocus())
			return true

		var children = this.children
		for(var i = 0; i < children.length; ++i) {
			var child = children[i]
			if (child._tryFocus()) {
				this._focusChild(child)
				return true
			}
		}
		return this.focus
	}

	function _propagateFocusToParents () {
		var item = this;
		while(item.parent && (!item.parent.focusedChild || !item.parent.focusedChild.visible)) {
			item.parent._focusChild(item)
			item = item.parent
		}
	}
	function hasActiveFocus () {
		var item = this
		while(item.parent) {
			if (item.parent.focusedChild != item)
				return false

			item = item.parent
		}
		return true
	}

	function _focusTree (active) {
		this.activeFocus = active;
		if (this.focusedChild)
			this.focusedChild._focusTree(active);
	}

	function _focusChild  (child) {
		if (child.parent !== this)
			throw "invalid object passed as child"
		if (this.focusedChild === child)
			return
		if (this.focusedChild)
			this.focusedChild._focusTree(false)
		this.focusedChild = child
		if (this.focusedChild)
			this.focusedChild._focusTree(this.hasActiveFocus())
	}

	function focusChild (child) {
		this._propagateFocusToParents()
		this._focusChild(child)
	}

	function setTransition(name, animation) {
		if (!window.Modernizr.csstransitions)
			return false

		var transition = {
			property: window.Modernizr.prefixedCSS('transition-property'),
			delay: window.Modernizr.prefixedCSS('transition-delay'),
			duration: window.Modernizr.prefixedCSS('transition-duration'),
			timing: window.Modernizr.prefixedCSS('transition-timing-function')
		}

		name = window.Modernizr.prefixedCSS(name) || name //replace transform: <prefix>rotate hack

		var property = this.style(transition.property) || []
		var duration = this.style(transition.duration) || []
		var timing = this.style(transition.timing) || []
		var delay = this.style(transition.delay) || []

		var idx = property.indexOf(name)
		if (idx === -1) { //if property not set
			property.push(name)
			duration.push(animation.duration + 'ms')
			timing.push(animation.easing)
			delay.push('0s')
		} else { //property already set, adjust the params
			duration[idx] = animation.duration + 'ms'
			timing[idx] = animation.easing
		}

		var style = {}
		style[transition.property] = property
		style[transition.duration] = duration
		style[transition.timing] = timing
		style[transition.delay] = delay
		this.style(style)
		return true
	}

	function _updateStyle() {
		var element = this.element
		if (element)
			element._updateStyle()
	}

	function _processKey(event) {
		this._tryFocus() //soft-restore focus for invisible components
		if (this.focusedChild && this.focusedChild.visible) {
			if (this.focusedChild._processKey(event))
				return true
		}

		var key = qml.core.keyCodes[event.which];
		if (key) {
			if (key in this._pressedHandlers) {
				var handlers = this._pressedHandlers[key]
				var invoker = qml.core.safeCall([key, event], function(ex) { log("on " + key + " handler failed:", ex, ex.stack) })
				for(var i = handlers.length - 1; i >= 0; --i) {
					var callback = handlers[i]
					if (invoker(callback)) {
						if (exports.trace.key)
							log("key", key, "handled by", this, new Error().stack)
						return true;
					}
				}
			}

			if ('Key' in this._pressedHandlers) {
				var handlers = this._pressedHandlers['Key']
				var invoker = qml.core.safeCall([key, event], function (ex) { log("onKeyPressed handler failed:", ex, ex.stack) })
				for(var i = handlers.length - 1; i >= 0; --i) {
					var callback = handlers[i]
					if (invoker(callback)) {
						if (exports.trace.key)
							log("key", key, "handled by", this, new Error().stack)
						return true
					}
				}
			}
		}
		else {
			log("unknown key", event.which);
		}
		return false;
	}



	onVisibleChanged: { this._updateVisibility() }
	setFocus: { this.forceActiveFocus(); }
}
