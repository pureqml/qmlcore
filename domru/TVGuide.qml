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
			id: dateView;
			anchors.left: logo.right;
			anchors.right: tvGuideLabel.left;
			anchors.top: parent.top;
			anchors.leftMargin: 20;
			anchors.rightMargin: 20;
			orientation: ListView.Horizontal;
			height: 50;
			clip: true;
			model: ListModel {
				property int dayseBefore: 2;
				property int dayseAfter: 5;

				onCompleted: {
					var now = new Date();
					var week = [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ];
					var curDay = now.getDay();

					for (var i = -this.dayseBefore; i < 0; ++i) {
						var cur = (curDay + i) % 7;
						this.append({ text: week[cur >= 0 ? cur : 7 + cur] });
					}
					this.append({ text: "Сегодня" });
					this.append({ text: "Завтра" });
					for (var i = 1; i < this.dayseAfter; ++i) {
						var cur = (curDay + i) % 7;
						this.append({ text: week[cur >= 0 ? cur : 7 + cur] });
					}
				}
			}
			delegate: Item {
				width: 100;
				height: parent.height;

				Text {
					text: model.text;
					color: "#fff";
					font.pointSize: 14;
					anchors.horizontalCenter: parent.horizontalCenter;
				}

				Rectangle {
					height: 10;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.bottom: parent.bottom;
					color: parent.activeFocus ? "#f00" : "#ccc";
				}
			}
		}

		Text {
			id: tvGuideLabel;
			text: "ТВ-ГИД";
			font.pointSize: 32;
			anchors.right: parent.right;
			anchors.top: parent.top;
			color: "#fff";
		}

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
						border.width: activeFocus ? 5 : 0;

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
