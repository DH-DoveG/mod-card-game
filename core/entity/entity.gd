extends RefCounted
class_name Entity

var name := ""
var values: Dictionary[String, Value] = {}
var behaviors: Array = []
var tags = []
var behavior_states: Dictionary[String, Dictionary] = {}

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

func get_behavior_state(code: String) -> Dictionary:
	if not behavior_states.has(code):
		behavior_states[code] = {}
	return behavior_states[code]

func set_behavior_state(code: String, key: String, value) -> void:
	get_behavior_state(code)[key] = value

func clear_behavior_state(code: String) -> void:
	if behavior_states.has(code):
		behavior_states[code].clear()

func reset_behavior_states() -> void:
	for code in behavior_states:
		var state = behavior_states[code]
		var keys_to_erase: Array = []
		for k in state.keys():
			if not k.begins_with("__"):
				keys_to_erase.append(k)
		for k in keys_to_erase:
			state.erase(k)

func reset_chain_triggers_overrides() -> void:
	# """清除所有 Entity 上所有 Behavior 的 chain-triggers 实例级覆盖"""
	for code in behavior_states:
		var state = behavior_states[code]
		state.erase("__chain_triggers_override")
		state.erase("__chain_triggers_add")
		state.erase("__chain_triggers_remove")
