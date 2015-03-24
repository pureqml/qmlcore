ListModel {
	property Protocol protocol;

	update: {
		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();

			var map = {};
			var defaultName = "Разное";
			for (var i in list)
			{
				if (list[i].genre)
				{
					if (!map[list[i].genre])
						map[list[i].genre] = [];
					map[list[i].genre].push(list[i]);
				}
				else
				{
					if (!map[defaultName])
						map[defaultName] = [];
					map[defaultName].push(list[i]);
				}
			}

			for (var genre in map)
				self.append({ text: genre, list: map[genre] });
		})
	}

	onProtocolChanged: { this.update(); }
	onCompleted: { this.update(); }
}
