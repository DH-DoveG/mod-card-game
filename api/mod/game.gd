extends Object
class_name ModGameApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("set_global_variable", state.create_function(set_global_variable))
	table.set("get_global_variable", state.create_function(get_global_variable))
	table.set("get_global_variable_list", state.create_function(get_global_variable_list))
	table.set("remove_global_variable", state.create_function(remove_global_variable))
	table.set("set_battle_ready_loading_state", state.create_function(set_battle_ready_loading_state))
	table.set("set_angle_of_view", state.create_function(set_angle_of_view))
	table.set("game_end", state.create_function(game_end))
	table.set("timeout", state.create_function(timeout))
	table.set("create_camp", state.create_function(create_camp))
	table.set("get_camp", state.create_function(get_camp))
	table.set("get_battle_info", state.create_function(get_battle_info))
	state.globals["package"]["loaded"]["std.api.game-api"] = table


static func get_battle_info(param) -> LuaTable:
	var player_id = param["player_id"] if param["player_id"] != null else null
	if player_id == null:
		return null

	var players = []
	# var camps = []
	var card_sets = {} # { "key": { id: string, size: int, public: []} }
	var areas = [] # { id: string, public_cards: [], top_card: string, low_heap: [] }

	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return ModManager.state.create_table()
	var battle: Battle = scene

	# camps = battle.battle_data_bind_list.camp_bind_players.keys()
	for camp in battle.battle_data_bind_list.camp_bind_players:
		for player in battle.battle_data_bind_list.camp_bind_players[camp]:
			players.append({"id": player, "camp": camp, "value": GApiManager.value_api.get_values_dict(player)})

	for cs in battle.battle_data_bind_list.card_set:
		card_sets[cs] = []
		for pid in battle.battle_data_bind_list.card_set[cs]["data"]:
			var cards = battle.battle_data_bind_list.card_set[cs]["data"][pid]
			var public = []
			for card in cards:
				if GApiManager.card_api.get_public_information(player_id, card):
					public.append(card)
			card_sets[cs].append({"id": pid, "size": cards.size(), "public": public})

	# for area: BattlefieldArea in Utils.get_scene_tree().get_nodes_in_group(&"area"):
	for area: AreaEntity in Utils.get_current_scene().areas.values():
		var heap = GApiManager.area_api.get_heap(area.name)
		var top = heap.pop_back()
		var pc = []
		for index in range(heap.size() - 1, -1, -1):
			if not GApiManager.card_api.get_public_information(player_id, heap[index]):
				# heap.remove_at(index)
				heap[index] = "<Private>"
			else:
				pc.push_back(heap[index])
		if top != null:
			if not GApiManager.card_api.get_public_information(player_id, top):
				top = "<Private>"
		if top:
			pc.push_back(top)
		areas.append({"id": area.name, "public_cards": pc, "top_card": top, "low_heap": heap})
		pass

	return LuaUtils.dictionary_to_table({
		"players": players,
		"card_sets": card_sets,
		"areas": areas,
	})


static func create_camp(param) -> void:
	var title = param["title"] if param["title"] != null else ""
	var leader = param["leader"] if param["leader"] != null else null
	var units = param["units"].to_array() if param["units"] != null else []
	var orientation = param["orientation"].to_dictionary() if param["orientation"] != null else {x = 0, y = 0}
	var color = param["color"] if param["color"] != null else "999"
	GApiManager.game_api.rpc("create_camp", title, leader, units, orientation, color)


static func get_camp(param) -> LuaTable:
	var title = param["title"] if param["title"] != null else ""
	# var camps = Utils.get_scene_tree().get_nodes_in_group(&"camp")
	var camps = Utils.get_current_scene().camps.values()
	if camps.is_empty():
		return null
	for camp in camps:
		if camp.title == title:
			return camp.to_table()
	return null


static func timeout(param: LuaTable) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		await Utils.get_scene_tree().create_timer(_arg["sec"]).timeout
	, param)


static func game_end(param) -> void:
	var wins = param["wins"].to_array() if param["wins"] != null else []
	var loses = param["loses"].to_array() if param["loses"] != null else []
	var dogfall = param["dogfall"].to_array() if param["dogfall"] != null else []
	GApiManager.game_api.rpc("game_end", wins, loses, dogfall)


static func set_angle_of_view(param) -> void:
	var player_id = param["player_id"] if param["player_id"] != null else null
	var angle = param["angle"] if param["angle"] != null else ""
	if player_id == null:
		return
	var p = FindUtils.find_player(player_id)
	if p == null:
		return
	if typeof(p.id) == TYPE_STRING:
		return
	GApiManager.game_api.rpc_id(p.id, "set_angle_of_view", angle)


static func set_battle_ready_loading_state(param) -> void:
	var state = param["state"] if param["state"] != null else false
	GApiManager.game_api.rpc("set_battle_ready_loading_state", state)


static func set_global_variable(param) -> void:
	var key = param["key"] if param["key"] != null else ""
	var value = param["value"] if param["value"] != null else null
	if key == "":
		return
	if value is LuaTable:
		value = LuaUtils.table_to_dictionary(value)
	GApiManager.game_api.rpc("set_global_variable", key, value)


static func get_global_variable(param) -> Variant:
	var key = param["key"] if param["key"] != null else ""
	if key == "":
		return null
	
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return null
	var battle: Battle = scene
	var value = battle.battle_global_data.get(key, null)
	if value is Dictionary:
		value = LuaUtils.dictionary_to_table(value)
	return value


static func get_global_variable_list(param) -> Variant:
	var key = param["key"] if param["key"] != null else ""
	var mode = param["mode"] if param["mode"] != null else "PREFIX"
	if key == "":
		return null
	
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return null
	var battle: Battle = scene

	var res = []
	for k in battle.battle_global_data:
		if mode == "PREFIX" and !k.begins_with(key):
			continue
		elif mode == "SUFFIX" and !k.ends_with(key):
			continue
		if mode == "ALL" and !battle.battle_data_bind_list.get(k):
			continue
		res.append({
			"key": k,
			"value": battle.battle_global_data[k]
		})

	return LuaUtils.array_to_table(res)


static func remove_global_variable(param) -> bool:
	var key = param["key"] if param["key"] != null else ""
	# if key == "":
	# 	return false
	# var scene = Utils.get_current_scene()
	# if scene is not Battle:
	# 	return false
	# var battle: Battle = scene
	# battle.battle_global_data.erase(key)
	# return true
	GApiManager.game_api.rpc("remove_global_variable", key)
	return GApiManager.game_api.remove_global_variable(key)
