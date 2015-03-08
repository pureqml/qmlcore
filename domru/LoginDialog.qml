Rectangle {
	id: loginDialogProto;
	property bool loginPage: true;
	property string login;
	property string password;
	anchors.fill: renderer;

	Item {
		anchors.fill: parent;
		anchors.rightMargin: 75;
		anchors.bottomMargin: 40;
		anchors.leftMargin: 75;
		anchors.topMargin: 42;

		Image {
			anchors.top: parent.top;
			anchors.left: parent.left;
			source: "res/logoDomru.png";
		}

		Text {
			id: labelText;
			anchors.right: parent.right;
			anchors.top: parent.top;
			text: "АВТОРИЗАЦИЯ ДОМ.RU";
			font.pointSize: 32;
			color: "#fff";
		}

		Row {
			id: content;
			anchors.top: labelText.bottom;
			anchors.bottom: parent.bottom;
			anchors.right: parent.right;
			anchors.left: parent.left;
			anchors.topMargin: 40;

			Keyboard {
				id: keyBoard;
				onKeySelected(key): { inputDialog.text += key; }
				onBackspase: { inputDialog.removeChar(); }
			}

			Column {
				width: parent.width / 2;
				anchors.right: parent.right;
				anchors.top: parent.top;
				anchors.bottom: parent.bottom;
				spacing: 5;
				focus: true;

				Text {
					text: loginDialogProto.loginPage ? "Введите логин" : "Введите пароль";
					color: "#fff";
				}

				Input {
					id: inputDialog;
					width: parent.width;
					height: 50;
					passwordMode: !loginDialogProto.loginPage;
				}

				Button {
					color: activeFocus ? "#fff": "#eee";
					textColor: "black";
					width: label.paintedWidth + 20;
					text: loginDialogProto.loginPage ? "Перейти к вводу пароля" : "Авторизоваться";

					onTriggered: {
						if (!loginDialogProto.loginPage) {
							loginDialogProto.password = inputDialog.text;
						} else {
							loginDialogProto.login = inputDialog.text;
							inputDialog.text = "";
							loginDialogProto.loginPage = false;
						}
					}
				}
			}
		}

		Item {
			height: 20;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;

			ListModel {
				id: loginContextModel;
				property string text;
				property Color color;

				ListElement { text: "Удалить";	color: "#f00"; }
				ListElement { text: "aA@";		color: "#00ab5f"; }
				ListElement { text: "Рус/Eng";	color: "#ff0"; }
				ListElement { text: "Пробел";	color: "#00f"; }
			}

			ContextMenu {
				id: loginContextMenu;
				model: loginContextModel;

				onOptionChoosed(text): {
					if (text == "Удалить")
						this.processRed();
					else if (text == "aA@")
						this.processGreen();
					else if (text == "Рус/Eng")
						this.processYellow();
					else if (text == "Пробел")
						this.processBlue();
				}

				onRightPressed: {
					if (this.currentIndex < this.count - 1) {
						this.currentIndex++;
					} else {
						loginOptions.currentIndex = 0;
						loginOptions.forceActiveFocus();
					}
				}

				processRed: { inputDialog.removeChar(); }
				processBlue: { inputDialog.text += " "; }
				processGreen: { keyBoard.switchCase(); }
				processYellow: { keyBoard.switchLanguage(); }
				onUpPressed: { keyBoard.forceActiveFocus(); }
			}

			ListModel {
				id: loginOptionsModel;
				property string text;
				property string source;

				ListElement {
					text: "Назад";
					source: "res/back.png";
				}
			}

			Options {
				id: loginOptions;
				model: loginOptionsModel;
			}
		}

		onRedPressed: { loginContextMenu.processRed(); }
		onBluePressed: { loginContextMenu.processBlue(); }
		onGreenPressed: { loginContextMenu.processGreen(); }
		onYellowPressed: { loginContextMenu.processYellow(); }
	}
}
