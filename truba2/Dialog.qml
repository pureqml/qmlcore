Activity {
	id: dialogProto;
	signal accepted;
	signal canceled;
	property string okText:	"OK";
	property string cancelText: "Отмена";
	property string title: "";
	property int innerWidth: renderer.width / 3;
	property int innerHeight: renderer.height / 3;
	anchors.left: renderer.left;
	anchors.right: renderer.right;
	width: renderer.width;
	height: renderer.height;
	visible: active;

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: true;
	}

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.5;
	}

	Rectangle {
		width: parent.innerWidth;
		height: parent.innerHeight;
		color: colorTheme.backgroundColor;
		anchors.centerIn: parent;

		Text {
			anchors.top: parent.top;
			anchors.topMargin: 10;
			width: parent.width;
			horizontalAlignment: Text.AlignHCenter;
			text: dialogProto.title;
			color: colorTheme.textColor;
			font.pointSize: 24;
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 10;
			spacing: 10;

			Button {
				text: dialogProto.okText;
				onClicked: { dialogProto.accepted(); }
			}

			Button {
				text: dialogProto.cancelText;
				onClicked: { dialogProto.canceled(); }
			}
		}
	}

	onCanceled: { this.stop(); }
}
