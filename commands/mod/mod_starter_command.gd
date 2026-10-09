extends Command
class_name ModStarterCommand

var _execute_result: Variant = null

func _do_execute():
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
		ModManager.print_lua_function_debug(table["use"], "use starter Error")
		assert(false, "use starter Error: " + use_result.message)
		return
	_execute_result = table

	return use_result

func _do_undo() -> void:
	_execute_result = null
