extends ColorRect


@onready var loading


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ConfigManager.page_config.has("DEFAULT_PAGE"):
		$Image.texture = GResourceManager.get_image_resoure(ConfigManager.page_config["DEFAULT_PAGE"])


func _on_timer_timeout() -> void:
	pass # Replace with function body.

func set_loading_text(text):
	$Label.text = text
