extends Animate


@onready var line: Line = $Line
@onready var remote: RemoteTransform3D = $Line/Path/PathFollow3D/RemoteTransform3D

var object: Node3D = null
var start_position = Vector3.ZERO
var target_position = Vector3.ZERO
var time = 0.5

var curve: Curve3D
var distance: float

func _ready() -> void:
	line.is_start = false
	line.finished.connect(func():
		remote.remote_path = ""
		line.is_start = false
		finished.emit()
	)


func set_arg(arg: Dictionary) -> void:
	object = arg["object"]
	start_position = arg["start_position"]
	target_position = arg["target_position"]
	time = arg["time"]
	distance = start_position.distance_squared_to(target_position)
	
	var high = 1.0
	if arg.has("high"):
		high = arg["high"]
	else:
		if start_position.y > target_position.y:
			high += start_position.y
		else:
			high += target_position.y
	
	curve = Curve3D.new()
	curve.add_point(start_position, Vector3.ZERO, Vector3(0, high, 0))
	curve.add_point(target_position, Vector3.ZERO, Vector3.ZERO)
	line.path_curve = curve

	$Line.line_space = distance / time

func _on_line_finished() -> void:
	if not is_instance_valid(object):
		return
	object.global_position = target_position

func play() -> void:
	line.is_start = true
	await get_tree().process_frame # 等待一帧来准备，以防止闪烁
	remote.remote_path = object.get_path() # 设置卡片跟随


func get_time() -> float:
	return line.get_time() + 0.5
