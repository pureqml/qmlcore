GlObject {
    property int components;
	property enum type { Float, Int, Bool };
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
        var gl = this.getGlContext()
        if (this._buffer === undefined)
            this._buffer = gl.createBuffer()

        gl.bindBuffer(gl.ARRAY_BUFFER, this._buffer);
        gl.bufferData(gl.ARRAY_BUFFER,
            this.getGlData(),
            gl.STATIC_DRAW);
    }

    function attachAttr(loc, desc) {
        var gl = this.getGlContext()
        if (!this._buffer)
            throw new Error("attaching attr to empty buffer")

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
