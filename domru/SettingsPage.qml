Item {
	anchors.fill: renderer;

	Rectangle {
		id: infoPanel;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		width: 200;
		color: "#000";
		opacity: 0.7;
	}

	//TODO: Use GridView whem it's done instead.
	ListView {
		id: optionsGrid;
		width: 200 * 3 + 2 * spacing;
		anchors.left: infoPanel.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		orientation: ListView.Horizontal;
		spacing: 10;

		model: ListModel {
			property string text;
			property string additopnalText;
			property string icon;

			ListElement { text: "Персональная информация"; icon: "res/settings.png"; }
			ListElement { text: "Оповещения"; icon: "res/settings.png"; additopnalText: 5; }
			ListElement { text: "Управление пакетами"; icon: "res/settings.png"; }
		}
		delegate: Rectangle {
			width: 200;
			height: 220;
			border.color: "#fff";
			border.width: activeFocus ? 10 : 0;
			gradient: Gradient {
				GradientStop { 
					color: "#326b01"; 
					position: 0; 

					Behavior on color { ColorAnimation { duration: 300; } }
				}
				GradientStop { 
					color: "#438f01"; 
					position: 1.0;

					Behavior on color { ColorAnimation { duration: 300; } }
				}
			}

			Image {
				anchors.centerIn: parent;
				anchors.bottomMargin: 20;
				source: model.icon;
			}

			Text {
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.margins: 20;
				font.pointSize: 16;
				color: "#fff";
				text: model.text;
				wrap: true;
			}

			Text {
				anchors.top: parent.top;
				anchors.right: parent.right;
				anchors.margins: 20;
				font.pointSize: 14;
				color: "#fff";
				text: model.additopnalText;
			}
		}
	}

	Rectangle {
		id: optionsAdPanel;
		anchors.left: optionsGrid.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		width: 200;
		color: "#ff0";
	}
}
