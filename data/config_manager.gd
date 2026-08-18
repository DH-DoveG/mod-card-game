extends RefCounted
class_name ConfigManager


#region 常量定义
# 卡片厚度
const CARD_THICKNESS = 0.006 #0.004
# 卡片长度
#const CARD_HEIGHT = 0.8 # 1
const CARD_HEIGHT = 0.6 # 1
# 卡片宽度
const CARD_WIDTH = 0.72
# 区域尺寸
const AREA_SIZE = 1 #1.20
#const AREA_HEIGHT_BASE = 0.1
#endregion


const window_size = Vector2(1920, 1080)


# 页面配置
static var page_index_title: String = ""
static var page_config: Dictionary = {}

## Mod配置文件
## 内容格式： { "${mod_name}": {"version": "${mod_version}", "path": "${mod_path}" }, ... }
static var MOD_CONFIG_FILE_PATH: String = "configs/mod_load_config.json"
static var mod_config = {}

## Mod设置文件
## 内容格式： {
## 	"${mod_name}": {
## 		"${mod_setting_item1}": "${mod_setting_item1_value}",
## 		... },
## 	...}
# static var MOD_SETTING_FILE_PATH: String = "configs/mod_setting.json"
# var mod_setting = {}
## Mod使用的环境目录集
# static var MOD_ENV_PATH_SET_FILE_PATH: String = "configs/mod_env_paths.json"
const IMAGE_SETTING_FILE_PATH: String = "configs/image_setting.json"
const MOD_SETTING_FILE_PATH: String = "configs/mod_setting.json"
const SOUND_SETTING_FILE_PATH: String = "configs/sound_setting.json"
const MULTIPLAYER_CONFIG_FILE_PATH = "configs/multiplayer_config.json"
const DECK_SEARCH_CONDITION_CONFIG_FILE_PATH = "configs/deck_search_condition_config.json"
const DECK_FOLDER_PATH = "decks/"

static var mod_env_paths: Array = []
static var multiplayer_config = []
static var deck_search_condition_config = {}
static var decks = []

static var setting_mod_config = [
	{"id": 0, "title": "模组搜索路径", "paths": [
		{"path": OS.get_executable_path().get_base_dir().path_join("mods"), "enable": true},
	]}
]

static var setting_sound_config = {
	"music": { "value": 5, "enable": true },
	"sound": { "value": 5, "enable": true }
}

static var setting_image_config = [
	{"id": 0, "title": "3D双线性缩放", "property": "scaling_3d_mode", "options": [
		{"id": 0, "text": "Bilinear", "value": Viewport.Scaling3DMode.SCALING_3D_MODE_BILINEAR},
		{"id": 1, "text": "FSR", "value": Viewport.Scaling3DMode.SCALING_3D_MODE_FSR},
		{"id": 2, "text": "FSR2", "value": Viewport.Scaling3DMode.SCALING_3D_MODE_FSR2},
	], "detail": "设置缩放 3D 模式。双线性（Bilinear）缩放会以不同的分辨率进行渲染，对视口进行欠采样或超采样。FidelityFX Super Resolution 1.0，缩写为 FSR，是一种放大技术，通过使用一种空间感知放大算法，以快速帧速率生成高质量图像。FSR 比双线性的性能消耗略高一些，但产生的图像质量却高得多。应尽可能使用 FSR。
", "choose": 1},
	{"id": 1, "title": "3D抗锯齿", "property": "msaa_3d", "options": [
		{"id": 0, "text": "Disabled", "value": Viewport.MSAA.MSAA_DISABLED},
		{"id": 1, "text": "2x", "value": Viewport.MSAA.MSAA_2X},
		{"id": 2, "text": "4x", "value": Viewport.MSAA.MSAA_4X},
		{"id": 3, "text": "8x", "value": Viewport.MSAA.MSAA_8X},
	], "detail": "3D 渲染的多重采样抗锯齿模式。数字越高，得到的边缘越平滑，代价是性能也会显著降低。设为 2 或 4 为佳，除非目标是非常高端的系统。另见 3D双线性缩放 实现超采样，能够提供更高的质量，但消耗也更高。对由着色器或纹理导致的锯齿无效。
", "choose": 1},
	{"id": 2, "title": "屏幕空间抗锯齿", "property": "screen_space_aa", "options": [
		{"id": 0, "text": "Disabled", "value": Viewport.ScreenSpaceAA.SCREEN_SPACE_AA_DISABLED},
		{"id": 1, "text": "FXAA", "value": Viewport.ScreenSpaceAA.SCREEN_SPACE_AA_FXAA},
		{"id": 2, "text": "SMAA", "value": Viewport.ScreenSpaceAA.SCREEN_SPACE_AA_SMAA}
	], "detail": "设置使用的屏幕空间抗锯齿方法。屏幕空间抗锯齿的原理是在后期处理着色器中选择性地模糊边缘。它与 MSAA 不同，后者在渲染对象时采用多个覆盖样本。屏幕空间抗锯齿方法通常比 MSAA 更快，并且会平滑高光锯齿，但往往会使场景显得模糊。
", "choose": 1}
]


static func load_config_for_file():
	_load_config_for_file_mod()
	_load_config_for_file_image()
	_load_config_for_file_other()


static func _load_config_for_file_image() -> void:
	var file: FileAccess = PersistenceUtils.open_file(IMAGE_SETTING_FILE_PATH)
	if file:
		var text = file.get_as_text()
		if text.is_empty(): pass
		else:
			# { <id>: <choose id> }
			var data = JSON.parse_string(text)
			for id in data:
				for sic in setting_image_config:
					if sic["id"] == int(id):
						sic["choose"] = int(data[id])
	file.close()


static func _load_config_for_file_music() -> void:
	var file: FileAccess = PersistenceUtils.open_file(MOD_SETTING_FILE_PATH)
	if file:
		var text = file.get_as_text()
		if text.is_empty(): pass
		else:
			setting_sound_config = JSON.parse_string(text)
	file.close()


static func _load_config_for_file_mod() -> void:
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


static func _load_config_for_file_other() -> void:
	var file: FileAccess = PersistenceUtils.open_file(MULTIPLAYER_CONFIG_FILE_PATH)
	if file:
		var text = file.get_as_text()
		if text.is_empty(): pass
		else:
			multiplayer_config = JSON.parse_string(text)
	file.close()
	
	file = PersistenceUtils.open_file(DECK_SEARCH_CONDITION_CONFIG_FILE_PATH)
	if file:
		var text = file.get_as_text()
		if text.is_empty(): pass
		else:
			deck_search_condition_config = JSON.parse_string(text)
	file.close()


static func load_image_setting() -> void:
	if Utils.get_current_scene() is Battle:
		var sv: SubViewport = Utils.get_current_scene().get_node("SubViewportContainer/SubViewport")
		for item in setting_image_config:
			sv.set(item["property"], item["options"][item["choose"]]["value"])


static func load_mod_setting() -> void:
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


static func load_sound_setting():
	pass


static func get_mod_env_paths() -> Array:
	var paths = []
	for smc in mod_env_paths:
		if smc["enable"]:
			paths.append(smc["path"])
	# 如果没有那么就初始化一个路径
	if paths.is_empty():
		PersistenceUtils.make_folder("mods")
		paths.append(PersistenceUtils.get_exec_path().path_join("mods"))
	#print("get_mod_env_paths : ", paths)
	return paths
