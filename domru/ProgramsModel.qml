ListModel {
	property Object parentModel;
	property int channelIdx;

	onCompleted: {
		var row = this.parentModel.get(this.channelIdx).schedule;

		var daysBefore = 2;
		var startTime = Math.round(new Date().getTime() / 1000) - daysBefore * 24 * 3600;
		var delta = row[0].start - startTime;
		if (delta > 0)
			this.append({
				title: "Нет информации",
				start: startTime,
				duration: delta,
				empty: true
			});
		this.append({
			title: row[0].title,
			start: row[0].start,
			duration: row[0].duration + delta
		});
		for (var i = 1; i < row.length; ++i)
			this.append(row[i]);

		var daysAfter = 5;
		var endTime = Math.round(new Date().getTime() / 1000) - daysAfter * 24 * 3600;
		delta = row[row.length - 1].start - endTime;
		if (delta > 0)
			this.append({
				title: "Нет информации",
				start: row[row.length - 1].start,
				duration: delta,
				empty: true
			});
	}
}
