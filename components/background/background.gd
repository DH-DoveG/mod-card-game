extends SubViewportContainer


func init_data(config: ConfigManager) -> void:
	$SubViewport.size = config.window_size


func _ready() -> void:
	if ConfigManager.page_config.has("BATTLE_BACKGROUND"):
		var pg = ConfigManager.page_config["BATTLE_BACKGROUND"]
		$SubViewport/ColorRect4/TextureRect.texture = GResourceManager.get_image_resoure(pg)


func _on_sub_viewport_size_changed() -> void:
	print("sub viewport size changed!")
