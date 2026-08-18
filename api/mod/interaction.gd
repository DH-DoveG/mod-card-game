extends Object
class_name ModInteractionApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("show_select_dialog", state.create_function(show_select_dialog))
	# table.set("show_throw_dice", state.create_function(show_throw_dice))
	table.set("show_select_card_dialog", state.create_function(show_select_card_dialog))
	table.set("show_confirm_dialog", state.create_function(show_confirm_dialog))
	# table.set("show_input_dialog", state.create_function(show_input_dialog))
	table.set("show_choose_areas", state.create_function(show_choose_areas))
	table.set("show_tab_dialog", state.create_function(show_tab_dialog))
	state.globals["package"]["loaded"]["std.api.interaction-api"] = table


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
		# 这里需要判断是不是主机玩家
		var scene: Battle = Utils.get_current_scene()
		var await_component = null
		if use != scene.host_player_id:
			# 这里需要显示等待组件
			await_component = load("res://components/top_tips/top_tips.tscn").instantiate()
			Utils.get_current_scene().add_child(await_component)
			await_component.set_text("请等待[" + player.name + "]操作")

		var pbtns = []
		for btn in btns:
			pbtns.append({
				"text": btn["text"],
				"callback": func(chooses):
					var lua_chooses = LuaUtils.array_to_table(chooses)
					var _a_res = btn["callback"].invoke(lua_chooses, btn)
					if _a_res:
						return {
							"close": true,
							"text": btn["text"],
							"value": btn["value"],
						}
					return {
							"close": _a_res,
							"text": btn["text"],
							"value": btn["value"],
						}
			})

		GApiManager.interaction_api.rpc("player_option", true)

		if not player: return null
		# 可以预处理，如果已经预处理了，就直接返回
		var interaction_processing = await player.interaction_processing(param)
		print("[CORE][show_choose_areas]预处理结果: ", interaction_processing)
		if interaction_processing:
			scene.in_option = false
			if await_component: await_component.queue_free()
			return interaction_processing

		var config = {
			"use": use,
			"title": title,
			"detail": detail,
			"areas": areas,
			"btns": pbtns,
			"max": _max,
			"min": _min,
			"can_cancel": can_cancel,
		}
		var _res = null

		if scene.host_player_id != use:
			# 1. 将 config 中
			var bs = []
			var ccids = []
			for b in config["btns"]:
				var id = IDUtils.generate("CC_DIG_" + str(scene.uid) + "_")
				ccids.append(id)
				# 问题是这里需要绑定
				Utils.get_current_scene().callback_cache.caches[id] = b["callback"]
				bs.append(id)
				b["callback"] = {
					"id": id,
					"cache_host_id": scene.uid
				}
			var uid = player.id
			var player_info = GNetManager.players.get(uid)
			assert(player_info, "player_info is null")
			_res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(3600, uid, GApiManager.interaction_api.show_choose_areas.bind(config))
			for ccid in ccids:
				Utils.get_current_scene().callback_cache.caches.erase(ccid)
			if await_component:
				await_component.queue_free()
		else:
			_res = await GApiManager.interaction_api.show_choose_areas(config)
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

		# 这里需要判断是不是主机玩家
		var scene: Battle = Utils.get_current_scene()
		var await_component = null
		if use != scene.host_player_id:
			# 这里需要显示等待组件
			await_component = load("res://components/top_tips/top_tips.tscn").instantiate()
			Utils.get_current_scene().add_child(await_component)
			await_component.set_text("请等待[" + player.name + "]操作")

		if not player: return null
		# # 可以预处理，如果已经预处理了，就直接返回
		var res = await player.interaction_processing(param)
		print("[CORE][show_select_dialog]预处理结果: ", res)
		if res:
			if await_component: await_component.queue_free()
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

		var table = ModManager.state.create_table({})

		var config = {
			"title": _title,
			"detail": _detail,
			"list": {
				"items": _show_list,
				"max": _max,
				"min": _min,
			},
			"btns": [
				{"text": "确定", "callback":
					func(chooses):
						if chooses.size() == 0:
							return {
								"close": false,
								"choose_list": chooses,
								"choose_text": "Confirm",
							}
						if _confirm:
							_confirm.invoke(chooses)
						return {
							"close": true,
							"choose_list": chooses,
							"choose_text": "Confirm",
						}},
			]
		}
		if _can_cancel:
			config["btns"].append({"text": "取消", "callback": func(chooses):
				return {
					"close": _cancel.invoke(chooses),
					"choose_list": chooses,
					"choose_text": "Cancel",
				}})

		# 上面的保留部分用于兼容Robot玩家
		# 下面需要对于多人游戏时做额外处理
		# 1. 先根据 use 判断其是否是 host_player_id
		# 2. 如果是就直接据徐就可，否则判断是否是网络玩家 GNetManager.players 中
		assert(scene is Battle, "Scene is not battle!!!")

		var _res = null

		if scene.host_player_id != use:
			# 1. 将 config 中
			var bs = []
			var ccids = []
			for b in config["btns"]:
				var id = IDUtils.generate("CC_DIG_" + str(scene.uid) + "_")
				ccids.append(id)
				# 问题是这里需要绑定
				Utils.get_current_scene().callback_cache.caches[id] = b["callback"]
				bs.append(id)
				b["callback"] = {
					"id": id,
					"cache_host_id": scene.uid
				}
			var uid = player.id
			var player_info = GNetManager.players.get(uid)
			assert(player_info, "player_info is null")
			_res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(3600, uid, GApiManager.interaction_api.show_select_dialog.bind(config))
			for ccid in ccids:
				Utils.get_current_scene().callback_cache.caches.erase(ccid)
		else:
			_res = await GApiManager.interaction_api.show_select_dialog(config)

		if await_component:
			await_component.queue_free()
	
		table = LuaUtils.dictionary_to_table(_res)
		return table
	, param)


