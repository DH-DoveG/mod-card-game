class_name BaseDialog
extends CanvasLayer

@onready var dialog = $Dialog
@onready var background = $Background
@onready var title = $Dialog/ColorRect/Title
@onready var detail = $Dialog/Detail
@onready var btns = $Dialog/Btns/Option

var visible_mode = false # 是否收缩

func _ready() -> void:
	add_to_group(&"Dialog")


func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.in_option = false


func _on_visible_pressed() -> void:
	visible_mode = !visible_mode
	if visible_mode:
		$HideBar.show()
		dialog.hide()
		background.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
		var scene = get_tree().current_scene
		if scene is Battle:
			scene.in_option = true


func _on_show_dialog_pressed() -> void:
	$HideBar.hide()
	dialog.show()
	background.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.in_option = true
