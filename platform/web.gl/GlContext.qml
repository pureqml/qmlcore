/// Canvas with initialized WebGl indeside
Canvas {
	id: localGlContext;
	signal drawScene;	///< triggered on scene rendering with time delta argument

	constructor: {
		var names = ["webgl", "experimental-webgl", "webkit-3d", "moz-webgl"]
		var gl = null
		for (var i = 0; i < names.length; ++i) {
			try {
				gl = this.getContext(names[i]);
			} catch (e) {
				log("Failed to create GL context", e)
			}
			if (gl)
				break;
		}
		this.gl = gl
	}

	/// @private
	function render(now) {
		var deltaTime
		now *= 0.001
		if (this.then === null) {
			deltaTime = 0
			this.then = now
		} else {
			deltaTime = now - this.then
			this.then = now
		}
		this.drawScene(deltaTime)
		requestAnimationFrame(this.render.bind(this))
	}

	/// @private
	function startRender() {
		this.then = null
		requestAnimationFrame(this.render.bind(this))
	}

	onWidthChanged,
	onHeightChanged: {
		this.gl.viewport(0, 0, this.width, this.height)
	}
}
