ListModel {
	property Protocol protocol;

	onCompleted: {
		if (!this.protocol)
			return;

		var self = this
		var list = this.protocol.getRegionList(function(res) {
			res.domains.forEach(function(row) { self.append(row) })
		})
	}
}
