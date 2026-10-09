extends Player
class_name RobotPlayer

func set_info(param: Dictionary) -> void:
	super(param)
	var t = GResourceManager.player_resource[param["template"]]
	var _meta: LuaFunction = ModManager.state.do_file(t["path"])
	var data = _meta.invoke()
	var deck_id = data["deck"]

	var deck_file = GResourceManager.deck_resource.get(deck_id)
	var deck_config = {}
	if deck_file:
		var deck_table = ModManager.state.do_file(deck_file)
		deck_config = LuaUtils.table_to_dictionary(deck_table)
		deck_config["stack"] = deck_config["stack"].values()
		for c in deck_config["stack"]:
			c["content"] = c["content"].values()
	else:
		var file = PersistenceUtils.open_file(ConfigManager.DECK_FOLDER_PATH.path_join(deck_id))
		deck_config = JSON.parse_string(file.get_as_text())
	use_deck_config = deck_config
	use_card_back = data["card_back"]

	data["entity"]["id"] = param["pid"]
	data["name"] = player_name
	meta = data

func start_round() -> Variant:
	var fun = meta["start_round"] as LuaFunction
	var co = LuaCoroutine.create(fun)
	var _res = co.resume(meta)
	if _res is LuaError:
		ModManager.print_lua_function_debug(fun, "ROBOT: [start_round]")
		assert(false, "ROBOT: [start_round] 错误：" + _res.message)
	if co.status == LuaCoroutine.STATUS_YIELD:
		_res = await co.completed
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		ModManager.print_lua_function_debug(fun, "ROBOT: [start_round]")
		assert(false, "ROBOT: [start_round] 错误：" + _res.message)
	return _res

func end_round() -> Variant:
	var fun = meta["end_round"] as LuaFunction
	var co = LuaCoroutine.create(fun)
	var _res = co.resume(meta)
	if _res is LuaError:
		ModManager.print_lua_function_debug(fun, "ROBOT: [end_round]")
		assert(false, "ROBOT: [end_round] 错误：" + _res.message)
	if co.status == LuaCoroutine.STATUS_YIELD:
		_res = await co.completed
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		ModManager.print_lua_function_debug(fun, "ROBOT: [end_round]")
		assert(false, "ROBOT: [end_round] 错误：" + _res.message)
	return _res

func interaction_processing(param) -> Variant:
	await Utils.get_scene_tree().create_timer(0.25).timeout
	var law = await ModManager.LuaAwaitWrapper.create_starter(func(_aw):
		var fun = meta["action_input"] as LuaFunction
		var co = LuaCoroutine.create(fun)
		var _res = co.resume(meta, param)
		if _res is LuaError:
			ModManager.print_lua_function_debug(fun, "ROBOT: [interaction_processing]")
			assert(false, "ROBOT: [interaction_processing] 错误：" + _res.message)
		if co.status == LuaCoroutine.STATUS_YIELD:
			_res = await co.completed
		# 如果执行的返回值是信号，需要等待信号触发
		if _res is Signal:
			_res = await _res
		if _res is LuaError:
			ModManager.print_lua_function_debug(fun, "ROBOT: [interaction_processing]")
			assert(false, "ROBOT: [interaction_processing] 错误：" + _res.message)
		return _res
	, param)
	await Utils.get_scene_tree().create_timer(0.05).timeout
	return law