ListModel {
	property string provider;
	property Object repository;

	update: {
		if (!this.protocol)
			return;

		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();
			self.repository = {};

			if (!self.provider) {
				log("Provider is undefined.");
				return;
			}

			var defaultGenre = "Разное";
			var map = {};

			for (var i in list) {
				if (self.provider != list[i].provider)
					continue;

				if (!list[i].genres || list[i].genres.length == 0) {
					if (!map[defaultGenre])
						map[defaultGenre] = [];
					list[i].genre = defaultGenre;
					map[defaultGenre].push(list[i]);
				} else {
					for (var j in list[i].genres) {
						var genre = list[i].genres[j];
						if (!map[genre])
							map[genre] = [];
						list[i].genre = genre;
						map[genre].push(list[i]);
					}
				}
			}

			for (var genre in map) {
				self.repository[genre] = map[genre];
				self.append({
					text: genre,
					list: map[genre]
				});
			}
		})
	}

	findChannels(request): {
		var result = []
		if (!request)
			return result;

		log("search channels: " + request);

		for (var genre in this.repository)
			for (var i in this.repository[genre])
				if (this.repository[genre][i].title.toLowerCase().indexOf(request.toLowerCase()) + 1)
					result.push(this.repository[genre][i])
		return result
	}

	onProviderChanged:			{ this.update(); }
	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
}
