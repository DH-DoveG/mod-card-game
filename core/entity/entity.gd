extends RefCounted
class_name Entity

var name := ""
var value_manager: Dictionary[String, Value] = {}
var behavior_manager := BehaviorManager.new()
var tags = []


var meta: Variant:
	set(_v):
		meta = _v
		__tick_values()
		__tick_tags()
		__tick_behaviors()


func __tick_values() -> void:
	if meta["entity"]:
		var values = LuaUtils.table_to_dictionary(meta["entity"]["values"])
		for v in values.values():
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
			#value_mount.add_child(vobj)
			value_manager[__code] = vobj


func __tick_tags() -> void:
	if meta["entity"]:
		tags = LuaUtils.table_to_dictionary(meta["entity"]["tags"]).values()


func __tick_behaviors() -> void:
	if meta["entity"]:
		for behavior in meta["entity"]["behaviors"].to_array():
			var behavior_lua = GApiManager.behavior_api.create(behavior)
			behavior_manager.add_behavior(behavior_lua)
