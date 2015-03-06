ListView {
	height: 70;
	anchors.top: parent.top;
	anchors.left: parent.left;
	width: contentWidth;
	spacing: 10;
	orientation: ListView.Horizontal;
	delegate: Item {
		width: categoryName.paintedWidth + 20;
		height: parent.height;

		Text {
			id: categoryName;
			font.pixelSize: 40;
			anchors.centerIn: parent;
			text: model.name;
			color: "#fff";
			opacity: parent.activeFocus ? 1.0 : 0.6;
		}
	}

	Rectangle {
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.right: renderer.right;
		height: parent.height + 50;
		z: parent.z - 2;

		gradient: Gradient {
			GradientStop { color: "#000"; position: 0; }
			GradientStop { color: "#000"; position: 0.6; }
			GradientStop { color: "#0000"; position: 1; }
		}
	}
}
