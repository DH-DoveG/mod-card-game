extends RefCounted
class_name TimepointManager

var timepoint_queue_sort_method: Callable = sort_timepoint_queue
var timepoint_queue: TimepointQueue = null
# var rr_meta = []
# var rr_hook = {} # key: 优先级数字, value: 回调函数数组

# 完成这个类，要求：
# 1. queue 可追加
# 2. 在 step 中每执行完成一次判定是否有 await_queue 如果里面有元素就添加到 queue 中，并且重新进行 run
# 3. 在 queue 中的元素执行完成后弹出加入已执行队列
# 4. 在 run 执行 1 步后，等待一个自己的信号，这个信号在 check_connect 中触发
#    如果 check_connect 中有连锁，发出的信号会返回 false 表示终止，返回 true 表示继续执行
# Q. 在因为信号返回 false 而中断后。如何回复执行呢？
# A. 需要约定，在响应后让其调用 call_event 以能够继续执行
# * 连锁越多就会有越多 call_event 被挂起
class TimepointQueue:
	var id: String = ""
	var in_executing: bool = false # 是否正在执行中
	var context: LuaTable = null # 上下文
	var queue: LuaTable = null
	var await_queue: Array[LuaTable] = [] # 等待执行的队列
	var finished_queue: LuaTable = null
	var has_exec: bool = false

	var sub_timepoint_queue: TimepointQueue = null

	var chain_count = 0

	signal has_connect()
	signal finished()
	signal run_next()

	func get_event(eid: String, mode: String) -> LuaTable:
		var queue_key = false
		var finished_queue_key = false
		if mode == "ALL":
			queue_key = true
			finished_queue_key = true
		elif mode == "QUEUE":
			queue_key = true
		elif mode == "FINISHED":
			finished_queue_key = true
		if queue_key:
			for item in queue.to_array():
				if item["header"]["id"] == eid:
					return item
		if finished_queue_key:
			for item in finished_queue.to_array():
				if item["header"]["id"] == eid:
					return item
		if sub_timepoint_queue != null:
			return sub_timepoint_queue.get_event(eid, mode)
		return null

	func get_last_sub_timepoint_queue() -> TimepointQueue:
		if sub_timepoint_queue == null:
			return self
		else:
			return sub_timepoint_queue.get_last_sub_timepoint_queue()

	func set_sub_timepoint_queue(stq: TimepointQueue):
		self.sub_timepoint_queue = stq
		stq.context = context
		stq.finished_queue = ModManager.state.create_table({})
		stq.queue = ModManager.state.create_table({})

	func start():
		if in_executing:
			if has_exec:
				run_next.emit()
			else:
				run()
			return
		check_connect() # ？
		var is_continue = await has_connect
		if not is_continue:
			# 如何实现 unlock 效果：即可配置的设置是否增加效果执行保护
			if has_exec:
				run_next.emit()
			else:
				run()

	func run():
		has_exec = true
		while queue.to_array().size() > 0:
			var index = queue.to_array().size()
			var item = queue.rawget(index)
			in_executing = true
			await step(item)
			finished_queue.rawset(finished_queue.to_array().size(), item)
			queue.rawset(index, null)
			in_executing = false
			if not await_queue.is_empty():
				for aq in await_queue:
					queue.rawset(queue.to_array().size() + 1, aq)
				await_queue = []
			if queue.to_array().size() == 0:
				finished.emit()
				return
			check_connect()
			var is_continue = await self.has_connect
			if is_continue:
				await self.run_next
		finished.emit()

	func append_event(event: LuaTable):
		if in_executing:
			await_queue.append(event)
		else:
			queue.rawset(queue.to_array().size() + 1, event)

	func step(item):
		# 开始取出队列中的时点
		# 处理时点
		var body = item["body"]
		var _method = body["method"]
		var _params = body["params"]
		var _params_mode: String = body["params_mode"] if body["params_mode"] else "TABLE"
		var _res = null

		#LogUtils.info(str("TIMEPOINT MANAGER :: step :: body > ", LuaUtils.table_to_dictionary(body)))
		#LogUtils.info(str("TIMEPOINT MANAGER :: step :: method > ", _method))
		#LogUtils.info(str("TIMEPOINT MANAGER :: step :: params > ", _params))
		#LogUtils.info(str("TIMEPOINT MANAGER :: step :: params_mode > ", _params_mode))

		if _method:
			var is_native_lua_func = true
			if _method is LuaFunction:
				var debug_info = _method.get_debug_info()
				if debug_info and debug_info.get_what() == "C":
					is_native_lua_func = false

			if is_native_lua_func:
				var co = LuaCoroutine.create(_method)
				if _params_mode == "ARRAY":
					var arr = _params.to_array()
					arr.append(queue)
					_res = co.resumev(arr)
				else:
					_res = co.resume(_params, queue)
				if _res is LuaError:
					ModManager.print_lua_function_debug(_method, "TimepointManager: sort_timepoint_queue: LuaError")
					assert(false, "TimepointManager: sort_timepoint_queue: LuaError: " + _res.message)
				if co.status == LuaCoroutine.STATUS_YIELD:
					_res = await co.completed
				elif _res is Signal:
					_res = await _res
			else:
				_res = _method.invoke(_params)
				if _res is LuaError:
					ModManager.print_lua_function_debug(_method, "TimepointManager: step: LuaError")
					assert(false, "TimepointManager: step: LuaError: " + _res.message)
				if _res is Signal:
					_res = await _res
		else:
			_res = _params

		item["response"] = _res

	
	#!!!! 这一部分需要确认能够从 tags 中将内容获取，用来判定是否连接
	func _extract_event_names(_queue: LuaTable) -> Array[String]:
		var names: Array[String] = []
		for item in _queue.to_array():
			var _arr = item["header"]["tags"].to_array()
			if _arr.is_empty():
				continue
			if item != null:
				names.append_array(_arr)
		return names

	func _collect_from_dict(candidates: Array, entity_dict: Dictionary, event_names: Array[String]) -> void:
		for origin in entity_dict:
			var entity: Entity = entity_dict[origin]
			if not is_instance_valid(entity):
				continue
			for bid in entity.behaviors:
				var behavior: Behavior = FindUtils.find_behavior(bid)
				var code = behavior.get_info()["code"]
				
				# 通过 BehaviorTrigger 解析链接触发条件（含实例级覆盖）
				var bt = Behavior.BehaviorTrigger.new()
				bt.setup(origin, code, behavior)
				var chain_triggers = bt.get_resolved_chain_triggers()
				
				# chain_triggers 中包含 * 表示匹配所有事件
				var matched = chain_triggers.has("*")
				if not matched:
					for trigger in chain_triggers:
						if event_names.has(trigger) or trigger == "*":
							matched = true
							break

				for i in event_names:
					if chain_triggers.has(i):
						# 确定传给自定义 timepoint_queue_sort_method 的 behaviors 参数
						candidates.append({
							"bt": bt.to_dict(),
							"behavior": behavior.data
						})

	func collect_chain_candidates(_queue: LuaTable) -> Array:
		var battle: Battle = Utils.get_current_scene()
		if not battle:
			return []
		
		var event_names = _extract_event_names(_queue)
		
		# print("collect_chain_candidates : ", event_names)

		var candidates: Array = []
		_collect_from_dict(candidates, battle.cards, event_names)
		_collect_from_dict(candidates, battle.players, event_names)
		_collect_from_dict(candidates, battle.areas, event_names)
		#_collect_from_dict(candidates, battle.camps, event_names)

		# print("candidates : ", candidates)
		
		return candidates

	func check_connect():
		# print("check_connect : ", queue)
		var chain_candidates = collect_chain_candidates(queue)
		# var launch = await Utils.get_current_scene().timepoint_manager.timepoint_queue_sort_method.call(chain_candidates, queue, context)
		var chain = await Utils.get_current_scene().timepoint_manager.timepoint_queue_sort_method.call(chain_candidates, queue, context)
		# context = launch["context"] # 更新上下文
		# var chain = launch.rawget("chain")
		if chain != null:
			chain_count += 1

			# var bt = Behavior.BehaviorTrigger.new()
			# var behavior: Behavior = FindUtils.find_behavior(launch["chain"]["behavior"])
			# bt.setup("", launch["chain"]["behavior"], behavior)
			# bt.set_trigger("EVENT_CHAINED", {
			# 	"user": launch["chain"]["player"],
			# 	"source_event": queue.to_array()[launch["chain"]["index"] - 1]["header"]["id"],
			# })
			# print("CHAIN ===>", LuaUtils.table_to_dictionary(chain))

			# print("----------LAUNCH:START:")
			# print(LuaUtils.table_to_dictionary(launch))
			# print("----------LAUNCH: END :")

			var behavior: Behavior = FindUtils.find_behavior(chain["bt"]["code"])
			var bt := Behavior.BehaviorTrigger.new()
			bt.setup(chain["bt"]["origin"], chain["bt"]["code"], behavior)
			# bt.set_trigger("EVENT_CHAINED", {
			# 	"user": chain["player"],
			# 	"source_event": queue.to_array()[chain["index"] - 1]["header"]["id"],
			# })
			bt.trigger = {
				"type": "EVENT",
				"data"  : queue.to_array()[chain["index"] - 1]["header"]["id"],
			}

			# 第二处 Behavior 触发点
			# await (behavior as BehaviorLua).launch(bt, {
			# 	"trigger": chain["player"],
			# 	"ban_cancel": true,
			# 	"event": {
			# 		"event": queue.to_array()[chain["index"] - 1],
			# 		"context": context,
			# 		"chain_id": chain,
			# 	},
			# 	"custom": chain.get("custom")
			# })
			var lua_arg = {
				"bt": bt.to_dict(),
				"events": {
					"queue": queue, # 时点队列
					"event": queue.to_array()[chain["index"] - 1], # 连锁的事件
					"context": context, # 上下文
					"chain": chain, # 连锁的事件的ID
				},
				"other": {
					"trigger": chain["player"],
					"ban_cancel": true,
				}
			}

			lua_arg = LuaUtils.dictionary_to_table(lua_arg)

			# print("----------LUA_ARG:START:")
			# print(LuaUtils.table_to_dictionary(lua_arg))
			print("行为发动参数2: ", lua_arg)
			# print("----------LUA_ARG: END :")

			var scene: Battle = Utils.get_current_scene()
			var res = await scene.rule_manager.exec_rule(scene.rule_manager.behavior_launch_rule, lua_arg)
			# var res = await scene.rule_manager.exec_rule(scene.rule_manager.behavior_launch_rule, {
			# 	"bt": LuaUtils.dictionary_to_table(bt.to_dict()),
			# 	"other": LuaUtils.dictionary_to_table(arg),
			# 	"event": 
			# 	"event": {
			# 		"event": queue.to_array()[chain["index"] - 1],
			# 		"context": context,
			# 		"chain_id": chain,
			# 	},
			# })
			print("行为发动结果2: ", res)

			await Utils.get_scene_tree().process_frame
			if await_queue.size() > 0:
				for aq in await_queue:
					queue.rawset(queue.to_array().size() + 1, aq)
				await_queue = []
			has_connect.emit(true)
			return
		has_connect.emit(false)

# func subscribe(entity: Behavior):
# 	if is_instance_valid(entity):
# 		rr_meta.append(entity.data)
# 		if entity.data["hook_callback"] != null:
# 			var priority = entity.data["hook_priority"]
# 			if rr_hook.has(priority):
# 				rr_hook[priority].append(entity.data)
# 			else:
# 				rr_hook[priority] = [entity.data]

func create_timepoint_queue() -> TimepointQueue:
	if timepoint_queue == null:
		timepoint_queue = TimepointQueue.new()
		timepoint_queue.finished_queue = ModManager.state.create_table({})
		timepoint_queue.queue = ModManager.state.create_table({})
		timepoint_queue.context = ModManager.state.create_table({})
	return timepoint_queue

func sort_timepoint_queue(behaviors, _context) -> Variant:
	return behaviors

func get_event(id: String, mode: String) -> LuaTable:
	if timepoint_queue == null:
		return null
	return timepoint_queue.get_event(id, mode)