static func show_select_card_dialog(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null

		var player: Player = FindUtils.find_player(use)

		# 这里需要判断是不是主机玩家
		var scene = Utils.get_current_scene()
		var await_component = null
		if scene is Battle:
			if use != scene.host_player_id:
				# 这里需要显示等待组件
				await_component = load("res://components/top_tips/top_tips.tscn").instantiate()
				Utils.get_current_scene().add_child(await_component)
				await_component.set_text("请等待[" + player.name + "]操作")

		if not player: return null
		# # 可以预处理，如果已经预处理了，就直接返回
		var res = await player.interaction_processing(param)
		print("[CORE][show_select_card_dialog](", use,") 预处理结果: ", res)
		if res:
			if await_component: await_component.queue_free()
			return res
		#######################################

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
				#"background": _card.entity.image,
				"background": _card.image,
				"text": _card.card_name,
			})
			pass

		var table = ModManager.state.create_table({})

		# btns
		var btns = []
		# 默认值
		if _btns == null:
			btns = [
				{
					"text": "确定",
					"callback": func(chooses):
						# print("默认确认")
						if chooses.size() < _min:
							return {
								"close": false,
								"choose_list": chooses,
								"choose_text": "Confirm",
								"choose_value": true
							}
						if _confirm:
							_confirm.invoke(chooses)
						# 这里整理数据
						return {
							"close": true,
							"choose_list": chooses,
							"choose_text": "Confirm",
							"choose_value": null
						}},
			]
			if _can_cancel:
				btns.append({
					"text": "取消",
					"callback": func(chooses):
						# print("默认取消")
						return {
							"close": true,
							"choose_list": chooses,
							"choose_text": "Cancel",
							"choose_value": null
						}},
				)
		else:
			for btn in _btns.to_array():
				btns.append({
					"text": btn["text"],
					"callback": func(chooses):
						print("自定义callback: ", btn["callback"])
						if btn["callback"] == null:
							return {
								"close": true,
								"choose_list": chooses,
								"choose_text": btn["text"],
								"choose_value": btn.get("value", null)
							}
						else:
							var lua_chooses = LuaUtils.array_to_table(chooses)
							var _a_res = await ModManager.run_lua_function(btn["callback"], lua_chooses)
							if _a_res:
								return {
									"close": true,
									"choose_list": chooses,
									"choose_text": btn["text"],
									"choose_value": btn.get("value", null)
								}
							return {
									"close": _a_res,
									"choose_list": chooses,
									"choose_text": btn["text"],
									"choose_value": btn.get("value", null)
								}
				})

		var config = {
			"title": _title,
			"detail": _detail,
			"list": {
				"items": _show_list,
				"max": _max,
				"min": _min,
			},
			"btns": btns,
		}

		var _res = null
		if scene.host_player_id != use:
		#if use != 1: # 不是主机的情况
			# 1. 将 config 中
			var bs = []
			var ccids = []
			for b in config["btns"]:
				var id = IDUtils.generate("CC_DIG_")
				ccids.append(id)
				# 问题是这里需要绑定
				Utils.get_current_scene().callback_cache.caches[id] = b["callback"]
				bs.append(id)
				# 如果使用弹窗的不是本机，那么就需要再额外的告诉他机去哪找到调用缓存
				b["callback"] = {
					"id": id,
					"cache_host_id": scene.uid
				}
			var uid = player.id
			var player_info = GNetManager.players.get(uid)
			assert(player_info, "player_info is null")
			_res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(3600, uid, GApiManager.interaction_api.show_select_card_dialog.bind(config))
			for ccid in ccids:
				Utils.get_current_scene().callback_cache.caches.erase(ccid)
		else:
			_res = await GApiManager.interaction_api.show_select_card_dialog(config)
		if await_component:
			await_component.queue_free()
		table = LuaUtils.dictionary_to_table(_res)
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
					return {
						"close": _a_res, # 是否关闭弹窗,
						"value": tab_value, # 处理完成后返回的值
					}
			})
		if pbtns.is_empty():
			pbtns = [ {
				"text": "确定",
				"callback": func(tab_value):
					tab_value.append(true)
					return {
						"close": true,
						"value": tab_value,
				}}, {
				"text": "取消",
				"callback": func(tab_value):
					tab_value.append(false)
					return {
						"close": true,
						"value": tab_value,
				}}]

		var player = FindUtils.find_player(use)
		var scene = Utils.get_current_scene()
		var await_component = null
		if scene is Battle:
			if use != scene.host_player_id:
				# 这里需要显示等待组件
				await_component = load("res://components/top_tips/top_tips.tscn").instantiate()
				Utils.get_current_scene().add_child(await_component)
				await_component.set_text("请等待[" + player.name + "]操作")

		GApiManager.interaction_api.rpc("player_option", true)

		if not player: return null

		# 可以预处理，如果已经预处理了，就直接返回
		var interaction_processing = await player.interaction_processing(param)
		print("[CORE][show_tab_dialog]预处理结果: ", interaction_processing)
		if interaction_processing:
			scene.in_option = false
			GApiManager.interaction_api.rpc("hide_top_tips")
			if await_component: await_component.queue_free()
			return interaction_processing

		var config = {
			"use": use,
			"title": title,
			"detail": detail,
			"btns": pbtns,
			"tabs": tabs
		}

		var _res = null

		if scene.host_player_id != use:
			# 1. 将 config 中
			var bs = []
			var ccids = []
			for b in config["btns"]:
				var id = IDUtils.generate("CC_DIG_" + str(scene.uid) + "_")
				ccids.append(id)
				# 问题是这里需要绑定
				Utils.get_current_scene().callback_cache.caches[id] = b["callback"]
				bs.append(id)
				b["callback"] = {
					"id": id,
					"cache_host_id": scene.uid
				}
			var uid = player.id
			var player_info = GNetManager.players.get(uid)
			assert(player_info, "player_info is null")
			_res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(3600, uid, GApiManager.interaction_api.show_tab_dialog.bind(config))
			for ccid in ccids:
				Utils.get_current_scene().callback_cache.caches.erase(ccid)
		else:
			_res = await GApiManager.interaction_api.show_tab_dialog(config)
		_res["tab"] += 1 # 为了和lua中的下标一致，需要加1
		var table = ModManager.state.create_table({})
		table = LuaUtils.dictionary_to_table(_res)
		if await_component:
			await_component.queue_free()
	
		GApiManager.interaction_api.rpc("player_option", false)

		return table
	, param)


