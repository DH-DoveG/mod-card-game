extends RefCounted
class_name Value

# Lua侧的定义
# @class ValueConfig 属性配置
# @field description string? 数值描述（用于在界面上展示给用户，例如鼠标悬停时的提示）
# @field tags string[]? 标签（用于在界面上展示给用户，悬停时在描述下方展示）
# @field show_enable boolean? 是否展示该属性（默认 false）
# @field show_prefix string? 在展示时的前缀，仅限1个字符，默认为空字符串
# @field show_color string? 在展示时的颜色，默认为 "#FFFFFF" （白色），字符固定有黑色描边
# @field dynmic_get nil|fun(entity_id: string, value: Value): number? 动态数值获取函数（如果是动态数值，必须提供该函数）
#
# @class Value
# @field value number 数值
# @field min_value number? 最小值
# @field max_value number? 最大值
# @field nick string 数值昵称（用于在界面上展示给用户，可能会因为本地化而改变）
# @field code string 数值代码（用于在代码中引用）
# @field config ValueConfig? 数值配置

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
