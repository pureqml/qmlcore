MouseArea {
	height: 50;
	hoverEnabled: true;

	Text {
		id: linkText;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		verticalAlignment: Text.AlignVCenter;
		horizontalAlignment: Text.AlignHCenter;
		text: "Try Beta";
		font.pixelSize: 24;
		color: colorTheme.textColor;
	}

	onClicked: { window.location.href = "http://beta.truba.tv"; }
}
