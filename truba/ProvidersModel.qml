ListModel {
	id: providersModelProto;
	property string defaultProvider: "bat";
	property string choosedProvider: "";

	LocalStorage {
		id: lastProvider;
		name: "lastProvider";

		onCompleted: {
			this.read();
			var provider = lastProvider.value ? JSON.parse(lastProvider.value) : { }

			if (provider && provider.id)
				providersModelProto.choosedProvider = provider.id
			else
				providersModelProto.choosedProvider = providersModelProto.defaultProvider
			providersModelProto.update();
		}
	}

	update: {
		if (!this.protocol)
			return;

		var self = this;

		this.protocol.getProviders(function(providers) {
			self.clear();
			for (var p in providers) {
				self.append({
					id: providers[p].alias,
					text: providers[p].name,
					source: "http://truba.tv" + providers[p].icon,
					selected: self.choosedProvider == providers[p].alias
				});
			}
		})
	}

	saveProvider(idx): {
		lastProvider.value = JSON.stringify(this.get(idx))
		this.choosedProvider = this.get(idx).id
	}

	onProtocolChanged:	{ this.update(); }
}
