ListModel {
	property Protocol protocol;

	onProtocolChanged: {
		if (!this.protocol)
			return

		var model = this;
		this.protocol.getChannelList(function(res) {
			res.channel_lists.forEach(function(list) { model.append(list); })
		})
	}
}