extends RefCounted
class_name Entity

var name := ""
var values: Dictionary[String, Value] = {}
var behaviors: Array = []
var tags = []

var meta: Variant:
	set(_v):
		meta = _v
		__tick_values()
		__tick_tags()
		__tick_behaviors()

func __tick_values() -> void:
	if meta["entity"]:
		var _values = LuaUtils.table_to_dictionary(meta["entity"]["values"])
		for v in _values.values():
			var template = ModManager.do_mod_file(GResourceManager.value_resource[v["template"]])
			template = template.invoke()
			var override = v["override"]
			var value: Dictionary = LuaUtils.table_to_dictionary(template)
			for k in override:
				value[k] = override[k]
			var __code = value["code"] if value.has("code") else null
			var __name = value["name"] if value.has("name") else __code
			var __max = value["max"] if value.has("max") else 256
			var __min = value["min"] if value.has("min") else -256
			var __value = value["value"] if value.has("value") else 0
			var __config = value["config"] if value.has("config") else null
			assert(__code, "Value code is null")
			var vobj = GApiManager.value_api.create(
				__code,
				__name,
				__value,
				__max,
				__min,
				__config
			)
			values[__code] = vobj

func __tick_tags() -> void:
	if meta["entity"]:
		tags = meta["entity"]["tags"].to_array()

func __tick_behaviors() -> void:
	if meta["entity"]:
		behaviors = meta["entity"]["behaviors"].to_array()

func add_behavior(b):
	behaviors.append(b)
