Item {
	id: textEditProto;
	property alias text: innerText.text;
	property Color color: "#fff";
	property bool cursorVisible: true;
	focus: true;

	Rectangle {
		id: cursor;
		x: innerText.paintedWidth;
		width: 2;
		height: parent.height;
		color: textEditProto.color;
		visible: parent.activeFocus && textEditProto.cursorVisible;
	}

	Text {
		id: innerText;
		anchors.verticalCenter: parent.verticalCenter;
		color: textEditProto.color;
		text: textEditProto.text;
	}

	Timer {
		running: parent.activeFocus && textEditProto.cursorVisible;
		repeat: true;
		duration: 1000;

		onTriggered: { cursor.visible = !cursor.visible; }
	}

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;
        z: parent.z + 1;

		onClicked: { button.triggered(); }
        onEntered: {
			if (!this.activeFocus)
				this.forceActiveFocus();
        }
    }

	removeChar: { innerText.text = innerText.text.slice(0, innerText.text.length - 1); }
	onTextChanged: { console.log("TextEdit::TextChanged: ", this.text); }
}
