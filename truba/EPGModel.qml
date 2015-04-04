ListModel {
	property Object programMap;

	update: {
		var self = this;
		this.protocol.getPrograms(function(programs) {
			self.programMap = {};
			for (var i in programs) {
				self.programMap[programs[i].channel] = {
					start: programs[i].start,
					stop: programs[i].stop,
					title: programs[i].title,
					description: programs[i].description
				}
			}
		})
	}

	getProgramInfo(channel): 	{ return this.programMap[channel]; }
	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
	onShowActivatedOnlyChanged:	{ this.update(); }
}
