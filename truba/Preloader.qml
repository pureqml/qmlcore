Item {
	width: 500;
	height: 100;

	Row {
		id: preloaderRow;
		width: contentWidth;
		height: parent.height;
		anchors.centerIn: parent;
		orientation: ListView.Horizontal;
		spacing: 10;

		PreloaderItem { small: true; }
		PreloaderItem {}
		PreloaderItem {}
	}

	Timer {
		property int currentItem;
		interval: 300;
		running: parent.visible;
		repeat: true;

		onTriggered: {
			this.currentItem = (this.currentItem + 1) % preloaderRow.children.length;
			var idx = this.currentItem;
			preloaderRow.children[this.currentItem].small = !preloaderRow.children[this.currentItem].small;
		}
	}
}
