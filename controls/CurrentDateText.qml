Text {
	updateText: {
		var now = new Date();
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
		var month = monthList[now.getMonth()]
		this.text = now.getDate() + " " + month + ", " + week[now.getDay()]
	}

	Timer {
		duration: 1000;
		running: true;
		repeat: parent.recursiveVisible;

		onTriggered: {
			this.parent.updateText();
		}
	}
}