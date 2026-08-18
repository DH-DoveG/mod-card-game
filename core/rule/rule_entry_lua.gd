extends RuleEntry


var rule: LuaTable = null


func execute(data):
	# 这里等一帧是为了确保没有立刻的返回调用结果，防止调用立即完成发出信号，而外层等待时没有收到信号（因为在开始等待前就已经发出了）
	await Utils.get_scene_tree().process_frame
	var res = rule["execute"].invoke(rule, data, null)
	if res is LuaCoroutine:
		var error = res.resume(rule, data, null)
		if error is LuaError:
			assert(false, "RuleEntry: execute: LuaError: " + error.message)
		if res.status == LuaCoroutine.STATUS_YIELD:
			res = await res.completed
		else: 
			res = error
	if res is Signal:
		res = await res
	if res is LuaError:
		assert(false, "RuleEntry: execute: LuaError: " + res.message)
	
	execute_finished.emit(res)


func later():
	(rule["later"] as LuaFunction).invoke(rule)
