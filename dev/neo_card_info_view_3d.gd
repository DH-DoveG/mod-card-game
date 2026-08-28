extends Node3D


# FIXME: 朝向问题修复


func _physics_process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	#look_at(camera.global_position, Vector3.RIGHT)
	#var forward_hint: Vector3 = Vector3.FORWARD
	#var dir_to_camera = (camera.global_position - global_position).normalized()
	## 防止hint和up方向共线导致抖动
	#if abs(dir_to_camera.dot(forward_hint)) > 0.99:
		#forward_hint = Vector3.RIGHT
	#Basis.
	#global_basis = global_basis.looking_at(dir_to_camera, forward_hint)
	#global_basis = Basis.from_up(dir_to_camera, forward_hint)
