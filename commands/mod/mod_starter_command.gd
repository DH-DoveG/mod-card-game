extends Command
class_name ModStarterCommand

## 启动命令
## 启动mod的资源

var _execute_result: Variant = null

func execute():
	# 样板代码
	if is_execute():
		return

	# 参数检查
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("path") or typeof(_args["path"]) != TYPE_STRING or not _args.has("param") or typeof(_args["param"]) != TYPE_DICTIONARY:
		return
	var path: String = _args["path"]
	var param: Dictionary = _args["param"]

	# 执行
	var load_table = ModManager.do_mod_file(path)
	if load_table is LuaError:
		assert(false, "load starter Error: " + load_table.message)
		return
	var table = load_table.invoke()
	var use_result = table["use"].invoke(table, LuaUtils.dictionary_to_table(param))
	if use_result is LuaError:
		assert(false, "use starter Error: " + use_result.message)
		return
	_execute_result = table

	# 样板代码
	_execute_state = true
	
	return use_result


func undo() -> void:
	# 样板代码
	if not is_execute():
		return

	_execute_result = null
	
	# 样板代码
	_execute_state = false
	return
