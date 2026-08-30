extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#$CardView3D.global_transform.basis = camera.global_transform.basis
	#$CardView3D.look_at(get_viewport().get_camera_3d().global_position)
	#pass


func _on_button_pressed() -> void:
	var camera = get_viewport().get_camera_3d()
	#$MeshInstance3D.look_at(get_viewport().get_camera_3d().global_position, Vector3(1, 0, 0), true)
	#$MeshInstance3D.look_at(get_viewport().get_camera_3d().global_position)
	#var view_dir: Vector3 = camera.global_position - global_position
	#view_dir = view_dir.normalized()
	#$MeshInstance3D.look_at(global_position + view_dir, Vector3.UP)
	#$MeshInstance3D.global_transform.basis = camera.global_transform.basis
	$CardView3D.global_transform.basis = camera.global_transform.basis
	#$CardView3D.rotation_degrees.x += 90
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	#$CardView3D.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 1, 0), true)
	#$CardView3D.rotation_degrees.y -= 90
	pass # Replace with function body.
	# 物体指向相机的方向
	var camera = get_viewport().get_camera_3d()
	var look_dir: Vector3 = (camera.global_position - global_position).normalized()
	# 关键：使用【相机自身的世界上向量】而不是Vector3.UP
	var cam_world_up: Vector3 = camera.global_transform.basis.y

	# look_at: 参数1目标点，参数2 up向量
	$CardView3D.look_at(global_position + look_dir, cam_world_up)
	#$CardView3D.rotation_degrees.x += 90


func _on_button_3_pressed() -> void:
	$MeshInstance3D.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 0, 1), true)
	#$CardView3D.rotation_degrees.y += 90
	pass # Replace with function body.


func _on_button_4_pressed() -> void:
	$CardView3D.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 0, 1), true)
	#$CardView3D.rotation_degrees.x += 90
	pass # Replace with function body.
