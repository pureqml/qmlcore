ListModel {
	property Protocol	protocol;
	property bool		showActivatedOnly: true;

	update: {
		if (!this.protocol)
			return;

		var self = this;
		this.protocol.getProviders(function(providers) {
			for (var p in providers) {
				if (self.showActivatedOnly && providers.authorized === false)
					continue;
				var activated = providers[p].authorized === false || providers[p].authorized === true ? providers[p].authorized : true;
				self.append({
					text: providers[p].alias,
					source: "http://truba.tv" + providers[p].icon,
					authorized: activated
				});
			}
		})
	}

	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
	onShowActivatedOnlyChanged:	{ this.update(); }
}
