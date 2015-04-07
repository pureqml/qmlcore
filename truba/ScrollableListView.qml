ListView {
	id: scrollableListViewProto;
	dragEnabled: !scrollUpArea.containsMouse;

	MouseArea {
		id: scrollUpArea;
		height: 50;
		width: parent.width;
		anchors.top: parent.top;
		anchors.right: parent.right;
		anchors.left: parent.left;
		hoverEnabled: true;
		visible: parent.contentHeight > parent.height && parent.contentY > 0;
		z: parent.z + 1;

		Rectangle {
			anchors.fill: parent;
			gradient: Gradient {
				GradientStop {
					color: scrollUpArea.containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
					position: 0.0;

					Behavior on color { ColorAnimation { duration: 300; } }
				}

				GradientStop {
					color: "#0000";
					position: 1.0;

					Behavior on color { ColorAnimation { duration: 300; } }
				}
			}
		}

		Image {
			anchors.centerIn: parent;
			source: "res/nav_up.png";
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
		visible: parent.contentHeight > parent.height && parent.contentY < parent.contentHeight - parent.height;
		z: parent.z + 1;

		Rectangle {
			anchors.fill: parent;
			gradient: Gradient {
				GradientStop {
					color: "#0000";
					position: 0.0;

					Behavior on color { ColorAnimation { duration: 300; } }
				}

				GradientStop {
					color: scrollDownArea.containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
					position: 1.0;

					Behavior on color { ColorAnimation { duration: 300; } }
				}
			}
		}

		Image {
			anchors.centerIn: parent;
			source: "res/nav_down.png";
		}

		onClicked: { scrollableListViewProto.currentIndex++; }
	}
}
