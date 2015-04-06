Activity {
	anchors.fill: parent;
	visible: active;
	name: "vodpanel";

	GridView {
		anchors.centerIn: parent;
		width: parent.width - 100;
		height: parent.height - 100;
		cellWidth: 150;
		cellHeight: 200;
		model: ListModel {
			//property string name;
			//property string poster;

			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
			//ListElement { name: "The Movie"; poster: "res/poster.jpg"; }
		}
		delegate: Rectangle {
			width: parent.cellWidth;
			height: parent.cellHeight;
			color: colorTheme.backgroundColor;
			border.color: colorTheme.activeBackgroundColor;
			border.width: activeFocus ? 5 : 0;

			Image {
				id: poster;
				width: 100;
				height: 150;
				anchors.top: parent.top;
				anchors.horizontalCenter: parent.horizontalCenter;
				anchors.topMargin: 5;
				source: model.poster;
			}

			Text {
				width: poster.paintedWidth;
				anchors.horizontalCenter: parent.horizontalCenter;
				horizontalAlignment: Text.AlignHCenter;
				anchors.top: poster.bottom;
				font.pointSize: 14;
				clipt: true;
				color: colorTheme.textColor;
				text: model.name;
			}
		}
	}

	Rectangle {
		height: 150;
		width: 300;
		anchors.centerIn: parent;
		radius: 16;
		color: colorTheme.backgroundColor;

		Text {
			width: parent.width;
			height: parent.height;
			verticalAlignment: Text.AlignVCenter;
			horizontalAlignment: Text.AlignHCenter;
			color: colorTheme.textColor;
			text: "Раздел находиться в разработке";
			font.pointSize: 18;
			wrap: true;
		}

		Behavior on opacity { Animation { duration: 300; } }
	}
}
