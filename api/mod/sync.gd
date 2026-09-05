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
				return await ModManager.run_lua_function(_aw["method"], _aw["param"])
			, aw)
			law.id = id
			law_list.append(law)
	var laws = ModManager.LuaAwaitWrapperSet.create(law_list)
	laws.start()
	return laws.await_all_completed

#{ 
	#"param": { 
		#1: { 
			#"behavior_id": {  }, 
			#"params": { "player_id": "PLAYER_1", "card_owner": "CARD_00000006" }, 
			#"method": [LuaFunction:0x162679d6ae0] 
			#} 
		#}, 
	#"method": [LuaFunction:0x1624d08d1a0] 
#}


static func create_sync(param) -> Signal:
	return ModManager.LuaAwaitWrapper.create_starter(func(_param):
		var co = param["method"]
		var arg = param["param"]
		var mode = param["mode"] if param["mode"] != null else "TABLE"
		#print("[CORE] create_sync : ", LuaUtils.table_to_dictionary(param))
		#print("CO = ", co)
		#print("ARG = ", LuaUtils.table_to_dictionary(arg))
		#print("MODE = ", mode)
		if arg:
			print(">>>> ", arg.to_dictionary())
		var res = await ModManager.run_lua_function(co, arg, mode)
		return res
	, param)
