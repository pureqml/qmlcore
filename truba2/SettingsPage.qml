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
			text: "Если у Вас есть пожелания к сервису или Вы хотите добавить сюда свой плейлист, напишите нам на support@truba.tv";
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
					var item = this.model.get(i)
					item.selected = false
					this.model.set(i, item)
					break;
				}

			var idx = this.currentIndex
			var item = this.model.get(idx)
			item.selected = true
			this.model.set(idx, item)

			this.model.saveProvider(idx)
		}

		onSelectPressed:	{ this.toggle() }
		onClicked:			{ this.toggle(); }
	}
}
