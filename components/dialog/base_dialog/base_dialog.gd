class_name BaseDialog
extends CanvasLayer

@onready var dialog = $Dialog
@onready var background = $Background

var visible_mode = false # 是否收缩

func _ready() -> void:
	add_to_group(&"Dialog")

func _on_visible_pressed() -> void:
	visible_mode = !visible_mode
	if visible_mode:
		background.size = Vector2(480, 128)
		background.position.x = 720
		dialog.hide()
	else:
		background.size = ConfigManager.window_size
		background.position.x = 0
		dialog.show()
