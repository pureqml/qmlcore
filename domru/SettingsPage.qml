Item {
	id: settingsPageProto;
	signal focusReturned;
	anchors.fill: parent;

	Image {
		id: infoPanel;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.leftMargin: 10;
		source: "res/ad2.png";
	}

	GridView {
		id: optionsGrid;
		width: 210 * 3;
		anchors.left: infoPanel.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		cellWidth: 210;
		cellHeight: 230;
		rows: 2;
		columns: 3;
		spacing: 10;
		delegate: OptionsDelegate { }
		model: ListModel {
			property string text;
			property string additopnalText;
			property string icon;

			ListElement { text: "Персональная информация"; icon: "res/settings.png"; }
			ListElement { text: "Пополнить счет банк.картой"; icon: "res/settings.png"; }
			ListElement { text: "Оповещения"; icon: "res/settings.png"; additopnalText: 5; }
			ListElement { text: "Настройки каналов"; icon: "res/settings.png"; }
			ListElement { text: "Управление услугами"; icon: "res/settings.png"; }
			ListElement { text: "Помощь"; icon: "res/settings.png"; }
		}
	}

	Image {
		id: optionsAdPanel;
		anchors.left: optionsGrid.right;
		anchors.top: parent.top;
		source: "res/ad1.png";
	}
}
