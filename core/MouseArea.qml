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
		log('UPDATE TOUCH', value)
		if (value) {
			if (!this._touchStart)
				this._touchStart = (function(event) { log('TS'); this.touchStart(event) }).bind(this)
			if (!this._touchEnd)
				this._touchEnd = (function(event) { this.touchEnd(event) }).bind(this)
			if (!this._touchMove)
				this._touchMove = (function(event) { this.touchMove(event) }).bind(this)

			if ('ontouchstart' in window)
				this.element.on('touchstart', this._touchStart)
			if ('ontouchend' in window)
				this.element.on('touchend', this._touchEnd)
			if ('ontouchmove' in window)
				this.element.on('touchmove', this._touchMove)
		} else {
			this.element.removeListener('touchstart', this._touchStart)
			this.element.removeListener('touchend', this._touchEnd)
			this.element.removeListener('touchmove', this._touchMove)
		}
	}

	onTouchEnabledChanged: {
		this._bindTouch(value)
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}

	function _bindClick() {
		if (!this._clicked)
			this._clicked = this.clicked.bind(this)
		this.element.on('click', this._clicked)
	}

	onClickableChanged: {
		if (value)
			this._bindClick()
		else
			this.element.removeListener('click', this._clicked)
	}

	onWheelEnabledChanged: {
		var self = this
		if (value)
			this.element.on('mousewheel', function(event) { self.wheelEvent(event.originalEvent.wheelDelta / 120) })
		else
			this.element.unbind('mousewheel')
	}

	onPressableChanged: {
		var self = this
		var onDown = function() { self.pressed = true }
		var onUp = function() { self.pressed = false }
		if (value) {
			this.element.on('mousedown', onDown)
			this.element.on('mouseup', onUp)
		} else {
			this.element.removeListener('mousedown', onDown)
			this.element.removeListener('mouseup', onUp)
		}
	}

	function _bindHover(value) {
		var self = this
		var onEnter = function() { self.hover = true }
		var onLeave = function() { self.hover = false }
		var onMove = function(event) { if (self.updatePosition(event)) event.preventDefault() }
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
		var x = event.pageX - box[0]
		var y = event.pageY - box[1]

		if (x >= 0 && y >= 0 && x < this.width && y < this.height) {
			this.mouseX = x
			this.mouseY = y
			return true
		}
		else
			return false
	}

	onTouchStart(event): {
		var box = this.toScreen()
		var e = event.originalEvent.touches[0]
		var x = e.pageX - box[0]
		var y = e.pageY - box[1]
		this._startX = x
		this._startY = y
		this._orientation = null;
		this._startTarget = event.target;
	}

	onTouchMove(event): {
		var box = this.toScreen()
		var e = event.originalEvent.touches[0]
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
			stopHandler.call(this, $.Event(stopEvent + '.' + namespace, event));
			return;
		}

		if (this._orientation == 'horizontal')
			this.horizontalSwiped(event)
		else
			this.verticalSwiped(event)
	}

	onCompleted: {
		var self = this

		if (this.clickable)
			this._bindClick()
		if (this.wheelEnabled)
			this.element.on('mousewheel', function(event) { self.wheelEvent(event.originalEvent.wheelDelta / 120) })
		if (this.pressable) {
			this.element.on('mousedown', function() { self.pressed = true })
			this.element.on('mouseup', function() { self.pressed = false })
		}

		if (this.hoverEnabled)
			this._bindHover(true)

		if (this.touchEnabled)
			this._bindTouch(true)
	}
}
