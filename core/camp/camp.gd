extends RefCounted
class_name Camp


var id = ""
var title = ""
var leader = ""
var units = []
var values = []
var custom = {}
var orientation = { "x": 0, "y": 0 }
var color := Color("999")


#func _ready() -> void:
	#add_to_group(&"camp")


func add_units(player: String):
	units.append(player)


func to_dict() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"leader": leader,
		"units": units,
		"values": values.map(func(value: Value): return value.to_dict()),
		"custom": custom,
		"orientation": orientation,
		"color": color.to_html(false)
	}


func to_table() -> LuaTable:
	return LuaUtils.dictionary_to_table(to_dict())
