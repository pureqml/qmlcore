Activity {
	id: channelList;
	signal activated;
	signal channelSwitched;
	property Protocol protocol;
	opacity: channelList.active ? 1.0 : 0.0;
	name: "channelList";

	ChannelListModel {
		id: channelListModel;
		protocol: channelList.protocol;

		onCountChanged: {
			log("loaded " + this.count + " channel lists, using 0");
			channelModel.setList(this.get(0));
		}
	}

	ChannelModel {
		id: channelModel;
		property bool firstTime: true;
		protocol: channelList.protocol;

		onCountChanged: {
			if (this.count == 1 && this.firstTime) {
				channelView.switchToChannel();
				this.firstTime = false;
			}
		}
	}

	ListView {
		id: channelView;
		anchors.top: categoriesList.bottom;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: 100;
		anchors.left: parent.left;
		anchors.right: parent.right;
		focus: true;
		clip: true;
		opacity: channelList.active ? 1.0 : 0.0;
		model : channelModel;
		delegate: GreenButton {
			width: 400;
			color: "#000";
			height: 45;

			Text {
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 12;
				font.pixelSize: 24;
				text: model.er_lcn;
				color: "#aaa";
			}

			Text {
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 62;
				font.pixelSize: 24;
				text: model.title;
				color: "#fff";
			}

			Image {
				anchors.right: parent.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.rightMargin: 10;
				source: model.pictureUrl? model.pictureUrl + "/30x30:contain": "";
			}
			
			onTriggered: { 
				channelView.switchToChannel(); 
			}
		}

		onUpPressed: {
			if (this.currentIndex)
				--this.currentIndex;
			else
				categoriesList.forceActiveFocus();
		}

		onSelectPressed: { channelView.switchToChannel(); }

		switchToChannel: {
			this.parent.stop();
			var list = this._get('channelList')
			this.model.getUrl(this.currentIndex, function(url) {
				list.activated(url)
			})

			var curRow = this.model.get(this.currentIndex)

			var channelInfo = {
				number: 		curRow.er_lcn,
				title:			curRow.title,
				logo: 			curRow.pictureUrl + "/30x30:contain",
				description:	curRow.description,
				isHd:			curRow.traits == "HD",
				is3d:			curRow.traits == "3D"
			}
			channelList.channelSwitched(channelInfo)
		}
	}

	ChannelsListView {
		id: categoriesList;
		model: channelListModel;

		onDownPressed: { channelView.forceActiveFocus(); }
		onLeftPressed: { --categoriesList.currentIndex; }
		onRightPressed: { ++categoriesList.currentIndex; }

		onCurrentIndexChanged: {
			channelModel.setList(channelListModel.get(this.currentIndex));
			channelView.currentIndex = 0;
		}
	}

	onLeftPressed: { --categoriesList.currentIndex; }
	onRightPressed: { ++categoriesList.currentIndex; }
	onGreenPressed: { 
		if (this.active)
			this.stop();
		else
			this.start();
	}

	getProgramInfo(callback): {
		var curRow = channelView.model.get(channelView.currentIndex)
		var currChannel = curRow.title;

		channelModel.protocol.getEpgProgramByParams(curRow.epg_channel_id, function(res) {
			var programs = res.collection;
			if (!programs)
				return;

			var currentTime = Math.round(new Date().getTime() / 1000);
			var currProgram;
			for (var i in programs) {
				if (currentTime >= programs[i].start && currentTime <= programs[i].start + programs[i].duration) {
					currProgram = programs[i];
					break;
				}
			}
			if (!currProgram) {
				log("Failed to find current programm.");
				return;
			}
			log("Current program: ", currProgram.title);
			var genres = currProgram.program.genres[0].name;
			for (var i = 1; i < currProgram.program.genres.length; ++i)
				genres += ", " + currProgram.program.genres[i].name;

			var startTime = new Date(currProgram.start * 1000);
			var endTime = new Date((currProgram.start + currProgram.duration) * 1000);
			var minutes = startTime.getMinutes();
			minutes = minutes >= 10 ? minutes : "0" + minutes;
			var info = startTime.getHours() + ":" + minutes;
			minutes = endTime.getMinutes();
			minutes = minutes >= 10 ? minutes : "0" + minutes;
			info += " - " + endTime.getHours() + ":" + minutes;
			info += ", " + currChannel;
			if (genres)
				info += ", " + genres;
			if (currProgram.program.age_rating)
				info += ", " + currProgram.program.age_rating + "+";

			var programInfo = {
				age:			currProgram.program.age_rating,
				info:			info,
				title:			currProgram.title,
				genre:			genres,
				endTime:		endTime,
				duration:		currProgram.duration,	// in seconds
				startTime:		startTime,
				description:	currProgram.description
			}
			callback(programInfo);
		})
	}

	channelUp: {
		channelView.currentIndex--;
		channelView.switchToChannel();
	}

	channelDown: {
		channelView.currentIndex++;
		channelView.switchToChannel();
	}

	Behavior on opacity { Animation { duration: 300; } }
}
