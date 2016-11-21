Item {
	signal entered;
	signal exited;
	signal clicked;
	signal canceled;
	signal wheelEvent;
	signal verticalSwiped;
	signal horizontalSwiped;
	signal mouseMove;
	signal touchEnd;
	signal touchMove;
	signal touchStart;

	property real mouseX;
	property real mouseY;
	property string cursor;
	property bool pressed;
	property bool containsMouse;
	property bool clickable: true;
	property bool pressable: true;
	property bool touchEnabled: true;
	property bool hoverEnabled: true;
	property bool wheelEnabled: true;

	property alias hover: containsMouse;
	property alias hoverable: hoverEnabled;

	onCursorChanged: { this.style('cursor', value) }

	function _bindTouch(value) {
		if (value && !this._touchBinder) {
			this._touchBinder = new _globals.core.EventBinder(this.element)

			var touchStart = function(event) { this.touchStart(event) }.bind(this)
			var touchEnd = function(event) { this.touchEnd(event) }.bind(this)
			var touchMove = (function(event) { this.touchMove(event) }).bind(this)

			if ('ontouchstart' in window)
				this._touchBinder.on('touchstart', touchStart)
			if ('ontouchend' in window)
				this._touchBinder.on('touchend', touchEnd)
			if ('ontouchmove' in window)
				this._touchBinder.on('touchmove', touchMove)
		}
		if (this._touchBinder)
			this._touchBinder.enable(value)
	}

	onTouchEnabledChanged: {
		this._bindTouch(value)
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}

	function _bindClick(value) {
		if (value && !this._clickBinder) {
			this._clickBinder = new _globals.core.EventBinder(this.element)
			this._clickBinder.on('click', this.clicked.bind(this))
		}
		if (this._clickBinder)
			this._clickBinder.enable(value)
	}

	onClickableChanged: {
		this._bindClick(value)
	}

	function _bindWheel(value) {
		if (value && !this._wheelBinder) {
			this._clickBinder = new _globals.core.EventBinder(this.element)
			this._clickBinder.on('mousewheel', function(event) { this.wheelEvent(event.wheelDelta / 120) }.bind(this))
		}
		if (this._clickBinder)
			this._clickBinder.enable(value)
	}

	onWheelEnabledChanged: {
		this._bindWheel(value)
	}

	function _bindPressable(value) {
		if (value && !this._pressableBinder) {
			this._pressableBinder = new _globals.core.EventBinder(this.element)
			this._pressableBinder.on('mousedown', function()	{ this.pressed = true }.bind(this))
			this._pressableBinder.on('mouseup', function()		{ this.pressed = false }.bind(this))
		}
		if (this._pressableBinder)
			this._pressableBinder.enable(value)
	}

	onPressableChanged: {
		this._bindPressable(value)
	}

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


	onHoverEnabledChanged: {
		this._bindHover(value)
	}

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

	function updatePosition(event) {
		if (!this.recursiveVisible)
			return false

		var box = this.toScreen()
		var x = event.clientX - box[0]
		var y = event.clientY - box[1]

		if (x >= 0 && y >= 0 && x < this.width && y < this.height) {
			this.mouseX = x
			this.mouseY = y
			this.mouseMove()
			return true
		}
		else
			return false
	}

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

	onCompleted: {
		if (this.clickable)
			this._bindClick(true)
		if (this.wheelEnabled)
			this._bindWheel(true)

		if (this.pressable)
			this._bindPressable(true)

		if (this.hoverEnabled)
			this._bindHover(true)

		if (this.touchEnabled)
			this._bindTouch(true)
	}
}
