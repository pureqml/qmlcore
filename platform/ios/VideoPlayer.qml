Item {
	signal error;
	signal finished;
	property string	source;
	property Color	backgroundColor: "#000";
	property float	volume: 1.0;
	property bool	loop: false;
	property bool	ready: false;
	property bool	muted: false;
	property bool	paused: false;
	property bool	autoPlay: false;
	property bool	waiting: false;
	property bool	seeking: false;
	property int	duration;
	property int	progress;
	property int	buffered;

	PropertyStorage { id: volumeStorage; name: "volume"; }

	play: { }
	stop: { }
	pause: { }
	seek(value): { }
	seekTo(value): { }

	volumeUp:			{ this.volume += 0.1 }
	volumeDown:			{ this.volume -= 0.1 }
	toggleMute:			{ this.element.dom.muted = !this.element.dom.muted }
	onVolumeChanged:	{ this.applyVolume() }

	applyVolume: {
		if (this.volume > 1.0)
			this.volume = 1.0;
		else if (this.volume < 0.0)
			this.volume = 0.0;

		volumeStorage.value = this.volume
		this.element.dom.volume = this.volume
	}
}
