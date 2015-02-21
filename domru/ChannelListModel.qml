ListModel {
	property Protocol protocol;

	onProtocolChanged: {
		if (!this.protocol)
			return

		var self = this;
		this.protocol.getChannelList(function(res) {
			res.channel_lists.forEach(function(list) { self.append(list); console.log(JSON.stringify(list)); })
		})
	}
}