extends Object
class_name ModPlayerApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("get_player", state.create_function(get_player))
	table.set("get_players", state.create_function(get_players))
	table.set("get_camp", state.create_function(get_camp))
	table.set("get_area", state.create_function(get_area))
	table.set("set_player_timeout", state.create_function(set_player_timeout))
	table.set("get_player_timeout", state.create_function(get_player_timeout))
	table.set("start_player_timeout", state.create_function(start_player_timeout))
	table.set("stop_player_timeout", state.create_function(stop_player_timeout))

	state.globals["package"]["loaded"]["std.api.player-api"] = table

static func add_blackboard_var(param) -> void:
	var id = param["player_id"] if param["player_id"] != null else ""
	var p = FindUtils.find_player(id)
	p.bt_player.blackboard.set_var(param["var"], param["value"])

static func get_player(param) -> LuaTable:
	var id = param["id"] if param["id"] != null else ""
	var player = FindUtils.find_player(id)
	return player.meta

static func get_players(param) -> LuaTable:
	var mode = "ID"
	if param:
		mode = param["mode"] if param["mode"] != null else "ID"
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return null
	var battle: Battle = scene
	var dir = {}
	for camp in battle.battle_data_bind_list.camp_bind_players:
		var player_ids = battle.battle_data_bind_list.camp_bind_players[camp]
		if not dir.has(camp):
			dir[camp] = []
		for id in player_ids:
			if mode == "ALL":
				var player = FindUtils.find_player(id)
				if player is not Player:
					continue
				dir[camp].append(player.meta)
			else:
				dir[camp].append(id)
	var table = LuaUtils.dictionary_to_table(dir)
	return table

static func get_area(param) -> LuaTable:

	var id = param["id"] if param["id"] != null else ""
	var mode = param["mode"] if param["mode"] != null else "ID"
	var scene = Utils.get_current_scene()
	if not is_instance_valid(scene):
		return
	if scene is not Battle:
		return
	var battle: Battle = scene
	var areas = battle.battle_data_bind_list.area_bind_players
	var use_areas = []
	for area_id in areas:
		if id in areas[area_id]:
			use_areas.append(area_id)
	match mode:
		"ID":
			return LuaUtils.array_to_table(use_areas)
		"ALL":
			var result = []
			for area_id in use_areas:
				var area = FindUtils.find_area(area_id)
				if area and area is not AreaEntity:
					continue
				result.append(area.meta)
			return LuaUtils.array_to_table(result)
	return ModManager.state.create_table()

static func get_camp(param) -> String:
	var player_id = param["id"]
	assert(Utils.is_battle_scene(), "is not battle scene")
	var battle: Battle = Utils.get_current_scene()
	for key in battle.battle_data_bind_list.camp_bind_players:
		if player_id in battle.battle_data_bind_list.camp_bind_players[key]:
			return key
	return ""

static func set_player_timeout(param: LuaTable) -> void:
	var pid = param["player_id"] if param["player_id"] else null
	var sec = param["sec"] if param["sec"] else 0
	var cal = param["callback"] if param["callback"] else null
	if typeof(pid) != TYPE_STRING:
		return
	var cal_id = ""
	if cal != null:
		cal_id = IDUtils.generate("CC_SPT_" + str(pid) + "_")
		Utils.get_current_scene().callback_cache.caches[cal_id] = func(pi):
			cal.invoke(pi)
	var self_net_id = GNetManager.uid

	GApiManager.player_api.rpc("set_player_timeout", pid, sec, cal_id, self_net_id)

static func get_player_timeout(param: LuaTable) -> int:
	var pid = param["player_id"]
	if typeof(pid) != TYPE_STRING:
		return -1
	var player: Player = FindUtils.find_player(pid)
	if player == null:
		return -1
	return player.round_timer_out

static func start_player_timeout(param: LuaTable) -> void:
	var pid = param["player_id"] if param["player_id"] else null
	if typeof(pid) != TYPE_STRING:
		return
	GApiManager.player_api.rpc("start_player_timeout", pid)

static func stop_player_timeout(param: LuaTable) -> void:
	var pid = param["player_id"] if param["player_id"] else null
	if typeof(pid) != TYPE_STRING:
		return
	GApiManager.player_api.rpc("stop_player_timeout", pid)
