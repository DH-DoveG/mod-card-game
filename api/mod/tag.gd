extends Object
class_name ModTagApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("append", state.create_function(append))
	table.set("remove", state.create_function(remove))
	table.set("has", state.create_function(has))
	table.set("find_condition", state.create_function(find_condition))
	state.globals["package"]["loaded"]["std.api.tag-api"] = table


static func append(_param) -> void:
	pass


static func remove(_param) -> void:
	pass


static func has(param) -> bool:
	var id: String = param["entity_id"] if param["entity_id"] else ""
	var tag: String = param["tag"] if param["tag"] else ""
	var strict: bool = param["strict"] if param["strict"] else false
	
	var entity: Entity = null
	if id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(id)
	elif id.begins_with("CARD_"):
		entity = FindUtils.find_card(id)
	elif id.begins_with("AREA_"):
		entity = FindUtils.find_area(id)
	else:
		return false
	
	for t in entity.tags:
		if strict:
			if t == tag:
				return true
		else:
			if t == tag or t.contains(tag):
				return true
	return false


static func find_condition(_param) -> void:
	pass
