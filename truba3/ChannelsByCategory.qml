Item {
	id: channelsByGenreProto;
	signal switched(channel);
	signal isAlive;
	height: parent.height;
	anchors.top: parent.top;
	anchors.left: safeArea.left;
	anchors.right: safeArea.right;
	clip: true;

	AlphaControl { alphaFunc: MaxAlpha; }

	ListView {
		id: channelsByGenres;
		anchors.top: parent.top;
		anchors.left: contentView.right;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		positionMode: ListView.Center;
		model: categoriesModel;
		spacing: 5;
		delegate: CategoryRowDelegate {
			onIsAlive:			{ channelsByGenreProto.isAlive() }
			onReturnedToMenu:	{ contentView.setFocus() }
			onMovedUp:		{ --channelsByGenres.currentIndex; }
			onMovedDown:	{ ++channelsByGenres.currentIndex; }

			onSwitched: {
				var itemRect = channelsByGenres.getItemRect(channelsByGenres.currentIndex);
				channel.y = channel.y + itemRect.Top - channelsByGenres.contentY + channelsByGenres.y;
				channelsByGenreProto.switched(channel)
			}
		}

		onCurrentIndexChanged: {
			channelsByGenreProto.isAlive();
			if (activeFocus)
				contentView.currentIndex = this.currentIndex;
		}

		onLeftPressed: { contentView.setFocus(); }
	}

	Rectangle {
		anchors.fill: contentView;
		color: colorTheme.activePanelColor;
	}

	//HighlightListView {
	ListView {
		id: contentView;
		property bool showFocused: menu.activeFocus || activeFocus;
		property int minSize: 50;
		width: showFocused ? 300 : minSize;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		positionMode: ListView.Center;
		//highlightColor: count && activeFocus ? colorTheme.activeFocusColor : "#0000";
		model: categoriesModel;
		delegate: CategoryDelegate { }

		Image {
			anchors.centerIn: parent;
			source: "apps/ondatra/res/more.png";
			opacity: !parent.showFocused ? 1.0 : 0.0;

			Behavior on opacity { animation: Animation {  duration: 300; } }
		}

		onCurrentIndexChanged: {
			channelsByGenreProto.isAlive();
			if (activeFocus)
				channelsByGenres.currentIndex = this.currentIndex;
		}

		onRightPressed: { channelsByGenres.setFocus(); }

		Behavior on width { animation: Animation { duration: 300; } }
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			contentView.setFocus()
	}
}
