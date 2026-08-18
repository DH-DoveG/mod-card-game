extends Node
class_name Modifier


# 修正需要传入 Value 对象以及当前结算得到的值
# current 是需要传递结算的
# other_info 是结算期间产生的上下文信息，通常是一个引用数据，例如字典或者数组或者其他的

var id = "" # 唯一ID
var code = "" # 是针对于哪一项数值的修正
var op = "" # 操作类型 "+","-","*","/","="
var value = 0 # 修正的数值
var custom = null # 自定义数据


func _init() -> void:
	add_to_group(&"modifier")

func calculation(v: int) -> int:
	match op:
		"+": return v + value
		"-": return v - value
		"*": return v * value
		"/": return float(v) / value
		"=": return value
	return v

func to_dict() -> Dictionary:
	return {
		"id": id,
		"code": code,
		"op": op,
		"value": value,
		"custom": custom,
	}

func to_table() -> LuaTable:
	return LuaUtils.dictionary_to_table(to_dict())
