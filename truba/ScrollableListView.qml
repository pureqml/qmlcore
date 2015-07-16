ListView {
	id: scrollableListViewProto;
	hoverEnabled: !scrollUpArea.containsMouse;

	MouseArea {
		id: scrollUpArea;
		height: 50;
		width: parent.width;
		anchors.top: parent.top;
		anchors.right: parent.right;
		anchors.left: parent.left;
		hoverEnabled: true;
		visible: parent.contentHeight > parent.height && parent.contentY > 0 && parent.count;
		z: parent.z + 1;

		Rectangle {
			anchors.fill: parent;
			color: scrollUpArea.containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
		}

		Image {
			anchors.centerIn: parent;
			source: "res/up.png";
		}

		onClicked: { scrollableListViewProto.currentIndex--; }
	}

	MouseArea {
		id: scrollDownArea;
		height: 50;
		width: parent.width;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.left: parent.left;
		hoverEnabled: true;
		visible: parent.contentHeight > parent.height && parent.contentY < parent.contentHeight - parent.height && parent.count;
		z: parent.z + 1;

		Rectangle {
			anchors.fill: parent;
			color: scrollDownArea.containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
		}

		Image {
			anchors.centerIn: parent;
			source: "res/down.png";
		}

		onClicked: { scrollableListViewProto.currentIndex++; }
	}
}
