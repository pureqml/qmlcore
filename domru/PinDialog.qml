Activity {
	id: pinDialogProto;
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

		DomruLogo { }

		Text {
			text: "ВВЕДИТЕ ПИН КОД";
			font.pointSize: 32;
			anchors.right: parent.right;
			anchors.top: parent.top;
			color: "#fff";
		}

		Row {
			width: pinDigitsList.width + applyButton.width + 10;
			spacing: 10;
			anchors.centerIn: parent;

			ListView {
				id: pinDigitsList;
				width: contentWidth;
				height: 50;
				orientation: ListView.Horizontal;
				spacing: 10;
				model: ListModel {
					property int digit;
					
					ListElement { digit: "0"; }
					ListElement { digit: "0"; }
					ListElement { digit: "0"; }
					ListElement { digit: "0"; }
				}
				delegate: GreenButtonBright {
					width: 50;
					height: width;
					//TODO: get value from digit - int value.
					text: "0";

					Image {
						source: "res/nav_up.png";
						anchors.bottom: parent.top;
						visible: parent.activeFocus;
					}

					Image {
						source: "res/nav_down.png";
						anchors.top: parent.bottom;
						visible: parent.activeFocus;
					}
				}

				onRightPressed: {
					if (this.currentIndex == this.count - 1)
						applyButton.forceActiveFocus();
					else
						this.currentIndex++;
				}
			}

			GreenButtonBright {
				id: applyButton;
				text: "";
				height: 50;
				text: "Применить";
				width: 120;
			}

			onDownPressed: { pinOptions.forceActiveFocus(); }
		}

		Item {
			id: mainMenuFooter;
			height: 20;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;

			ListModel {
				id: pinOptionsModel;
				property string text;
				property string source;

				ListElement { text: "Назад"; source: "res/back.png"; }
			}

			Options {
				id: pinOptions;
				model: pinOptionsModel;

				onUpPressed: { applyButton.forceActiveFocus(); }

				onOptionChoosed(text): {
					if (text == "Назад")
						pinDialogProto.stop();
				}
			}
		}
	}
}
