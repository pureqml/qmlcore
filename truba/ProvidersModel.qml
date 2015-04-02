ListModel {
	property Protocol	protocol;
	property bool		showActivatedOnly: true;

	update: {
		var self = this;
		this.protocol.getProviders(function(result) {
			var providers = {}
			for (var i in result) {
				providers[result[i].alias] = {}
				providers[result[i].alias]['name'] = result[i].alias;
				providers[result[i].alias]['authorized'] = result[i].authorized;
				providers[result[i].alias]['genres'] = [];
			}

			self.protocol.getChannels(function(list) {
				self.clear();

				var defaultGenre = "Разное";
				var defaultProvider = "Нет провайдера";

				for (var i in list) {
					var provider = list[i].provider ? list[i].provider : defaultProvider;
					if (!providers[provider])
						providers[provider] = {};

					if (!list[i].genres || list[i].genres.length == 0) {
						if (!providers[provider]['genres'][defaultGenre])
							providers[provider]['genres'][defaultGenre] = [];
						providers[provider]['genres'][defaultGenre].push(list[i]);
					} else {
						for (var j in list[i].genres) {
							var genre = list[i].genres[j];
							if (!providers[provider]['genres'][genre])
								providers[provider]['genres'][genre] = [];
							providers[provider]['genres'][genre].push(list[i]);
						}
					}
				}

				for (var p in providers) {
					if (self.showActivatedOnly && providers[p]['authorized'] === false)
						continue;
					var activated = providers[p].authorized === false || providers[p].authorized === true ? providers[p].authorized : true;
					self.append({
						text: p,
						icon: providers[p].icon,
						authorized: activated,
						genres: providers[p].genres
					});
				}
			})
		})
	}

	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
	onShowActivatedOnlyChanged:	{ this.update(); }
}
