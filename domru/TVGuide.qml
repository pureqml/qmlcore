Item {
	id: tvGuideProto;
	anchors.fill: renderer;
	property Protocol protocol;

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.7;
	}

	ChannelListModel {
		protocol: tvGuideProto.protocol;

		onCountChanged: { tvGuideChannelModel.setList(this.get(0)); }
	}

	ChannelModel {
		id: tvGuideChannelModel;
		protocol: tvGuideProto.protocol;
	}
	
	Item {
		anchors.fill: parent;
		anchors.leftMargin: 75;
		anchors.rightMargin: 75;
		anchors.bottomMargin: 40;
		anchors.topMargin: 42;

		DomruLogo { id: logo; }

		ListView {
			anchors.top: logo.bottom;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.margins: 20;
			clip: true;
			spacing: 5;
			model: tvGuideChannelModel;
			delegate: Item {
				//height: activeFocus ? 100 : 50;
				height: 50;
				width: parent.width;

				Rectangle {
					anchors.left: parent.left;
					anchors.top: parent.top;
					anchors.leftMargin: 5;
					height: parent.height;
					width: 300;
					color: "#333";
					border.color: "#fff";
					border.width: parent.activeFocus ? 5 : 0;

					Text {
						anchors.left: parent.left;
						anchors.verticalCenter: parent.verticalCenter;
						anchors.leftMargin: 12;
						font.pixelSize: 16;
						text: model.er_lcn;
						color: "#aaa";
					}

					Text {
						anchors.left: parent.left;
						anchors.verticalCenter: parent.verticalCenter;
						anchors.leftMargin: 48;
						font.pixelSize: 16;
						text: model.title;
						color: "#fff";
					}

					Image {
						anchors.right: parent.right;
						anchors.verticalCenter: parent.verticalCenter;
						anchors.rightMargin: 10;
						source: model.pictureUrl? model.pictureUrl + "/30x30:contain": "";
					}
				}
			}
		}
	}
}
