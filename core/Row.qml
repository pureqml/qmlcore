Layout {
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch(key) {
			case 'Left':	this.focusPrevChild(); return true;
			case 'Right':	this.focusNextChild(); return true;
		}
	}
}
