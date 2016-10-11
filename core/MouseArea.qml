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
		if (value) {
			var touchStart = function(event) { this.touchStart(event) }.bind(this)
			var touchEnd = function(event) { this.touchEnd(event) }.bind(this)
			var touchMove = (function(event) { this.touchMove(event) }).bind(this)

			if ('ontouchstart' in window)
				this.element.on('touchstart', touchStart)
			if ('ontouchend' in window)
				this.element.on('touchend', touchEnd)
			if ('ontouchmove' in window)
				this.element.on('touchmove', touchMove)
		} else {
			this.element.removeListener('touchstart', touchStart)
			this.element.removeListener('touchend', touchEnd)
			this.element.removeListener('touchmove', touchMove)
		}
	}

	onTouchEnabledChanged: {
		this._bindTouch(value)
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}

	function _bindClick(value) {
		var clicked = this.clicked.bind(this)
		if (value) {
			this.element.on('click', clicked)
		} else {
			this.element.removeListener('click', clicked)
		}
	}

	onClickableChanged: {
		this._bindClick(value)
	}

	function _bindWheel(value) {
		var onWheel = function(event) { this.wheelEvent(event.originalEvent.wheelDelta / 120) }.bind(this)

		if (value)
			this.element.on('mousewheel', onWheel)
		else
			this.element.removeListener('mousewheel', onWheel)
	}

	onWheelEnabledChanged: {
		this._bindWheel(value)
	}

	function _bindPressable(value) {
		var onDown = function() { this.pressed = true }.bind(this)
		var onUp = function() { this.pressed = false }.bind(this)

		if (value) {
			this.element.on('mousedown', onDown)
			this.element.on('mouseup', onUp)
		} else {
			this.element.removeListener('mousedown', onDown)
			this.element.removeListener('mouseup', onUp)
		}
	}

	onPressableChanged: {
		this._bindPressable(value)
	}

	function _bindHover(value) {
		var onEnter = function() { this.hover = true }.bind(this)
		var onLeave = function() { this.hover = false }.bind(this)
		var onMove = function(event) { if (this.updatePosition(event)) event.preventDefault() }.bind(this)
		if (value) {
			this.element.on('mouseenter', onEnter)
			this.element.on('mouseleave', onLeave)
			this.element.on('mousemove', onMove)
		} else {
			this.element.removeListener('mouseenter', onEnter)
			this.element.removeListener('mouseleave', onLeave)
			this.element.removeListener('mousemove', onMove)
		}
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

	updatePosition(event): {
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
