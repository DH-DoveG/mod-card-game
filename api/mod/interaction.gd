extends Object
class_name ModInteractionApi


static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("show_select_dialog", state.create_function(show_select_dialog))
	table.set("show_select_card_dialog", state.create_function(show_select_card_dialog))
	table.set("show_confirm_dialog", state.create_function(show_confirm_dialog))
	table.set("show_choose_areas", state.create_function(show_choose_areas))
	table.set("show_tab_dialog", state.create_function(show_tab_dialog))
	state.globals["package"]["loaded"]["std.api.interaction-api"] = table


# ============================================================
# Helpers
# ============================================================

static func _show_waiting_tips(use: String, player_id: String, current_round_player: String) -> String:
	if use != current_round_player:
		var player_name = FindUtils.find_player(player_id).player_name
		var top_tips_id = IDUtils.generate("TOP_TIPS_")
		GApiManager.interaction_api.rpc("show_top_tips", {
			"id": top_tips_id,
			"text": "请等待[" + player_name + "]操作",
			"skip_player_id": use
		})
		return top_tips_id
	return ""


static func _hide_waiting_tips(top_tips_id: String) -> void:
	if not top_tips_id.is_empty():
		GApiManager.interaction_api.rpc("hide_top_tips", {"id": top_tips_id})


static func _route_interaction(use: String, config: Dictionary, rpc_method: Callable, uid_suffix: bool = true, wrap_callback: bool = true) -> Variant:
	var scene: Battle = Utils.get_current_scene()
	if scene.host_player_id == use:
		return await rpc_method.call(config)

	var ccids: Array = []
	var prefix = str(scene.uid) + "_" if uid_suffix else ""
	for b in config["btns"]:
		var id = IDUtils.generate("CC_DIG_" + prefix)
		ccids.append(id)
		Utils.get_current_scene().callback_cache.caches[id] = b["callback"]
		if wrap_callback:
			b["callback"] = {"id": id, "cache_host_id": scene.uid}
		else:
			b["callback"] = id

	var player = FindUtils.find_player(use)
	var uid = player.id
	var player_info = GNetManager.players.get(uid)
	assert(player_info, "player_info is null")

	var _res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(3600, uid, rpc_method.bind(config))
	for ccid in ccids:
		Utils.get_current_scene().callback_cache.caches.erase(ccid)
	return _res


# ============================================================
# Dialog Functions
# ============================================================

static func show_choose_areas(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null

		var title = _arg["title"] if _arg["title"] else "选择区域"
		var detail = _arg["detail"] if _arg["detail"] != null else ""
		var areas = _arg["areas"].to_array() if _arg["areas"] != null else []
		var btns = _arg["btns"].to_array() if _arg["btns"] != null else []
		var _max = _arg["max_num"] if _arg["max_num"] != null else 1
		var _min = _arg["min_num"] if _arg["min_num"] != null else 1
		var can_cancel = _arg["can_cancel"] if _arg["can_cancel"] != null else true

		var player = FindUtils.find_player(use)
		var scene: Battle = Utils.get_current_scene()
		var top_tips_id = _show_waiting_tips(use, player.name, scene.current_round_player)

		var pbtns = []
		for btn in btns:
			pbtns.append({
				"text": btn["text"],
				"callback": func(chooses):
					var lua_chooses = LuaUtils.array_to_table(chooses)
					var _a_res = btn["callback"].invoke(lua_chooses, btn)
					if _a_res:
						return {"close": true, "text": btn["text"], "value": btn["value"]}
					return {"close": _a_res, "text": btn["text"], "value": btn["value"]}
			})

		GApiManager.interaction_api.rpc("player_option", true)

		if not player: return null
		var interaction_processing = await player.interaction_processing(param)
		if interaction_processing:
			scene.remove_in_option("_IN_OPT_PLAYER")
			_hide_waiting_tips(top_tips_id)
			return interaction_processing

		var config = {
			"use": use, "title": title, "detail": detail,
			"areas": areas, "btns": pbtns,
			"max": _max, "min": _min, "can_cancel": can_cancel,
		}
		var _res = await _route_interaction(use, config, GApiManager.interaction_api.show_choose_areas)
		_hide_waiting_tips(top_tips_id)

		var table = ModManager.state.create_table({})
		table = LuaUtils.dictionary_to_table(_res)
		GApiManager.interaction_api.rpc("player_option", false)
		return table
	, param)


