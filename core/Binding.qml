Object {
	property bool delayed; 		///< delays update to the next tick
	property string property; 	///< target property
	property Object target; 	///< target object
	property bool when: true;	///< assign value to target when this condition met
	property var value; 		///< any value

	function _updateTarget() {
		if (this.delayed)
			this._context.delayedAction("binding:update", this, this._updateTargetImpl)
		else
			this._updateTargetImpl()
	}

	function _updateTargetImpl() {
		$core.assign(this.target, this.property, this.value)
	}

	onTargetChanged, onValueChanged, onWhenChanged: {
		if (this.target && this.when && this.property)
			this._updateTarget()
	}
}
