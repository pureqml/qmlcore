Item {
	id: keyboardProto;
	signal keySelected;
	signal backspase;
	property int currentRow;
	width: 420;
	height: 480;

	ListModel {
		id: keyboardModel;
		property int language: 0;
		property int mode: 0;
		property string rusLetters: "абвгдеёжзийклмнопрстуфхцчшщъыьэюя.,1234567890";
		property string engLetters: "abcdefghijklmnopqrstuvwxyz.,1234567890";
		property string rusLettersUp: "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ.,1234567890";
		property string engLettersUp: "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,1234567890";
		property string special: "!#$%&+?/:;_-*@";
		property string letters: mode == 2 ? special :
			language == 0 && mode == 0 ? rusLetters :
			language == 0 && mode == 1 ? rusLettersUp :
			language == 1 && mode == 0 ? engLetters : engLettersUp;

		fill: {
			this.clear();
			this.append({});
			this.append({});
			if (this.mode == 2)
				return;
			this.append({});
			this.append({});
			this.append({});
			this.append({});
			this.append({});
			if (this.language == 0)
				this.append({});
		}

		switchLanguage: {
			this.language = (++this.language % 2);
			this.fill();
		}

		switchCase: {
			this.mode = (++this.mode % 3);
			this.fill();
		}

		onCompleted: { this.fill(); }
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
			handleNavigationKeys: false;
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

			onCurrentIndexChanged: { keyboardProto.currentRow = this.currentIndex; }
			onLeftPressed: { --this.currentIndex; }

			onRightPressed: {
				if (this.currentIndex == this.count - 1)
					event.accepted = false;
				else
					++this.currentIndex;
			}

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

		//TODO: Try something better this hardcode.
		onDownPressed: {
			if (keyboardModel.mode != 2 && this.currentIndex == this.count - 3) {
				if (keyboardProto.currentRow == 3 || keyboardProto.currentRow == 4)
					keyboardProto.currentRow = 3;
				if (keyboardProto.currentRow == 5 || keyboardProto.currentRow == 6)
					keyboardProto.currentRow = 4;
			} else if (keyboardModel.mode != 2 && this.currentIndex == this.count - 2) {
				if (keyboardProto.currentRow == 0 || keyboardProto.currentRow == 1)
					keyboardProto.currentRow = 0;
				if (keyboardProto.currentRow == 2 || keyboardProto.currentRow == 3)
					keyboardProto.currentRow = 1;
				if (keyboardProto.currentRow == 4)
					keyboardProto.currentRow = 2;
			}
			this.currentIndex++;
		}

		onUpPressed: {
			if (keyboardModel.mode != 2 && this.currentIndex == this.count - 1) {
				if (keyboardProto.currentRow == 0)
					keyboardProto.currentRow = 0;
				if (keyboardProto.currentRow == 1)
					keyboardProto.currentRow = 3;
				if (keyboardProto.currentRow == 2)
					keyboardProto.currentRow = 4;
			} else if (keyboardModel.mode != 2 && this.currentIndex == this.count - 2) {
				if (keyboardProto.currentRow == 3)
					keyboardProto.currentRow = 3;
				if (keyboardProto.currentRow == 4)
					keyboardProto.currentRow = 5;
			}
			this.currentIndex--;
		}
	}

	switchLanguage: { keyboardModel.switchLanguage(); }
	switchCase: { keyboardModel.switchCase(); }
}
