extends SubViewportContainer

func init_data(config: ConfigManager) -> void:
	$SubViewport.size = config.window_size

func _ready() -> void:
	pass

func _on_sub_viewport_size_changed() -> void:
	print("sub viewport size changed!")
