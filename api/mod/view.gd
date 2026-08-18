extends Object
class_name ModViewApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("phase_show", state.create_function(phase_show))
	table.set("card_move", state.create_function(card_move))
	table.set("info", state.create_function(info))
	table.set("warn", state.create_function(warn))
	table.set("error", state.create_function(error))
	table.set("success", state.create_function(success))
	state.globals["package"]["loaded"]["std.api.view-api"] = table

static func card_move(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_p):
		var mode = param["mode"] if param["mode"] else "CURVE"
		var card_id = param["card_id"] if param["card_id"] != null else null
		var area_id = param["area_id"] if param["area_id"] != null else null
		var time = param["time"] if param["time"] != null else 0.5
		if card_id == null or area_id == null:
			await Utils.get_scene_tree().create_timer(0.05).timeout
			return
		GApiManager.view_api.rpc("card_move", card_id, area_id, mode, time)
		await GApiManager.view_api.card_move(card_id, area_id, mode, time)
	, param)

static func phase_show(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_p):
		await Utils.get_scene_tree().create_timer(0.1).timeout
		GApiManager.view_api.rpc("phase_show", _p["context"], _p["sound"])
		await GApiManager.view_api.phase_show(_p["context"], _p["sound"])
	, param)

static func info(param) -> void:
	var text = param["text"] if param["text"] else ""
	var pos = param["pos"] if param["pos"] else "TL"
	var broadcast = param["broadcast"] if param["broadcast"] else false
	if broadcast:
		GApiManager.view_api.rpc("info", text, pos)
	else:
		GApiManager.view_api.info(text, pos)

static func warn(param) -> void:
	var text = param["text"] if param["text"] else ""
	var pos = param["pos"] if param["pos"] else "T"
	var broadcast = param["broadcast"] if param["broadcast"] else false
	if broadcast:
		GApiManager.view_api.rpc("warn", text, pos)
	else:
		GApiManager.view_api.warn(text, pos)

static func error(param) -> void:
	var text = param["text"] if param["text"] else ""
	var pos = param["pos"] if param["pos"] else "T"
	var broadcast = param["broadcast"] if param["broadcast"] else false
	if broadcast:
		GApiManager.view_api.rpc("error", text, pos)
	else:
		GApiManager.view_api.error(text, pos)

static func success(param) -> void:
	var text = param["text"] if param["text"] else ""
	var pos = param["pos"] if param["pos"] else "T"
	var broadcast = param["broadcast"] if param["broadcast"] else false
	if broadcast:
		GApiManager.view_api.rpc("success", text, pos)
	else:
		GApiManager.view_api.success(text, pos)
