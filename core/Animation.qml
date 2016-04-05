Object {
	property int duration: 200;
	property bool cssTransition: true;
	property bool running: false;
	property string easing: "ease";

	constructor:	{ this._disabled = 0 }
	disable:		{ ++this._disabled }
	enable:			{ --this._disabled }
	enabled:		{ return this._disabled == 0 }

	function _update(name, value) {
		var parent = this.parent
		if (this._target && parent && parent._updateAnimation && parent._updateAnimation(this._target, this.enabled() ? this: null))
			return

		qml.core.Object.prototype._update.apply(this, arguments);
	}

	function interpolate(dst, src, t) {
		return t * (dst - src) + src;
	}

	function complete() { }

}
