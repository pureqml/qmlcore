GlObject {
	property int components;
	property enum type { Float, Int, Bool };
	property enum target { Array, ElementArray };
	property enum usage { StaticDraw, DynamicDraw, StreamDraw };
	property bool normalize;
	property int stride;
	property int offset;

	property array data;

	function getGlType() {
		var gl = this.getGlContext()
		switch(this.type) {
			case this.Float:
				return gl.FLOAT
			case this.Int:
				return gl.INT
			case this.Bool:
				return gl.BOOL
			default:
				throw new Error("Invalid type " + this.type)
		}
	}

	function getGlTarget() {
		var gl = this.getGlContext()
		switch(this.target) {
			case this.Array:
				return gl.ARRAY_BUFFER
			case this.ElementArray:
				return gl.ELEMENT_ARRAY_BUFFER;
			default:
				throw new Error("Invalid target " + this.target)
		}
	}

	function getGlUsage() {
		var gl = this.getGlContext()
		switch(this.usage) {
			case this.StaticDraw:
				return gl.STATIC_DRAW
			case this.DynamicDraw:
				return gl.DYNAMIC_DRAW
			case this.StreamDraw:
				return gl.STREAM_DRAW
			default:
				throw new Error("Invalid usage " + this.usage)
		}
	}

	function getGlData() {
		var gl = this.getGlContext()
		var data = this.data
		switch(this.type) {
			case this.Float:
				return new Float32Array(data)
			case this.Int:
				return new Int32Array(data)
			case this.Bool:
				return new Int8Array(data)
			default:
				throw new Error("Invalid type " + this.type)
		}
	}

	onDataChanged: {
		if (this._buffer !== undefined)
			this.__updateBuffer()
	}

	function __updateBuffer() {
		var gl = this.getGlContext()
		var target = this.getGlTarget()
		gl.bindBuffer(target, this._buffer);
		gl.bufferData(target, this.getGlData(), this.getGlUsage());
	}

	function attachAttr(loc, desc) {
		var gl = this.getGlContext()

		if (this._buffer === undefined) {
			this._buffer = gl.createBuffer()
			this.__updateBuffer()
		}

		gl.bindBuffer(gl.ARRAY_BUFFER, this._buffer);
		gl.vertexAttribPointer(
			loc,
			this.components,
			this.getGlType(),
			this.normalize,
			this.stride,
			this.offset);
		gl.enableVertexAttribArray(loc)
	}
}
