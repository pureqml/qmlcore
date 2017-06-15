/// @private content for base view scrolling area
Item {
	onXChanged:		{ this.parent._delayedLayout.schedule() } //fixme: if you need sync _layout here, please note that discarding delegate can result in recursive createDelegate() call from _layout, do not change it without fixing that first.
	onYChanged:		{ this.parent._delayedLayout.schedule() }

	///@private silently updates scroll positions, because browser animates scroll
	function _updateScrollPositions(x, y) {
		this._setProperty('x', -x)
		this._setProperty('y', -y)
		this.parent._layout()
	}

}
