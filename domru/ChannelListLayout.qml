Item {
	anchors.fill: parent;
	clip: true;

	ListModel {
		id: listsModel;
		property string name;

		ListElement { name: "ТВ"; }
		ListElement { name: "HDTV"; }
		ListElement { name: "3D каналы"; }
		ListElement { name: "Мой список каналов"; }
		ListElement { name: "Спорт"; }
		ListElement { name: "Детям"; }
		ListElement { name: "Только фильмы"; }
		ListElement { name: "Музыкальные каналы"; }
		ListElement { name: "Развлекательное"; }
	}

	ListModel {
		id: channelsModel;
		property string name;

		ListElement { name: "Первый"; }
		ListElement { name: "Россия 1"; }
		ListElement { name: "Спорт ХД"; }
		ListElement { name: "Mezzo Live"; }
		ListElement { name: "Карусель"; }
		ListElement { name: "ОТР"; }
		ListElement { name: "ТНТ"; }
		ListElement { name: "НТВ"; }
		ListElement { name: "Lifenews"; }
		ListElement { name: "Первый"; }
		ListElement { name: "Россия 1"; }
		ListElement { name: "Спорт ХД"; }
		ListElement { name: "Mezzo Live"; }
		ListElement { name: "Карусель"; }
		ListElement { name: "ОТР"; }
		ListElement { name: "ТНТ"; }
		ListElement { name: "НТВ"; }
		ListElement { name: "Lifenews"; }
	}

	ListView {
		id: listsList;
	 	model: listsModel;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		clip: true;
		height: 60;
		spacing: 20;
		orientation: ListView.Horizontal;
		focus: true;
	 	delegate: Text {
	 		id: listDelegate;
 			color: "blue"; 
 			text: model.name; 
			font.pointSize: activeFocus ? 40 : 24;
			width: paintedWidth;
 		} 
	}

	ListView {
		id: channelsList;
	 	model: channelsModel;
		anchors.top: listsList.bottom;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: 90;
		anchors.left: parent.left;
		spacing: 2;
		width: 400;
		clip: true;
		focus: true;
	 	delegate: GreenButton {
	 		height: 65;
	 		width: parent.width;
	 		Text {
	 			anchors.centerIn: parent;
	 			color: "blue"; 
	 			text: model.name; 
				font.pointSize: 24;
				width: paintedWidth;
	 		}
		}
	}
}