ListModel {
	property string	channel;
	property bool	isBusy: false;

	getEPGForChannel(channel): {
		this.channel = channel;
		this.clear();
		this.isBusy = true;
		var self = this;
		this.protocol.getProgramsAtDate(new Date(), function(programs) {
			for (var i in programs) {
				if (programs[i].channel == self.channel) {
					var start = new Date(programs[i].start)
					start = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes();
					self.append({
						title: programs[i].title,
						start: start
					});
				}
			}
			self.isBusy = false;
		})
	}
}
