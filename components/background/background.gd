extends SubViewportContainer

func init_data(config: ConfigManager) -> void:
	$SubViewport.size = config.window_size
