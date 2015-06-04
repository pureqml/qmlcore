Activity {
	id: settingsPanelProto;
	signal choosed;

	Shadow {
		id: settingsShadow;
		active: parent.active;
		leftToRight: false;
		anchors.top: parent.top;
		anchors.right: settingsInnerPanel.left;
		anchors.bottom: parent.bottom;
	}

	Rectangle {
		id: settingsInnerPanel;
		width: parent.width - settingsShadow.width;
		height: parent.height;
		anchors.right: parent.right;
		color: colorTheme.backgroundColor;
		clip: true;

		Text {
			id: settingsPanelTitle;
			width: parent.width;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.margins: 10;
			font.pointSize: 24;
			color: colorTheme.textColor;
			text: "Настройки";
		}

		Rectangle {
			height: 1;
			anchors.top: settingsPanelTitle.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.margins: 10;
			color: "#ccc";
		}

		Text {
			id: providerSettingLabel;
			anchors.top: settingsPanelTitle.bottom;
			anchors.left: parent.left;
			anchors.topMargin: 21;
			anchors.leftMargin: 10;
			font.pointSize: 16;
			color: colorTheme.textColor;
			text: "Выберите провайдера";
		}

		Rectangle {
			id: providersListPanel;
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
				z: active ? settingsPanelButtons.z + 1 : parent.z + 1;
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
			anchors.top: settingsPanelTitle.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.margins: 10;

			Rectangle {
				id: selectedProviderLabel;
				height: 50;
				width: parent.width;
				anchors.top: providerSettingLabel.bottom;
				color: colorTheme.backgroundColor;
				border.color: colorTheme.activeBackgroundColor;
				border.width: 2;
				clip: true;

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
					opacity: 0.7;
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

		Column {
			id: settingsPanelButtons;
			anchors.top: selectedProviderLabel.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: 10;
			spacing: 10;

			Button {
				anchors.horizontalCenter: parent.horizontalCenter;
				text: "Добавить оператора";

				onClicked: {
				}
			}

			Button {
				anchors.horizontalCenter: parent.horizontalCenter;
				text: "Хотите улучшить сервис?";

				onClicked: {
				}
			}
		}
	}

	onActiveChanged: {
		if (!this.active && selectedProviderText.choosed) {
			log("Choosed provider: " + selectedProviderText.text);
			settingsPanelProto.choosed(providersList.model.get(providersList.currentIndex).id);
		}
	}

	Behavior on width { Animation { duration: 300; } }
}
