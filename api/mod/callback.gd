extends Object
class_name ModCallbackApi

static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("call_hook", state.create_function(call_hook))
	table.set("call_event", state.create_function(call_event))
	table.set("get_event", state.create_function(get_event))
	table.set("has_timepoint_queue", state.create_function(has_timepoint_queue))
	table.set("set_timepoint_queue_sort_method", state.create_function(set_timepoint_queue_sort_method))
	table.set("set_card_info_show_method", state.create_function(set_card_info_show_method))
	table.set("set_area_info_show_method", state.create_function(set_area_info_show_method))

	state.globals["package"]["loaded"]["std.api.callback-api"] = table

# 	# Utils.get_current_scene().timepoint_manager.rr_hook[priority].append(behavior)

# 	# Utils.get_current_scene().timepoint_manager.rr_hook[behavior["priority"]].remove(behavior)

static func call_hook(param: LuaTable) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		await Utils.get_scene_tree().process_frame

		var hook_name: String = _arg["name"] as String
		var hook_args: Variant = _arg["param"]

		var entries: Array = _collect_hook_entries(hook_name)

		entries.sort_custom(func(a, b):
			return a["priority"] > b["priority"]
		)

		for entry in entries:
			var behavior: Behavior = entry["behavior_ref"]
			var bt: Behavior.BehaviorTrigger = entry["bt"]

			var result = await behavior.hook_callback(bt, hook_name, hook_args)

			if result is Signal:
				result = await result

			if typeof(result) == TYPE_ARRAY:
				hook_args = result[0]
				if result[1]:
					break
			else:
				hook_args = result

		return hook_args
	, param)


static func _collect_hook_entries(hook_name: String) -> Array:
	var battle: Battle = Utils.get_current_scene()
	if not battle:
		return []

	var entries: Array = []

	var all_entity_dicts: Array[Dictionary] = [
		battle.cards,
		battle.players,
		battle.areas,
	]

	for entity_dict in all_entity_dicts:
		for entity_id in entity_dict:
			var entity: Entity = entity_dict[entity_id]
			if not is_instance_valid(entity):
				continue

			for behavior_code in entity.behaviors:
				var behavior: Behavior = FindUtils.find_behavior(behavior_code)
				if behavior == null or behavior.data == null:
					continue

				var hooks = behavior.data.get("hooks")
				if hooks == null:
					continue

				var hook_config = hooks.get(hook_name)
				if hook_config == null:
					hook_config = hooks.get("*")
					if hook_config == null:
						continue

				var priority: int = 100
				
				if hook_config is LuaTable:
					priority = hook_config.rawget("priority", 0)
				else:
					priority = 0

				var bt := Behavior.BehaviorTrigger.new()
				bt.setup(entity_id, behavior_code, behavior)

				entries.append({
					"priority": priority,
					"bt": bt,
					"behavior_ref": behavior,
				})

	return entries

# 关于 SN02 的效果循环问题：
# 1. [1]处理过程中触发新的事件
# 2. [1]触发的新事件调用call_event成为[2]
# 3. [2]处理完成后,处理[1]
# 4. [1]处理过程中触发新的事件……

static func get_event(param: LuaTable) -> Variant:
	var eid = param["event"]
	var mode = param["mode"] if param["mode"] else "ALL"
	return Utils.get_current_scene().timepoint_manager.get_event(eid, mode)

static func call_event(param: LuaTable) -> Signal:
	# LogUtils.info(str("call_event > START: ", LuaUtils.table_to_dictionary(param)))
	# print(str("call_event > START: ", LuaUtils.table_to_dictionary(param)))
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		# LogUtils.info(str("[CORE] call_event: ", LuaUtils.table_to_dictionary(param)))
		# print(str("[CORE] call_event: ", LuaUtils.table_to_dictionary(param)))

		var event = param["event"]
		# 其他的配置 config 作为动画演出效果，在这里处理
		var config = LuaUtils.table_to_dictionary(param["config"])
		var unlock = false
		if config.has("unlock"):
			unlock = config["unlock"]
		if config.has("animate") and config.get("animate") == "Default":
			if event["header"]["type"] == "EFFECT":
				await effect_animate(event, config)

		var table = null
		var timepoint_queue = Utils.get_current_scene().timepoint_manager.create_timepoint_queue()

		if timepoint_queue.in_executing and unlock:
			LogUtils.info("创建 sub 时点列表")
			var tq = timepoint_queue.get_last_sub_timepoint_queue()
			var sub = Utils.get_current_scene().timepoint_manager.TimepointQueue.new()
			tq.set_sub_timepoint_queue(sub)
			sub.append_event(event)
			sub.start()
			await sub.finished
			table = sub.finished_queue
			tq.sub_timepoint_queue = null
			LogUtils.info("sub 时点列表处理完毕")
		else:
			timepoint_queue.append_event(event)
			timepoint_queue.start()
			await timepoint_queue.finished
			table = timepoint_queue.finished_queue
			Utils.get_current_scene().timepoint_manager.timepoint_queue = null
			# LogUtils.info("时点队列处理完毕，队列已销毁")
			print("时点队列处理完毕，队列已销毁")
		return table
	, param)

