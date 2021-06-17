Item {
	property enum horizontalScrollBarPolicy	{ ScrollBarAsNeeded, ScrollBarAlwaysOff, ScrollBarAlwaysOn}: ScrollBarAlwaysOff;
	property enum verticalScrollBarPolicy	{ ScrollBarAsNeeded, ScrollBarAlwaysOff, ScrollBarAlwaysOn};
	cssPointerTouchEvents: true;

	constructor: {
		this.style({ 'overflow-x': 'hidden', 'overflow-y': 'auto' })
	}

	///@private
	function _setStyle(style, value) {
		switch(value) {
			case ScrollViewPrototype.ScrollBarAsNeeded:
				this.style(style, 'auto')
				break
			case ScrollViewPrototype.ScrollBarAlwaysOn:
				this.style(style, 'visible')
				break
			case ScrollViewPrototype.ScrollBarAlwaysOff:
				this.style(style, 'hidden')
				break
		}
	}

	onHorizontalScrollBarPolicyChanged: {
		this._setStyle('overflow-x', value)
	}

	onVerticalScrollBarPolicyChanged: {
		this._setStyle('overflow-y', value)
	}
}
