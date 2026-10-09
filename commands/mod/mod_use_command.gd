extends Command
class_name ModUseCommand

var _execute_result: Variant = null

func _do_execute() -> void:
	# 参数检查
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("mods") or typeof(_args["mods"]) != TYPE_ARRAY:
		return

	var mods: Array = _args["mods"]
	var enabled_paths: Array = ConfigManager.mod.get_mod_env_paths()

	GResourceManager.clear()

	# 只让处于启用搜索路径中的 Mod 生效
	var active_mods: Array = []
	for mod: Dictionary in mods:
		if enabled_paths.has(mod.get("prefix")):
			active_mods.append(mod)

	ModManager.use_mods = active_mods

	# 将这些MOD写入文件
	var file = PersistenceUtils.open_file(ModConfigManager.MOD_CONFIG_FILE_PATH)
	var ms = {}

	for mod: Dictionary in active_mods:
		var lii: LuaTable = mod["load_introducer_info"]
		ms.set(
			lii["id"],
			{
				"version": lii["version"],
				"name": lii["name"]
			}
		)
		ModAutoRegisterCommand.new().args({"path": mod["register"], "prefix": mod["prefix"]}).execute()
		ModRegisterCommand.new().args({"path": mod["register"], "prefix": mod["prefix"]}).execute()
		# 这里预设一定是在Mod页面调用，所以设置类型为 PAGE
		ModStarterCommand.new().args({ "param": {"type": "PAGE"}, "path": mod["starter"], "prefix": mod["prefix"]}).execute()

	file.resize(ms.size())
	file.store_string( JSON.stringify(ms) )

# 这里不考虑实现UNDO
func _do_undo() -> void:
	_execute_result = null