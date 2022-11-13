GlObject {
	/// Shaders attached to this program
	property array shaders;
	/// Object with automatic properties reflecting program attrs
	property Object attr;
	/// Object with automatic properties reflecting program uniforms
	property Object uniform;

	function __link() {
		var gl = this.getGlContext()
		var program = this._program
		gl.linkProgram(program)
		if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
			throw new Error('Unable to initialize the shader program: ' + gl.getProgramInfoLog(program))
		}

		var attrObject = new Object()
		var addAttr = function(i) {
			var desc = gl.getActiveAttrib(program, i)
			var loc = gl.getAttribLocation(program, desc.name)
			Object.defineProperty(attrObject, desc.name, {
				get: function() {
					return { loc: loc, desc: desc}
				},
				set: function(value) {
					value.attachAttr(loc, desc)
				}
			})
		}
		for(var i = 0, n = gl.getProgramParameter(program, gl.ACTIVE_ATTRIBUTES); i < n; ++i) {
			addAttr(i)
		}

		var uniformObject = new Object()
		var addUniform = function(i) {
			var desc = gl.getActiveUniform(program, i)
			var loc = gl.getUniformLocation(program, desc.name)
			Object.defineProperty(uniformObject, desc.name, {
				get: function() {
					return gl.getUniform(program, loc)
				},
				set: function(value) {
					switch(desc.type) {
						case gl.FLOAT_MAT4:
							gl.uniformMatrix4fv(loc, false, value);
							break

						default:
							throw new Error("Unhandled type " + desc.type + " for uniform " + desc.name)
					}
				}
			})
		}
		for(var i = 0, n = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS); i < n; ++i) {
			addUniform(i)
		}
		this.attr = attrObject
		this.uniform = uniformObject
	}

	function attach(shader) {
		var gl = this.getGlContext()
		gl.attachShader(this._program, shader._shader)
	}

	function use() {
		var gl = this.getGlContext()
		gl.useProgram(this._program)
	}

	onShadersChanged: {
		var gl = this.getGlContext()
		this._program = gl.createProgram()
		var shaders = this.shaders
		for(var i = 0; i < shaders.length; ++i) {
			var shader = shaders[i]
			this.attach(shader)
		}
		this.__link()
	}
}
