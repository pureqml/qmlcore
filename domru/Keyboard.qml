Item {
	id: keyboardProto;
	signal keySelected;
	signal backspase;
	property int currentRow;
	width: 420;
	height: 480;

	ListModel {
		id: keyboardModel;
		property string rusLetters: "абвгдеёжзийклмнопрстуфхцчшщъыьэюя.,1234567890";
		property string engLetters: "abcdefghijklmnopqrstuvwxyz";

		ListElement { }
		ListElement { }
		ListElement { }
		ListElement { }
		ListElement { }
		ListElement { }
		ListElement { }
		ListElement { }
	}

	ListView {
		anchors.fill: parent;
		spacing: 5;
		model: keyboardModel;
		delegate: ListView {
			spacing: 5;
			width: parent.width;
			height: 45;
			orientation: ListView.Horizontal;
			keyNavigationWraps: false;
			model: KeyboardRowModel {
				parentModel: keyboardModel;
				begin: model.index * 7;
				end: begin + 7;
			}
			delegate: Rectangle {
				id: key;
				height: 45;
				width: model.widthScale ? model.widthScale * (height + 5) - 5 : height;
				color: model.contextColor ? model.contextColor : "#444";
				border.color: "#fff";
				border.width: activeFocus && parent.activeFocus ? 5 : 0;
				
				Text {
					id: keyText;
					anchors.centerIn: parent;
					text: model.text;
					color: "#fff";
				}

				Image {
					anchors.centerIn: parent;
					source: model.icon;
					visible: model.icon;
				}
			}

			onLeftPressed: { --this.currentIndex; }
			onRightPressed: { ++this.currentIndex; }
			onCurrentIndexChanged: { keyboardProto.currentRow = this.currentIndex; }

			onSelectPressed: {
				var row = this.model.get(this.currentIndex);
				if (row.text)
					keyboardProto.keySelected(row.text);
				else
					keyboardProto.backspase();
			}

			onActiveFocusChanged: {
				if (this.activeFocus)
					this.currentIndex = keyboardProto.currentRow;
			}
		}
	}
}
