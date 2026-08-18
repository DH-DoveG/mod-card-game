@tool
extends RemoteTransform3D

@export var camera_node: Camera3D
const OPTIMAL_DISTANCE: float = 4.328
const CAMERA_FOV_DEG: float = 75.0
const MIN_SCALE: float = 0.1
const MAX_SCALE: float = 5.0
const SMOOTH_SPEED: float = 9.0
const DISTANCE_THRESHOLD: float = 0.01

var base_scale: Vector3

func _ready() -> void:
	base_scale = scale
	assert(camera_node, "请赋值相机节点！")

func _process(delta: float) -> void:
	update_object_scale_to_keep_visual_size(delta)

func update_object_scale_to_keep_visual_size(delta: float) -> void:
	var current_distance: float = global_position.distance_to(camera_node.global_position)
	if abs(current_distance - OPTIMAL_DISTANCE) < DISTANCE_THRESHOLD:
		return
	
	var scale_factor: float = current_distance / OPTIMAL_DISTANCE if OPTIMAL_DISTANCE > 0 else 1.0
	scale_factor = clamp(scale_factor, MIN_SCALE, MAX_SCALE)
	var target_scale: Vector3 = base_scale * scale_factor
	
	# 平滑过渡缩放
	scale = lerp(scale, target_scale, SMOOTH_SPEED * delta)
