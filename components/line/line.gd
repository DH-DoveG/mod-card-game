extends Node3D
class_name Line


signal finished

@export var line_space = 4 # 0/m
@export var path_curve: Curve3D:
	set(v):
		path_curve = v
		if !$Path.curve:
			$Path.curve = path_curve

@onready var path: Path3D = $Path
@onready var path_follow: PathFollow3D = $Path/PathFollow3D

var is_start = true


# 计算耗时
func get_time() -> float:
	return path.curve.get_baked_length() / line_space


func _physics_process(delta: float) -> void:
	if !is_start:
		return
	path_follow.progress += line_space * delta
	if path_follow.progress >= path.curve.get_baked_length():
		path_follow.progress = 0
		finished.emit()
