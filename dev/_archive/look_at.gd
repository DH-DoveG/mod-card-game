extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_button_pressed() -> void:
	var camera = get_viewport().get_camera_3d()

	$CardView3D.global_transform.basis = camera.global_transform.basis

func _on_button_2_pressed() -> void:
	# 物体指向相机的方向
	var camera = get_viewport().get_camera_3d()
	var look_dir: Vector3 = (camera.global_position - global_position).normalized()
	# 关键：使用【相机自身的世界上向量】而不是Vector3.UP
	var cam_world_up: Vector3 = camera.global_transform.basis.y

	$CardView3D.look_at(global_position + look_dir, cam_world_up)

func _on_button_3_pressed() -> void:
	$MeshInstance3D.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 0, 1), true)

func _on_button_4_pressed() -> void:
	$CardView3D.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 0, 1), true)
