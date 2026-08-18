extends Node3D


@onready var deep_ray: DeepRayCast3D = $Node3D/DeepRayCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	# 从鼠标屏幕点生成3D射线 origin 起点，end 终点
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var dr = $Node3D
	dr.global_position = ray_origin
	dr.look_at(ray_origin + ray_dir, Vector3.UP)
		
	print("\n=====鼠标悬浮命中堆叠物体=====")
	for i in range(deep_ray.get_collider_count()):
		var collider = deep_ray.get_collider(i)
		var _position = deep_ray.get_position(i)
		var normal = deep_ray.get_normal(i)
		print("Hit:", collider, "at", _position, "normal:", normal)
