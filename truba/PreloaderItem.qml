Rectangle {
	property bool small: false;
	anchors.verticalCenter: parent.verticalCenter;
	height: small ? 20 : 10;
	width: height;
	color: "#fff";
	radius: width / 2;

	Behavior on width { Animation { duration: 300; } }
	Behavior on height { Animation { duration: 300; } }
}
