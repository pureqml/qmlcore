BaseMixin {
	property string cursor;			///< mouse cursor

	///@private
	constructor: {
		if (this.cursor)
			this.parent.style('cursor', this.cursor)
	}

	onCursorChanged: {
		this.parent.style('cursor', value)
	}
}
