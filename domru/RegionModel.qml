ListModel {
	property Protocol protocol;

	onCompleted: {
		if (!this.protocol)
			return;

		var model = this
		var list = this.protocol.getRegionList(function(res) {
			res.domains.forEach(function(row) { model.append(row) })
		})
	}
}
