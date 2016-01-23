Item {
	property int value;
	width: 100;
	height: 100;

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 1;

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.horizontalCenter: parent.horizontalCenter;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 2;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			height: parent.height / 2;
			anchors.top: parent.top;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			height: parent.height / 2;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 3;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 9;

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.height / 2;
			width: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.left: parent.left;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.right: parent.right;
			anchors.left: parent.left;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.bottom: parent.bottom;
			anchors.right: parent.right;
			anchors.left: parent.left;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.right: parent.right;
			anchors.left: parent.left;
			color: colorTheme.itemsColor;
		}
	}


	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 8;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 7;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 6;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			height: parent.height / 2;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 5;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			height: parent.height / 2;
			anchors.top: parent.top;
			anchors.left: parent.left;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			height: parent.height / 2;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 4;

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			height: parent.height / 2;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 0;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.leftMargin: parent.size;
			anchors.rightMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			anchors.topMargin: parent.size;
			anchors.bottomMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: parent.size;
			anchors.rightMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.topMargin: parent.size;
			anchors.bottomMargin: parent.size;
			color: colorTheme.itemsColor;
		}
	}

	Item {
		property int size: 20;
		width: 100;
		height: 150;
		visible: parent.value == 10;

		Rectangle {
			height: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.leftMargin: 2 * parent.size;
			anchors.rightMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			anchors.topMargin: parent.size;
			anchors.bottomMargin: parent.size;
			anchors.leftMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			height: parent.size;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: 2 * parent.size;
			anchors.rightMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.topMargin: parent.size;
			anchors.bottomMargin: parent.size;
			anchors.leftMargin: parent.size;
			color: colorTheme.itemsColor;
		}

		Rectangle {
			width: parent.size;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.right: parent.left;
			color: colorTheme.itemsColor;
		}
	}
}
