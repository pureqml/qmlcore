Object {
	property string property; 	///< target property
	property Object target; 	///< target object
	property Object animation;

	function addChild(child) {
		$core.Object.prototype.addChild.apply(this, arguments)
		if (child instanceof $core.Animation) {
			this.animation = child
		}
	}

	function update() {
		if (this.property && this.animation) {
			var target = this.target || this.parent
			target.setAnimation(this.property, this.animation)
			this.__old_target = target
		}
	}
	onTargetChanged: {
		var target = this.target || this.parent
		if (this.__old_target) {
			target.setAnimation(this.property, null)
			this.__old_target = undefined
		}
		update()
	}

	onPropertyChanged, onAnimationChanged: {
		this.update()
	}
}