static func show_select_dialog(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		await Utils.get_scene_tree().process_frame

		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null

		var player = FindUtils.find_player(use)
		var scene: Battle = Utils.get_current_scene()
		var top_tips_id = _show_waiting_tips(use, player.name, scene.current_round_player)

		if not player: return null
		var res = await player.interaction_processing(param)
		if res:
			_hide_waiting_tips(top_tips_id)
			return res

		var _max = _arg["max"] if _arg["max"] else 1
		var _min = _arg["min"] if _arg["min"] else 1
		var _detail = _arg["detail"] if _arg["detail"] else ""
		var _title = _arg["title"] if _arg["title"] else "选择选项弹窗"
		var _cancel = _arg["cancel"]
		var _confirm = _arg["confirm"]
		var _can_cancel = _arg["can_cancel"] if _arg["can_cancel"] != null else true
		var _show_list = []
		for i in _arg["items"].to_array():
			_show_list.append(LuaUtils.table_to_dictionary(i))

		var config = {
			"title": _title, "detail": _detail,
			"list": {"items": _show_list, "max": _max, "min": _min},
			"btns": [
				{"text": "确定", "callback": func(chooses):
					if chooses.size() == 0:
						return {"close": false, "choose_list": chooses, "choose_text": "Confirm"}
					if _confirm: _confirm.invoke(chooses)
					return {"close": true, "choose_list": chooses, "choose_text": "Confirm"}},
			]
		}
		if _can_cancel:
			config["btns"].append({"text": "取消", "callback": func(chooses):
				return {"close": _cancel.invoke(chooses), "choose_list": chooses, "choose_text": "Cancel"}})

		assert(scene is Battle, "Scene is not battle!!!")

		var _res = await _route_interaction(use, config, GApiManager.interaction_api.show_select_dialog)
		_hide_waiting_tips(top_tips_id)

		var table = LuaUtils.dictionary_to_table(_res)
		return table
	, param)


static func show_select_card_dialog(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null

		var player: Player = FindUtils.find_player(use)
		var scene = Utils.get_current_scene()
		var top_tips_id = ""
		if scene is Battle:
			top_tips_id = _show_waiting_tips(use, player.name, scene.current_round_player)

		if not player: return null
		var res = await player.interaction_processing(param)
		if res:
			_hide_waiting_tips(top_tips_id)
			return res

		var _max = _arg["max_num"] if _arg["max_num"] != null else 1
		var _min = _arg["min_num"] if _arg["min_num"] != null else 0
		var _detail = _arg["detail"] if _arg["detail"] != null else ""
		var _title = _arg["title"] if _arg["title"] != null else "选择卡牌弹窗"
		var _btns = _arg["btns"] if _arg["btns"] != null else null
		var _can_cancel = _arg["can_cancel"] if _arg["can_cancel"] != null else true
		var _confirm = _arg["confirm"]
		var _show_list = []
		for cid in _arg["cards"].to_array():
			var _card = FindUtils.find_card(cid)
			_show_list.append({
				"value": cid,
				"background": _card.image,
				"text": _card.card_name,
			})

		var btns = []
		if _btns == null:
			btns = [
				{"text": "确定", "callback": func(chooses):
					if chooses.size() < _min:
						return {"close": false, "choose_list": chooses, "choose_text": "Confirm", "choose_value": true}
					if _confirm: _confirm.invoke(chooses)
					return {"close": true, "choose_list": chooses, "choose_text": "Confirm", "choose_value": null}},
			]
			if _can_cancel:
				btns.append({"text": "取消", "callback": func(chooses):
					return {"close": true, "choose_list": chooses, "choose_text": "Cancel", "choose_value": null}})
		else:
			for btn in _btns.to_array():
				btns.append({
					"text": btn["text"],
					"callback": func(chooses):
						if btn["callback"] == null:
							return {"close": true, "choose_list": chooses, "choose_text": btn["text"], "choose_value": btn.rawget("value", null)}
						var lua_chooses = LuaUtils.array_to_table(chooses)
						var _a_res = await ModManager.run_lua_function(btn["callback"], lua_chooses)
						if _a_res:
							return {"close": true, "choose_list": chooses, "choose_text": btn["text"], "choose_value": btn.rawget("value", null)}
						return {"close": _a_res, "choose_list": chooses, "choose_text": btn["text"], "choose_value": btn.rawget("value", null)}
				})

		var config = {
			"title": _title, "detail": _detail,
			"list": {"items": _show_list, "max": _max, "min": _min},
			"btns": btns,
		}

		var _res = await _route_interaction(use, config, GApiManager.interaction_api.show_select_card_dialog, false)
		_hide_waiting_tips(top_tips_id)
		var table = LuaUtils.dictionary_to_table(_res)
		return table
	, param)


