ListModel {
	property Protocol	protocol;
	property Object		allProviders;
	property bool		showActivatedOnly: true;

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
				if (self.showActivatedOnly)
					self.append({
						text: provider,
						genres: map[provider]
					});
				else
					self.allProviders[provider].activated = true;
			}

			if (self.showActivatedOnly)
				return;

			for (var i in self.allProviders)
				self.append(self.allProviders[i]);
		})
	}

	onProtocolChanged:			{ this.update(); }
	onShowActivatedOnlyChanged:	{ this.update(); }

	onCompleted: {
		this.allProviders = {};

		this.allProviders["rt"] = {
			text: "Ростелеком",
			icon: "res/providers/rt.png",
			activated: false
		};
		this.allProviders["public"] = {
			text: "Public domain",
			icon: "res/providers/public.png",
			activated: false
		};
		this.allProviders["dom"] = {
			text: "Дом.ру",
			icon: "res/providers/dom.png",
			activated: false
		};
		this.allProviders["interz"] = {
			text: "Inter Z",
			icon: "res/providers/izet.png",
			activated: false
		};

		this.update();
	}
}
