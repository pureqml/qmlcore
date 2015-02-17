Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.margins: 100;
	Column {
		id: col;
		Text { text: "line 1"; }
		Text { text: "line 2"; }
		Text { text: "line 3"; }
		Text { text: "line 4"; }
	}

	Row {
		anchors.left: col.right;
		Text { text: "word 1"; }
		Text { text: "word 2"; }
		Text { text: "word 3"; }
		Text { text: "word 4"; }
	}

	ListModel {
		id: animalModel;
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		onCompleted: {
			console.log("hello", this.count);
		}
	}

	ListView {
		model: animalModel;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		width: 200;
		contentY: 50;
		delegate: Rectangle { width: 100; height: 100; color: "green"; Text { anchors.centerIn: parent; color: "white"; text: /*model.type*/ "Test"; } }
	}
}
