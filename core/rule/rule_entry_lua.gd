extends RuleEntry

var rule: LuaTable = null

func execute(data):
	# 这里等一帧是为了确保没有立刻的返回调用结果，防止调用立即完成发出信号，而外层等待时没有收到信号（因为在开始等待前就已经发出了）
	await Utils.get_scene_tree().process_frame
	var fun = rule["execute"] as LuaFunction
	var co = LuaCoroutine.create(fun)
	var res = co.resume(rule, data)
	if res is LuaError:
		ModManager.print_lua_function_debug(fun, "RuleEntry: execute: LuaError")
		assert(false, "RuleEntry: execute: LuaError: " + res.message)
	if co.status == LuaCoroutine.STATUS_YIELD:
		res = await co.completed
	if res is Signal:
		res = await res
	if res is LuaError:
		ModManager.print_lua_function_debug(fun, "RuleEntry: execute: LuaError")
		assert(false, "RuleEntry: execute: LuaError: " + res.message)
	execute_finished.emit(res)

func later(data = null):
	await Utils.get_scene_tree().process_frame
	var fun = rule["later"] as LuaFunction
	var co = LuaCoroutine.create(fun)
	var res = co.resume(rule, data)
	if res is LuaError:
		ModManager.print_lua_function_debug(fun, "RuleEntry: later: LuaError")
		assert(false, "RuleEntry: later: LuaError: " + res.message)
	if co.status == LuaCoroutine.STATUS_YIELD:
		res = await co.completed
	if res is Signal:
		res = await res
	if res is LuaError:
		ModManager.print_lua_function_debug(fun, "RuleEntry: later: LuaError")
		assert(false, "RuleEntry: later: LuaError: " + res.message)
