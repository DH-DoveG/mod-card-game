extends Command
class_name ModProbeCommand

## 探测命令
## 探测mod的资源

var _execute_result: Variant = null


func execute() -> void:
	# 样板代码
	if is_execute():
		return
	var result = {}
	# 参数检查
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("paths") and typeof(_args["paths"]) != TYPE_STRING:
		return
	var paths: Array = _args["paths"]
	# 执行
	for path: String in paths:
		var dir = DirAccess.open(path)
		if not dir:
			continue
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				file_name = dir.get_next()
				continue
			if dir.file_exists(file_name + "/register.lua") and \
			dir.file_exists(file_name + "/introducer.lua") and \
			dir.file_exists(file_name + "/starter.lua"):
				var introducer_path = path.path_join(file_name).path_join("introducer.lua")
				var introducer_run = ModManager.do_mod_file(introducer_path)
				assert(introducer_run is not LuaError, "introducer_run is LuaError: " + str(introducer_run) )
				var introducer_table = introducer_run.invoke()
				assert(introducer_table is not LuaError, "introducer_table is LuaError: " + str(introducer_run) )
				result[file_name] = {
					"prefix": path,
					"introducer": introducer_path,
					"register": path.path_join(file_name).path_join("register.lua"),
					"starter": path.path_join(file_name).path_join("starter.lua"),
					"load_introducer_info": introducer_table
				}
			file_name = dir.get_next()

	# 修改外部值
	ModManager.probe_mods = result.values()
	# 记录值，用于undo撤销时使用
	_execute_result = result

	# 样板代码
	_execute_state = true
	return


func undo() -> void:
	# 样板代码
	if not is_execute():
		return
	
	# 检查参数
	if not _args.has("path") and typeof(_args["path"]) != TYPE_STRING:
		return

	# 撤销修改外部值
	for mod in ModManager.probe_mods:
		if (mod["prefix"] as String).erase(0, _args["path"].length()) in _execute_result.keys():
			ModManager.probe_mods.erase(mod)
	
	# 样板代码
	_execute_result = null
	_execute_state = false
	return
