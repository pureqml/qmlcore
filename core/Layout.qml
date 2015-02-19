Item {
	property int childrenWidth;
	property int childrenHeight;

	property int spacing;
	property bool handleNavigationKeys: true;

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

	width: childrenWidth;
	height: childrenHeight;

	onCompleted: { this._layout(); }
}
