Activity {
	id: providersPanelProto;
	signal choosed;
	width: renderer.width / 3;
	height: renderer.height / 3;
	visible: active;

	Rectangle {
		width: parent.width;
		height: parent.height;
		anchors.centerIn: parent;
		color: colorTheme.backgroundColor;
		//TODO: use shadows instead.
		border.color: colorTheme.activeBackgroundColor;
		border.width: 1;

		MouseArea {
			id: acceptProviderButton;
			width: parent.width / 4;
			height: width / 2;
			anchors.bottom: parent.bottom;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottomMargin: 10;
			hoverEnabled: true;

			Rectangle {
				anchors.fill: parent;
				color: colorTheme.activeDialogBackground;

				Text {
					width: parent.width;
					anchors.verticalCenter: parent.verticalCenter;
					horizontalAlignment: Text.AlignHCenter;
					font.pointSize: 24;
					color: colorTheme.focusedTextColor;
					text: "OK";
				}
			}

			onClicked: {
				log("Choosed provider: " + selectedProviderText.text);
				providersPanelProto.choosed(selectedProviderText.text);
				providersPanelProto.stop();
			}
		}

		Text {
			id: providersPanelTitle;
			width: parent.width;
			anchors.top: parent.top;
			anchors.topMargin: 10;
			horizontalAlignment: Text.AlignHCenter;
			font.pointSize: 24;
			font.bold: true;
			color: colorTheme.textColor;
			text: "Выберете провайдера";
		}

		Rectangle {
			height: providersList.active ? providersList.count * 50 : 0;
			anchors.top: selectedProviderLabel.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.leftMargin: 10;
			anchors.rightMargin: 10;
			color: colorTheme.backgroundColor;
			border.color: colorTheme.activeBackgroundColor;
			border.width: 2;
			clip: true;

			ListView {
				id: providersList;
				property bool active: false;
				height: count * 50;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				model: providersModel;
				delegate: Rectangle {
					height: 50;
					width: parent.width;
					color: colorTheme.backgroundColor;

					Text {
						anchors.left: parent.left;
						anchors.verticalCenter: parent.verticalCenter;
						anchors.leftMargin: 10;
						text: model.text;
						color: colorTheme.textColor;
					}
				}

				choose: {
					selectedProviderText.text = this.model.get(this.currentIndex).text;
					this.active = false;
				}

				onSelectPressed:	{ this.choose(); }
				onClicked:			{ this.choose(); }
			}

			Behavior on height { Animation { duration: 300; } }
		}

		Item {
			anchors.top: providersPanelTitle.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.margins: 10;
			anchors.bottom: acceptProviderButton.top;

			Rectangle {
				id: selectedProviderLabel;
				height: 50;
				width: parent.width;
				anchors.centerIn: parent;
				color: colorTheme.backgroundColor;
				border.color: colorTheme.activeBackgroundColor;
				border.width: 2;

				Text {
					id: selectedProviderText;
					property bool choosed: text != "Провайдер";
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.leftMargin: 10;
					font.italic: !choosed;
					font.pixelSize: 20;
					color: !choosed ? colorTheme.disabledTextColor : colorTheme.textColor;

					onCompleted: { this.text = "Провайдер"; }
				}

				Image {
					anchors.right: parent.right;
					anchors.rightMargin: 10;
					anchors.verticalCenter: parent.verticalCenter;
					source: "res/details.png";
				}

				MouseArea {
					anchors.fill: parent;
					hoverEnabled: true;

					toggle:				{ providersList.active = !providersList.active; }
					onClicked:			{ this.toggle(); }
					onSelectPressed:	{ this.toggle(); }
				}
			}
		}
	}
}
