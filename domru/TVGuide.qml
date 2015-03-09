Activity {
	id: tvGuideProto;
	property Protocol protocol;
	anchors.fill: renderer;

	ChannelListModel {
		id: tvGuideChannelListModel;
		protocol: tvGuideProto.protocol;

		onCountChanged: {
			if (this.count == 1)
				tvGuideChannelModel.update();
		}
	}

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.7;
	}

	ListModel {
		id: tvGuideChannelModel;

		update: {
			if (!tvGuideChannelListModel.count) {
				log("No channels list found.");
				return;
			}
			var startTime = Math.round(new Date().getTime() / 1000);
			var endTime = startTime;
			startTime -= 2 * 24 * 3600;
			endTime += 5 * 24 * 3600;

			var cat = tvGuideListsItem.model.get(tvGuideListsItem.currentIndex);
			var options = {
				select: 'title,start,duration',
				startFrom: startTime,
				startTo: endTime,
				category: cat.id
			};

			var model = this;
			model.reset();
			tvGuideProto.protocol.getChannelsWithSchedule(options, function(result) {
				for (var i in result.channels)
					model.append(result.channels[i]);
			});
		}

		onCompleted: { this.update(); }
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
			anchors.left: parent.left;
			anchors.right: tvGuideLabel.left;
			anchors.top: parent.top;
			anchors.leftMargin: 200;
			anchors.rightMargin: 20;
			orientation: ListView.Horizontal;
			height: 50;
			clip: true;
			model: ListModel {
				property int daysBefore: 2;
				property int daysAfter: 5;

				onCompleted: {
					var now = new Date();
					var week = [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ];
					var curDay = now.getDay();

					for (var i = -this.daysBefore; i < 0; ++i) {
						var cur = (curDay + i) % 7;
						this.append({ text: week[cur >= 0 ? cur : 7 + cur] });
					}
					this.append({ text: "Сегодня" });
					this.append({ text: "Завтра" });
					for (var i = 2; i <= this.daysAfter; ++i) {
						var cur = (curDay + i) % 7;
						this.append({ text: week[cur >= 0 ? cur : 7 + cur] });
					}
				}
			}
			delegate: Item {
				width: dayDelegateText.paintedWidth + 60;
				height: parent.height;

				Text {
					id: dayDelegateText;
					text: model.text;
					color: "#fff";
					font.pointSize: 14;
					anchors.horizontalCenter: parent.horizontalCenter;
					opacity: parent.activeFocus ? 1.0 : 0.6;
				}

				Rectangle {
					height: 10;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.bottom: parent.bottom;
					color: parent.activeFocus ? "#f00" : "#ccc";
				}
			}

			onDownPressed: { tvGuideChannels.forceActiveFocus(); }

			onCurrentIndexChanged: {
				this._get("tvGuideChannels").shift = this.currentIndex * 24 * 360;

				var curMin = new Date().getMinutes();
				var min = curMin > 30 ? 0 : 30;

				curMin = curMin ? curMin : 60;
				min = min ? min : 60;
				this._get("timeLineList").shift = (30 - (min - curMin)) * 6 - 90;
				timeLineList.contentX = this.currentIndex * 24 * 360 + this._get("timeLineList").shift;
			}
		}

		Image {
			source: "res/nav_up.png";
			anchors.bottom: programmsHead.top;
			anchors.horizontalCenter: tvGuideChannels.horizontalCenter;
			opacity: tvGuideChannels.currentIndex ? 1.0 : 0.0;

			Behavior on opacity { Animation { duration: 300; } }
		}

		Image {
			source: "res/nav_down.png";
			anchors.top: tvGuideChannels.bottom;
			anchors.horizontalCenter: tvGuideChannels.horizontalCenter;
			opacity: tvGuideChannels.currentIndex < tvGuideChannels.count - 1 ? 1.0 : 0.0;

			Behavior on opacity { Animation { duration: 300; } }
		}

		Image {
			source: "res/nav_left.png";
			anchors.right: tvGuideChannels.left;
			anchors.verticalCenter: tvGuideChannels.verticalCenter;
			visible: tvGuideChannels.count; 
			opacity: dateView.currentIndex ? 1.0 : 0.0;

			Behavior on opacity { Animation { duration: 300; } }
		}

		Image {
			source: "res/nav_right.png";
			anchors.left: tvGuideChannels.right;
			anchors.verticalCenter: tvGuideChannels.verticalCenter;
			visible: tvGuideChannels.count; 
			opacity: dateView.currentIndex < dateView.count - 1 ? 1.0 : 0.0;

			Behavior on opacity { Animation { duration: 300; } }
		}

		Item {
			id: programmsHead;
			height: 50;
			anchors.top: logo.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: 40;

			Rectangle {
				id: headChannelsRect;
				width: 200;
				height: parent.height;
				anchors.top: parent.top;
				anchors.left: parent.left;
				color: "#333";

				Text {
					anchors.centerIn: parent;
					font.pixelSize: 16;
					text: "Все каналы";
					color: "#aaa";
				}
			}

			Rectangle {
				height: parent.height;
				anchors.top: parent.top;
				anchors.left: headChannelsRect.right;
				anchors.right: parent.right;
				anchors.leftMargin: tvGuideChannels.spacing;
				color: headChannelsRect.color;
				clip: true;

				ListView {
					id: timeLineList;
					property int shift;
					anchors.fill: parent;
					orientation: ListView.Horizontal;
					focus: false;
					contentFollowsCurrentItem: false;
					model: ListModel {
						onCompleted: {
							var daysBefore = 2;
							var daysAfter = 5;
							var hours = new Date().getHours();
							var min = new Date().getMinutes();

							if (min > 30) {
								++hours;
								min = 0;
							} else if (min) {
								min = 30;
							}

							for (var i = 0; i < (daysAfter + daysBefore + 1) * 48; ++i) {
								this.append({ text: hours + ":" + (min ? min : ("0" + min)) });
								min = min == 0 ? 30 : 0;
								if (!min)
									hours = (hours + 1) % 24;
							}
						}
					}
					delegate: Item {
						width: 180;	// 6 * 30 = 180, 6pix per minute.
						height: parent.height;

						Text {
							anchors.centerIn: parent;
							text: model.text;
							color: "#aaa";
						}
					}
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
			id: tvGuideChannels;
			property int shift;
			anchors.top: programmsHead.bottom;
			anchors.bottom: tvGuideFooter.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: spacing;
			anchors.leftMargin: -spacing;
			anchors.bottomMargin: spacing;
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
					width: 200;
					color: "#333";
					clip: true;
					border.color: "#fff";
					border.width: parent.activeFocus ? 5 : 0;
					focus: true;

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

					//Image {
						//anchors.right: parent.right;
						//anchors.verticalCenter: parent.verticalCenter;
						//anchors.rightMargin: 10;
						//source: model.pictureUrl? model.pictureUrl + "/30x30:contain": "";
					//}

					onRightPressed: { this._get("brickWall").forceActiveFocus(); }
				}

				ListView {
					id: brickWall;
					height: parent.height + spacing * 2;
					anchors.left: channelRect.right;
					anchors.right: parent.right;
					anchors.top: parent.top;
					anchors.topMargin: -spacing;
					anchors.leftMargin: spacing;
					contentX: tvGuideChannels.shift;
					contentFollowsCurrentItem: false;
					clip: true;
					spacing: 5;
					orientation: ListView.Horizontal;
					model: ProgramsModel {
						channelIdx: model.index;
						daysBefore: 2;
						daysAfter: 5;
						parentModel: tvGuideChannelModel;
					}
					delegate: Rectangle {
						id: programDelegate;
						property int start: model.start;
						width: model.duration / 10;
						height: 50;
						anchors.verticalCenter: parent.verticalCenter;
						color: "#333";
						clip: true;
						border.color: "#fff";
						border.width: activeFocus ? 5 : 0;
						opacity: model.empty ? 0.6 : 1.0;

						EllipsisText {
							anchors.left: parent.left;
							anchors.right: parent.right;
							anchors.verticalCenter: parent.verticalCenter;
							anchors.rightMargin: 5;
							color: "#fff";
							text: model.title;
						}
					}

					onActiveFocusChanged: {
						if (!this.activeFocus)
							return;
						for (var i in this._items) {
							if (this._items[i].viewX >= this.contentX) {
								this.currentIndex = i;
								break;
							}
						}
					}
				}
			}

			onUpPressed: {
				if (this.currentIndex == 0)
					dateView.forceActiveFocus();
				else
					--this.currentIndex;
			}

			onDownPressed: {
				if (this.currentIndex == this.count - 1) {
					tvGuideContextMenu.currentIndex = 0;
					tvGuideContextMenu.forceActiveFocus();
				} else {
					++this.currentIndex;
				}
			}
		}

		Rectangle {
			id: currentTimeLine;
			width: 4;
			anchors.top: tvGuideChannels.top;
			anchors.bottom: tvGuideChannels.bottom;
			x: 4 + headChannelsRect.width + timeLineList.contentX - 2 * 24 * 360 - timeLineList.shift;
			color: "#f00";
			visible: tvGuideChannels.count;

			Behavior on x { Animation { duration: 300; } }
		}

		ChannelsListView {
			id: tvGuideListsItem;
			height: 120;
			model: tvGuideChannelListModel;
			visible: false;
			z: tvGuideProto.z + 1;

			onLeftPressed: { --tvGuideListsItem.currentIndex; }
			onRightPressed: { ++tvGuideListsItem.currentIndex; }

			onDownPressed: {
				this.hide();
				dateView.forceActiveFocus();
			}

			onSelectPressed: {
				tvGuideListsItem.hide();
				tvGuideChannelModel.update();
			}

			onBackPressed: {
				this.visible = false;
				dateView.forceActiveFocus();
			}

			hide: {
				tvGuideListsItem.visible = false;
				dateView.forceActiveFocus();
			}
		}
	}

	Item {
		id: tvGuideFooter;
		height: 20;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;

		ListModel {
			id: tvGuideContextModel;
			property string text;
			property Color color;

			ListElement { text: "список задач"; color: "#f00"; }
			ListElement { text: "сейчас"; color: "#00ab5f"; }
			ListElement { text: "списки каналов"; color: "#ff0"; }
			ListElement { text: "помощь"; color: "#00f"; }
		}

		ContextMenu {
			id: tvGuideContextMenu;
			model: tvGuideContextModel;

			onUpPressed: { tvGuideChannels.forceActiveFocus(); }
			processRed: {}
			processBlue: {}
			processGreen: {}

			processYellow: {
				if (tvGuideListsItem.visible) {
					tvGuideListsItem.hide();
				} else {
					tvGuideListsItem.visible = true;
					tvGuideLists.forceActiveFocus();
				}
			}

			onOptionChoosed(text): {
				if (text == "список задач")
					this.processRed();
				else if (text == "сейчас")
					this.processGreen();
				else if (text == "списки каналов")
					this.processYellow();
				else if (text == "помощь")
					this.processBlue();
			}

			onRightPressed: {
				if (this.currentIndex < this.count - 1) {
					this.currentIndex++;
				} else {
					tvguideOptions.currentIndex = 0;
					tvguideOptions.forceActiveFocus();
				}
			}
		}

		ListModel {
			id: tvguideOptionsModel;
			property string text;
			property string source;

			ListElement { text: "Назад"; source: "res/back.png"; }
			ListElement { text: "Выход"; source: "res/exit.png"; }
		}

		Options {
			id: tvguideOptions;
			model: tvguideOptionsModel;

			onUpPressed: { timePanel.forceActiveFocus(); }
			onCurrentIndexChanged: { hideTimer.restart(); }

			onLeftPressed: {
				if (this.currentIndex) {
					this.currentIndex--;
				} else {
					tvGuideContextMenu.currentIndex = tvGuideContextMenu.count - 1;
					tvGuideContextMenu.forceActiveFocus();
				}
			}

			onOptionChoosed(text): { tvGuideProto.stop(); }
		}
	}

	onActiveChanged: {
		if (!this.active)
			this.visible = false;
	}

	onVisibleChanged: {
		if (this.visible) {
			dateView.currentIndex = 2;
			dateView.forceActiveFocus();
		}
	}

	onYellowPressed: { tvGuideContextMenu.processYellow(); }
}
