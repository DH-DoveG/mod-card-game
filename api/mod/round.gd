extends Object
class_name ModRoundApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("set_current", state.create_function(set_current))
	table.set("get_current", state.create_function(get_current))
	table.set("start_round", state.create_function(start_round))
	table.set("end_round", state.create_function(end_round))
	table.set("set_action_sequence", state.create_function(set_action_sequence))
	table.set("get_action_sequence", state.create_function(get_action_sequence))
	state.globals["package"]["loaded"]["std.api.round-api"] = table


static func set_current(param) -> void:
	var round_num = param["round_num"] if param["round_num"] else -1
	var id: String = param["id"] if param["id"] else ""
	GApiManager.round_api.rpc("set_current", round_num, id)


static func get_current(param) -> LuaTable:
	var mode = param["mode"] if param["mode"] else "ID"
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	var player = battle.current_round_player
	if mode == "ALL":
		player = FindUtils.find_player(player).meta
	return ModManager.state.create_table({
		"round_num": battle.round_num,
		"id": player
	})


static func start_round() -> void:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	
	if battle.current_round_player.is_empty():
		return
	
	var player = FindUtils.find_player(battle.current_round_player)
	player.start_round()
	GApiManager.round_api.rpc("start_round", battle.current_round_player)
	# var player = FindUtils.find_player(player_id)
	# player.start_round()


static func end_round() -> void:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	
	if battle.current_round_player.is_empty():
		return
	
	var player = FindUtils.find_player(battle.current_round_player)
	await player.end_round()


static func set_action_sequence(param) -> void:
	var list = param["list"].to_array() if param["list"] else null
	var index = param["index"] if param["index"] else null
	print("LIST: ", list)
	GApiManager.round_api.rpc("set_action_sequence", list, index)


static func get_action_sequence(param) -> LuaTable:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return ModManager.state.create_table()
	var battle: Battle = scene
	
	var mode = "ID"
	if param:
		mode = param["mode"] if param["mode"] else "ID"
	
	if mode == "ID":
		var _table = LuaUtils.dictionary_to_table({
			"list": battle.round_action_sequence,
			"index": battle.round_index
		})
		return _table
	
	# var players = Utils.get_scene_tree().get_nodes_in_group(&"player")
	var players = Utils.get_current_scene().players
	var dic = []
	for player: Player in players.values():
		dic.append(player)
	
	# 调顺序
	var new_dic = []
	for p: String in battle.round_action_sequence:
		for d: Player in dic:
			if d.name == p:
				new_dic.append(d.meta)
	
	var table = LuaUtils.dictionary_to_table({
		"list": new_dic,
		"index": battle.round_index
	})

	print("GET ACTION SEQUENCE: ", {
		"list": new_dic,
		"index": battle.round_index
	})

	return table
