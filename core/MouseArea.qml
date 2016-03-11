Item {
	signal entered;
	signal exited;
	signal clicked;
	signal canceled;
	signal wheelEvent;
	signal verticalSwiped;
	signal horizontalSwiped;
	signal mouseMove;

	property real mouseX;
	property real mouseY;
	property string cursor;
	property bool pressed;
	property bool containsMouse;
	property bool clickable: true;
	property bool pressable: true;
	property bool hoverEnabled: true;
	property bool wheelEnabled: true;
	property bool verticalSwipable: true;
	property bool horizontalSwipable: true;

	property alias hover: containsMouse;
	property alias hoverable: hoverEnabled;

	onCursorChanged: { this.element.css('cursor', value) }

	onSwipableChanged: {
		if (value)
			this.element.drag(this.dragEventHandler.bind(this))
		else
			this.element.unbind('drag')
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

	horizontalSwipeHandler(event): {
		if (!event || !this.hoverEnabled || !this.recursiveVisible || !('ontouchstart' in window))
			return

		this.pressed = !event.end
		this.horizontalSwiped(event)

		event.preventDefault()
	}

	verticalSwipeHandler(event): {
		if (!event || !this.hoverEnabled || !this.recursiveVisible || !('ontouchstart' in window))
			return

		this.pressed = !event.end
		this.verticalSwiped(event)

		event.preventDefault()
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

	onCompleted: {
		var self = this

		if (this.element.verticalSwipe && this.verticalSwipable)
			this.element.verticalSwipe(this.verticalSwipeHandler.bind(this))
		if (this.element.horizontalSwipe && this.horizontalSwipable)
			this.element.horizontalSwipe(this.horizontalSwipeHandler.bind(this))
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
	}
}
