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
	# table.set("append_hook", state.create_function(append_hook))
	# table.set("remove_hook", state.create_function(remove_hook))
	state.globals["package"]["loaded"]["std.api.callback-api"] = table


# static func append_hook(param: LuaTable) -> void:
# 	var name = param["name"]
# 	var priority = param["priority"]
# 	var behavior = param["behavior"]
# 	# Utils.get_current_scene().timepoint_manager.rr_hook[priority].append(behavior)


# static func remove_hook(param: LuaTable) -> void:
# 	var behavior = param["behavior"]
# 	# Utils.get_current_scene().timepoint_manager.rr_hook[behavior["priority"]].remove(behavior)


static func call_hook(param: LuaTable) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		# await Utils.get_scene_tree().process_frame
		var _n = param["name"]
		var _p = param["param"]

		var prioritys = Utils.get_current_scene().timepoint_manager.rr_hook.keys()
		prioritys.sort()
		prioritys.reverse()

		for key in prioritys:
			for rr in Utils.get_current_scene().timepoint_manager.rr_hook[key]:
				var behavior = rr
				var res = behavior["hook_callback"].invoke(behavior, _n, _p)
				if res is LuaError:
					assert(false, "HOOK回调方法错误:" + res.message)
				if res is LuaCoroutine:
					var error = res.resume(behavior, _n, _p)
					if error is LuaError:
						assert(false, "HOOK回调方法错误[Coroutine]:" + error.message)
					if res.status == LuaCoroutine.STATUS_YIELD:
						res = await res.completed
					else:
						res = error

		return _p
	, param)


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
	return ModManager.LuaAwaitWrapper.create_starter(func(_arg):
		var event = param["event"]
		# 其他的配置 config 作为动画演出效果，在这里处理
		# animate
		# sound
		var config = LuaUtils.table_to_dictionary(param["config"])
		var unlock = false
		if config.has("unlock"):
			unlock = config["unlock"]
		
		# ##### 表现效果
		if event["header"]["type"] == "EFFECT":
			var c = GApiManager.behavior_api.get_ownership(event["header"]["trigger"])
			var b = FindUtils.find_behavior(event["header"]["trigger"])
			var a = GApiManager.card_api.get_area(c.name)
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
				await GApiManager.view_api.card_effect_show("【" + behavior_info["type"] + "】" + behavior_info["name"], behavior_info["description"], area, c.image, sound)
		else:
			pass
		# #####

		var table = null
		var timepoint_queue = Utils.get_current_scene().timepoint_manager.create_timepoint_queue()

		if timepoint_queue.in_executing and unlock:
			# print("创建 sub 时点列表")
			var tq = timepoint_queue.get_last_sub_timepoint_queue()
			var sub = Utils.get_current_scene().timepoint_manager.TimepointQueue.new()
			tq.set_sub_timepoint_queue(sub)
			sub.append_event(event)
			sub.start()
			await sub.finished
			table = sub.finished_queue
			tq.sub_timepoint_queue = null
			# print("sub 时点列表处理完毕")
		else:
			timepoint_queue.append_event(event)
			timepoint_queue.start()
			await timepoint_queue.finished
			table = timepoint_queue.finished_queue
			Utils.get_current_scene().timepoint_manager.timepoint_queue = null
			# print("时点队列处理完毕，队列已销毁")
		return table
	, param)

static func set_timepoint_queue_sort_method(param) -> void:
	var method = param["method"]
	Utils.get_current_scene().timepoint_manager.timepoint_queue_sort_method = func(rr_meta: Array, queue: LuaTable, context: LuaTable):
		await Utils.get_scene_tree().process_frame
		var tb = LuaUtils.array_to_table(rr_meta)
		var res = method.invoke(tb, queue, context)
		if res is LuaError:
			assert(false, "时点队列排序方法错误:" + res.message)
		if res is LuaCoroutine:
			var error = res.resume(tb, queue, context)
			if error is LuaError:
				assert(false, "时点队列排序方法错误[Coroutine]:" + error.message)
			if res.status == LuaCoroutine.STATUS_YIELD:
				res = await res.completed
			else:
				res = error
		if res is not LuaTable:
			assert(false, "时点队列排序方法返回值不是 LuaTable 类型")
		# res: { chain: { chain: index<int>这个是连锁的索引, behavior: Behavior 这是进行连锁的行为 }, context: context }
		return res

static func set_card_info_show_method(param) -> void:
	var method = param["method"]
	Utils.get_current_scene().callback_cache.card_info_show_method = func(player_id, card_id):
		print("调用 card_info_show_method ： ", player_id, " | ", card_id)
		var res = method.invoke(card_id, player_id)
		if res is LuaError:
			assert(false, "时点队列排序方法错误:" + res.message)
		if res is LuaCoroutine:
			var error = res.resume(card_id, player_id)
			if error is LuaError:
				assert(false, "时点队列排序方法错误[Coroutine]:" + error.message)
			if res.status == LuaCoroutine.STATUS_YIELD:
				res = await res.completed
			else:
				res = error
		if res is not String:
			assert(false, "时点队列排序方法返回值不是 LuaTable 类型")
		# res: { chain: { chain: index<int>这个是连锁的索引, behavior: Behavior 这是进行连锁的行为 }, context: context }
		return res
	pass
static func set_area_info_show_method(param) -> void:
	var method = param["method"]
	Utils.get_current_scene().callback_cache.area_info_show_method = func(player_id, area_id):
		print("调用 area_info_show_method ： ", player_id, " | ", area_id)
		var res = method.invoke(area_id, player_id)
		if res is LuaError:
			assert(false, "时点队列排序方法错误:" + res.message)
		if res is LuaCoroutine:
			var error = res.resume(area_id, player_id)
			if error is LuaError:
				assert(false, "时点队列排序方法错误[Coroutine]:" + error.message)
			if res.status == LuaCoroutine.STATUS_YIELD:
				res = await res.completed
			else:
				res = error
		if res is not String:
			assert(false, "时点队列排序方法返回值不是 String 类型")
		# res: { chain: { chain: index<int>这个是连锁的索引, behavior: Behavior 这是进行连锁的行为 }, context: context }
		return res
	pass

static func has_timepoint_queue() -> bool:
	return Utils.get_current_scene().timepoint_manager.timepoint_queue != null
