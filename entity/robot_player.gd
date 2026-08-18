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
	var _res =meta["start_round"].invoke(meta)
	if _res is LuaCoroutine:
		var error = _res.resume(meta)
		if error is LuaError:
			assert(false, "ROBOT: [start_round] 错误：" + error.message)
		if _res.status == LuaCoroutine.STATUS_YIELD:
			_res = await _res.completed
		else:
			_res = error
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		assert(false, "ROBOT: [start_round] 错误：" + _res.message)
	return _res


func end_round() -> Variant:
	var _res = meta["end_round"].invoke(meta)
	if _res is LuaCoroutine:
		var error = _res.resume(meta)
		if error is LuaError:
			assert(false, "ROBOT: [end_round] 错误：" + error.message)
		if _res.status == LuaCoroutine.STATUS_YIELD:
			_res = await _res.completed
		else:
			_res = error
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		assert(false, "ROBOT: [end_round] 错误：" + _res.message)
	return _res

func interaction_processing(param) -> Variant:
	await Utils.get_scene_tree().create_timer(0.25).timeout
	var law = await ModManager.LuaAwaitWrapper.create_starter(func(_aw): 
		var _res = meta["action_input"].invoke(meta, param)
		# 如果执行的返回值是携程，需要等待携程完成
		if _res is LuaCoroutine:
			var error = await _res.resume(meta, param)
			if error is LuaError:
				assert(false, "ROBOT: [interaction_processing] 错误：" + error.message)
			if _res.status == LuaCoroutine.STATUS_YIELD:
				_res = await _res.completed
			else:
				_res = error
		# 如果执行的返回值是信号，需要等待信号触发
		if _res is Signal:
			_res = await _res
		if _res is LuaError:
			assert(false, "ROBOT: [interaction_processing] 错误：" + _res.message)
		return _res
	, param)
	await Utils.get_scene_tree().create_timer(0.05).timeout
	return law
