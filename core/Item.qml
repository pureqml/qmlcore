/// base component for every visible objects.
Object {
	property int x;							///< x coordinate
	property int y;							///< y coordinate
	property int z;							///< z coordinate
	property int width;						///< width of visible area
	property int height;					///< height of visible area
	property bool clip;						///< clip all children outside rectangular area defined by x, y, width, height
	property real radius;					///< round corner radius

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

	property lazy left:		AnchorLine	{ boxIndex: 0; }
	property lazy top:		AnchorLine	{ boxIndex: 1; }
	property lazy right:	AnchorLine	{ boxIndex: 2; }
	property lazy bottom:	AnchorLine	{ boxIndex: 3; }

	property lazy horizontalCenter:	AnchorLine	{ boxIndex: 4; }
	property lazy verticalCenter:	AnchorLine	{ boxIndex: 5; }

	//do not use, view internal
	signal boxChanged;						///< emitted when position or size changed
	property int viewX;						///< x position in view (if any)
	property int viewY;						///< y position in view (if any)

	///@private
	constructor: {
		this._topPadding = 0
		if (parent) {
			if (this.element)
				throw new Error('double ctor call')

			this._createElement(this.getTag(), this.getClass())
		} //no parent == top level element, skip
	}

	///@private
	function discard() {
		_globals.core.Object.prototype.discard.apply(this)
		this.focusedChild = null
		if (this.element)
			this.element.discard()
	}

	/// returns tag for corresponding element
	function getTag() { return 'div' }

	/// returns tag for corresponding element
	function getClass() { return '' }

	///@private
	function registerStyle(style, tag, cls) {
		style.addRule(tag, cls, 'position: absolute; border-style: solid; border-width: 0px; white-space: nowrap; border-radius: 0px; opacity: 1.0; transform: none; left: 0px; top: 0px; width: 0px; height: 0px;')
	}

	/// default implementation of element creation routine.
	function _createElement(tag, cls) {
		var context = this._context
		if (context === null)
			context = this

		this.element = context.createElement(tag, cls)
		this.element._item = this
		context.registerStyle(this, tag, cls)
		this.parent.element.append(this.element)
	}

	/// map relative component coordinates to absolute screen ones
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
		_globals.core.Object.prototype.addChild.apply(this, arguments)
		if (child._tryFocus())
			child._propagateFocusToParents()
	}

	///@private
	function _updateVisibility() {
		var visible = this.visible && this.visibleInView

		if (this.element) {
			this.style('display', visible? '': 'none')
		}

		this.recursiveVisible = visible && (this.parent !== null? this.parent.recursiveVisible: true)
	}

	function _updateVisibilityForChild(child, value) {
		child.recursiveVisible = value && child.visible && child.visibleInView
	}

	onRecursiveVisibleChanged: {
		this.children.forEach(function(child) {
			child.recursiveVisible = value && child.visible && child.visibleInView
		})

		if (!value)
			this.parent._tryFocus()
	}

	onVisibleChanged:		{ this._updateVisibility() }
	onVisibleInViewChanged:	{ this._updateVisibility() }

	onWidthChanged: 	{ this.style('width', value); this.boxChanged() }
	onHeightChanged:	{ this.style('height', value - this._topPadding); this.boxChanged() }

	onXChanged,
	onViewXChanged: {
		var x = this.x + this.viewX
		if (this.cssTranslatePositioning)
			this.style('transform', 'translateX(' + x + 'px)')
		else
			this.style('left', x)
		this.boxChanged()
	}

	onYChanged,
	onViewYChanged: {
		var y = this.y + this.viewY
		if (this.cssTranslatePositioning)
			this.style('transform', 'translateY(' + y + 'px)')
		else
			this.style('top', y)
		this.boxChanged()
	}

	onOpacityChanged:	{ if (this.element) this.style('opacity', value); }
	onZChanged:			{ this.style('z-index', value) }
	onRadiusChanged:	{ this.style('border-radius', value) }
	onClipChanged:		{ this.style('overflow', value? 'hidden': 'visible') }

	///@private sets current global focus to component
	function forceActiveFocus() {
		var item = this;
		while(item.parent) {
			item.parent._focusChild(item);
			item = item.parent;
		}
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
	function invokeKeyHandlers(key, handlers, invoker) {
		for(var i = handlers.length - 1; i >= 0; --i) {
			var callback = handlers[i]
			if (invoker(callback)) {
				if (_globals.core.trace.key)
					log("key", key, "handled by", this, new Error().stack)
				return true;
			}
		}
		return false;
	}

	///@private
	function _processKey(event) {
		var key = _globals.core.keyCodes[event.which || event.keyCode];
		var ctx = this._context
		var eventTime = event.timeStamp

		if (key) {
			if (eventTime !== ctx._lastEvent && eventTime - ctx.keyProcessDelay < ctx._lastEvent)
				return true

			if (ctx._lastEvent !== eventTime)
				ctx._lastEvent = eventTime

			//fixme: create invoker only if any of handlers exist
			var invoker = _globals.core.safeCall(this, [key, event], function (ex) { log("on " + key + " handler failed:", ex, ex.stack) })
			var proto_callback = this['__key__' + key]

			if (key in this._pressedHandlers)
				return this.invokeKeyHandlers(key, this._pressedHandlers[key], invoker)

			if (proto_callback)
				return this.invokeKeyHandlers(key, proto_callback, invoker)

			var proto_callback = this['__key__Key']
			if ('Key' in this._pressedHandlers)
				return this.invokeKeyHandlers(key, this._pressedHandlers['Key'], invoker)

			if (proto_callback)
				return this.invokeKeyHandlers(key, proto_callback, invoker)
		} else {
			log("unknown key", event.which);
		}
		return false;
	}

	/// focus this item
	setFocus:		{ this.forceActiveFocus() }
}
