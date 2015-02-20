Item {
	property bool	autoPlay;
	property string	source;

	play: {
		this._player.get(0).play()
	}

	onSourceChanged: {
		console.log("source changed to", this.source)
		this._source.attr('src', this.source)
	}

	onWidthChanged: {
		if (this._player)
			this._player.attr('width', this.width)
	}

	onHeightChanged: {
		if (this._player)
			this._player.attr('height', this.height)
	}

	onCompleted: {
		this._player = $('<video width="' + this.width + '" height="' + this.height + '" ' + (this.autoPlay? "autoplay": "") + '>')
		this._player.css('background-color', 'black')
		this.element.append(this._player)
		this._source = $('<source src="' + this.source + '">')
		this._player.append(this._source)
	}
}
