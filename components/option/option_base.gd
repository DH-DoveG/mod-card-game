extends CanvasLayer
class_name OptionBase

@onready var side = $Side

var is_hidden = false
var battle: Battle = null

var _in_option_key: String = ""

signal finished

func set_data(_param) -> void:
	pass

func _enter_tree() -> void:
	var scene = Utils.get_current_scene()
	if not is_instance_valid(scene):
		return
	if scene is not Battle:
		return

	battle = scene
	_in_option_key = "OPT_" + str(get_instance_id())
	battle.add_in_option(_in_option_key)

func _exit_tree() -> void:
	if battle:
		if not _in_option_key.is_empty():
			battle.remove_in_option(_in_option_key)
		battle.ui.show()

func _on_close_pressed() -> void:
	finished.emit()

func _on_confirmed_pressed() -> void:
	finished.emit()