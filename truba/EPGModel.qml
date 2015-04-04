ListModel {
	property Object channelMap;

	getEPGForChannel(channel): {
		this.clear();
		for (var i in this.channelMap[channel])
			this.append(this.channelMap[channel][i]);
	}

	update: {
		var self = this;
		this.protocol.getPrograms(function(programs) {
			self.channelMap = {}
			for (var i in programs) {
				if (!self.channelMap[programs[i].channel])
					self.channelMap[programs[i].channel] = [];
				self.channelMap[programs[i].channel].push(programs[i]);
			}
		})
	}

	getProgramInfo(channel): 	{ return this.channelMap[channel]; }
	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
}
