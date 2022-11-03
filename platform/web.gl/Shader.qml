GlObject {
	/**@param {enum} type - shader type */
	property enum type { Vertex, Fragment };
	/**@param {string} sourceCode - shader source code */
	property string source;

	/// @private
	function getGlType() {
		var gl = this.glContext.gl
		switch(this.type) {
			case this.Vertex: 	return gl.VERTEX_SHADER
			case this.Fragment: return gl.FRAGMENT_SHADER
			default:
				throw new Error("getType " + this.type)
		}
	}

	onTypeChanged,
	onSourceChanged: {
		if (!this.source)
			return

		var gl = this.getGlContext()
		if (this._shader) {
			gl.deleteShader(this._shader)
			this._shader = null
		}

		var shader = gl.createShader(this.getGlType())
		gl.shaderSource(shader, this.source)
		gl.compileShader(shader)

		if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
			var info = gl.getShaderInfoLog(shader)
			gl.deleteShader(shader)
			throw new Error('Could not compile WebGL program: ' + info)
		}
		this._shader = shader
	}
}
