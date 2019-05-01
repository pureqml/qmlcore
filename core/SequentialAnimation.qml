Object {
	property bool running: false;
	property bool trace: false;

	constructor: {
		this._sequence = []
		this._currentTarget = null
		this._currentProperty = null
	}

	onRunningChanged: {
		if (value)
		{
			if ($manifest$disableAnimations || this._sequence.length === 0) {
				this.running = false
				return
			}
			this._start(0)
		}
	}

	function _start(idx) {
		for(var i = idx, n = this._sequence.length; i < n; ++i) {
			var animation = this._sequence[i]
			var target = animation.target
			var property = animation.property
			var to = animation.to
			if (!target || !property || to === undefined) {
				log('invalid animation ', this.getComponentPath(), 'without target/property or to')
				continue
			}
			var from = animation.from
			if (from !== undefined) {
				if (this.trace)
					log('animation #' + idx + 'setting initial property value to', from)
				target[property] = from
			}

			if (target[property] === to) {
				if (this.trace)
					log('skipping animation #' + idx + ', same value')
					continue
			}
			if (this.trace)
				log('starting animation #' + idx, 'target', target.getComponentPath(), 'property', property, 'to', to)
			this._currentTarget = target
			this._currentProperty = property
			target.setAnimation(property, animation)
			target[property] = to
			return;
		}
		if (this.trace)
			log('animation sequence ', this.getComponentPath(), 'finished')
		this.running = false //no valid animation found
		return
	}

	function _onAnimationRunningChanged(animation, running) {
		if (this.trace)
			log('animation', animation.getComponentPath(), 'changed running to', running)
		if (!running) {
			this._currentTarget.resetAnimation(this._currentProperty)
			this._currentTarget = this._currentProperty = null
			var idx = this._sequence.indexOf(animation)
			this._start(idx + 1)
		}
	}

	function addChild (animation) {
		if (animation instanceof $core.Animation)
		{
			animation.cssTransition = false //we will add keyframe mode here later
			this._sequence.push(animation)
			this.connectOnChanged(animation, 'running', function(value) {
				this._onAnimationRunningChanged(animation, value)
			}.bind(this))
		}
		else
			$core.Object.prototype.addChild.call(this, animation)
	}
}
