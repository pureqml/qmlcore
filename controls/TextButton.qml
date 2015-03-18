BaseButton {
	width: 140;
	height: 60;
	property string text;
//	width: internalText.width + 30; //causes page crash 

	Text {
		id: internalText;
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		text: parent.text;
		font.pointSize: 16;
		color: "white";
		wrap: true;
	}
}