Item {
	width: renderer.width * 0.4;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { }

	ListView {
		id: categoriesListView;
		anchors.fill: parent;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		model: providersModel;
		delegate: ProviderDelegate { }

		toggle: {
			for (var i = 0; i < this.count; ++i)
				if (this.model.get(i).selected) {
					this.model.get(i).selected = false
					this._onRowsChanged(i, i + 1)
					break;
				}

			var idx = this.currentIndex
			this.model.get(idx).selected = true
			this._onRowsChanged(idx, idx + 1)
			this.model.saveProvider(idx)
		}

		onSelectPressed:	{ this.toggle() }
		onClicked:			{ this.toggle(); }
	}
}
