ListModel {
	property string defaultProvider;

	update: {
		if (!this.protocol)
			return;

		this.defaultProvider = "";
		var self = this;

		this.protocol.getProviders(function(providers) {
			self.clear();
			for (var p in providers) {
				if (providers[p].name == "Ondatara")
					self.defaultProvider = providers[p].alias;

				self.append({
					id: providers[p].alias,
					text: providers[p].name,
					source: "http://truba.tv" + providers[p].icon
				});
			}
		})
	}

	onCompleted:		{ this.update(); }
	onProtocolChanged:	{ this.update(); }
}