static func show_confirm_dialog(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var use = _arg["use"] if _arg["use"] else ""
		if use.is_empty(): return null
		var player: Player = FindUtils.find_player(use)
		# 这里需要判断是不是主机玩家
		var scene = Utils.get_current_scene()
		var await_component = null
		if scene is Battle:
			if use != scene.host_player_id:
				# 这里需要显示等待组件
				await_component = load("res://components/top_tips/top_tips.tscn").instantiate()
				Utils.get_current_scene().add_child(await_component)
				await_component.set_text("请等待[" + player.name + "]操作")

		if not player: return null
		# # 可以预处理，如果已经预处理了，就直接返回
		var res = await player.interaction_processing(param)
		print("[CORE][show_confirm_dialog]预处理结果: ", res)
		if res:
			if await_component: await_component.queue_free()
			return res

		var _title = _arg["title"] if _arg["title"] != null else "选择卡牌弹窗"
		var _detail = _arg["detail"] if _arg["detail"] != null else ""

		var config = {
			"title": _title,
			"detail": _detail,
			"btns": [
				{
					"text": "确定",
					"callback": func(): return {
						"close": true,
						"option": true
					}},
				{
					"text": "取消",
					"callback": func(): return {
						"close": true,
						"option": false
					}}
			]
		}

		# 这里需要判断是不是主机玩家
		var _res = false
		if scene.host_player_id != use:
			# 1. 将 config 中
			var bs = []
			var ccids = []
			for b in config["btns"]:
				var id = IDUtils.generate("CC_DIG_")
				ccids.append(id)
				# 问题是这里需要绑定
				Utils.get_current_scene().callback_cache.caches[id] = b["callback"]
				bs.append(id)
				b["callback"] = id
			var uid = player.id
			var player_info = GNetManager.players.get(uid)
			assert(player_info, "player_info is null")
			_res = await Utils.get_current_scene().rpc_awaiter.send_rpc_timeout(3600, uid, GApiManager.interaction_api.show_confirm_dialog.bind(config))
			for ccid in ccids:
				Utils.get_current_scene().callback_cache.caches.erase(ccid)
		else:
			_res = await GApiManager.interaction_api.show_confirm_dialog(config)
		var table = LuaUtils.dictionary_to_table({"confirm": _res})
		return table
	, param)
