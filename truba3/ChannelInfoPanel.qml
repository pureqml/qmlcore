Item {
	id: channelInfoPanelProto;
	signal isAlive;
	signal switched;
	//property variant channel;
	//visible: false;
	//focus: true;

	//AlphaControl { alphaFunc: MaxAlpha; }

	//Rectangle {
		//id: fog;
		//anchors.fill: mainWindow;
		////color: utils.lighter(logoBg.color, 0.4);
		//opacity: parent.visible ? 1.0 : 0.0;

		//Behavior on opacity { Animation { duration: 300; } }
	//}

	//BorderShadow3D { anchors.fill: parent; }

	//Rectangle {
		//anchors.fill: parent;
		//color: colorTheme.activePanelColor;
	//}

	//Rectangle {
		//id: logoBg;
		//anchors.fill: selectedChannelLogo;
	//}

	//Image {
		//id: selectedChannelLogo;
		//anchors.top: parent.top;
		//anchors.left: parent.left;
	//}

	//Text {
		//id: channelInfoTitle;
		//anchors.top: parent.top;
		//anchors.left: selectedChannelLogo.right;
		//anchors.right: parent.right;
		//anchors.margins: 10;
		//color: colorTheme.accentTextColor;
		//clip: true;
		//font.pixelSize: 18;
	//}

	//Text {
		//id: currentProgramText;
		//anchors.left: logoBg.right;
		//anchors.right: parent.right;
		//anchors.bottom: currentProgress.top;
		//anchors.margins: 10;
		//color: colorTheme.activeTextColor;
		//clip: true;
		//font.pixelSize: 14;
	//}

	//Item {
		//anchors.left: logoBg.right;
		//anchors.right: parent.right;
		//anchors.bottom: logoBg.bottom;
		//anchors.leftMargin: 10;
		//anchors.rightMargin: 10;

		//Rectangle {
			//id: currentProgress;
			//property real progress: 0.0;
			//height: 10;
			//width: progress * parent.width;
			//anchors.left: parent.left;
			//anchors.bottom: parent.bottom;
			//color: colorTheme.accentColor;
		//}
	//}

	//Rectangle {
		//anchors.fill: programsList;
		//color: "#0003";
	//}

	////HighlightListView {
	//ListView {
		//id: programsList;
		//width: parent.width / 2;
		//anchors.top: logoBg.bottom;
		//anchors.left: parent.left;
		//anchors.bottom: parent.bottom;
		////highlightColor: count && activeFocus ? colorTheme.activeFocusColor : "#0000";
		//anchors.margins: 10;
		//clip: true;
		//model: epgModel;
		//delegate: EPGDelegate { }

		//onRightPressed: { acceptedButton.setFocus(); }

		//onActiveFocusChanged: {
			//if (this.activeFocus)
				//programDescription.updateDescription()
		//}

		//onCurrentIndexChanged: { programDescription.updateDescription(); }
	//}

	//SmallText {
		//id: programDescription;
		//anchors.top: programsList.top;
		//anchors.left: programsList.right;
		//anchors.right: parent.right;
		//anchors.bottom: acceptedButton.top;
		//anchors.leftMargin: 10;
		//anchors.rightMargin: 10;
		//wrapMode: Text.Wrap;
		//color: colorTheme.activeTextColor;

		//updateDescription: { this.text = programsList.model.get(programsList.currentIndex).description }
	//}

	//Button {
		//id: acceptedButton;
		//anchors.left: programsList.right;
		//anchors.right: parent.right;
		//anchors.bottom: parent.bottom;
		//anchors.margins: 10;
		//text: "Телесмотреть";

		//onLeftPressed: { programsList.setFocus() }

		//onSelectPressed: {
			////channelInfoPanelProto.switched(channelInfoPanelProto.channel);
			////channelInfoPanelProto.hide();
		//}
	//}

	//Timer {
		//interval: 3000;
		//running: channelInfoPanelProto.visible;
		//repeat: channelInfoPanelProto.visible;

		//onTriggered: {
			//channelInfoPanelProto.isAlive()
			//channelInfoPanelProto.updateProgress()
		//}
	//}

	//onVisibleChanged: {
		//if (this.visible)
			//acceptedButton.setFocus()
	//}

	//function show(channel) {
		//this.visible = true
		////this.channel = channel

		//this.x = channel.x
		//panelXAnimation.complete()
		//this.y = channel.y
		//panelYAnimation.complete()

		//logoBg.color = channel.color
		//channelInfoTitle.text = channel.text
		//programsList.model.getEPGForChannel(channel.id);
		//programsList.currentIndex = 0;

		//this.width = channel.width
		//panelWidthAnimation.complete()
		//this.height = channel.height
		//selectedChannelLogo.source = channel.source
		//selectedChannelLogo.width = channel.width
		//selectedChannelLogo.height = channel.height
		//programDescription.text = "";

		//var w = safeArea.width / 3 * 2
		//this.width = w
		//this.height = safeArea.height - 50
		//this.x = safeArea.x - this.parent.x + (safeArea.width - w) /  2 - 70
		//this.y = safeArea.y - this.parent.y + 25
		//this.updateProgress()
	//}

	//hide: {
		//this.visible = false
	//}

	//updateProgress: {
		//var channel = this.channel
		//if (channel.program.startTime) {
			//var currDate = new Date();
			//var start = channel.program.startTime
			//var stop = channel.program.stopTime
			//currentProgress.progress = (currDate.getTime() - start.getTime()) / (stop.getTime() - start.getTime())
			//currentProgramText.text = channel.program.start + "-" + channel.program.stop + " " + channel.program.title
		//}
	//}

	//onBackPressed: {
		//this.hide();
		//return true;
	//}

	//Behavior on x { Animation { id: panelXAnimation; duration: 300; } }
	//Behavior on y { Animation { id: panelYAnimation; duration: 300; } }
	//Behavior on width { Animation { id: panelWidthAnimation; duration: 300; } }
}
