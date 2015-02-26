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

	Item {
		id: visibilityTest;
		Item {
			Item {
				onRecursiveVisibleChanged: {
					console.log("RECURSIVE VISIBILITY", this.recursiveVisible)
				}
			}
		}
	}

	onSelectPressed: {
		console.log("SELECT RV")
		visibilityTest.visible = !visibilityTest.visible
	}

	ListModel {
		id: animalModel;

		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }
		ListElement { type: "Dog"; age: 8; }
		ListElement { type: "Cat"; age: 5; }

		onCompleted: {
			console.log("hello", this.count);
		}
	}

	ListView {
		focus: true;
		clip: true;
		model: animalModel;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		keyNavigationWraps: false;
		width: contentWidth;
		contentY: 50;
		orientation: ListView.Vertical;
		delegate: Rectangle { width: 100; height: 100; color: activeFocus? "green": "yellow"; Text { anchors.centerIn: parent; color: "white"; text: model.type; } }
	}
}
