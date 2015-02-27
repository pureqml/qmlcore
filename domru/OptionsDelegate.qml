Rectangle {
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
		anchors.margins: 15;
		font.pointSize: 16;
		color: "#fff";
		text: model.text;
		wrap: true;
	}

	Text {
		anchors.top: parent.top;
		anchors.right: parent.right;
		anchors.margins: 15;
		font.pointSize: 14;
		color: "#fff";
		text: model.additopnalText;
	}
}
