Item {
	id: infoPlateItem;
	property bool active: true;
	property bool isHd: false;
	property bool is3d: false;
	property int channelNumber: 0;
	property string title;
	property string logo;
	property string programTitle;
	property string programDescription;
	property string programInfo;
	property real programProgress;
	anchors.fill: parent;
	opacity: active ? 1 : 0;

	signal channelListCalled;

	Timer {
		id: hideTimer;
		interval: 10000;
		running: true;

		onTriggered: {
			console.log("Infoplate hideTimer triggered");
			infoPlateItem.close();
		}
	}

	show(ms): {
		this.active = true;
		this.forceActiveFocus();
		hideTimer.interval = ms;
		console.log("Restarting timer", hideTimer.interval);
		hideTimer.restart();
	}

	close: {
		this.active = false;
		hideTimer.stop();
	}

	onBackPressed: {
		if (this.active)
			this.close();
	}

	onBluePressed: {
		if (this.active)
			this.close();
		else
			this.show(10000);
	}

	onActiveChanged: {
		settingsColumn.active = false;
	}

	Rectangle {
		anchors.bottom: renderer.bottom;
		anchors.left: renderer.left;
		anchors.right: renderer.right;
		height: 140;

		gradient: Gradient {
			GradientStop { color: "#00000000"; position: 0; }
			GradientStop { color: "#000000ff"; position: 0.8; }
			GradientStop { color: "#000000ff"; position: 1; }
		}
	}

	DomruLogo {
		anchors.left: parent.left;
		anchors.top: parent.top;
	}

	Rectangle {
		width: 125;
		height: 68;
		anchors.top: parent.top;
		anchors.right: parent.right;
		opacity: 0.6;
		color: "#000000";

		Text {
			anchors.centerIn: parent;
			font.pointSize: 32;
			text: infoPlateItem.channelNumber;
			color: "#fff";
		}
	}

	Item {
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: footer.top;
		anchors.bottomMargin: 35;

		GreenButton {
			id: timePanel;
			height: 68;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;

			Text {
				id: timeText;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#fff";
				text: "00:00";
			}

			Text {
				id: dateText;
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: "-- ---- --";
			}

			onLeftPressed: { shareButton.forceActiveFocus(); }
			onRightPressed: { channelPanel.forceActiveFocus(); }
		}

		GreenButton {
			id: channelPanel;
			height: channelPanel.activeFocus ? 136 : 68;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: timePanel.right;
			anchors.leftMargin: 8;

			Text {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: infoPlateItem.channelNumber;
			}

			Text {
				anchors.centerIn: parent;
				color: "white";
				text: infoPlateItem.title;
				opacity: channelPanel.activeFocus ? 1 : 0;

				Behavior on opacity	{ Animation { duration: 300; } }
			}

			Image {
				anchors.right: parent.right;
				anchors.top: parent.top;
				anchors.topMargin: 12;
				anchors.rightMargin: 10;
				source: infoPlateItem.logo;
			}

			Image {
				id: hdLogo;
				anchors.left: parent.left;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				source: "res/hd.png";
				visible: infoPlateItem.isHd;
			}

			Image {
				anchors.left: hdLogo.right;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				source: "res/3d.png";
				visible: infoPlateItem.is3d;
			}

			Image {
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 12;
				anchors.rightMargin: 10;
				source: "res/lock.png";
			}

			onLeftPressed: { timePanel.forceActiveFocus(); }
			onRightPressed: { programPanel.forceActiveFocus(); }
		}

		GreenButton {
			id: programPanel;
			height: activeFocus ? 204 : 68;
			width: 675;
			anchors.bottom: parent.bottom;
			anchors.left: channelPanel.right;
			anchors.right: settingsColumn.left;
			anchors.leftMargin: 8;
			anchors.rightMargin: 8;

			Text {
				id: programText;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.topMargin: 4;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				font.pointSize: 18;
				color: "#fff";
				text: infoPlateItem.programTitle;
			}

			Text {
				anchors.top: programText.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				anchors.topMargin: 4;
				color: "#ccc";
				text: infoPlateItem.programInfo;
			}

			ProgressBar {
				id: programProgress;
				y: 62;//anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				progress: infoPlateItem.programProgress;
			}

			Rectangle {
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.top: programProgress.bottom;
				anchors.bottom: parent.bottom;
				color: "gray";
				clip: true;

				Text {
					id: programDescriptionText;
					anchors.top: programProgress.bottom;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.bottom: parent.right;
					anchors.margins: 10;
					text: infoPlateItem.programDescription;
					wrap: true;
					color: "#fff";
				}
			}

			onLeftPressed: { channelPanel.forceActiveFocus(); }
			onRightPressed: { settingsButton.forceActiveFocus(); }
		}


		Column {
			id: settingsColumn;
			property bool active;
			width: 68;
			anchors.bottom: parent.bottom;
			anchors.right: shareButton.left;
			anchors.rightMargin: 8;
			spacing: 8;

				
			GreenButton {
				id: ttxButton;
				height: 68;
				width: height;
				visible: settingsColumn.active;

				Image {
					anchors.centerIn: parent;
					source: "res/ttx.png";
				}
			}

			GreenButton {
				id: subButton;
				height: 68;
				width: height;
				property bool checked;
				isGreen: subButton.activeFocus || subButton.checked;
				visible: settingsColumn.active;

				onTriggered: { subButton.checked = !subButton.checked; }

				Image {
					anchors.centerIn: parent;
					source: "res/sub.png";
				}
			}

			GreenButton {
				id: audioButton;
				height: 68;
				width: height;
				visible: settingsColumn.active;

				Image {
					anchors.centerIn: parent;
					source: "res/audio.png";
				}
			}

			GreenButton {
				id: settingsButton;
				height: 68;
				width: height;

				Image {
					anchors.centerIn: parent;
					source: "res/settings.png";
				}

				onTriggered: { settingsColumn.active = !settingsColumn.active; }
			}

			onLeftPressed: { programPanel.forceActiveFocus(); }
			onRightPressed: { shareButton.forceActiveFocus(); }
		}


		GreenButton {
			id: shareButton;
			height: 68;//bottomPanel.innerHeight;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.right: parent.right;

			Image {
				anchors.centerIn: parent;
				source: "res/share.png";
			}

			onLeftPressed: { settingsButton.forceActiveFocus(); }
			onRightPressed: { timePanel.forceActiveFocus(); }
		}
	}

	Item {
		id: footer;
		height: 20;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;

		Item {
			id: tvGuideContext;
			height: 20;
			width: height + contextText.paintedWidth + 10;

			Rectangle {
				id: tvRect;
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
				anchors.left: tvRect.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 8;
				color: "#fff";
				text: "ТВ Гид";
			}
		}

		Item {
			id: listContext;
			anchors.left: tvGuideContext.right;
			anchors.leftMargin: 20;
			height: 20;
			width: height + contextText.paintedWidth + 10;
			property bool active;


			Rectangle {
				id: listRect;
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
				anchors.left: listRect.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 8;
				color: listContext.active ? "#5f6": "#fff";
				text: "Список каналов (F2)";
				property int fontSize: listContext.active ? 15 : 12;
				font.pointSize: fontSize;
			
				Behavior on fontSize { Animation { duration: 100; } }
				Behavior on color  { ColorAnimation { duration: 200; } }
			}

			MouseArea {
				anchors.fill: parent;
				anchors.margins: -10;
				hoverEnabled: true;
				onClicked: { infoPlateItem.channelListCalled(); listContext.active = false; }
				onEntered: { listContext.active = true; }//listContext.forceActiveFocus(); }
				onExited: { listContext.active = false; }
			}
		}

		// ListModel {
		// 	id: contextModel;
		// 	property string text;
		// 	property Color color;

		// 	ListElement {
		// 		text: "ТВ Гид";
		// 		color: "#f00";
		// 	}

		// 	ListElement {
		// 		text: "Список каналов";
		// 		color: "#00ab5f";
		// 	}
		// }

		// ContextMenu { model: contextModel; }

		ListModel {
			id: optionsModel;
			property string text;
			property string source;

			ListElement {
				text: "Назад";
				source: "res/back.png";
			}

			ListElement {
				text: "ТВ меню";
				source: "res/qMenu.png";
			}

			ListElement {
				text: "Выход";
				source: "res/exit.png";
			}
		}

		Options { 
			model: optionsModel; 
		}
	}

	Timer {
		duration: 600;
		running: infoPlateItem.active;

		onTriggered: {
			var now = new Date();
			var minutes = now.getMinutes();
			minutes = minutes >= 10 ? minutes : "0" + minutes
			timeText.text = now.getHours() + ":" + minutes
			//TODO: Move it somethere out there.
			var monthList = [
				'январь',
				'февраль',
				'март',
				'апрель',
				'май',
				'июнь',
				'июль',
				'август',
				'сентябрь',
				'октябрь',
				'ноябрь',
				'декабрь'
			]
			var week = [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ]
			var month = monthList[now.getMonth()]
			dateText.text = now.getDate() + " " + month + " " + week[now.getDay()]
		}
	}

	Behavior on opacity	{ Animation { duration: 300; } }
}
