Rectangle {
	id: buttonProto;
	property string text: "";
	color: activeFocus ? octoColors.accentColor : octoColors.focusablePanelColor;
	height: buttonInnerText.paintedHeight + 20;
	width: buttonInnerText.paintedWidth + 20;
	radius: 4;
	focus: true;

	MainText {
		id: buttonInnerText;
		anchors.centerIn: parent;
		colol: octoColors.textColor;
		text: buttonProto.text;
	}

	Behavior on color { ColorAnimation { duration: 300; } }
}
