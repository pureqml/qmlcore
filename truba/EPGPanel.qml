Activity {
	anchors.fill: parent;
	active: false;
	opacity: active ? 1.0 : 0.0;

	Rectangle {
		anchors.fill: epgPanelChannels;
		color: colorTheme.backgroundColor;
	}

	ChannelsList {
		id: epgPanelChannels;
		width: 400;
		anchors.left: epgPanelCategories.left;
		anchors.leftMargin: 50;
		model: ListModel {}

		onLeftPressed: { epgPanelCategories.forceActiveFocus(); }
		onRightPressed: { programsList.forceActiveFocus(); }

		onCurrentIndexChanged: {
			var programs = [
				{ programName: "Менты-14", startTime: "12:00" },
				{ programName: "Менты-14", startTime: "13:00" },
				{ programName: "Менты-14", startTime: "14:00" },
				{ programName: "Менты-14", startTime: "15:00" },
				{ programName: "Менты-14", startTime: "16:00" },
				{ programName: "Менты-14", startTime: "17:00" }
			];
			programsList.fillPrograms(programs);
		}
	}

	Rectangle {
		anchors.fill: programsList;
		color: colorTheme.backgroundColor;
	}

	ListView {
		id: programsList;
		anchors.left: epgPanelChannels.right;
		anchors.right: parent.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		delegate: Rectangle {
			width: parent.width;
			height: 50;
			color: activeFocus ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;

			Text {
				id: startTimeDelegateText;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				text: model.startTime;
				color: colorTheme.accentTextColor;
				font.pointSize: 18;
			}

			Text {
				anchors.left: startTimeDelegateText.right;
				anchors.right: parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				font.pointSize: 18;
				clip: true;
				text: model.programName;
				color: colorTheme.accentTextColor;
			}
		}
		model: ListModel { }

		fillPrograms(programs): {
			var model = this.model;
			model.clear();

			for (var i in programs)
				model.append(programs[i]);

			this.currentIndex = 0;
		}

		onLeftPressed: { epgPanelChannels.forceActiveFocus(); }
	}

	Rectangle {
		anchors.left: epgPanelChannels.left;
		anchors.top: epgPanelChannels.top;
		anchors.bottom: epgPanelChannels.bottom;
		anchors.right: programsList.right;
		color: "#000";
		opacity: epgPanelChannels.activeFocus || programsList.activeFocus ? 0.0 : 0.6;

		Behavior on opacity { Animation { duration: 300; } }
	}

	Rectangle {
		anchors.fill: epgPanelCategories;
		color: colorTheme.backgroundColor;
	}

	CategoriesList {
		id: epgPanelCategories;
		model: ListModel {
			property string text;
			property string source;

			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
			ListElement { text: "ololo"; source: "res/scrambled.png"; }
		}

		onCurrentIndexChanged: {
			var list = [
				{ text: "ololo", source: "res/scrambled.png" },
				{ text: "ololo", source: "res/scrambled.png" },
				{ text: "ololo", source: "res/scrambled.png" },
				{ text: "ololo", source: "res/scrambled.png" },
				{ text: "ololo", source: "res/scrambled.png" },
				{ text: "ololo", source: "res/scrambled.png" }
			]; 
			epgPanelChannels.setList(list);
		}

		onRightPressed: { epgPanelChannels.forceActiveFocus(); }
	}

	onActiveChanged: {
		if (this.active)
			epgPanelCategories.forceActiveFocus();
	}

	Behavior on opacity { Animation { duration: 300; } }
}
