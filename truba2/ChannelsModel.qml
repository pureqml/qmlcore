ListModel {
	getColor: {
		var colors = ["#CE93D8", "#FF8A80", "#90CAF9", "#80CBC4", "#F0F4C3", "#D7CCC8", "#FFCCBC"];
		return colors[Math.round(Math.random() * (colors.length - 1))];
	}

	setList(list): {
		this.clear();

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
		}

		var self = this;
		this.protocol.getCurrentPrograms(function(programs) {
			for (var i in programs) {
				var rows = self._rows;
				for (var j = 0; j < rows.length; ++j) {
					var curChannel = self._rows[j].text;
					if (curChannel == programs[i].channel) {
						var start = new Date(programs[i].start);
						var stop = new Date(programs[i].stop);
						rows[j].start = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes();
						rows[j].stop = stop.getHours() + ":" + (stop.getMinutes() < 10 ? "0" : "") + stop.getMinutes();
						rows[j].programName = programs[i].title;
						self.set(j, rows[j]);
					}
				}
			}
		});
	}
}
