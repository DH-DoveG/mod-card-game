extends Node3D


# FIXME: 朝向问题修复
var event_id := ""
var user: CardView3D

func _ready() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		change_dirction(scene.visual_angle)
		event_id = scene.event_manager.subscribe("VISUAL_ANGLE_CHANGED", change_dirction)
	user = get_parent()


func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.event_manager.unsubscribe("VISUAL_ANGLE_CHANGED", event_id)


func set_rander_priority(priority):
	$Sprite3D2.render_priority = priority
	$Sprite3D.render_priority = priority + 1


# 是否立起
func change_x(status: bool):
	var tween = get_tree().create_tween().set_parallel(true)
	if status:
		#$Sprite3D2.rotation_degrees.x = -75
		#$Sprite3D.rotation_degrees.x = -75
		tween.tween_property($Sprite3D2, "rotation_degrees:x", -75, 0.2)
		tween.tween_property($Sprite3D, "rotation_degrees:x", -75, 0.2)
		tween.tween_property($Sprite3D2, "position:y", 0.14, 0.2)
		tween.tween_property($Sprite3D, "position:y", 0.14, 0.2)
	else:
		#$Sprite3D2.rotation_degrees.x = 0
		#$Sprite3D.rotation_degrees.x = 0
		tween.tween_property($Sprite3D2, "rotation_degrees:x", -90, 0.2)
		tween.tween_property($Sprite3D, "rotation_degrees:x", -90, 0.2)
		tween.tween_property($Sprite3D2, "position:y", 0.02, 0.2)
		tween.tween_property($Sprite3D, "position:y", 0.02, 0.2)


func change_dirction(visual):
	match visual:
		Vector2i.DOWN:
			rotation_degrees.y = 180
		Vector2i.UP:
			rotation_degrees.y = 0
		Vector2i.LEFT:
			rotation_degrees.y = -90
		Vector2i.RIGHT:
			rotation_degrees.y = 90
