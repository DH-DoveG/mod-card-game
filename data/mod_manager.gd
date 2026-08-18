extends RefCounted
class_name ModManager

# 规范化后的 Lua 异步等待包装器类
class LuaAwaitWrapper extends Object:
	# 信号：异步任务完成时触发，携带任务返回结果
	signal await_completed(result)
	var _method: Callable
	var _arg = null
	var id = ""
	# 私有方法：执行异步任务
	func _run_async_task() -> void:
		await Utils.get_scene_tree().process_frame
		var taskResult = await _method.call(_arg)
		await_completed.emit(taskResult)
		Utils.get_scene_tree().process_frame.connect(func():
			self.free()
		, ConnectFlags.CONNECT_ONE_SHOT)
	func start() -> Signal:
		_run_async_task()
		return await_completed
	static func create(method: Callable, arg) -> LuaAwaitWrapper:
		var awaitWrapper = LuaAwaitWrapper.new()
		awaitWrapper._method = method
		awaitWrapper._arg = arg
		return awaitWrapper
	# 静态方法：创建异步启动器并启动（返回任务完成信号，供 Lua 侧 await）
	static func create_starter(method: Callable, arg) -> Signal:
		var awaitWrapper = LuaAwaitWrapper.new()
		awaitWrapper._method = method
		awaitWrapper._arg = arg
		return awaitWrapper.start()


# 异步等待包装器集合类。这个类主要用户多个异步同时执行
# 不过我们值得注意的一点是，Godot中其他线程不能够重绘页面
# 然后目前单机的实现形式下，也需要按顺序来进行，这是因为模态对话框的特性决定的
# 所以我们需要等待所有异步任务完成后，再触发 await_all_completed 信号
class LuaAwaitWrapperSet extends Object:
	signal await_all_completed(result_list)
	var await_wrappers: Array = []
	var _start_run_count = 0
	var _start_run_results = []
	func _run_async_tasks(law, result) -> void:
		await Utils.get_scene_tree().process_frame
		var item = {
			"id": law.id,
			"result": result
		}
		_start_run_results.append(item)
		_start_run_count += 1
		if _start_run_count == await_wrappers.size():
			await_all_completed.emit(LuaUtils.array_to_table(_start_run_results))
			await Utils.get_scene_tree().process_frame
			self.free()
	func start() -> Signal:
		Utils.get_scene_tree().process_frame.connect(func():
			for awaitWrapper: LuaAwaitWrapper in await_wrappers:
				awaitWrapper.start()
				awaitWrapper.await_completed.connect(func(result):
					_run_async_tasks(awaitWrapper, result)
				, ConnectFlags.CONNECT_ONE_SHOT)
		, ConnectFlags.CONNECT_ONE_SHOT)
		return await_all_completed
	static func create(laws: Array) -> LuaAwaitWrapperSet:
		var awaitWrapperSet = LuaAwaitWrapperSet.new()
		awaitWrapperSet.await_wrappers = laws
		return awaitWrapperSet


# Lua状态机
static var state: LuaState = null:
	set(v): state = v
	get:
		if state == null:
			reset_state()
		return state
static var use_mods = [] # 使用中的Mod
static var probe_mods = [] # 扫描到的Mod
#static var lua_cache = {} # 缓存创建的表

static func do_mod_file(file_path: String) -> Variant:
	#if lua_cache.has(file_path):
		#return lua_cache[file_path]
	var load_table = state.do_file(file_path)
	if load_table is LuaError:
		assert(false, "DO MOD FILE ERROR: " + load_table.message)
	#lua_cache[file_path] = load_table
	return load_table


static func run_lua_function(method, param, _self = null, _invoke_type = "TABLE") -> Variant:
	assert(method is LuaFunction, "run_lua_function: method is not LuaFunction")
	var _res = null
	if _self:
		_res = method.invoke(_self, param)
	else:
		if _invoke_type == "TABLE":
			_res = method.invoke(param)
		elif _invoke_type == "ARRAY":
			_res = method.invokev(param.to_array())
	# 如果执行的返回值是携程，需要等待携程完成
	if _res is LuaCoroutine:
		var error = null
		if _self:
			error = _res.resume(_self, param)
		else:
			if _invoke_type == "TABLE":
				error = _res.resume(param)
			elif _invoke_type == "ARRAY":
				error = _res.resumev(param.to_array())
		if error is LuaError:
			assert(false, "Async: [wait] 错误：" + error.message)
		if _res.status == LuaCoroutine.STATUS_YIELD:
			_res = await _res.completed
		else:
			_res = error
	# 如果执行的返回值是信号，需要等待信号触发
	if _res is Signal:
		_res = await _res
	if _res is LuaError:
		print(_res.message)
		assert(false, "Async: [wait] 错误：" + _res.message)
	return _res


static func set_package_paths(paths: Array) -> void:
	var pp = ""
	for path in paths:
		pp += path + "/?.lua;"
	pp = pp.replace("/", "\\")
	state.globals["package"]["path"] = pp


static func reset_state() -> void:
	state = LuaState.new()
	#lua_cache = {}
	# 基础库
	state.open_libraries(LuaState.Library.LUA_ALL_LIBS | LuaState.Library.GODOT_UTILITY_FUNCTIONS)
	state.globals["os"]["execute"] = null
	state.globals["os"]["remove"] = null
	state.globals["os"]["tmpname"] = null
	state.globals["os"]["rename"] = null
	state.globals["os"]["getenv"] = null
	state.globals["os"]["setenv"] = null
	state.globals["io"]["popen"] = null
	state.globals["io"]["input"] = null
	state.globals["io"]["output"] = null
	state.globals["io"]["write"] = null
	state.globals["io"]["tmpfile"] = null
	state.globals["debug"] = null
	state.globals["collectgarbage"].invoke("restart")
	state.globals["print"] = print
	# 设置随机数种子
	state.do_string("math.randomseed(tostring(os.time()):reverse():sub(1, 7))")
	state.stop_gc()
	# API Register
	ModViewApi.require(state)
	ModAreaApi.require(state)
	ModSyncApi.require(state)
	ModBehaviorApi.require(state)
	ModCallbackApi.require(state)
	ModCardApi.require(state)
	ModEntityApi.require(state)
	ModGameApi.require(state)
	ModIdApi.require(state)
	ModInteractionApi.require(state)
	ModPlayerApi.require(state)
	ModResourceApi.require(state)
	ModRuleApi.require(state)
	ModTagApi.require(state)
	ModValueApi.require(state)
	ModRoundApi.require(state)
	ModCardSetApi.require(state)
