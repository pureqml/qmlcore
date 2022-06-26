// RUN: %build
// RUN: grep "\this.wrap = Text.NoWrap;" %out/qml.enum_and_ids_in_string_context.js
// RUN: grep "Text = _globals.core.Text.prototype" %out/qml.enum_and_ids_in_string_context.js
// RUN: grep "\$this._removeUpdater('textFormat'); \$this.textFormat = Text.Html;" %out/qml.enum_and_ids_in_string_context.js
// RUN: ! grep "_globals.core.Device.prototype.Platform" %out/qml.enum_and_ids_in_string_context.js
// RUN: grep "this.setValue('Device.Platform', \"text.wrap\")" %out/qml.enum_and_ids_in_string_context.js
Text {
	id: text;
	textFormat: Text.Html;

	function setValue(name, value) { }

    onText: {
		this.wrap = Text.NoWrap;
		this.setValue('Device.Platform', "text.wrap")
    }
}
