extends Control
class_name Page


@onready var background = $Background

var page_id: String = "DEFAULT_PAGE":
	set(v):
		# 设置时会检查字典里有没有注册，没有就增加
		if not ConfigManager.page_config.has(v):
			ConfigManager.page_config[v] = ""
		page_id = v


func _ready() -> void:
	if ConfigManager.page_config.has(page_id):
		var path = ConfigManager.page_config[page_id]
		var texture: Texture2D = GResourceManager.get_image_resoure(path)
		if texture:
			background.texture = texture
		else:
			path = ConfigManager.page_config.get("DEFAULT_PAGE")
			if path == null:
				background.texture = load("res://assets/images/background/hex2.jpg")
				return
			texture = GResourceManager.get_image_resoure(path)
			if texture:
				background.texture = texture
