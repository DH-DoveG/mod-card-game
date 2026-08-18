extends RefCounted
class_name Value


var value = 0
var nick = ""
var code = ""
var max_value = 1024
var min_value = -1024
var config = null

var modifiers: Array[Modifier] = []


func to_dict() -> Dictionary:
	var result = {
		"value": value,
		"nick": nick,
		"code": code,
		"max_value": max_value,
		"min_value": min_value,
		"config": config
	}
	return result


func to_table() -> LuaTable:
	return LuaUtils.dictionary_to_table(to_dict())


func get_value(user_id: String) -> int:
	var v = value
	for modifier in get_modifiers():
		v = modifier.calculation(v)
	var dict = to_table()
	dict["value"] = v
	if config and config.has("dynmic_get"):
		if config["dynmic_get"] and (config["dynmic_get"] is LuaFunction or config["dynmic_get"] is Callable):
			return config["dynmic_get"].invoke(user_id, dict)
	return v


func get_modifiers() -> Array:
	for i in range(modifiers.size() - 1, -1, -1):
		if modifiers[i] == null:
			modifiers.remove_at(i)
	return modifiers
