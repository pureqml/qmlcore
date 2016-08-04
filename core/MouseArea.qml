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

	onTouchEnabledChanged: {
		if (value) {
			var self = this
			if ('ontouchstart' in window)
				this.element.bind('touchstart', function(event) { self.touchStart(event) })
			if ('ontouchend' in window)
				this.element.bind('touchend', function(event) { self.touchEnd(event) })
			if ('ontouchmove' in window)
				this.element.bind('touchmove', function(event) { self.touchMove(event) })
		} else {
			this.element.unbind('touchmove touchend touchstart')
		}
	}

	onRecursiveVisibleChanged: {
		if (!value)
			this.containsMouse = false
	}

	onClickableChanged: {
		if (value)
			this.element.click(this.clicked.bind(this))
		else
			this.element.unbind('click')
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
		if (value) {
			this.element.mousedown(function() { self.pressed = true })
			this.element.mouseup(function() { self.pressed = false })
		} else {
			this.element.unbind('mousedown mouseup')
		}
	}

	onHoverEnabledChanged: {
		var self = this
		if (value) {
			this.element.hover(function() { self.hover = true }, function() { self.hover = false })
			this.element.mousemove(function(event) { if (self.updatePosition(event)) event.preventDefault() })
		} else {
			this.element.unbind('mouseenter mouseleave mousemove')
		}
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
			this.element.click(this.clicked.bind(this))
		if (this.wheelEnabled)
			this.element.on('mousewheel', function(event) { self.wheelEvent(event.originalEvent.wheelDelta / 120) })
		if (this.pressable) {
			this.element.mousedown(function() { self.pressed = true })
			this.element.mouseup(function() { self.pressed = false })
		}
		if (this.hoverEnabled) {
			this.element.hover(function() { self.containsMouse = true }, function() { self.containsMouse = false })
			this.element.mousemove(function(event) { self.mouseMove(); if (self.updatePosition(event)) event.preventDefault() })
		}
		if (this.touchEnabled) {
			if ('ontouchstart' in window)
				this.element.bind('touchstart', function(event) { self.touchStart(event) })
			if ('ontouchend' in window)
				this.element.bind('touchend', function(event) { self.touchEnd(event) })
			if ('ontouchmove' in window)
				this.element.bind('touchmove', function(event) { self.touchMove(event) })
		}
	}
}
