Object {
	signal reset;			///< model reset signal
	signal rowsInserted;	///< rows inserted signal
	signal rowsChanged;		///< rows changed signal
	signal rowsRemoved;		///< rows removed signal

	property int count;		///< model rows count. Please note that you can't directly/indirectly modify model from onChanged handler. Use view.onCountChanged instead

	/// @private
	function attachTo(object) {
		if (object._modelAttached)
			object._modelAttached.detachFrom(object)
		if (!object._modelReset)
			object._modelReset = object._onReset.bind(object)
		if (!object._modelRowsInserted)
			object._modelRowsInserted = object._onRowsInserted.bind(object)
		if (!object._modelRowsChanged)
			object._modelRowsChanged = object._onRowsChanged.bind(object)
		if (!object._modelRowsRemoved)
			object._modelRowsRemoved =  object._onRowsRemoved.bind(object)

		var Model = $core.Model
		var model = this
		var modelType = typeof model
		if ((Model !== undefined) && (model instanceof Model)) {
		} else if (Array.isArray(model)) {
			model = new $core.model.ArrayModelWrapper(model)
		} else if (modelType === 'number') {
			var data = []
			for(var i = 0; i < model; ++i)
				data.push({})
			model = new $core.model.ArrayModelWrapper(data)
		} else
			throw new Error("unknown value of type '" + (typeof model) + "', attached to model property: " + model + ((modelType === 'object') && ('componentName' in model)? ', component name: ' + model.componentName: ''))

		model.on('reset', object._modelReset)
		model.on('rowsInserted', object._modelRowsInserted)
		model.on('rowsChanged', object._modelRowsChanged)
		model.on('rowsRemoved', object._modelRowsRemoved)

		object._modelAttached = model
		object._onReset()
	}

	/// @private
	function detachFrom(object) {
		var model = object._modelAttached
		if (!model)
			return

		object._modelAttached = null

		model.removeListener('reset', object._modelReset)
		model.removeListener('rowsInserted', object._modelRowsInserted)
		model.removeListener('rowsChanged', object._modelRowsChanged)
		model.removeListener('rowsRemoved', object._modelRowsRemoved)

	}

}
