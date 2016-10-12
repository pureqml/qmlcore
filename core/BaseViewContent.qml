/// @internal content for base view scrolling area
Item {
	onXChanged:		{ this.parent._layout() }
	onYChanged:		{ this.parent._layout() }
}
