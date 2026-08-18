extends Animate


var card: Card
var origin_y: float
var target_z: float


func set_arg(arg: Dictionary) -> void:
	card = arg["card"]
	origin_y = arg["origin_y"]
	target_z = arg["target_z"]


func play() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(card, "rotation_degrees:z", target_z / 2, 0.2)
	tween.tween_property(card, "global_position:y", origin_y + ConfigManager.CARD_WIDTH / 2, 0.2)
	await tween.finished
	
	var tween2 = create_tween().set_parallel(true)
	tween2.tween_property(card, "rotation_degrees:z", target_z, 0.2)
	tween2.tween_property(card, "global_position:y", origin_y, 0.2)
	await tween2.finished
	
	card.rotation_degrees.z = target_z
	card.global_position.y = origin_y
	
	emit_signal(&"finished")


func get_time() -> float:
	return 0.45
