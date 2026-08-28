extends Node3D


# FIXME: 朝向问题修复


func _ready() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		match scene.visual_angle:
			Vector2.DOWN:
				rotation_degrees.y = 0
			Vector2.UP:
				rotation_degrees.y = 180
			Vector2.LEFT:
				rotation_degrees.y = 90
			Vector2.RIGHT:
				rotation_degrees.y = -90


#
#func _physics_process(_delta: float) -> void:
	#var camera = get_viewport().get_camera_3d()
	#if not camera:
		#return
	### 获取节点的相对位置
	###var upos = camera.unproject_position()
	###rotation.x = 
	##var dir = global_position.direction_to(camera.global_position)
	##print(dir)
	###look_at(camera.global_position, Vector3.RIGHT)
	###var forward_hint: Vector3 = Vector3.FORWARD
	###var dir_to_camera = (camera.global_position - global_position).normalized()
	#### 防止hint和up方向共线导致抖动
	###if abs(dir_to_camera.dot(forward_hint)) > 0.99:
		###forward_hint = Vector3.RIGHT
	###Basis.
	###global_basis = global_basis.looking_at(dir_to_camera, forward_hint)
	###global_basis = Basis.from_up(dir_to_camera, forward_hint)
	## 获取世界位置
	#var my_pos: Vector3 = global_position
	#var cam_pos: Vector3 = camera.global_position
	## ✂️ 去掉Y分量，只保留水平面XZ，只做水平转向，忽略高度
	#var dir_xz: Vector3 = (cam_pos - my_pos)
	#dir_xz.y = 0.0
	#dir_xz = dir_xz.normalized()
	## 计算目标Y旋转角：Vector3.FORWARD 是物体默认前向(-Z)
	## get_angle_to：得到绕Y轴需要转的弧度
	##var target_y_rot: float = Vector3.FORWARD.get_angle_to(dir_xz, Vector3.UP)
	#var target_y_rot: float = Vector3.FORWARD.angle_to(dir_xz)
	## 设置世界Y旋转；如果你用local rotation就改成 rotation.y
	#global_rotation.y = target_y_rot
