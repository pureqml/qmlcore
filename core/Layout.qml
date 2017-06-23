/// base layout component.
BaseLayout {
	width: contentWidth;		///< inner content width
	height: contentHeight;		///< inner content height
	handleNavigationKeys: true;	///< handle navigation keys, move focus
	keyNavigationWraps: true;	///< key navigation wraps from first to last and vise versa

	///move focus to the next child
	focusNextChild: {
		var idx = 0;
		if (this.focusedChild)
			idx = this.children.indexOf(this.focusedChild)

		if (!this.keyNavigationWraps && idx == this.children.length - 1)
			return false

		idx = (idx + 1) % this.children.length
		this.currentIndex = idx
		this.focusChild(this.children[idx])
		return true
	}

	///move focus to the previous child
	focusPrevChild: {
		var idx = 0;
		if (this.focusedChild)
			idx = this.children.indexOf(this.focusedChild)

		if (!this.keyNavigationWraps && idx == 0)
			return false

		idx = (idx + this.children.length - 1) % this.children.length
		this.currentIndex = idx
		this.focusChild(this.children[idx])
		return true
	}

	onCurrentIndexChanged: { this.focusChild(this.children[value]) }

	///@private
	onCompleted: { this._scheduleLayout() }
}
