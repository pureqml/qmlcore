Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.margins: 100;

	Button {
		id: button1;
		text: "Click me";
		onDownPressed: {
			button2.forceActiveFocus();
		}
	}

	Button {
		id: button2;
		anchors.top: button1.bottom;
		anchors.topMargin: 10;
		text: "Don't click me";
		onUpPressed: {
			button1.forceActiveFocus();
		}
		onDownPressed: {
			button3.forceActiveFocus();
		}
	}

	Button {
		id: button3;
		anchors.top: button2.bottom;
		anchors.topMargin: 10;
		text: "JUST DON'T";
		color: "red";
		onUpPressed: {
			button2.forceActiveFocus();
		}
	}

	onCompleted: {
		button1.forceActiveFocus();
	}
}
