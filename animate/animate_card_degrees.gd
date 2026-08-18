extends Animate


var card: Card
var degrees: float


func set_arg(arg: Dictionary) -> void:
	card = arg["card"]
	degrees = arg["degrees"]


func play() -> void:
	
	var tween = create_tween()
	tween.tween_property(card, "rotation_degrees:y", degrees, 0.2)
	await tween.finished
	
	emit_signal(&"finished")


func get_time() -> float:
	return 0.2
