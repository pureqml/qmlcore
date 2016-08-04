Item {
	property int contentWidth;
	property int contentHeight;

	property int spacing;
	property bool handleNavigationKeys: true;

	constructor: {
		var self = this
		this._delayedLayout = new qml.core.DelayedAction(this.getContext(), function() {
			self._layout()
		})
	}

	focusNextChild: {
		var idx = 0;
		if (this.focusedChild)
			idx = this.children.indexOf(this.focusedChild)
		idx = (idx + 1) % this.children.length
		this.focusChild(this.children[idx])
	}

	focusPrevChild: {
		var idx = 0;
		if (this.focusedChild)
			idx = this.children.indexOf(this.focusedChild)
		idx = (idx + this.children.length - 1) % this.children.length
		this.focusChild(this.children[idx])
	}

	width: contentWidth;
	height: contentHeight;

	onCompleted: { this._delayedLayout.schedule() }
}
