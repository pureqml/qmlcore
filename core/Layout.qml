/// base layout component.
BaseLayout {
	width: contentWidth;		///< inner content width
	height: contentHeight;		///< inner content height
	handleNavigationKeys: true;	///< handle navigation keys, move focus
	keyNavigationWraps: true;	///< key navigation wraps from first to last and vise versa

	///move focus to the next child
	focusNextChild: {
		var idx = 0;
		var children = this.children
		if (this.focusedChild)
			idx = children.indexOf(this.focusedChild)

		for (var i = idx + 1; i < children.length; ++i) {
			if (children[i]._tryFocus()) {
				this.currentIndex = i
				this.focusChild(this.children[i])
				return true
			}
		}

		if (!this.keyNavigationWraps)
			return false

		for (var i = 0; i <= idx; ++i) {
			if (children[i]._tryFocus()) {
				this.currentIndex = i
				this.focusChild(this.children[i])
				return true
			}
		}

		return false
	}

	///move focus to the previous child
	focusPrevChild: {
		var idx = 0;
		var children = this.children
		if (this.focusedChild)
			idx = children.indexOf(this.focusedChild)

		for (var i = idx - 1; i >= 0; --i) {
			if (children[i]._tryFocus()) {
				this.currentIndex = i
				this.focusChild(this.children[i])
				return true
			}
		}

		if (!this.keyNavigationWraps)
			return false

		var last = children.length - 1
		for (var i = last; i >= idx; --i) {
			if (children[i]._tryFocus()) {
				this.currentIndex = i
				this.focusChild(this.children[i])
				return true
			}
		}

		return false

	}

	onCurrentIndexChanged: {
		if (value >= 0 && value < this.children.length)
			this.focusChild(this.children[value])
	}
}
