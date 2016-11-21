BaseLayout {
	width: contentWidth;
	height: contentHeight;
	handleNavigationKeys: true;
	keyNavigationWraps: true;

	function focusNextChild() {
		var idx = 0;
		if (this.focusedChild)
			idx = this.children.indexOf(this.focusedChild)

		if (!this.keyNavigationWraps && idx == this.children.length - 1)
			return

		idx = (idx + 1) % this.children.length
		this.currentIndex = idx
		this.focusChild(this.children[idx])
	}

	function focusPrevChild() {
		var idx = 0;
		if (this.focusedChild)
			idx = this.children.indexOf(this.focusedChild)

		if (!this.keyNavigationWraps && idx == 0)
			return

		idx = (idx + this.children.length - 1) % this.children.length
		this.currentIndex = idx
		this.focusChild(this.children[idx])
	}

	onCompleted: { this._delayedLayout.schedule() }
}
