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

func _process(_delta: float) -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		if scene.host_player_id not in scene.battle_data_bind_list.card_public_information[user.entity.name] and \
		   "PUBLIC" not in scene.battle_data_bind_list.card_public_information[user.entity.name]:
			hide()
		else:
			show()

func update_entity(entity: CardEntity):
	$InfoView/SubViewport/Info/CardName.text = entity.card_name
	var values = []
	for key: String in entity.values:
		var value: Value = entity.values[key]
		if value.config:
			if value.config.get("show_enable") == true:
				var prefix: String = value.config.get("show_prefix", "")
				var text = prefix + str(int(value.value))
				var scolor = value.config.get("show_color")
				if scolor:
					text = "[color=" + scolor + "]" + text + "[/color]"
				values.append(text)
	$InfoView/SubViewport/Info/CardValues.append_text("[center]" + "/".join(values) + "[/center]")
	
	entity.card_quaternion_changed.connect(func():
		var scene = get_tree().current_scene
		if scene is Battle:
			change_dirction(scene.visual_angle)
		if user.get_front():
			rotation_order = EULER_ORDER_ZYX
			$ImageView.show()
		else:
			rotation_order = EULER_ORDER_YXZ
			rotation_degrees.z = 180
			$ImageView.hide()
	)

func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.event_manager.unsubscribe("VISUAL_ANGLE_CHANGED", event_id)

func set_rander_priority(priority):
	$ImageView.render_priority = priority
	$InfoView.render_priority = priority + 1

# 是否立起
func change_x(status: bool):
	var tween = get_tree().create_tween().set_parallel(true)
	if status:
		tween.tween_property($ImageView, "rotation_degrees:x", -75, 0.2)
		tween.tween_property($InfoView, "rotation_degrees:x", -75, 0.2)
		tween.tween_property($ImageView, "position:y", 0.14, 0.2)
		tween.tween_property($InfoView, "position:y", 0.14, 0.2)
	else:
		tween.tween_property($ImageView, "rotation_degrees:x", -90, 0.2)
		tween.tween_property($InfoView, "rotation_degrees:x", -90, 0.2)
		tween.tween_property($ImageView, "position:y", 0.02, 0.2)
		tween.tween_property($InfoView, "position:y", 0.02, 0.2)

func change_dirction(visual):
	match visual:
		Vector2i.DOWN: global_rotation_degrees.y = 0
		Vector2i.UP: global_rotation_degrees.y = 180
		Vector2i.LEFT: global_rotation_degrees.y = 90
		Vector2i.RIGHT: global_rotation_degrees.y = -90
