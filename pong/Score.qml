Item {
	property int value;
	width: 100;
	height: 100;

	Text {
		id: scoreText;
		anchors.centerIn: parent;
		color: colorTheme.itemsColor;
		font.pixelSize: 72;
		text: "0";
	}

	onValueChanged: { scoreText.text = value.toString() }
}
