ListModel {
	property string providers: providersStorage.value;

	LocalStorage { id: providersStorage; name: "providers"; }

	update: {
		if (!this.protocol)
			return;

		providersStorage.read();
		var providersMap = providersStorage.value? JSON.parse(providersStorage.value): {};
		var self = this;

		this.protocol.getProviders(function(providers) {
			self.clear();
			for (var p in providers) {
				var activated = providers[p].authorized === false || providers[p].authorized === true ? providers[p].authorized : true;
				self.append({
					text: providers[p].alias,
					source: "http://truba.tv" + providers[p].icon,
					authorized: activated,
					enabled: providersMap ? providersMap[providers[p].alias] : true
				});
			}
		})
	}

	enable(idx): {
		var authorized = this.get(idx).authorized;
		if (authorized) {
			this.get(idx).enabled = !this.get(idx).enabled;
		} else {
		//TODO: Implement login dialog appearance.
		}
		this.save();
	}

	save: {
		var providersMap = {};
		for (var i = 0; i < this.count; ++i)
			providersMap[this.get(i).text] = this.get(i).enabled;
		providersStorage.value = JSON.stringify(providersMap);
	}

	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
}
