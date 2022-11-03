GlObject {
    property int components;
    property bool normalize;
    property int stride;
    property int offset;

    property array value;

    onValueChanged: {
        var gl = this.getGlContext()
        if (this._buffer === undefined)
            this._buffer = gl.createBuffer()

        gl.bindBuffer(gl.ARRAY_BUFFER, this._buffer);
        gl.bufferData(gl.ARRAY_BUFFER,
            new Float32Array(value), //fixme: add types
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
            gl.FLOAT,
            this.normalize,
            this.stride,
            this.offset);
        gl.enableVertexAttribArray(loc)
    }
}