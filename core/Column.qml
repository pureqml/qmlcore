Layout {
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch(key) {
			case 'Up':		this.focusPrevChild(); return true;
			case 'Down':	this.focusNextChild(); return true;
		}
	}
}
