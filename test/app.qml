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
					log("RECURSIVE VISIBILITY", this.recursiveVisible)
				}
			}
		}
	}

	onSelectPressed: {
		log("SELECT RV")
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
			log("hello", this.count);
		}
	}

	GridView {
		id: zoo;
		anchors.right: parent.right;
		focus: true;
		clip: true;
		model: animalModel;
		width: 300;
		height: 300;
		keyNavigationWraps: false;

		delegate: Rectangle {
			effects.blur: 2;
			effects.hueRotate: 90;
			width: 100; height: 100; color: activeFocus? "green": "yellow"; Text { anchors.centerIn: parent; color: "white"; text: model.type; } }
	}
}
