extends Control


func _ready() -> void:
	ConfigManager.load_config_for_file()
	ConfigManager.load_sound_setting()
	ConfigManager.load_image_setting()
	ConfigManager.load_mod_setting()
	get_tree().call_deferred("change_scene_to_file", "res://pages/index.tscn")