static func set_timepoint_queue_sort_method(param) -> void:
	var method = param["method"]
	Utils.get_current_scene().timepoint_manager.timepoint_queue_sort_method = func(rr_meta: Array, queue: LuaTable, context: LuaTable):
		#print("==== 触发时点队列排序方法 ====")
		#print("rr_meta : ", rr_meta.size())
		#print("method  : ", method)
		#print("QUEUE   : ", LuaUtils.table_to_dictionary(queue))
		await Utils.get_scene_tree().process_frame
		var tb = LuaUtils.array_to_table(rr_meta)
		var co = LuaCoroutine.create(method)
		var res = co.resume(tb, queue, context)
		if res is LuaError:
			ModManager.print_lua_function_debug(method, "时点队列排序方法错误")
			assert(false, "时点队列排序方法错误:" + res.message)
		if co.status == LuaCoroutine.STATUS_YIELD:
			res = await co.completed
		#if res is not LuaTable:
		#	assert(false, "时点队列排序方法返回值不是 LuaTable 类型")
		# res: { chain: { chain: index<int>这个是连锁的索引, behavior: Behavior 这是进行连锁的行为 }, context: context }
		#print("chain : ", LuaUtils.table_to_dictionary(res))
		#print("==== 触发时点队列排序结果 ====\n\n")
		return res

static func set_card_info_show_method(param) -> void:
	var method = param["method"]
	Utils.get_current_scene().callback_cache.card_info_show_method = func(player_id, card_id):
		var co = LuaCoroutine.create(method)
		var res = co.resume(card_id, player_id)
		if res is LuaError:
			ModManager.print_lua_function_debug(method, "卡片信息自定义方法错误")
			assert(false, "卡片信息自定义方法错误:" + res.message)
		if co.status == LuaCoroutine.STATUS_YIELD:
			res = await co.completed
		if res is not String:
			assert(false, "卡片信息自定义方法返回值不是 LuaTable 类型")
		return res
	pass
static func set_area_info_show_method(param) -> void:
	var method = param["method"]
	Utils.get_current_scene().callback_cache.area_info_show_method = func(player_id, area_id):
		var co = LuaCoroutine.create(method)
		var res = co.resume(area_id, player_id)
		if res is LuaError:
			ModManager.print_lua_function_debug(method, "区域信息自定义方法错误")
			assert(false, "区域信息自定义方法错误:" + res.message)
		if co.status == LuaCoroutine.STATUS_YIELD:
			res = await co.completed
		if res is not String:
			assert(false, "时点队列排序方法返回值不是 String 类型")
		return res
	pass

static func has_timepoint_queue() -> bool:
	return Utils.get_current_scene().timepoint_manager.timepoint_queue != null

static func effect_animate(event, config):
	var bt := Behavior.BehaviorTrigger.new()
	var b := FindUtils.find_behavior(event["header"]["bt"]["code"])
	bt.setup(event["header"]["bt"]["origin"], event["header"]["bt"]["code"], b)
	var c := FindUtils.find_card(bt.origin)
	var a: Dictionary = GApiManager.card_api.get_area(bt.origin)
	var area = ""
	var behavior_info = b.get_info()
	if a["area_id"]:
		area = "Scene"
	else:
		area = a["type"]
	if behavior_info["name"]:
		ToastUtils.info("在 [%s] 的 [%s] 的效果发动（[%s][%s]）" % [area, c.name, behavior_info["type"], behavior_info["name"]])
	else:
		ToastUtils.info("在 [%s] 的 [%s] 的效果发动（[%s]）" % [area, c.name, behavior_info["type"]])
	if config.has("animate") and config["animate"] == "Default":
		var sound = ""
		if config.has("sound"):
			sound = config["sound"]
		await GApiManager.view_api.card_effect_show(bt, "【" + behavior_info["type"] + "】" + behavior_info["name"], behavior_info["description"], area, c.image, sound)
