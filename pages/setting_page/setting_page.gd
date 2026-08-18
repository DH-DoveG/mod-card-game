extends Page


@onready var panel = $Panel
@onready var panel_image = $Panel/Image/VBox
@onready var mod_load_paths = $Panel/Mod/VBox/Item/Paths
@onready var panel_sound = $Panel/Sound/VBox


func _init() -> void:
	page_id = "SETTING_PAGE"


func _ready() -> void:
	panel.set_tab_title(0, "    画 面 设 置    ")
	panel.set_tab_title(1, "    声 音 设 置    ")
	panel.set_tab_title(2, "    模 组 设 置    ")
	_init_mod_set_options()
	_init_image_set_options()
	_init_sound_set_options()


func _init_image_set_options():
	# { title: String, property: String, options: [], details: String, choose: int<options.id> }
	var i = 0
	for config in ConfigManager.setting_image_config:
		var item = $Template/ImageSetItem.duplicate()
		item.name = str(i)
		panel_image.add_child(item)
		item.get_node("HBox/Title").text = config["title"]
		var option_node = item.get_node("HBox/Option")
		for option in config["options"]:
			option_node.add_item(option["text"])
		option_node.selected = config["choose"]
		item.get_node("Detail").text = config["detail"]
		item.show()
		i += 1


func _init_mod_set_options():
	for config in ConfigManager.setting_mod_config[0]["paths"]:
		_create_mod_load_path_item(config["path"], config["enable"])


func _init_sound_set_options():
	$Panel/Sound/VBox/Music/HBox/Option.value = ConfigManager.setting_sound_config["music"]["value"]
	$Panel/Sound/VBox/Music/HBox/CheckBox.button_pressed = ConfigManager.setting_sound_config["music"]["enable"]
	$Panel/Sound/VBox/Sound/HBox/Option.value = ConfigManager.setting_sound_config["sound"]["value"]
	$Panel/Sound/VBox/Sound/HBox/CheckBox.button_pressed = ConfigManager.setting_sound_config["sound"]["enable"]


func _create_mod_load_path_item(path: String, enable: bool):
	var item = $Template/ModPathItem.duplicate()
	mod_load_paths.add_child(item)
	item.get_node("Path").text = path
	item.get_node("CheckBox").button_pressed = enable
	item.get_node("Remove").pressed.connect(func(): item.queue_free())
	item.show()


func _on_quit_pressed() -> void:
	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_option_pressed() -> void:
	$ChooseModFolderPathDialog.current_dir = PersistenceUtils.get_exec_path()
	$ChooseModFolderPathDialog.popup_centered()
	var _dir = await $ChooseModFolderPathDialog.dir_selected
	_create_mod_load_path_item(_dir, true)


func _on_save_pressed() -> void:
	var save_image = {}
	for item in panel_image.get_children():
		var set_item = ConfigManager.setting_image_config[int(item.name)]
		set_item["choose"] = item.get_node("HBox/Option").selected
		save_image[str(set_item["id"])] = set_item["choose"]
	var file = PersistenceUtils.open_file(ConfigManager.IMAGE_SETTING_FILE_PATH)
	var text = str(save_image)
	file.resize(text.length())
	file.store_string(text)
	file.close()

	for item in mod_load_paths.get_children():
		var path = item.get_node("Path").text
		var check = item.get_node("CheckBox").button_pressed
		var k = true
		for c in ConfigManager.setting_mod_config[0]["paths"]:
			if c["path"] == path:
				c["enable"] = check
				k = false
				break
		if k:
			ConfigManager.setting_mod_config[0]["paths"].append({"path": path, "enable": check})
	file = PersistenceUtils.open_file(ConfigManager.MOD_SETTING_FILE_PATH)
	text = str(ConfigManager.setting_mod_config[0]["paths"])
	file.resize(text.length())
	file.store_string(text)
	file.close()
	
	for item in panel_sound.get_children():
		var v = {
			"value": item.get_node("HBox/Option").value,
			"enable": item.get_node("HBox/CheckBox").button_pressed
		}
		if item.name == "Music": ConfigManager.setting_sound_config["music"] = v
		if item.name == "Sound": ConfigManager.setting_sound_config["sound"] = v
	file = PersistenceUtils.open_file(ConfigManager.SOUND_SETTING_FILE_PATH)
	text = str(ConfigManager.setting_sound_config)
	file.resize(text.length())
	file.store_string(text)
	file.close()
	
	ToastUtils.success("设置已保存")
