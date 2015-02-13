Item {
	id: mainWindow;
	anchors.fill: renderer;

	Button {
		id: button1;
		text: "Click me";
	}
	Button {
		id: button2;
		anchors.top: button1.bottom;
		text: "Don't click me";
	}
}
