Item {
	id: textEditProto;
	property alias text: innerText.text;
	property Color color: "#000";
	property bool cursorVisible: true;
	property Font font: Font {}
	focus: true;

	Rectangle {
		id: cursor;
		width: 2;
		height: innerText.paintedHeight;
		anchors.verticalCenter: parent.verticalCenter;
		x: innerText.paintedWidth;
		color: textEditProto.color;
		visible: parent.activeFocus && textEditProto.cursorVisible;
	}

	Text {
		id: innerText;
		anchors.verticalCenter: parent.verticalCenter;
		color: textEditProto.color;
		text: textEditProto.text;
		font: textEditProto.font;
		font.pointSize: 24;
		onCompleted: {
			this.style('white-space', 'pre')
		}
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

        onEntered: {
			if (!this.activeFocus)
				this.forceActiveFocus();
        }
    }

	removeChar: { textEditProto.text = textEditProto.text.slice(0, textEditProto.text.length - 1); }
	onTextChanged: { log("TextEdit::TextChanged: ", this.text); }
}
