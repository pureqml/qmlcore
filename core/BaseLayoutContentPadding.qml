/// class controlling internal paddings of BaseLayout content
Object {
	property int top: all;		///< top padding
	property int left: all;		///< left padding
	property int right: all;	///< right padding
	property int bottom: all;	///< bottom padding
	property int all;			///< a value for all sides

	prototypeConstructor: {
		BaseLayoutContentPaddingPrototype.defaultProperty = 'all'
	}

	constructor: {
		this.parent._padding = this
	}

	onTopChanged,
	onLeftChanged,
	onRightChanged,
	onBottomChanged: { this.parent._scheduleLayout(); }
}
