extends Node3D
class_name Scene


@onready var card_mount: Node3D = $CardMount
@onready var area_mount: Node3D = $AreaMount
@onready var camera: Camera3D = $Camera3D
@onready var phantom_camera_down: PhantomCamera3D = $PCDown
@onready var phantom_camera_up: PhantomCamera3D = $PCUp
@onready var phantom_camera_left: PhantomCamera3D = $PCLeft
@onready var phantom_camera_right: PhantomCamera3D = $PCRight
@onready var phantom_camera_top: PhantomCamera3D = $PCTop
@onready var deep_ray: DeepRayCast3D = $Ray/DeepRayCast3D


var max_x = 0
var max_y = 0
var max_z = 0
var min_x = 0
var min_y = 0
var min_z = 0


var current_hight_card: CardView3D = null
var current_hight_area: AreaView3D = null


var check_click := true
func enabled_ray_click_check(state := true):
	check_click = state


func enabled_ray(state := true):
	deep_ray.enabled = state


func _physics_process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	
	# 从鼠标屏幕点生成3D射线 origin 起点，end 终点
	var ray_normal := camera.project_ray_normal(mouse_pos)
	var ray_origin := camera.project_ray_origin(mouse_pos)
	
	var ray = $Ray
	ray.global_position = ray_origin
	ray.look_at(ray_origin + ray_normal, Vector3.UP)
	
	if deep_ray.get_collider_count() == 0:
		if current_hight_card:
			current_hight_card.normallight()
			current_hight_card = null
		if current_hight_area:
			current_hight_area.normallight()
			current_hight_area = null
	
	# 如果点击就检查是否有检查到CardView3D，进行模板的弹出尝试
	if check_click and deep_ray.get_collider_count() and Input.is_action_just_pressed("click"):
		var first_card: CardView3D = null
		var first_area: AreaView3D = null
		for i in range(deep_ray.get_collider_count()):
			var collider = deep_ray.get_collider(i)
			if first_card == null and collider is CardView3D:
				first_card = collider
			elif first_area == null and collider is AreaView3D:
				first_area = collider
			if first_card and first_area:
				break
		if first_card:
			first_card.trigger()
		if first_area:
			first_area.trigger()
	else:
		var first_card: CardView3D = null
		var first_area: AreaView3D = null
		for i in range(deep_ray.get_collider_count()):
			var collider = deep_ray.get_collider(i)
			if collider == null:
				continue
			if first_card == null and collider is CardView3D:
				first_card = collider
			elif first_area == null and collider is AreaView3D:
				first_area = collider
			if first_card and first_area:
				break
		if first_card:
			Utils.get_current_scene().event_manager.emit("SHOW_CARD_INFO_IN_PANEL", {
				"params": first_card.entity
			})
			first_card.hightlight()
			if current_hight_card and current_hight_card != first_card:
				current_hight_card.normallight()
			current_hight_card = first_card
		if first_area:
			Utils.get_current_scene().event_manager.emit("SHOW_AREA_INFO_IN_PANEL", {
				"params": first_area.entity
			})
			first_area.hightlight()
			if current_hight_area and current_hight_area != first_area:
				current_hight_area.normallight()
			current_hight_area = first_area


func battle_visual_angle_changed(visual_angle: Vector2i) -> void:
	match visual_angle:
		Vector2i.DOWN:
			phantom_camera_down.priority = 1
			phantom_camera_left.priority = 0
			phantom_camera_right.priority = 0
			phantom_camera_up.priority = 0
		Vector2i.UP:
			phantom_camera_up.priority = 1
			phantom_camera_left.priority = 0
			phantom_camera_right.priority = 0
			phantom_camera_down.priority = 0
		Vector2i.LEFT:
			phantom_camera_left.priority = 1
			phantom_camera_right.priority = 0
			phantom_camera_up.priority = 0
			phantom_camera_down.priority = 0
			pass
		Vector2i.RIGHT:
			phantom_camera_right.priority = 1
			phantom_camera_left.priority = 0
			phantom_camera_up.priority = 0
			phantom_camera_down.priority = 0
	
	Utils.get_current_scene().event_manager.emit("BATTLE_VISUAL_ANGLE_CHANGED", {
		"visual_angle": visual_angle,
		"camera": camera
	})

#
# 一个工具方法，算出 4 个方位的中心点
# 例如：
#   X (UP)
# OOOOO
# OOOOO
# OOOOO
#   X (DOWN)
# 得到两个X应该在的位置的中心点，以及长度
func get_area_center() -> Dictionary:
	# 1. 通过 max_x 与 max_y 分别乘以 AREA_SIZE 得到这个战场的整体大小
	var width: float = (max_x + 1) * ConfigManager.AREA_SIZE
	var height: float = (max_y + 1) * ConfigManager.AREA_SIZE
	
	# 2. 因为从 0,0 点开始，所以 max_x 和 max_y 都需要减去 TILE_SIZE / 2
	#    第一个除2是得到这个形成的矩形的中心点，减去 TILE_SIZE / 2 是为了修正偏移量
	var center_x = width / 2
	var center_y = height / 2
	# 3. 在获得了中心点后，需要获取 UP、DOWN、LEFR、RIGHT 四个方向的位置（这个位置刚好在这个矩形外）
	var up_x = center_x - 0.5
	var up_y = center_y - height / 2 + 0.5 #- ConfigManager.AREA_SIZE
	var down_x = center_x + 0.5
	var down_y = center_y + height / 2 - 0.5 #+ #ConfigManager.AREA_SIZE
	var left_x = center_x - width / 2 + 0.5 #ConfigManager.AREA_SIZE
	var left_y = center_y
	var right_x = center_x + width / 2 - 0.5 #ConfigManager.AREA_SIZE
	var right_y = center_y
	# 结果
	var result = {
		"up": Vector2(up_x, up_y),
		"down": Vector2(down_x, down_y),
		"left": Vector2(left_x, left_y),
		"right": Vector2(right_x, right_y),
		"center": Vector2(center_x, center_y),
		"height": height,
		"width": width,
	}
	return result


func add_area(x: int, y: int, z: int = 1) -> AreaView3D:
	max_x = x if x > max_x else max_x
	max_y = y if y > max_y else max_y
	max_z = z if z > max_z else max_z
	var area: AreaView3D = load("res://components/area_view_3d/area_view_3d.tscn").instantiate()
	area.x = x
	area.y = y
	area.set_height(z)
	area.position.x = x
	area.position.y = 0
	area.position.z = y
	area_mount.add_child(area)
	
	adjust_camera()
	adjust_position()
	return area

func adjust_camera() -> void:
	var pos = get_area_center()
	phantom_camera_up.position = Vector3(pos["up"].x, 4, pos["up"].y)
	phantom_camera_down.position = Vector3(pos["down"].x, 4, pos["down"].y)
	phantom_camera_left.position = Vector3(pos["left"].x, 4, pos["left"].y)
	phantom_camera_right.position = Vector3(pos["right"].x, 4, pos["right"].y)


# 调整位置（在添加Area后调用，用于调整相机、战场区域偏移、卡组手牌弃区位置偏移）
# 手牌、弃区、卡组都会靠近Area战场边缘
# 最大x||y / 2 * AREA_SIZE
func adjust_position() -> void:
	battle_visual_angle_changed(get_tree().current_scene.visual_angle)
