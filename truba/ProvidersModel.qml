ListModel {
	property Protocol protocol;

	update: {
		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();

			var map = {};
			var defaultGenre = "Разное";
			var defaultProvider = "Нет провайдера";

			for (var i in list) {
				var provider = list[i].provider ? list[i].provider : defaultProvider;
				if (!map[provider])
					map[provider] = {};
				
				if (!list[i].genres || list[i].genres.length == 0) {
					if (!map[provider][defaultGenre])
						map[provider][defaultGenre] = [];
					map[provider][defaultGenre].push(list[i]);
				} else {
					for (var j in list[i].genres) {
						var genre = list[i].genres[j];
						if (!map[provider][genre])
							map[provider][genre] = [];
						map[provider][genre].push(list[i]);
					}
				}
			}

			for (var provider in map) {
				self.append({ text: provider, genres: map[provider] });
			}
		})
	}

	onProtocolChanged:	{ this.update(); }
	onCompleted:		{ this.update(); }
}
