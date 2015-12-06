Item {
	id: channelsByGenreProto;
	signal switched;
	signal isAlive;
	height: parent.height;
	anchors.top: parent.top;
	anchors.left: safeArea.left;
	anchors.right: safeArea.right;
	clip: true;

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
			onMovedUp:		{ --channelsByGenres.currentIndex; }
			onMovedDown:	{ ++channelsByGenres.currentIndex; }
			onSwitched(channel): { channelsByGenreProto.switched(channel) }

			onReturnedToMenu: {
				contentView.showFocused = true;
				contentView.forceActiveFocus();
			}
		}

		onCurrentIndexChanged: {
			channelsByGenreProto.isAlive();
			if (channelsByGenres.activeFocus)
				contentView.currentIndex = this.currentIndex;
		}
	}

	Rectangle {
		anchors.fill: contentView;
		color: colorTheme.activePanelColor;
	}

	ListView {
		id: contentView;
		property bool showFocused: true;
		property int minSize: 50;
		width: showFocused ? 300 : minSize;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		model: categoriesModel;
		delegate: CategoryDelegate { }

		Image {
			anchors.centerIn: parent;
			source: "res/osd/more.png";
			opacity: !parent.showFocused ? 1.0 : 0.0;

			Behavior on opacity { Animation {  duration: 300; } }
		}

		onCurrentIndexChanged: {
			channelsByGenreProto.isAlive();
			if (contentView.activeFocus)
				channelsByGenres.currentIndex = this.currentIndex;
		}

		onRightPressed: {
			channelsByGenres.forceActiveFocus();
			this.showFocused = false;
		}

		Behavior on width { Animation { duration: 300; } }
	}

	focusCategories: {
		contentView.showFocused = true
		contentView.forceActiveFocus()
	}

	focusChannels: {
		contentView.showFocused = false
		channelsByGenres.forceActiveFocus()
	}
}
