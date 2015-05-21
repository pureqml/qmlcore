ListModel {
	property string	channel;
	property Object epgMap;
	property bool	isBusy: false;

	getEPGForSearchRequest(request): {
		this.clear();
		for (var channel in this.epgMap) {
			for (var i in this.epgMap[channel]) {
				if (this.epgMap[channel][i].title.toLowerCase().indexOf(request) >= 0) {
					var start = this.epgMap[channel][i].start;
					start = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes();
					this.append({
						title: this.epgMap[channel][i].title,
						channel: this.epgMap[channel][i].channel,
						start: start
					});
				}
			}
		}
	}

	getEPGForChannel(channel): {
		this.channel = channel;
		this.clear();
		for (var i in this.epgMap[channel]) {
			var start = this.epgMap[channel][i].start;
			var now = new Date();
			if (start <= now)
				continue;
			start = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes();
			this.append({
				title: this.epgMap[channel][i].title,
				start: start
			});
		}
	}

	onIsBusyChanged: {
		if (!this.isBusy && this.channel)
			this.getEPGForChannel();
	}

	update: {
		if (!this.protocol)
			return;

		this.isBusy = true;
		this.epgMap = {};
		var self = this;
		this.protocol.getProgramsAtDate(new Date(), function(programs) {
			for (var i in programs) {
				var channel = programs[i].channel;
				if (!self.epgMap[channel])
					self.epgMap[channel] = [];
				self.epgMap[channel].push({
					title: programs[i].title,
					channel: programs[i].channel,
					start: new Date(programs[i].start),
					stop: new Date(programs[i].stop)
				});
			}
			self.isBusy = false;
		})
	}

	onCompleted:		{ this.update(); }
	onProtocolChanged:	{ this.update(); }
}
