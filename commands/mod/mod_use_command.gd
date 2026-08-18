extends Command
class_name ModUseCommand

## 启动命令
## 启动mod的资源

var _execute_result: Variant = null

## _args 包含一个数组
func execute() -> void:
	# 样板代码
	if is_execute():
		return

	# 参数检查
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("mods") and typeof(_args["mods"]) != TYPE_ARRAY:
		return
	
	var mods: Array = _args["mods"]
	
	GResourceManager.clear()

	ModManager.use_mods = mods
	
	# 将这些MOD写入文件
	var file = PersistenceUtils.open_file(ConfigManager.MOD_CONFIG_FILE_PATH)
	var ms = {}
	
	for mod: Dictionary in mods:
		var lii: LuaTable = mod["load_introducer_info"]
		ms.set(
			lii["id"],
			{
				"version": lii["version"],
				"name": lii["name"]
			}
		)
		ModRegisterCommand.new().args({"path": mod["register"], "prefix": mod["prefix"]}).execute()
		# 这里预设一定是在Mod页面调用，所以设置类型为 PAGE
		ModStarterCommand.new().args({ "param": {"type": "PAGE"}, "path": mod["starter"], "prefix": mod["prefix"]}).execute()
	
	file.resize(ms.size())
	file.store_string( JSON.stringify(ms) )
	# 样板代码
	_execute_state = true


# 这里不考虑实现UNDO
func undo() -> void:
	# 样板代码
	if not is_execute():
		return
	
	_execute_result = null
	
	# 样板代码
	_execute_state = false
	return
