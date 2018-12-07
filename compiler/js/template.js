{% if strict %}'use strict'{% endif %}
{% if release %}var log = function() { }{% else %}var log = null{% endif %}
{{ manifest }}
var {{ns}} = (function() {/** @const */
	var exports = {}
	/** @const */
	var _globals = exports
	{{ prologue }}

	//========================================

	/** @const @type {!CoreObject} */
	var core = $core.core
	{% for component in components %}

//=====[component {{component.type}}]=====================

	var {{ component.base_local_name }} = {{ component.base_type_mangled}}
	var {{ component.base_proto_name }} = {{ component.base_local_name}}.prototype

	/**
	 * @constructor
	 * @extends { {{ component.base_type_mangled }} }
	 */
	var {{ component.local_name }} = {{ component.name_mangled }} = function(parent, row) {
		{{ component.base_local_name }}.apply(this, arguments)
		{{ component.ctor }}
	}

	{{ component.code }}
	{{ component.prototype }}
	{%- endfor %}

	{{ imports }}

	return exports;
} )();
{% if module %}
module.exports = {{ns}}
module.exports.run = function(nativeContext) {
{% endif %}

try {
	var l10n = {{ l10n }}

	var context = {{ns}}._context = new qml.{{context_type}}(null, false, {id: 'qml-context-{{app}}', l10n: l10n, nativeContext: {% if module %} nativeContext {% else %} null {% endif %}})
	context.init()
	{{ startup }}
} catch(ex) { log("{{ns}} initialization failed: ", ex, ex.stack) }
{% if module %}

	return context
}
{% endif %}
