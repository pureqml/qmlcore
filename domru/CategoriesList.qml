Item {
	id: channelList;
	signal activated;
	signal channelSwitched;
	property Protocol protocol;
	property bool active: false;
	opacity: channelList.active ? 1.0 : 0.0;

	ChannelListModel {
		id: channelListModel;
		protocol: channelList.protocol;

		onCountChanged: {
			console.log("loaded " + this.count + " channel lists, using 0");
			channelModel.setList(this.get(0));
		}
	}

	ChannelModel {
		id: channelModel;
		protocol: channelList.protocol;

		onCountChanged: {
			if (this.count == 1)
				channelView.switchToChannel();
		}
	}

	Rectangle {
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.right: renderer.right;
		height: 120;

		gradient: Gradient {
			GradientStop { color: "#000"; position: 0; }
			GradientStop { color: "#000"; position: 0.6; }
			GradientStop { color: "#0000"; position: 1; }
		}
	}

	ListView {
		id: categoriesList;
		height: 70;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		spacing: 10;
		orientation: ListView.Horizontal;
		model: channelListModel;
		delegate: Item {
			width: categoryName.paintedWidth + 20;
			height: parent.height;

			Text {
				id: categoryName;
				font.pixelSize: 40;
				anchors.centerIn: parent;
				text: model.name;
				color: "#fff";
				opacity: parent.activeFocus ? 1.0 : 0.6;
			}
		}

		onDownPressed: { channelView.forceActiveFocus(); } 
		onLeftPressed: { channelView.forceActiveFocus(); } //TODO: fixme
		onRightPressed: { channelView.forceActiveFocus(); } //TODO: fixme
//		onCurrentIndexChanged: { channelModel.setList(channelModel.get(this.currentIndex)); }//TODO: fixme
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
//				channelView.currentIndex = model.index;
				channelView.switchToChannel(); 
			}
		}

		onUpPressed: {
			if (this.currentIndex)
				--this.currentIndex;
			else
				categoriesList.forceActiveFocus();
		}

		onSelectPressed: {
			channelView.switchToChannel();
		}

		switchToChannel: {
			channelList.active = false;
			var activated = channelList.activated
			this.model.getUrl(this.currentIndex, function(url) {
				activated(url)
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

	onLeftPressed: { --categoriesList.currentIndex; }
	onRightPressed: { ++categoriesList.currentIndex; }

	toggle: {
		channelList.active = !channelList.active;
		if (channelList.active)
			categoriesList.forceActiveFocus();
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
				console.log("Failed to find current programm.");
				return;
			}
			console.log("Current program: ", currProgram.title);
			var genres = currProgram.program.genres[0].name;
			for (var i = 1; i < currProgram.program.genres.length; ++i)
				genres += ", " + currProgram.program.genres[i].name;

			var startTime = new Date(currProgram.start * 1000);
			var endTime = new Date((currProgram.start + currProgram.duration) * 1000);
			var minutes = startTime.getMinutes();
			minutes = minutes >= 10 ? minutes : "0" + minutes;
			var info = startTime.getHours() + ":" + minutes;
			var minutes = endTime.getMinutes();
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

	Behavior on opacity { Animation { duration: 300; } }
}
