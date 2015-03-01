ListModel {
	property Object parentModel;
	property int channelIdx;

	onCompleted: {
		var row = this.parentModel.get(this.channelIdx).schedule;
		for (var i in row)
			this.append(row[i]);
	}
}
