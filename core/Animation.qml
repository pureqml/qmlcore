/**
controls property animation behavior in declarative way
Animation class works only for integral types, please use ColorAnimation for animating color properties
*/
Object {
	property int delay: 0;					///< delay in ms
	property int duration: 200;				///< duration in ms
	property bool cssTransition: true;		///< use css transition if possible
	property bool running: false;			///< currently running
	property string easing: "ease";			///< easing function

	constructor:	{ this._disabled = 0 }
	/// disable animation.
	disable:		{ ++this._disabled }
	/// enable animation.
	enable:			{ --this._disabled }
	/// returns true if animation is enabled
	enabled:		{ return this._disabled == 0 }

	/// @private
	function _update(name, value) {
		var parent = this.parent
		if (this._target && parent && parent._updateAnimation && parent._updateAnimation(this._target, this.enabled() ? this: null))
			return

		_globals.core.Object.prototype._update.apply(this, arguments);
	}

	/// @private
	function interpolate(dst, src, t) {
		return t * (dst - src) + src;
	}

	/// @private
	function complete() { }

}
