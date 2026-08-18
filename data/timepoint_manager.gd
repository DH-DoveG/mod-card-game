extends RefCounted
class_name TimepointManager

var timepoint_queue_sort_method: Callable = sort_timepoint_queue
var timepoint_queue: TimepointQueue = null
var rr_meta = []
var rr_hook = {} # key: 优先级数字, value: 回调函数数组

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
			var item = queue.get(index)
			in_executing = true
			await step(item)
			# queue 不弹出元素就会无限循环
			# set为null就会报错
			finished_queue.set(finished_queue.to_array().size(), item)
			queue.set(index, null)
			in_executing = false
			if not await_queue.is_empty():
				for aq in await_queue:
					queue.set(queue.to_array().size() + 1, aq)
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
			queue.set(queue.to_array().size() + 1, event)

	func step(item):
		# 开始取出队列中的时点
		# 处理时点
		# print(">>>> 处理开始：", item["header"]["name"])
		var res = await ModManager.LuaAwaitWrapper.create_starter(func(__):
			var _owner = item["body"]["owner"]
			var _res = null
			if typeof(_owner) == TYPE_STRING and not _owner.is_empty():
				_owner = FindUtils.find_behavior(_owner).data
				_res = item["body"]["method"].invoke(_owner, item["body"]["params"], queue)
			else:
				_res = item["body"]["method"].invoke(item["body"]["params"], queue)
			if _res is LuaCoroutine:
				var error = null
				if _owner != null:
					error = _res.resume(_owner, item["body"]["params"], queue)
				else:
					error = _res.resume(item["body"]["params"], queue)
				if error is LuaError:
					assert(false, "TimepointManager: sort_timepoint_queue: LuaError: " + error.message)
				if _res.status == LuaCoroutine.STATUS_YIELD:
					_res = await _res.completed
				else:
					_res = error
			return _res
		, null)
		# print(">>>> 处理结束：", item["header"]["name"])
		item["response"] = res
	
	func check_connect():
		# print("进行连锁检查：", chain_count)
		var launch = await Utils.get_current_scene().timepoint_manager.timepoint_queue_sort_method.call(Utils.get_current_scene().timepoint_manager.rr_meta, queue, context)
		context = launch["context"] # 更新上下文
		if launch["chain"] != null:
			chain_count += 1
			# 调用 launch 的 behavior
			var behavior: Behavior = FindUtils.find_behavior(launch["chain"]["behavior"])
			# 这里等待 behavior 执行完成
			# * 这里的launch是不允许用户取消的，因为用户先前已经确认了发动
			# 但是因为可能需要执行将卡选取位置摆放的操作，所以需要等待其完成
			# in_executing = true
			await (behavior as BehaviorLua).launch({
				"trigger": launch["chain"]["player"],
				"ban_cancel": true, # 不可取消的发动
				"event": {
					"event": queue.to_array()[launch["chain"]["index"] - 1],
					"context": context, # 上下文信息
					"chain_id": launch["chain"],
				},
				"custom": launch["chain"].get("custom")
			})
			# in_executing = false
			await Utils.get_scene_tree().process_frame
			if await_queue.size() > 0:
				for aq in await_queue:
					queue.set(queue.to_array().size() + 1, aq)
				await_queue = []
			has_connect.emit(true)
			return
		has_connect.emit(false)

func subscribe(entity: Behavior):
	if is_instance_valid(entity):
		rr_meta.append(entity.data)
		if entity.data["hook_callback"] != null:
			var priority = entity.data["hook_priority"]
			if rr_hook.has(priority):
				rr_hook[priority].append(entity.data)
			else:
				rr_hook[priority] = [entity.data]

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
