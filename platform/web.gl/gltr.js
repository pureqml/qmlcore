var GlTr = function(data, bin) {
	this.data = data
	this.bin = bin
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
	return new GlTr(json, bin)
}
