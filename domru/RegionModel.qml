ListModel {
	property Protocol protocol;

	onCompleted: {
		if (!this.protocol)
			return;
		console.log("COMPLETED", this.protocol)
		var model = this
		var list = this.protocol.getRegionList(function(res) {
			console.log(res)
			var domains = res.domains
			for(var i = 0; i < domains.length; ++i)
				model.append(domains[i])
		})
	}
}
