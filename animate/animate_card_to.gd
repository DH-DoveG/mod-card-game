extends Animate


var object: Node3D = null
var start_position = Vector3.ZERO
var target_position = Vector3.ZERO
var time = 0.5

var distance: float


func set_arg(arg: Dictionary) -> void:
	object = arg["object"]
	start_position = arg["start_position"]
	target_position = arg["target_position"]
	time = arg["time"]
	distance = start_position.distance_squared_to(target_position)

func play() -> void:
	var tween = create_tween()
	tween.tween_property(object, "global_position", target_position, time)
	await tween.finished
	finished.emit()

func get_time() -> float:
	return distance / time + 0.15
