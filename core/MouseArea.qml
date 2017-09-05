///item provide mouse and touch events API
Item {
	signal entered;				///< emitted when mouse entered the item's area
	signal exited;				///< emitted when mouse leaved the item's area
	signal clicked;				///< emitted on mouse click
	signal canceled;			///< emitted when mouse leaved the item's area while mouse button was pressed
	signal wheelEvent;			///< emitted when mouse wheel scrolling
	signal verticalSwiped;		///< emitted on vertical swipe
	signal horizontalSwiped;	///< emitted on horizontal swipe
	signal mouseMove;			///< emitted on mouse moved inside the item's area
	signal touchEnd;			///< emitted on touch event end
	signal touchMove;			///< emitted on mouse move while touching
	signal touchStart;			///< emitted on touch event start

	property real mouseX;				///< mouse x coordinate
	property real mouseY;				///< mouse y coordinate
	property string cursor;				///< mouse cursor inside the item's area
	property bool pressed;				///< mouse pressed flag
	property bool containsMouse;		///< mouse inside item's area flag
	property bool clickable: true;		///< enable mouse click event handling flag
	property bool pressable: true;		///< enable mouse click event handling flag
	property bool touchEnabled: true;	///< enable touch events handling flag
	property bool hoverEnabled: true;	///< enable mouse hover event handling flag
	property bool wheelEnabled: true;	///< enable mouse click event handling flag
	property alias hover: containsMouse;	///< containsMouse property alias
	property alias hoverable: hoverEnabled;	///< hoverEnabled property alias

	/// @private
	onCursorChanged: { this.style('cursor', value) }

	/// @private
	function _bindTouch(value) {
		if (value && !this._touchBinder) {
			this._touchBinder = new _globals.core.EventBinder(this.element)

			var touchStart = function(event) { this.touchStart(event) }.bind(this)
			var touchEnd = function(event) { this.touchEnd(event) }.bind(this)
			var touchMove = (function(event) { this.touchMove(event) }).bind(this)

			this._touchBinder.on('touchstart', touchStart)
			this._touchBinder.on('touchend', touchEnd)
			this._touchBinder.on('touchmove', touchMove)
		}
		if (this._touchBinder)
			this._touchBinder.enable(value)
	}

	/// @private
	onTouchEnabledChanged: {
		this._bindTouch(value)
	}

	/// @private
	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}

	/// @private
	function _bindClick(value) {
		if (value && !this._clickBinder) {
			this._clickBinder = new _globals.core.EventBinder(this.element)
			this._clickBinder.on('click', this.clicked.bind(this))
		}
		if (this._clickBinder)
			this._clickBinder.enable(value)
	}

	/// @private
	onClickableChanged: {
		this._bindClick(value)
	}

	/// @private
	function _bindWheel(value) {
		if (value && !this._wheelBinder) {
			this._clickBinder = new _globals.core.EventBinder(this.element)
			this._clickBinder.on('mousewheel', function(event) { this.wheelEvent(event.wheelDelta / 120) }.bind(this))
		}
		if (this._clickBinder)
			this._clickBinder.enable(value)
	}

	/// @private
	onWheelEnabledChanged: {
		this._bindWheel(value)
	}

	/// @private
	function _bindPressable(value) {
		if (value && !this._pressableBinder) {
			this._pressableBinder = new _globals.core.EventBinder(this.element)
			this._pressableBinder.on('mousedown', function()	{ this.pressed = true }.bind(this))
			this._pressableBinder.on('mouseup', function()		{ this.pressed = false }.bind(this))
		}
		if (this._pressableBinder)
			this._pressableBinder.enable(value)
	}

	/// @private
	onPressableChanged: {
		this._bindPressable(value)
	}

	/// @private
	function _bindHover(value) {
		if (value && !this._hoverBinder) {
			this._hoverBinder = new _globals.core.EventBinder(this.element)
			this._hoverBinder.on('mouseenter', function() { this.hover = true }.bind(this))
			this._hoverBinder.on('mouseleave', function() { this.hover = false }.bind(this))
			this._hoverBinder.on('mousemove', function(event) { if (this.updatePosition(event)) event.preventDefault() }.bind(this))
		}
		if (this._hoverBinder)
			this._hoverBinder.enable(value)
	}

	/// @private
	onHoverEnabledChanged: {
		this._bindHover(value)
	}

	/// @private
	onContainsMouseChanged: {
		if (this.containsMouse) {
			this.entered()
		} else if (!this.containsMouse && this.pressable && this.pressed) {
			this.pressed = false
			this.canceled()
		} else {
			this.exited()
		}
	}

	/// @private
	updatePosition(event): {
		if (!this.recursiveVisible)
			return false

		var x = event.offsetX
		var y = event.offsetY

		if (x >= 0 && y >= 0 && x < this.width && y < this.height) {
			this.mouseX = x
			this.mouseY = y
			this.mouseMove()
			return true
		}
		else
			return false
	}

	/// @private
	onTouchStart(event): {
		var box = this.toScreen()
		var e = event.touches[0]
		var x = e.pageX - box[0]
		var y = e.pageY - box[1]
		this._startX = x
		this._startY = y
		this._orientation = null;
		this._startTarget = event.target;
	}

	/// @private
	onTouchMove(event): {
		var box = this.toScreen()
		var e = event.touches[0]
		var x = e.pageX - box[0]
		var y = e.pageY - box[1]
		var dx = x - this._startX
		var dy = y - this._startY
		var adx = Math.abs(dx)
		var ady = Math.abs(dy)
		var motion = adx > 5 || ady > 5
		if (!motion)
			return

		if (!this._orientation)
			this._orientation = adx > ady ? 'horizontal' : 'vertical'

		// for delegated events, the target may change over time
		// this ensures we notify the right target and simulates the mouseleave behavior
		while (event.target && event.target !== this._startTarget)
			event.target = event.target.parentNode;
		if (event.target !== this._startTarget) {
			event.target = this._startTarget;
			return;
		}

		if (this._orientation == 'horizontal')
			this.horizontalSwiped(event)
		else
			this.verticalSwiped(event)
	}

	/// @private
	constructor: {
		this._bindClick(this.clickable)
		this._bindWheel(this.wheelEnabled)
		this._bindPressable(this.pressable)
		this._bindHover(this.hoverEnabled)
		this._bindTouch(this.touchEnabled)
	}
}
