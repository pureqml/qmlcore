Item {
	id: mainMenuProto;
	signal tvGuideChoosed;
	anchors.fill: renderer;

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.7;
	}

	Item {
		anchors.fill: parent;
		anchors.leftMargin: 75;
		anchors.rightMargin: 75;
		anchors.bottomMargin: 40;
		anchors.topMargin: 42;

		DomruLogo { id: logo; }

		ListView {
			id: menuOptions;
			height: 70;
			anchors.top: logo.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: 40;
			orientation: ListView.Horizontal;
			model: ListModel {
				property string text;

				ListElement { text: "РЕКОМЕНДУЕМ"; }
				ListElement { text: "ВИДЕО"; }
				ListElement { text: "НОВОСТИ"; }
				ListElement { text: "НАСТРОЙКИ"; }
			}
			delegate: Item {
				height: 70;
				width: optionText.paintedWidth + 30;

				Text {
					id: optionText;
					font.pointSize: 24;
					color: "#fff";
					opacity: parent.activeFocus ? 1.0 : 0.6;
					text: model.text;
				}
			}

			onDownPressed: { optionsPageStack.forceActiveFocus(); }
		}

		PageStack {
			id: optionsPageStack;
			anchors.top: menuOptions.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: mainMenuFooter.top;
			anchors.bottomMargin: 20;
			currentIndex: menuOptions.currentIndex;

			RecomendedPage {
				anchors.fill: parent;

				onFocusReturned: { menuOptions.forceActiveFocus(); }

				onRecomendedItemChoosed(text): {
					if (text == "ТВ гид")
						mainMenuProto.tvGuideChoosed();
					else if (text == "Телевидение")
						mainMenuProto.hide();
				}
			}

			VideoPage { anchors.fill: parent; }
			NewsPage { anchors.fill: parent; }
			SettingsPage { anchors.fill: parent; }

			onUpPressed: { menuOptions.forceActiveFocus(); }
		}

		Item {
			id: mainMenuFooter;
			height: 20;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;

			ListModel {
				id: mainMenuOptionsModel;
				property string text;
				property string source;

				ListElement { text: "Выход"; source: "res/exit.png"; }
			}

			Options {
				id: mainMenuOptions;
				model: mainMenuOptionsModel;

				onUpPressed: { optionsPageStack.forceActiveFocus(); }

				onOptionChoosed(text): {
					if (text == "Выход")
						mainMenuProto.hide();
				}
			}
		}
	}

	show: {
		this.visible = true;
		this.forceActiveFocus();
	}

	onBackPressed: { mainMenuProto.hide(); }
	hide: { this.visible = false; }
	onCompleted: { menuOptions.forceActiveFocus(); }
}
