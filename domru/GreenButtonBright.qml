Rectangle {
	id: buttonProto;
	property string text;

	gradient: Gradient {
		GradientStop { 
			color: buttonProto.activeFocus ? "#326b01" : "#fff"; 
			position: 0.0; 

			Behavior on color { ColorAnimation { duration: 300; } }
		}

		GradientStop { 
			color: buttonProto.activeFocus ? "#438f01" : "#fff"; 
			position: 0.9;

			Behavior on color { ColorAnimation { duration: 300; } }
		}
	}

	Text {
		anchors.centerIn: parent;
		text: buttonProto.text;
		color: parent.activeFocus ? "#fff" : "#000";
		font.pointSize: 14;

		Behavior on color { ColorAnimation { duration: 300; } }
	}
}
