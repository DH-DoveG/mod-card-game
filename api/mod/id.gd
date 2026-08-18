extends Object
class_name ModIdApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("generate", state.create_function(generate))
	table.set("find", state.create_function(find))
	table.set("assign", state.create_function(assign))
	state.globals["package"]["loaded"]["std.api.id-api"] = table


static func generate(param) -> String:
	var value = param["value"] if param["value"] != null else ""
	var lenght = param["lenght"] if param["lenght"] != null else 8
	var id = IDUtils.generate(param["prefix"], value, lenght)
	return id


static func find(_param) -> void:
	pass


static func assign(_param) -> void:
	pass
