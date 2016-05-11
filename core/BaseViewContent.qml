Item {
	onXChanged:		{ this.parent._layout() }
	onYChanged:		{ this.parent._layout() }

	constructor: {
		log('created content')
		this.element.scroll(function(event) { log('scroll event', event) })
		this.parent.element.scroll(function(event) { log('parent scroll event', event) })
	}
}
