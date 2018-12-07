{%- macro expr(var, op, idx) -%}
{%- if idx != 0 -%}
{{var}} {{op}} {{idx}}
{%- else -%}
{{var}}
{%- endif -%}
{%- endmacro -%}
{% if prefix %}
		/* {{ source }}*/
		var $n = arguments.length
		var {{name}} = new Array({{ expr('$n', '+', extra) }})
		{{name}}[0] = {{prefix}}
		var $s = {{index}}, $d = {{ expr('$i' , '+', extra)}};
		while ($s < $n) {
			{{name}}[$d++] = arguments[$s++]
		}
{% else %}
		/* {{ source }} */
		var $n = arguments.length
		var {{name}} = new Array({{ expr('$n', '-', index) }})
		var $d = 0, $s = {{index}};
		while ($s < $n) {
			{{name}}[$d++] = arguments[$s++]
		}
{% endif %}
