extends RefCounted
class_name ModConfigManager

## 内容格式： { "${mod_name}": {"version": "${mod_version}", "path": "${mod_path}" }, ... }
const MOD_CONFIG_FILE_PATH: String = "configs/mod_load_config.json"
const MOD_SETTING_FILE_PATH: String = "configs/mod_setting.json"

var mod_config = {}
var mod_env_paths: Array = []

var setting_mod_config = [
	{"id": 0, "title": "模组搜索路径", "paths": [
		{"path": OS.get_executable_path().get_base_dir().path_join("mods"), "enable": true},
	]}
]

func load_config_for_file() -> void:
	var file: FileAccess = PersistenceUtils.open_file(MOD_SETTING_FILE_PATH)
	var text = ""
	if file:
		text = file.get_as_text()
		if text.is_empty():
			mod_env_paths = []
		else:
			mod_env_paths = JSON.parse_string(text)
		setting_mod_config[0]["paths"] = mod_env_paths
	file.close()

	file = PersistenceUtils.open_file(MOD_CONFIG_FILE_PATH)
	if file:
		text = file.get_as_text()
		if text.is_empty(): pass
		else:
			mod_config = JSON.parse_string(text)
	file.close()

func load_mod_setting() -> void:
	var paths = get_mod_env_paths()
	ModManager.reset_state()
	ModManager.set_package_paths(paths)

	ModProbeCommand.new().args({"paths": paths}).execute()

	var mods = ModManager.probe_mods
	var uses = []
	for mod: Dictionary in mods:
		var lii: LuaTable = mod["load_introducer_info"]
		if mod_config.has(lii["id"]) and mod_config[lii["id"]]["version"] == lii["version"]:
			uses.append(mod)
	ModUseCommand.new().args({"mods": uses}).execute()

func get_mod_env_paths() -> Array:
	var paths = []
	for smc in mod_env_paths:
		if smc["enable"]:
			paths.append(smc["path"])
	# 如果没有那么就初始化一个路径
	if paths.is_empty():
		PersistenceUtils.make_folder("mods")
		paths.append(PersistenceUtils.get_exec_path().path_join("mods"))

	return paths