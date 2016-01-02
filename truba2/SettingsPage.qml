Item {
	width: renderer.width * 0.4;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { }

	Item {
		id: feedbackLabel;
		height: feedbackText.paintedHeight;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.margins: 10;

		MainText {
			id: feedbackText;
			color: colorTheme.textColor;
			wrap: true;
			text: "Если у Вы знаете о других рабочих плейлистах, напишите нам support@truba.tv.";
		}
	}

	ListView {
		id: categoriesListView;
		anchors.top: feedbackText.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
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
