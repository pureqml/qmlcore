Item {
	property bool	autoPlay;
	property string	source;

	property bool	flash : true;
	property bool	ready : false;
	property float	volume: 1.0;

	LocalStorage { id: volumeStorage; name: "volume"; }

	play: {
		if (!this.source)
			return

		console.log("play", this.source)
		if (this.flash) {
			var player = this.getObject('videoPlayer')
			if (!player || !player.playerLoad) //flash player is not ready yet
				return

			player.playerLoad(this.source)
			player.playerPlay(-1)
		}
		else
			this._player.get(0).play()

		this.applyVolume();
	}

	onAutoPlayChanged: {
		if (value)
			this.play()
	}

	onSourceChanged: {
		log("source changed to", this.source)
		if (!this.flash) {
			this._player.attr('src', this.source)
		}
		if (this.autoPlay)
			this.play()
	}

	onWidthChanged: {
		if (!this._player)
			return;
		if (this.flash) {
			$('#videoPlayer').attr('width', value)
			$('embed[name=videoPlayer]').attr('width', value)
		} else
			this._player.attr('width', this.width)
	}

	onHeightChanged: {
		if (!this._player)
			return;
		if (this.flash) {
			$('#videoPlayer').attr('height', value)
			$('embed[name=videoPlayer]').attr('height', value)
		} else
			this._player.attr('height', this.height)
	}

	onCompleted: {
		if (navigator.userAgent.indexOf('Android') >= 0 || navigator.userAgent.indexOf('iPhone') >= 0)
			this.flash = false

		if (!this.flash) {
			this._player = $('<video preload="metadata" width="' + this.width +
				'" height="' + this.height +
				'" src="' + this.src +
				'" controls ' +
				' ' + (this.autoPlay? "autoplay": "") + '>')
			this._player.css('background-color', 'black')
		} else {
			console.log("creating object")
			this._player = $(
				'<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="" id="videoPlayer" width="' + this.width + '" height="' + this.height + '">' +
				'<param name="movie"  value="flashlsChromeless.swf?inline=1" />' +
				'<param name="quality" value="autohigh" />' +
				'<param name="swliveconnect" value="true" />' +
				'<param name="allowScriptAccess" value="sameDomain" />' +
				'<param name="bgcolor" value="#0" />' +
				'<param name="allowFullScreen" value="true" />' +
				'<param name="wmode" value="window" />' +
				'<embed src="flashlsChromeless.swf?inline=1" width="' + this.width + '" height="' + this.height + '" name="videoPlayer" quality="autohigh" bgcolor="#0" align="middle" allowFullScreen="true" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" swliveconnect="true" wmode="window" pluginspage="http://www.macromedia.com/go/getflashplayer"> </embed>' +
				'</object>'
			)
		}
		this.element.append(this._player)
		if (this.autoPlay)
			this.play()

		volumeStorage.read();

		this.volume = volumeStorage.value ? +(volumeStorage.value) : 1.0;
	}

	Timer {
		interval: 500;
		repeat: true;
		running: true;

		onTriggered: { this.parent.ready = this.parent._player.get(0).readyState ||
			this.parent.flash; }	//TODO: temporary fix.
	}

	Timer {
		interval: 100;
		repeat: true;
		running: true; //fixme: rewrite as 'parent.flash && !parent.flashReady'

		onTriggered: {
			var parent = this.parent
			if (!parent.flash)
				return

			var player = parent.getObject('videoPlayer')
			if (player && player.playerLoad) {
				console.log("flash player is ready")
				this.running = false;
				if (parent.autoPlay)
					parent.play()
			}
		}
	}

	getObject(name): {
		if (window.document[name])
			return window.document[name];
		if (navigator.appName.indexOf("Microsoft Internet")==-1) {
			if (document.embeds && document.embeds[name])
				return document.embeds[name];
		} else
			return document.getElementById(name);
	}

	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume;

		if (this.flash) {
			var player = this.getObject('videoPlayer')
			if (!player || !player.playerLoad)
				return
			player.playerVolume(100 * this.volume)
		} else if (this._player) {
			this._player.get(0).volume = this.volume;
		}
	}

	volumeUp:			{ this.volume += 0.1; }
	volumeDown:			{ this.volume -= 0.1; }
	onVolumeChanged:	{ this.applyVolume(); }
	onReadyChanged:		{ log("ReadyState: " + this.ready); }
}
