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

	constructor:	{ this._disabled = 0; this._native = false }
	/// disable animation.
	disable:		{ ++this._disabled; this._updateAnimation() }
	/// enable animation.
	enable:			{ --this._disabled; this._updateAnimation() }
	/// returns true if animation is enabled
	enabled:		{ return this._disabled == 0 }

	/// @private
	onDelayChanged,
	onDurationChanged,
	onCssTransitionChanged,
	onRunningChanged,
	onEasingChanged: { this._updateAnimation() }

	function active() {
		return this.enabled() && this.duration > 0
	}

	function _updateAnimation() {
		if (this._target)
			this._target.updateAnimation(this._property, this)
	}

	/// @private
	function interpolate(dst, src, t) {
		return t * (dst - src) + src;
	}

	/// @private
	function complete() { }

}
