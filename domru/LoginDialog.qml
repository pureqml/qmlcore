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
			id: footer;
			height: 20;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;

			Item {
				id: removeContext;
				height: 20;
				width: height + contextText.paintedWidth + 10;

				Rectangle {
					id: bgRect;
					height: parent.height;
					width: height;
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					color: "#f00";
					radius: height / 4;
					border.width: 2;
					border.color: "#fff";
				}

				Text {
					id: contextText;
					anchors.left: bgRect.right;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.leftMargin: 8;
					color: "#fff";
					text: "Удалить";
				}
			}

			Item {
				id: specialSymbolsContext;
				anchors.left: removeContext.right;
				anchors.leftMargin: 20;
				height: 20;
				width: height + contextText.paintedWidth + 10;

				Rectangle {
					id: bgRect;
					height: parent.height;
					width: height;
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					color: "#00ab5f";
					radius: height / 4;
					border.width: 2;
					border.color: "#fff";
				}

				Text {
					id: contextText;
					anchors.left: bgRect.right;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.leftMargin: 8;
					color: "#fff";
					text: "aA@";
				}
			}

			Item {
				id: langContext;
				anchors.left: specialSymbolsContext.right;
				anchors.leftMargin: 20;
				height: 20;
				width: height + contextText.paintedWidth + 10;

				Rectangle {
					id: bgRect;
					height: parent.height;
					width: height;
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					color: "#ff0";
					radius: height / 4;
					border.width: 2;
					border.color: "#fff";
				}

				Text {
					id: contextText;
					anchors.left: bgRect.right;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.leftMargin: 8;
					color: "#fff";
					text: "Рус/Eng";
				}
			}

			Item {
				id: spaceContext;
				anchors.left: langContext.right;
				anchors.leftMargin: 20;
				height: 20;
				width: height + contextText.paintedWidth + 10;

				Rectangle {
					id: bgRect;
					height: parent.height;
					width: height;
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					color: "#00f";
					radius: height / 4;
					border.width: 2;
					border.color: "#fff";
				}

				Text {
					id: contextText;
					anchors.left: bgRect.right;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.leftMargin: 8;
					color: "#fff";
					text: "Пробел";
				}
			}

			ListModel {
				id: loginoptionsModel;
				property string text;
				property string source;

				ListElement {
					text: "Назад";
					source: "res/back.png";
				}
			}

			Options {
				width: 100;
				model: loginoptionsModel;
			}
		}

		onRedPressed: { inputDialog.removeChar(); }
		onBluePressed: { inputDialog.text += " "; }
		onYellowPressed: { keyBoard.switchLanguage(); }
	}
}
