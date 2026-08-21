extends Object
class_name ModCardApi


static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("get_image", state.create_function(get_image))
	table.set("get_card", state.create_function(get_card))
	table.set("get_front", state.create_function(get_front))
	table.set("set_front", state.create_function(set_front))
	table.set("set_orientation", state.create_function(set_orientation))
	table.set("get_direction", state.create_function(get_direction))
	table.set("get_ownership", state.create_function(get_ownership))
	table.set("get_controller", state.create_function(get_controller))
	table.set("get_area", state.create_function(get_area))
	table.set("set_area", state.create_function(set_area))
	# table.set("set_rotation", state.create_function(set_rotation))
	table.set("set_index", state.create_function(set_index))
	table.set("find_condition", state.create_function(find_condition))
	table.set("set_border_color", state.create_function(set_border_color))
	table.set("set_public_information", state.create_function(set_public_information))
	table.set("get_public_information", state.create_function(get_public_information))
	
	state.globals["package"]["loaded"]["std.api.card-api"] = table


static func set_public_information(param):
	var cid = param["card_id"] if param["card_id"] != null else ""
	var pids = param["player_ids"].to_array() if param["player_ids"] != null else []
	print("[CORE] cid: ", cid, " | pids: ", pids)
	GApiManager.card_api.rpc("set_public_information", cid, pids)


static func get_public_information(param):
	var cid = param["card_id"] if param["card_id"] != null else ""
	return GApiManager.card_api.get_public_information(cid)


static func set_border_color(param):
	var id = param["id"] if param["id"] != null else null
	var color = param["color"] if param["color"] != null else null
	if not id:
		return
	GApiManager.card_api.rpc("set_border_color", id, color)


static func get_image(param: LuaTable) -> LuaTable:
	var id = param["id"] if param["id"] != null else null
	return ModManager.state.create_table(GApiManager.card_api.get_image(id))


static func get_card(param: LuaTable) -> LuaTable:
	var id = param["id"] if param["id"] != null else null
	
	if not id:
		return null
	
	var card = FindUtils.find_card(id)
	if card is not CardEntity:
		return null
	#return card.entity.meta
	return card.meta


static func get_front(param: LuaTable) -> bool:
	var id = param["id"] if param["id"] != null else null
	return GApiManager.card_api.get_front(id)


static func set_front(param: LuaTable) -> void:
	var id = param["id"] if param["id"] != null else null
	var front = param["front"] if param["front"] != null else true
	if not id:
		return
	GApiManager.card_api.rpc("set_front", id, front)


static func get_direction(param: LuaTable) -> LuaTable:
	var id = param["id"] if param["id"] != null else null
	if not id:
		return null
	return ModManager.state.create_table(GApiManager.card_api.get_direction(id))


static func set_orientation(param: LuaTable) -> void:
	var id = param["id"] if param["id"] != null else null
	var orientation = param["orientation"] if param["orientation"] != null else true
	if not id:
		return
	GApiManager.card_api.rpc("set_orientation", id, orientation)


static func get_ownership(param: LuaTable) -> String:
	var card_id = param["id"] if param["id"] != null else ""
	if card_id.is_empty():
		return ""
	return GApiManager.card_api.get_ownership(card_id)


static func get_controller(param: LuaTable) -> String:
	var card_id = param["id"]
	return GApiManager.card_api.get_controller(card_id)


static func get_area(param: LuaTable) -> LuaTable:
	var card_id = param["id"]
	return ModManager.state.create_table(GApiManager.card_api.get_area(card_id))


static func set_area(param: LuaTable) -> void:
	var card_id = param["card_id"] if param["card_id"] != null else null
	var area_id = param["area_id"] if param["area_id"] != null else null
	# { "play_sound": "<SoundID>" }
	var config = LuaUtils.table_to_dictionary(param["config"]) if param["config"] != null else {}

	assert(card_id, "CardID is null")
	assert(area_id, "AreaID is null")
	
	if not card_id or not area_id:
		return
	
	GApiManager.card_api.rpc("set_area", card_id, area_id, config)


static func set_index(_param: LuaTable) -> void:
	pass


static func find_condition(param: LuaTable) -> LuaTable:
	var values = param["values"].to_array() if param["values"] != null else []
	var tags = param["tags"].to_array() if param["tags"] != null else []
	var areas = param["areas"].to_array() if param["areas"] != null else []
	var kinds = param["kinds"].to_array() if param["kinds"] != null else []
	var owners = param["owners"].to_array() if param["owners"] != null else []
	var sets = param["sets"].to_array() if param["sets"] != null else []
	
	var mode = param["mode"] if param["mode"] != null else "ID"
	
	var dir = {}
	if values.size(): dir["values"] = values
	if tags.size(): dir["tags"] = tags
	if areas.size(): dir["areas"] = areas
	if kinds.size(): dir["kinds"] = kinds
	if owners.size(): dir["owners"] = owners
	if sets.size(): dir["sets"] = sets

	var cards = FindUtils.find_condition_cards(dir)
	
	var result = []
	for card: CardEntity in cards:
		if mode == "ID":
			result.append(str(card.name))
		elif mode == "ALL":
			# result.append(card.entity.meta)
			result.append(card.meta)
	
	var table = LuaUtils.array_to_table(result)
	
	return table
