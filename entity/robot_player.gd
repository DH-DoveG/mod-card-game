extends Player
class_name RobotPlayer


func set_info(param: Dictionary) -> void:
	# print("ROBOT: [set_info] :", param)
	super(param)
	var t = GResourceManager.player_resource[param["template"]]
	var _meta: LuaFunction = ModManager.state.do_file(t["path"])
	# print("_deck: ", _deck)
	var data = _meta.invoke()
	# print("_di: ", data)
	# print("_di:： ", LuaUtils.table_to_dictionary(data))
	var deck_id = data["deck"]

	# FIXME
	#var df = GResourceManager.deck_resource[deck_id]
	#var _deck = ModManager.state.do_file(df)
	#if _deck is LuaError:
		#assert(false, "Robot Load Deck Error = " + _deck.message)
	#if _deck is not LuaTable:
		#assert(false, "Robot Load Deck is not lua table.")
	#use_deck_config = LuaUtils.table_to_dictionary(_deck)
	#use_deck_config["content"] = use_deck_config["content"].values()
	#var template = option_side_player_template.get_item_text(deck_id)
	#var deck = option_side_used_deck.get_item_text(option_side_used_deck.get_selected_id())
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
	
	# print("ROBOT: [set_info] DECK:", LuaUtils.table_to_dictionary(_deck.invoke()))
	# FIXME
	# EventBus.subscribe("EVENT", event_processing)
	# data["camp"] = param["camp"]
	data["entity"]["id"] = param["pid"]
	data["name"] = player_name
	meta = data


#func set_camp(_camp: String) -> void:
	#super(_camp)
	#meta["camp"] = _camp


func start_round() -> Variant:
	# print("[ROBOT] start_round")
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
		# print("ROBOT: [start_round] 错误：", _res)
		assert(false, "ROBOT: [start_round] 错误：" + _res.message)
	return _res


func end_round() -> Variant:
	# print("[ROBOT] end_round")
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
		# print("ROBOT: [end_round] 错误：", _res)
		assert(false, "ROBOT: [end_round] 错误：" + _res.message)
	return _res


#func event_processing(param) -> Variant:
	## print("ROBOT: [event_processing] :", param)
	#return null

func interaction_processing(param) -> Variant:
	# print("\n===============")
	# print("ROBOT: [interaction_processing] :", LuaUtils.table_to_dictionary(param))
	#await get_tree().create_timer(0.25).timeout
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
	# print("返回值：", law)
	# print("转换：", LuaUtils.table_to_dictionary(law))
	#await get_tree().create_timer(0.05).timeout
	await Utils.get_scene_tree().create_timer(0.05).timeout
	return law