static func show_tab_dialog(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null

		var title = _arg["title"] if _arg["title"] else "选择区域"
		var detail = _arg["detail"] if _arg["detail"] else ""
		var btns = _arg["btns"].to_array() if _arg["btns"] else []
		var tabs = LuaUtils.table_to_dictionary(_arg["tabs"]).values()

		var pbtns = []
		for btn in btns:
			pbtns.append({
				"text": btn["text"],
				"background": btn["background"],
				"callback": func(tab_value):
					var lua_tab_value = LuaUtils.array_to_table(tab_value)
					var _a_res = btn["callback"].invoke(lua_tab_value, btn)
					tab_value.append(btn["value"])
					return {"close": _a_res, "value": tab_value}
			})
		if pbtns.is_empty():
			pbtns = [
				{"text": "确定", "callback": func(tab_value):
					tab_value.append(true)
					return {"close": true, "value": tab_value}},
				{"text": "取消", "callback": func(tab_value):
					tab_value.append(false)
					return {"close": true, "value": tab_value}},
			]

		var player = FindUtils.find_player(use)
		var scene = Utils.get_current_scene()
		var top_tips_id = ""
		if scene is Battle:
			top_tips_id = _show_waiting_tips(use, player.name, scene.current_round_player)

		GApiManager.interaction_api.rpc("player_option", true)

		if not player: return null
		var interaction_processing = await player.interaction_processing(param)
		if interaction_processing:
			scene.remove_in_option("_IN_OPT_PLAYER")
			_hide_waiting_tips(top_tips_id)
			return interaction_processing

		var config = {"use": use, "title": title, "detail": detail, "btns": pbtns, "tabs": tabs}

		var _res = await _route_interaction(use, config, GApiManager.interaction_api.show_tab_dialog)
		_res["tab"] += 1
		_hide_waiting_tips(top_tips_id)

		var table = ModManager.state.create_table({})
		table = LuaUtils.dictionary_to_table(_res)
		GApiManager.interaction_api.rpc("player_option", false)
		return table
	, param)


static func show_confirm_dialog(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null
		var player: Player = FindUtils.find_player(use)

		var scene = Utils.get_current_scene()
		var top_tips_id = ""
		if scene is Battle:
			top_tips_id = _show_waiting_tips(use, player.name, scene.current_round_player)

		if not player: return null
		var res = await player.interaction_processing(param)
		if res:
			_hide_waiting_tips(top_tips_id)
			return res

		var _title = _arg["title"] if _arg["title"] != null else "选择卡牌弹窗"
		var _detail = _arg["detail"] if _arg["detail"] != null else ""

		var config = {
			"title": _title,
			"detail": _detail,
			"btns": [
				{"text": "确定", "callback": func(): return {"close": true, "option": true}},
				{"text": "取消", "callback": func(): return {"close": true, "option": false}},
			]
		}

		var _res = await _route_interaction(use, config, GApiManager.interaction_api.show_confirm_dialog, false, false)
		_hide_waiting_tips(top_tips_id)
		var table = LuaUtils.dictionary_to_table({"confirm": _res})
		return table
	, param)
