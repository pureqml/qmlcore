Item {
	id: tvGuideProto;
	property Protocol protocol;
	anchors.fill: renderer;

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.7;
	}

	ListModel {
		id: tvGuideChannelModel;

		onCompleted: {
			var startTime = Math.round(new Date().getTime() / 1000);
			var endTime = startTime;
			startTime -= 2 * 24 * 3600;
			endTime += 7 * 24 * 3600;

			var options = {
				select: 'title,start,duration',
				startFrom: startTime,
				startTo: endTime
			};

			var model = this;
			tvGuideProto.protocol.getChannelsWithSchedule(options, function(result) {
				for (var i in result.channels)
					model.append(result.channels[i])
			});
		}
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
				height: 50;
				width: parent.width;

				Rectangle {
					id: channelRect;
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
						text: model.epg_channel_id;
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

				ListView {
					height: 50;
					anchors.left: channelRect.right;
					anchors.right: parent.right;
					clip: true;
					spacing: 10;
					orientation: ListView.Horizontal;
					model: ProgramsModel {
						channelIdx: model.index;
						parentModel: tvGuideChannelModel;
					}
					delegate: Rectangle {
						width: model.duration / 12;
						height: 40;
						color: "#333";
						clip: true;
						border.color: "#fff";
						border.width: parent.activeFocus && activeFocus ? 5 : 0;

						Text {
							id: programTitleText;
							anchors.left: parent.left;
							anchors.verticalCenter: parent.verticalCenter;
							text: model.title;
						}
					}
				}
			}
		}
	}
}
