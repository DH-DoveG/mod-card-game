extends Player
class_name HumanPlayer


func set_info(param: Dictionary) -> void:
	super(param)
	use_deck_config = param["deck"]
	var template = GResourceManager.player_entitys_resource[param["template"]]
	var player_meta = ModManager.state.do_file(template)
	var data = player_meta.invoke()
	data["mount_type"] = "HUMAN"
	# 这里需要思考人类的卡组是否在 lua 中注册
	# 因为现在用的卡组来自 lua mod 的注册预组
	# 但是卡组不一定是在 lua 中注册的，玩家可以手动编辑，
	# 不过有一说一：卡组文件是 .lua 文件，所以是会被收集加载的
	# 也就是说即使是玩家自己的卡组文件，也是放在一个指定目录下的文件
	# 所以会被收集加载，注册到 lua 中，并且根据卡组文件里的名称自动注册卡组为对应名称
	# 所以这里传入卡组文件的名字（资源根据名称进行查找）
	# 所以这里需要传入卡组文件的名称
	# { "TYPE": "HUMAN", 
	#   "avatar": "DEFAULT_AVATAR", 
	#   "standing_sign": "", 
	#   "deck": "D:/dh/mod_card/mod_card_mods/coci/decks/default.lua", 
	#   "TEMPLATE": "base_player", 
	#   "id": "PLAYER_00000000" }
	#data["deck"] = use_deck
	#data["avatar"] = param["avatar"]
	data["entity"]["id"] = param["pid"]
	data["name"] = player_name
	meta = data


#func set_camp(_camp: String) -> void:
	#super(_camp)
	#meta["camp"] = _camp


func start_round() -> Variant:
	# print("[HUMAN] start_round ", name)
	var _res = meta["start_round"].invoke(meta)
	if _res is LuaCoroutine:
		var error = _res.resume(meta)
		if error is LuaError:
			assert(false, "HUMAN: [start_round] 错误：" + error.message)
		if _res.status == LuaCoroutine.STATUS_YIELD:
			_res = await _res.completed
		else:
			_res = error
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		assert(false, "HUMAN: [start_round] 错误：" + _res.message)
	return _res

func end_round() -> Variant:
	var _res = meta["end_round"].invoke(meta)
	if _res is LuaCoroutine:
		var error = _res.resume(meta)
		if error is LuaError:
			assert(false, "HUMAN: [end_round] 错误：" + error.message)
		if _res.status == LuaCoroutine.STATUS_YIELD:
			_res = await _res.completed
		else:
			_res = error
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		assert(false, "HUMAN: [end_round] 错误：" + _res.message)
	return _res


func event_processing(_param) -> Variant:
	# print("HUMAN: [event_processing] :", param)
	return null


func interaction_processing(_param) -> Variant:
	# print("\n===============")
	# print("HUMAN: [interaction_processing] :", LuaUtils.table_to_dictionary(param))
	return null
