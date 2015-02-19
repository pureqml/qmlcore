Item {
	anchors.fill: parent;

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

		onCompleted: {
			console.log("hello", this.count);
		}
	}

	ListView {
	 	model: listsModel;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: 60;
		spacing: 20;
		orientation: 1;
	 	delegate: Text { 
 			color: "blue"; 
 			text: model.name; 
			font.pointSize: 24;
 		} 
	}
}