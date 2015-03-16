ListModel {
	property Protocol protocol;


	getList(callback): {
		if (!this.protocol)
			return;

		this.protocol.getChannels(function(res) {
			callback(res);
		})
	}

	update: {
		this.clear();
		this.append({ text: "Все", source: "res/scrambled.png" });
	}

	onProtocolChanged: { this.update(); }
}
