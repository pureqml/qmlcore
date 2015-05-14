ListModel {
	getColor: {
		var colors = ["#CE93D8", "#FF8A80", "#90CAF9", "#80CBC4", "#F0F4C3", "#D7CCC8", "#FFCCBC"];
		return colors[Math.round(Math.random() * (colors.length - 1))];
	}

	setList(list): {
		this.clear();
		var self = this;

		for (var i = 0; i < list.length; ++i) {
			var channelColor = list[i].icon ? list[i].icon.color : this.getColor();
			this.append({
				text:	list[i].title,
				url:	list[i].url,
				lcn:	list[i].lcn,
				source:	list[i].icon ? "http://truba.tv" + list[i].icon.source : "",
				color:	channelColor,
				start:	"",
				stop:	"",
				programName: ""
			});

			var curChannel = list[i].title;
			var curIdx = i;
			var program = this.protocol.getCurrentPrograms(function(programs){
				for (var i in programs) {
					if (curChannel == programs[i].channel) {
						self.programDescription = programs[i].description;
						var start = new Date(programs[i].start);
						var stop = new Date(programs[i].stop);
						self._rows[curIdx].start = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes();
						self._rows[curIdx].stop = stop.getHours() + ":" + (stop.getMinutes() < 10 ? "0" : "") + stop.getMinutes();
						self._rows[curIdx].programName = programs[i].title;
						self.set(curIdx, self._rows[curIdx]);
						break;
					}
				}
			});
		}
	}
}
