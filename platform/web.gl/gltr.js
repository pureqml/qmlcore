var GlTr = function(data, bin) {
	this.data = data
	this.bin = bin
}
var GlTrPrototype = GlTr.prototype
GlTrPrototype.constructor = GlTr

GlTrPrototype.loadBufferView = function(idx) {
	var data = this.data
	var view = data.bufferViews[idx]
	if (view.buffer !== 0)
		throw new Error("can only load from buffer 0")

	var offset = view.byteOffset
	var size = view.byteLength
	return this.bin.slice(offset, offset + size)
}

GlTrPrototype.loadAccessor = function(idx) {
	if (idx === undefined)
		throw new Error("missing accessor id")
	var accessor = this.data.accessors[idx]
	var buffer = this.loadBufferView(accessor.bufferView)
	switch(accessor.componentType) {
		case 5123: //UNSIGNED_SHORT
			buffer = new Uint16Array(buffer)
			break
		case 5125: //UNSIGNED_INT
			buffer = new Uint32Array(buffer)
			break
		case 5126: //FLOAT
			buffer = new Float32Array(buffer)
			break
		default:
			throw new Error("invalid accessor type: " + accessor.componentType + "/" + accessor.type)
	}
	return buffer
}

GlTrPrototype.renderPrimitive = function(ctx, primitive) {
	var material
	var gl = ctx.gl
	var attrs = primitive.attributes

	var pos = this.loadAccessor(attrs.POSITION)
	var bufferPos = gl.createBuffer()
	gl.bindBuffer(gl.ARRAY_BUFFER, bufferPos)
	gl.bufferData(gl.ARRAY_BUFFER, pos, gl.STATIC_DRAW)

	var posIndices = this.loadAccessor(primitive.indices)
	var bufferPosIndices = gl.createBuffer()
	gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, bufferPosIndices)
	gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, posIndices, gl.STATIC_DRAW)

	// var normal = this.loadAccessor(attrs.NORMAL)
	// var bufferNorm = gl.createBuffer()
	// gl.bindBuffer(gl.ARRAY_BUFFER, bufferNorm)
	// gl.bufferData(gl.ARRAY_BUFFER, normal, gl.STATIC_DRAW)

	if (primitive.material !== undefined) {
		material = this.data.materials[primitive.material]
	}

	var matrix = ctx.matrix

	ctx.queue.push(function(runCtx) {
		var gl = runCtx.gl
		var program = runCtx.program

		program.uniform.model = matrix
		if (material) {
			if (material.pbrMetallicRoughness && material.pbrMetallicRoughness.baseColorFactor)
				program.uniform.baseColor = material.pbrMetallicRoughness.baseColorFactor
		}

		var pos = program.attr.aVertexPosition
		gl.bindBuffer(gl.ARRAY_BUFFER, bufferPos)
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, bufferPosIndices);
		gl.vertexAttribPointer(
			pos.loc,
			3,
			gl.FLOAT,
			false,
			0,
			0);
		gl.enableVertexAttribArray(pos.loc)
		//fixme: get type from accessor?
		gl.drawElements(gl.TRIANGLES, posIndices.length, gl.UNSIGNED_INT, 0)
	})
}

GlTrPrototype.renderMesh = function(ctx, mesh) {
	var primitives = mesh.primitives
	if (primitives === undefined)
		return

	for(var i = 0; i != primitives.length; ++i) {
		this.renderPrimitive(ctx, primitives[i])
	}
}

GlTrPrototype.renderNode = function(ctx, node) {
	var mat4 = $web$gl.matrix.mat4

	var oldMatrix = ctx.matrix
	var rotation = node.rotation || [0, 0, 0, 1]
	var translation = node.translation || [0, 0, 0]
	var scale = node.scale || [1, 1, 1]
	var matrix
	if (node.matrix) {
		matrix = node.matrix
	} else {
		matrix = mat4.create()
		mat4.multiply(matrix, matrix, mat4.fromTranslation(mat4.create(), translation))
		mat4.multiply(matrix, matrix, mat4.fromQuat(mat4.create(), rotation))
		mat4.multiply(matrix, matrix, mat4.fromScaling(mat4.create(), scale))
	}
	ctx.matrix = mat4.create()
	mat4.multiply(ctx.matrix, oldMatrix, matrix)

	var mesh = node.mesh
	if (mesh !== undefined) {
		this.renderMesh(ctx, this.data.meshes[mesh])
	}

	var children = node.children
	if (children !== undefined) {
		for(var i = 0; i != children.length; ++i) {
			this.renderNode(ctx, this.data.nodes[children[i]])
		}
	}
	ctx.matrix = oldMatrix
}

GlTrPrototype.render = function(gl) {
	gl.getExtension('OES_element_index_uint')
	var mat4 = $web$gl.matrix.mat4
	var ctx = {
		gl: gl,
		queue: [],
		matrix: mat4.create()
	}
	var nodes = this.data.scenes[this.data.scene].nodes
	for(var i = 0; i != nodes.length; ++i) {
		this.renderNode(ctx, this.data.nodes[nodes[i]])
	}

	var queue = ctx.queue
	return function(runCtx) {
		queue.forEach(function(func) {
			func(runCtx)
		})
	}
}

exports.load = function(buffer) {
	var header = new Int32Array(buffer.slice(0, 12))
	if (header[0] != 0x46546C67)
		throw new Error("Invalid magic")

	var totalSize = header[2]
	var offset = 12
	var json = null
	var bin = null
	while(offset + 4 <= totalSize)
	{
		header = new Int32Array(buffer.slice(offset, offset + 8))
		offset += 8

		var chunkData = buffer.slice(offset, offset + header[0])
		offset += header[0]
		switch(header[1]) {
			case 0x4E4F534A: //JSON
				json = JSON.parse(String.fromCharCode.apply(null, new Uint8Array(chunkData)))
				break
			case 0x004E4942: //BIN
				bin = chunkData
				break
			default:
				break
		}
	}
	if (!json)
		throw new Error("No JSON chunk found")
	if (!bin)
		throw new Error("No BIN chunk found")
	log("json", json)
	return new GlTr(json, bin)
}
