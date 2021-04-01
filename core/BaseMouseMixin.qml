BaseMixin {
	property bool enabled: true;	///< enable/disable mixin
	property string cursor;			///< mouse cursor

	///@private
	constructor: {
		this.element = this.parent.element
		if (this.cursor)
			this.parent.style('cursor', this.cursor)
	}

	onCursorChanged: {
		this.parent.style('cursor', value)
	}
}
