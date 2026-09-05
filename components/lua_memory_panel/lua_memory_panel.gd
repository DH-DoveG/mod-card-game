extends Control

@onready var label = $Label

func _on_timer_timeout() -> void:
	label.text = "Lua脚本内存使用：" + str("%.6f" % (ModManager.state.get_memory_used() / 1024.0)) + " MB"
