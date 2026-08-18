extends Object
class_name ModSyncApi


# Lua 异步等待实例集
static var await_wrappers = {}


static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("create", state.create_function(create))
	table.set("clear", state.create_function(clear))
	table.set("wait", state.create_function(wait))
	table.set("create_sync", state.create_function(create_sync))
	state.globals["package"]["loaded"]["std.api.sync-api"] = table


static func create(param) -> String:
	var id = IDUtils.generate("ASYNC_")
	await_wrappers[id] = param
	return id


static func clear(param) -> void:
	var ids: Array = param["ids"].to_array()
	for id in ids:
		if await_wrappers.has(id):
			await_wrappers.erase(id)


static func wait(param) -> Signal:
	var ids: Array = param["ids"].to_array()
	if ids.is_empty():
		return Utils.get_scene_tree().process_frame
	var law_list = []
	for id in ids:
		if await_wrappers.has(id):
			var aw = await_wrappers[id]
			var law = ModManager.LuaAwaitWrapper.create(func(_aw): 
				# var _param = _aw["param"]
				# var _method: LuaFunction = _aw["method"]
				# var _res = _method.invoke(_param)
				# # 如果执行的返回值是携程，需要等待携程完成
				# if _res is LuaCoroutine:
				# 	var error = _res.resume(_param)
				# 	if error is LuaError:
				# 		assert(false, "Async: [wait] 错误：" + error.message)
				# 	if _res.status == LuaCoroutine.STATUS_YIELD:
				# 		_res = await _res.completed
				# 	else:
				# 		_res = error
				# # 如果执行的返回值是信号，需要等待信号触发
				# if _res is Signal:
				# 	_res = await _res
				# if _res is LuaError:
				# 	assert(false, "Async: [wait] 错误：" + _res.message)
				# return _res
				return await ModManager.run_lua_function(_aw["method"], _aw["param"])
				
			, aw)
			law.id = id
			law_list.append(law)
	var laws = ModManager.LuaAwaitWrapperSet.create(law_list)
	laws.start()
	return laws.await_all_completed


static func create_sync(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_param):
		var co = param["method"]
		var arg = param["param"]
		var _self = param["self"]
		var _invoke_mode = param["mode"] if param["mode"] != null else "TABLE"
		# await Utils.get_scene_tree().process_frame
		var res = await ModManager.run_lua_function(co, arg, _self, _invoke_mode)
		return res
	, param)
