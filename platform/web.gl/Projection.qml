GlObject {
	property real fieldOfView: 45;
	property real aspect: localGlContext.width / localGlContext.height;
	property real near: 0.1;
	property real far: 100;

	property var matrix;

	constructor: {
		var mat4 = $web$gl.matrix.mat4
		this.matrix = mat4.create()
	}

	function __update() {
		var mat4 = $web$gl.matrix.mat4
		if (
			!Number.isFinite(this.fieldOfView) ||
			!Number.isFinite(this.aspect))
			return

		mat4.perspective(this.matrix,
				   this.fieldOfView,
				   this.aspect,
				   this.near,
				   this.far)
		var storage = this.__properties.matrix
		if (storage !== undefined)
			storage.callOnChanged(this, 'matrix', this.matrix) //force update signal
	}

	onFieldOfViewChanged,
	onNearChanged,
	onFarChanged,
	onAspectChanged: {
		this.__update()
	}
}
