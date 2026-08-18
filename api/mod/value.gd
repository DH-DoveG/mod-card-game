extends Object
class_name ModValueApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("append", state.create_function(append))
	table.set("remove", state.create_function(remove))
	table.set("get_all", state.create_function(get_all))
	table.set("increase", state.create_function(increase))
	table.set("reset", state.create_function(reset))
	table.set("get_only", state.create_function(get_only))
	table.set("append_modifier", state.create_function(append_modifier))
	table.set("get_modifier", state.create_function(get_modifier))
	table.set("remove_modifier", state.create_function(remove_modifier))
	state.globals["package"]["loaded"]["std.api.value-api"] = table


static func append(param) -> void:
	var id: String = param["id"] if param["id"] else ""
	var value: Dictionary = LuaUtils.table_to_dictionary(param["value"]) if param["value"] else {}
	# print("[CORE] ADD VALUE: ", id, " v:", value)
	if id.is_empty() or value.is_empty():
		return
	GApiManager.value_api.rpc("append", id, value)


static func remove(param) -> void:
	var id = param["id"] if param["id"] else ""
	var code = param["code"] if param["code"] else ""
	if code.is_empty() or id.is_empty():
		return
	GApiManager.value_api.rpc("remove", id, code)


static func get_all(param) -> LuaTable:
	var id: String = param["id"] if param["id"] else ""
	var entity: Entity = null
	if id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(id)
	elif id.begins_with("CARD_"):
		entity = FindUtils.find_card(id)
	elif id.begins_with("AREA_"):
		entity = FindUtils.find_area(id)
	else:
		return
	var result = {}
	for code in entity.value_manager:
		var v: Value = entity.value_manager[code]
		result[code] = v.get_value(id)
	return LuaUtils.dictionary_to_table(result)


static func increase(param) -> void:
	var id = param["id"] if param["id"] != null else ""
	var code = param["code"] if param["code"] != null else ""
	var value = param["value"] if param["value"] != null else null
	if code.is_empty() or id.is_empty() or value == null:
		return
	GApiManager.value_api.rpc("increase", id, code, value)


static func reset(param) -> void:
	var id = param["id"] if param["id"] else ""
	var code = param["code"] if param["code"] else ""
	var value = param["value"] if param["value"] else null
	if code.is_empty() or id.is_empty() or value == null:
		return
	GApiManager.value_api.rpc("reset", id, code, value)


static func get_only(param) -> Variant:
	var id = param["id"] if param["id"] else ""
	var code = param["code"] if param["code"] else ""
	if code.is_empty() or id.is_empty():
		return null
	var entity: Entity = null
	if id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(id)
	elif id.begins_with("CARD_"):
		entity = FindUtils.find_card(id)
	elif id.begins_with("AREA_"):
		entity = FindUtils.find_area(id)
	else:
		return null
	#var entity: Entity = FindUtils.find_entity(id)
	if not entity:
		return null
	if code in entity.value_manager:
		var v: Value = entity.value_manager[code]
		return v.get_value(id)
	return null

static func remove_modifier(param) -> void:
	var modifier_id = param["modifier_id"] if param["modifier_id"] else ""
	# print("Remove Modifier ID: ", modifier_id)
	if modifier_id.is_empty():
		return
	GApiManager.value_api.rpc("remove_modifier", modifier_id)


static func append_modifier(param) -> void:
	var id = param["id"] if param["id"] else ""
	var modifier = param["modifier"] if param["modifier"] else null
	# print("append_modifier: ", modifier)
	if id.is_empty() or modifier == null:
		return
	if modifier is not LuaTable:
		return
	GApiManager.value_api.rpc("append_modifier", id, LuaUtils.table_to_dictionary(modifier))

static func get_modifier(param) -> LuaTable:
	var id = param["id"] if param["id"] else ""
	var code = param["code"] if param["code"] else ""
	if code.is_empty() or id.is_empty():
		return null
	var result = []
	var ms = GApiManager.value_api.get_modifier(id, code)
	for m: Modifier in ms:
		result.append(m.to_table())
	return LuaUtils.array_to_table(result)
