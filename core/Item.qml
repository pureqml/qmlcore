/// base component for every visible objects.
Object {
	property int x;							///< x coordinate
	property int y;							///< y coordinate
	property int z;							///< z coordinate
	property int width;						///< width of visible area
	property int height;					///< height of visible area
	property bool clip;						///< clip all children outside rectangular area defined by x, y, width, height
	property lazy radius: Radius { }		///< round corner radius(es), allow forwarding, e.g. item.radius: 5;

	property bool focus;					///< this item can be focused
	property bool focused; ///< this item is focused among its siblings
	property bool activeFocus;				///< this item can receive events and really focused at this moment
	property Item focusedChild;				///< current focused item (this item only)

	property bool visible: true;			///< this item and its children are visible
	property bool visibleInView: true;		///< this item is visible inside view content area
	property bool recursiveVisible: false;	///< this item is actually visible on screen (all parents are visible as well)
	property real opacity: 1;				///< opacity of the item

	property lazy anchors: Anchors { }
	property lazy effects: Effects { }
	property lazy transform: Transform { }
	property bool cssTranslatePositioning;
	property bool cssNullTranslate3D;
	property bool cssDelegateAlwaysVisibleOnAcceleratedSurfaces: true;

	property const left: 	{ return [this, 0]; }
	property const top: 	{ return [this, 1]; }
	property const right:	{ return [this, 2]; }
	property const bottom:	{ return [this, 3]; }

	property const horizontalCenter:	{ return [this, 4]; }
	property const verticalCenter:		{ return [this, 5]; }

	//do not use, view internal
	signal newBoundingBox;					///< emitted when position or size changed
	signal anchorsMarginsUpdated;			///< emitted when anchors margins have been changed

	property int viewX;						///< x position in view (if any)
	property int viewY;						///< y position in view (if any)

	property int keyProcessDelay;			///< delay time between key pressed events

	constructor: {
		this._pressedHandlers = {}
		this._topPadding = 0
		this._borderXAdjust = 0
		this._borderYAdjust = 0
		this._borderWidthAdjust = 0
		this._borderHeightAdjust = 0
		if (parent) {
			if (this.element)
				throw new Error('double ctor call')

			this._createElement(this.getTag(), this.getClass())
		} //no parent == top level element, skip
	}

	///@private release any held resources, including connections, delegates, etc
	function discard() {
		$ns$core.Object.prototype.discard.apply(this)
		this.focusedChild = null
		this._pressedHandlers = {}
		if (this.element)
			this.element.discard()
	}

	/// returns tag for corresponding element
	function getTag() { return 'div' }

	/// returns tag for corresponding element
	function getClass() { return '' }

	///@private
	function registerStyle(style, tag) {
		var rules = 'position: absolute; visibility: inherit; opacity: 1.0;'
		rules += 'border-style: solid; border-width: 0px; border-radius: 0px; box-sizing: border-box; border-color: rgba(0,0,0,1);'
		rules += 'white-space: nowrap; transform: none;'
		rules += 'left: 0px; top: 0px; width: 0px; height: 0px;'
		rules += 'font-family: ' + $manifest$style$font$family + '; line-height: ' + $manifest$style$font$lineHeight + '; '
		if ($manifest$style$font$pixelSize)
			rules += 'font-size: ' + $manifest$style$font$pixelSize + 'px; '
		else if ($manifest$style$font$pointSize)
			rules += 'font-size: ' + $manifest$style$font$pointSize + 'pt; '
		style.addRule(tag, rules)
	}

	function _attachElement(element) {
		if (this.element)
			this.element.discard()

		element._item = this
		this.element = element
		var parent = this.parent
		if (parent)
			parent.element.append(element)
	}

	/// default implementation of element creation routine.
	function _createElement(tag, cls) {
		var context = this._context
		if (context === null)
			context = this

		context.registerStyle(this, tag, cls)
		this._attachElement(context.createElement(tag, cls))
	}

	/// map relative component coordinates to absolute screen ones
	function toScreen() {
		var item = this
		var x = 0, y = 0
		var w = this.width, h = this.height
		while(item) {
			x += item.x + item.viewX
			y += item.y + item.viewY
			if (item.hasOwnProperty('view')) {
				var content = item.view.content
				x += content.x
				y += content.y
			}
			item = item.parent
		}
		return [x, y, x + w, y + h, x + w / 2, y + h / 2];
	}

	///@private passes style (or styles { a:, b:, c: ... }) to underlying element
	function style(name, style) {
		var element = this.element
		if (element)
			return element.style(name, style)
		else
			log('WARNING: style skipped:', name, style)
	}

	///@private adds child, focus it if child accepts focus
	function addChild (child) {
		$ns$core.Object.prototype.addChild.apply(this, arguments)
		if (child._tryFocus())
			child._propagateFocusToParents()
	}

	///@private
	function _updateVisibility() {
		var visible = this.visible && this.visibleInView

		var updateStyle = true
		var view = this.view
		if (view !== undefined) {
			var content = view.content
			//do not update real style for individual delegate in case of hardware accelerated surfaces
			//it may trigger large invisible repaints
			//consider this as default in the future.
			if (content.cssDelegateAlwaysVisibleOnAcceleratedSurfaces && (content.cssTranslatePositioning || content.cssNullTranslate3D) && !$manifest$cssDisableTransformations)
				updateStyle = false
		}

		if (updateStyle)
			this.style('visibility', visible? 'inherit': 'hidden')

		this.recursiveVisible = visible && (this.parent !== null? this.parent.recursiveVisible: true)
	}

	///@private
	function _updateVisibilityForChild(child, value) {
		child.recursiveVisible = value && child.visible && child.visibleInView
	}

	///@private
	function _setSizeAdjust() {
		var x = this.x + this.viewX + this._borderXAdjust
		var y = this.y + this.viewY + this._borderYAdjust

		if (this.cssTranslatePositioning && !$manifest$cssDisableTransformations) {
			this.transform.translateX = x
			this.transform.translateY = y
		} else {
			this.style('left', x)
			this.style('top', y)
		}
	}

	onRecursiveVisibleChanged: {
		var children = this.children
		for(var i = 0, n = children.length; i < n; ++i) {
			var child = children[i]
			this._updateVisibilityForChild(child, value)
		}

		if (!value && this.parent)
			this.parent._tryFocus()
	}

	onFocusChanged: {
		if (this.parent)
			this.parent._tryFocus()
	}

	onVisibleChanged:		{ this._updateVisibility() }
	onVisibleInViewChanged:	{ this._updateVisibility() }

	onWidthChanged: 	{ this.style('width', value + this._borderWidthAdjust); this.newBoundingBox() }
	onHeightChanged:	{ this.style('height', value - this._topPadding + this._borderHeightAdjust); this.newBoundingBox() }

	onXChanged,
	onViewXChanged: {
		var x = this.x + this.viewX
		if (this.cssTranslatePositioning && !$manifest$cssDisableTransformations)
			this.transform.translateX = x
		else
			this.style('left', x)
		this.newBoundingBox()
	}

	onYChanged,
	onViewYChanged: {
		var y = this.y + this.viewY
		if (this.cssTranslatePositioning && !$manifest$cssDisableTransformations)
			this.transform.translateY = y
		else
			this.style('top', y)
		this.newBoundingBox()
	}

	onCssNullTranslate3DChanged: {
		if (!$manifest$cssDisableTransformations)
			this.style('transform', value ? 'translateZ(0)' : '')
	}

	onOpacityChanged:	{ if (this.element) this.style('opacity', value); }
	onZChanged:			{ this.style('z-index', value) }
	onClipChanged:		{ this.style('overflow', value? 'hidden': 'visible') }

	///@private sets current global focus to component
	function forceActiveFocus() {
		var item = this
		while(item.parent) {
			item.parent._focusChild(item);
			item = item.parent;
		}
		if (this._tryFocus())
			this._propagateFocusToParents()
	}

	///@private tries to focus children or item itself
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

	///@private propagates focus to parent, if not set there
	function _propagateFocusToParents () {
		var item = this;
		while(item.parent && (!item.parent.focusedChild || !item.parent.focusedChild.visible)) {
			item.parent._focusChild(item)
			item = item.parent
		}
	}

	///@private returns status of global focus
	function hasActiveFocus () {
		var item = this
		while(item.parent) {
			if (item.parent.focusedChild != item)
				return false

			item = item.parent
		}
		return true
	}

	/// @private focus subtree of current focused child
	function _focusTree (active) {
		this.activeFocus = active;
		if (this.focusedChild)
			this.focusedChild._focusTree(active);
	}

	///@private
	function _focusChild  (child) {
		if (child.parent !== this)
			throw new Error('invalid object passed as child')
		if (this.focusedChild === child)
			return
		if (this.focusedChild) {
			this.focusedChild._focusTree(false)
			this.focusedChild.focused = false
		}
		this.focusedChild = child
		if (this.focusedChild) {
			this.focusedChild._focusTree(this.hasActiveFocus())
			this.focusedChild.focused = true
		}
	}

	///@private
	function focusChild (child) {
		this._propagateFocusToParents()
		this._focusChild(child)
	}

	///@private
	function _updateStyle() {
		var element = this.element
		if (element)
			element.updateStyle()
	}

	///@private
	function _enqueueNextChildInFocusChain(queue, handlers) {
		this._tryFocus() //soft-restore focus for invisible components
		var focusedChild = this.focusedChild
		if (focusedChild && focusedChild.visible) {
			queue.unshift(focusedChild)
			handlers.unshift(focusedChild)
		}
	}

	///@private
	function invokeKeyHandlers(key, event, handlers, invoker) {
		for(var i = handlers.length - 1; i >= 0; --i) {
			var callback = handlers[i]
			if (invoker(callback)) {
				if ($manifest$trace$keys)
					log("key " + key + " handled in " + (performance.now() - event.timeStamp).toFixed(3) + " ms by", this, new Error().stack)
				return true;
			}
		}
		return false;
	}

	///@private
	function _processKey(event) {
		var keyCode = event.which || event.keyCode
		var key = $ns$core.keyCodes[keyCode]
		var eventTime = event.timeStamp

		if (key !== undefined) {
			if (this.keyProcessDelay) {
				if (this._lastEvent && eventTime > this._lastEvent && eventTime - this._lastEvent < this.keyProcessDelay)
					return true

				this._lastEvent = eventTime
			}

			//fixme: create invoker only if any of handlers exist
			var invoker = $ns$core.safeCall(this, [key, event], function (ex) { log("on " + key + " handler failed:", ex, ex.stack) })
			var proto_callback = this['__key__' + key]

			if (key in this._pressedHandlers)
				return this.invokeKeyHandlers(key, event, this._pressedHandlers[key], invoker)

			if (proto_callback)
				return this.invokeKeyHandlers(key, event, proto_callback, invoker)

			var proto_callback = this['__key__Key']
			if ('Key' in this._pressedHandlers)
				return this.invokeKeyHandlers(key, event, this._pressedHandlers['Key'], invoker)

			if (proto_callback)
				return this.invokeKeyHandlers(key, event, proto_callback, invoker)
		} else {
			log("unknown keycode " + keyCode + ": [" + event.charCode + " " + event.keyCode + " " + event.which + " " + event.key + " " + event.code + " " + event.location + "]")
		}
		return false
	}

	///@private registers key handler
	function onPressed (name, callback) {
		var wrapper
		if (name != 'Key')
			wrapper = function(key, event) { event.accepted = true; callback(key, event); return event.accepted }
		else
			wrapper = callback;

		if (name in this._pressedHandlers)
			this._pressedHandlers[name].push(wrapper);
		else
			this._pressedHandlers[name] = [wrapper];
	}

	/// focus this item
	function setFocus() {
		this.forceActiveFocus()
	}
}
