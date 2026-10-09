extends Object
class_name ModEntityApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("get_custom", state.create_function(get_custom))
	table.set("get_entity", state.create_function(get_entity))
	state.globals["package"]["loaded"]["std.api.entity-api"] = table

static func get_custom(param: LuaTable) -> LuaTable:
	var id: String = param["entity_id"] if param["entity_id"] != null else ""
	if id == "":
		return null
	var entity = FindUtils.find_entity(id)
	if not entity:
		return null
	return entity.meta["entity"]["custom"]

static func get_entity(param: LuaTable) -> LuaTable:
	var id: String = param["entity_id"] if param["entity_id"] != null else ""
	if id == "":
		return null
	var entity = FindUtils.find_entity(id)
	if not entity:
		return null
	return entity.meta["entity"]
