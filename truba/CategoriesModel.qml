ListModel {
	property Protocol protocol;

	update: {
		if (!this.protocol)
			return
	
		var self = this;
		this.protocol.getChannels(function(res) {
			//log("res " + res);
		})
	}

	onProtocolChanged: { this.update(); }
}
