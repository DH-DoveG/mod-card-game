extends Node3D


var event_id := ""
var user: CardView3D

func _ready() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		get_tree().process_frame.connect(func():
			change_dirction(scene.visual_angle)
		, ConnectFlags.CONNECT_ONE_SHOT)
		event_id = scene.event_manager.subscribe("VISUAL_ANGLE_CHANGED", change_dirction)
	user = get_parent()
	#signal card_changed(_item: String, _ce: CardEntity)

func update_entity(entity: CardEntity):
	#entity.card_changed.connect(func(item: String, _entity: CardEntity):
		#var scene = get_tree().current_scene
		#if scene is Battle:
			#change_dirction(scene.visual_angle)
		#print("ITEM: ", item, " | ", user.get_front())
		#if item == "orientation":
			#if user.get_front():
				#rotation_order = EULER_ORDER_ZYX
				#rotation_degrees.z = 180
				#$Sprite3D2.hide()
			#else:
				#rotation_order = EULER_ORDER_YXZ
				#$Sprite3D2.show()
	#)
	entity.card_quaternion_changed.connect(func():
		var scene = get_tree().current_scene
		if scene is Battle:
			change_dirction(scene.visual_angle)
		print("ITEM: card_quaternion_changed | ", user.get_front())
		if user.get_front():
			rotation_order = EULER_ORDER_ZYX
			$Sprite3D2.show()
		else:
			rotation_order = EULER_ORDER_YXZ
			rotation_degrees.z = 180
			$Sprite3D2.hide()
	)

#卡片的翻转应该是一个信号

#func _process(_delta: float) -> void:
	#if user.get_front():
		#rotation_order = EULER_ORDER_ZYX
		#$Sprite3D2.show()
	#else:
		#rotation_order = EULER_ORDER_XYZ
		#$Sprite3D2.hide()
	#var scene = get_tree().current_scene
	#if scene is Battle:
		#change_dirction(scene.visual_angle)
	##print("user front: ", user.get_front())
	#pass


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
		tween.tween_property($Sprite3D2, "rotation_degrees:x", -75, 0.2)
		tween.tween_property($Sprite3D, "rotation_degrees:x", -75, 0.2)
		tween.tween_property($Sprite3D2, "position:y", 0.14, 0.2)
		tween.tween_property($Sprite3D, "position:y", 0.14, 0.2)
	else:
		tween.tween_property($Sprite3D2, "rotation_degrees:x", -90, 0.2)
		tween.tween_property($Sprite3D, "rotation_degrees:x", -90, 0.2)
		tween.tween_property($Sprite3D2, "position:y", 0.02, 0.2)
		tween.tween_property($Sprite3D, "position:y", 0.02, 0.2)


func change_dirction(visual):
	match visual:
		Vector2i.DOWN:
			global_rotation_degrees.y = 0
		Vector2i.UP:
			global_rotation_degrees.y = 180
		Vector2i.LEFT:
			global_rotation_degrees.y = 90
		Vector2i.RIGHT:
			global_rotation_degrees.y = -90
