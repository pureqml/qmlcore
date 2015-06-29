Item {
	clip: true;

	Rectangle {
		id: programInfoChannelPlate;
		width: 100;
		height: 100;
		anchors.top: parent.top;
		anchors.left: parent.left;
	}

	Image {
		id: programInfoIcon;
		anchors.centerIn: programInfoChannelPlate;
	}

	Text {
		id: programInfoChannel;
		anchors.left: programInfoChannelPlate.right;
		anchors.verticalCenter: programInfoChannelPlate.verticalCenter;
		anchors.leftMargin: 20;
		font.pointSize: 26;
		color: colorTheme.textColor;
		bold: true;
	}

	Text {
		id: programInfoTime;
		anchors.left: parent.left;
		anchors.top: programInfoChannelPlate.bottom;
		anchors.topMargin: 10;
		color: colorTheme.textColor;
		font.pointSize: 20;
		bold: true;
	}

	Text {
		id: programInfoProgram;
		anchors.left: programInfoTime.right;
		anchors.right: parent.right;
		anchors.bottom: programInfoTime.bottom;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;
		color: colorTheme.textColor;
		font.pointSize: 18;
	}

	Text {
		id: programInfoDescription;
		anchors.top: programInfoTime.bottom;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 10;
		anchors.bottomMargin: 10;
		wrap: true;
	}

	setChannel(channel): {
		programInfoIcon.source = "";
		programInfoChannel.text = "";
		programInfoChannelPlate.color = "#fff";
		programInfoTime.text = "";
		programInfoProgram.text = "";
		programInfoDescription.text = "";

		if (!channel) {
			log("ProgrmInfo: Empty channel info.");
			return;
		}

		programInfoIcon.source = channel.source;
		programInfoChannel.text = channel.text;
		programInfoChannelPlate.color = channel.color;
	}

	setProgram(program): {
		programInfoTime.text = "";
		programInfoProgram.text = "";
		programInfoDescription.text = "";
		if (!program) {
			log("ProgrmInfo: Empty program info.");
			return;
		}

		programInfoTime.text = program.start != undefined ? program.start : "";
		programInfoProgram.text = program.start != undefined ? program.title : "";
		programInfoDescription.text = program.start != undefined ? program.description : "";
	}
}
