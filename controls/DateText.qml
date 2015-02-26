Text {
	property Date date;

	onDateChanged: {
		var monthList = [
			'январь',
			'февраль',
			'март',
			'апрель',
			'май',
			'июнь',
			'июль',
			'август',
			'сентябрь',
			'октябрь',
			'ноябрь',
			'декабрь'
		]
		var week = [ 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' ]
		var date = this.date
		var month = monthList[date.getMonth()]
		this.text = date.getDate() + " " + month + " " + week[date.getDay()]
	}
}