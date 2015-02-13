Item {
	id: mainWindow;
	anchors.fill: renderer;

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
		text: "Don't click me";
		onUpPressed: {
			button2.forceActiveFocus();
		}
	}
}
