Activity {
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
			height: 440;
			anchors.top: menuOptions.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			currentIndex: menuOptions.currentIndex;

			RecomendedPage {
				anchors.fill: parent;

				onRecomendedItemChoosed(text): {
					if (text == "ТВ гид")
						mainMenuProto.tvGuideChoosed();
					else if (text == "Телевидение")
						mainMenuProto.stop();
				}
			}

			VideoPage { anchors.fill: parent; }
			NewsPage { anchors.fill: parent; }
			SettingsPage { anchors.fill: parent; }

			onUpPressed: { menuOptions.forceActiveFocus(); }

			onDownPressed: {
				mainMenuOptions.currentIndex = 0;
				mainMenuOptions.forceActiveFocus();
			}
		}

		Item {
			id: mainMenuFooter;
			height: 20;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;

			ListModel {
				id: contextMainMenuModel;
				property string text;
				property Color color;

				ListElement { text: "выход из профиля"; color: "#f00"; }
				ListElement { text: "помощь"; color: "#00ab5f"; }
			}

			ContextMenu {
				id: contextMainMenu;
				model: contextMainMenuModel;

				//TODO: implement.
				onOptionChoosed(text): { }
				onUpPressed: { optionsPageStack.forceActiveFocus(); }

				onRightPressed: {
					if (this.currentIndex < this.count - 1) {
						this.currentIndex++;
					} else {
						mainMenuOptions.currentIndex = 0;
						mainMenuOptions.forceActiveFocus();
					}
				}
			}

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

				onLeftPressed: {
					contextMainMenu.currentIndex = contextMainMenu.count - 1;
					contextMainMenu.forceActiveFocus();
				}

				onOptionChoosed(text): {
					if (text == "Выход")
						mainMenuProto.stop();
				}
			}
		}
	}

	onActiveChanged: {
		if (!this.active) {
			this.visible = false;
		} else {
			menuOptions.currentIndex = 0;
			menuOptions.forceActiveFocus();
		}
	}
}
