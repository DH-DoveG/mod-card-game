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
	
	# 如果点击就检查是否有检查到CardView3D，进行模板的弹出尝试
	if check_click and deep_ray.get_collider_count() and Input.is_action_just_pressed("click"):
		print("CLICK !")
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
		if first_area:
			Utils.get_current_scene().event_manager.emit("SHOW_AREA_INFO_IN_PANEL", {
				"params": first_area.entity
			})
		#for i in range(deep_ray.get_collider_count()):
			#var collider = deep_ray.get_collider(i)
			#var _position = deep_ray.get_position(i)
			#var normal = deep_ray.get_normal(i)
		#print("Hit:", collider, "at", _position, "normal:", normal, " | ", collider is AreaView3D)


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
	#print("MaxX: ", max_x)
	#print("MaxY: ", max_y)
	# 1. 通过 max_x 与 max_y 分别乘以 AREA_SIZE 得到这个战场的整体大小
	var width: float = (max_x + 1) * ConfigManager.AREA_SIZE
	var height: float = (max_y + 1) * ConfigManager.AREA_SIZE
	
	#print("Width: ", width)
	#print("Height: ", height)
	
	# 2. 因为从 0,0 点开始，所以 max_x 和 max_y 都需要减去 TILE_SIZE / 2
	#    第一个除2是得到这个形成的矩形的中心点，减去 TILE_SIZE / 2 是为了修正偏移量
	var center_x = width / 2
	var center_y = height / 2
	# 3. 在获得了中心点后，需要获取 UP、DOWN、LEFR、RIGHT 四个方向的位置（这个位置刚好在这个矩形外）
	var up_x = center_x - 0.5
	var up_y = center_y - height / 2 + 0.5 #- ConfigManager.AREA_SIZE
	var down_x = center_x
	var down_y = center_y + height / 2 - 1 #+ #ConfigManager.AREA_SIZE
	var left_x = center_x - width / 2 - ConfigManager.AREA_SIZE
	var left_y = center_y
	var right_x = center_x + width / 2 + ConfigManager.AREA_SIZE
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

#
#func _generate(pos: Vector3):
	## 00 00 00
	##print("id: ", int(pos.x + pos.y * 100 + pos.z * 10000))
	##return int(int(pos.x) + int(pos.y) * 100) # + int(pos.z) * 10000)
	#return int(int(pos.x) + int(pos.y) * 100 + 10000)

#
#func _dec(id):
	#var id_str = str(id)
	#if id_str.length() == 1:
		#return Vector3(id, 0, 0)
	#if id_str.length() == 5:
		#id_str = "0" + id_str
	#var z = id_str.substr(0, 2)
	#var y = id_str.substr(2, 2)
	#var x = id_str.substr(4, 2)
	#if x.begins_with("0"):
		#x = x.substr(1)
	#if y.begins_with("0"):
		#y = y.substr(1)
	#if z.begins_with("0"):
		#z = z.substr(1)
	##print("_dec: ", id, " --> ", Vector3(int(x), int(y), int(z)))
	#return Vector3(int(x), int(y), int(z))


#func add_area(area: Area, x: int, y: int, z: int = 0) -> void:
func add_area(x: int, y: int, z: int = 1) -> AreaView3D:
	#IDUtils.generate()
	#area_mount.add_child(area)
	#var pos_x = x * ConfigManager.AREA_SIZE
	#var pos_y = y * ConfigManager.AREA_SIZE
	## var pos_z = z * ConfigManager.AREA_HEIGHT_BASE
	#area.position.x = pos_x
	#area.position.z = pos_y
	max_x = x if x > max_x else max_x
	max_y = y if y > max_y else max_y
	max_z = z if z > max_z else max_z
#
	#area.set_height_level(z)
	
	#$GridMap.set_cell_item(Vector3i(x, 0, y), z)
	var area: AreaView3D = load("res://components/area_view_3d/area_view_3d.tscn").instantiate()
	area.x = x
	area.y = y
	area.set_height(z)
	#area.position = Vector3(x + 0.5, 0, y + 0.5)
	#area.position = Vector3(x, 0.0, y)
	area.position.x = x
	area.position.y = 0
	area.position.z = y
	area_mount.add_child(area)
	
	adjust_camera()
	adjust_position()
	# reset_astar(AStarMode.CROSS)
	return area

#
#func build_astar(config: AStarMode, check: Callable) -> AStar3D:
	#var astar: AStar3D = AStar3D.new()
	#for area in area_mount.get_children():
		#if not check.call(area):
			#continue
		#astar.add_point(_generate(Vector3(area.x, area.y, area.z)), area.get_top_position())
	#for id in astar.get_point_ids():
		#var dec_pos = _dec(id)
		#var up = dec_pos + Vector3.UP
		#var down = dec_pos + Vector3.DOWN
		#var left = dec_pos + Vector3.LEFT
		#var right = dec_pos + Vector3.RIGHT
		#var up_left = dec_pos + Vector3.UP + Vector3.LEFT
		#var up_right = dec_pos + Vector3.UP + Vector3.RIGHT
		#var down_left = dec_pos + Vector3.DOWN + Vector3.LEFT
		#var down_right = dec_pos + Vector3.DOWN + Vector3.RIGHT
		#if config == AStarMode.CROSS:
			#if astar.has_point(_generate(up)):
				#astar.connect_points(_generate(dec_pos), _generate(up))
			#if astar.has_point(_generate(down)):
				#astar.connect_points(_generate(dec_pos), _generate(down))
			#if astar.has_point(_generate(left)):
				#astar.connect_points(_generate(dec_pos), _generate(left))
			#if astar.has_point(_generate(right)):
				#astar.connect_points(_generate(dec_pos), _generate(right))
		#elif config == AStarMode.ADJOIN:
			#if astar.has_point(_generate(up)):
				#astar.connect_points(_generate(dec_pos), _generate(up))
			#if astar.has_point(_generate(down)):
				#astar.connect_points(_generate(dec_pos), _generate(down))
			#if astar.has_point(_generate(left)):
				#astar.connect_points(_generate(dec_pos), _generate(left))
			#if astar.has_point(_generate(right)):
				#astar.connect_points(_generate(dec_pos), _generate(right))
			#if astar.has_point(_generate(up_left)):
				#astar.connect_points(_generate(dec_pos), _generate(up_left))
			#if astar.has_point(_generate(up_right)):
				#astar.connect_points(_generate(dec_pos), _generate(up_right))
			#if astar.has_point(_generate(down_left)):
				#astar.connect_points(_generate(dec_pos), _generate(down_left))
			#if astar.has_point(_generate(down_right)):
				#astar.connect_points(_generate(dec_pos), _generate(down_right))
		##var i = 1
	##for id in astar.get_point_ids():
	##	print(i, " :ID: ", id, " | IDS: ", astar.get_point_connections(id))
	##	i += 1
	##print("==================================")
	#return astar

#
func adjust_camera() -> void:
	var pos = get_area_center()
	pass
	#var result = {
		#"up": Vector2(up_x, up_y),
		#"down": Vector2(down_x, down_y),
		#"left": Vector2(left_x, left_y),
		#"right": Vector2(right_x, right_y),
		#"center": Vector2(center_x, center_y),
		#"height": height,
		#"width": width,
	#}
	phantom_camera_up.position = Vector3(pos["up"].x, 4, pos["up"].y)
	phantom_camera_down.position = Vector3(pos["down"].x, 4, pos["down"].y)
	phantom_camera_left.position = Vector3(pos["left"].x, 4, pos["left"].y)
	phantom_camera_right.position = Vector3(pos["right"].x, 4, pos["right"].y)


# TODO
# 调整位置（在添加Area后调用，用于调整相机、战场区域偏移、卡组手牌弃区位置偏移）
# 手牌、弃区、卡组都会靠近Area战场边缘
# 最大x||y / 2 * AREA_SIZE
func adjust_position() -> void:
	battle_visual_angle_changed(get_tree().current_scene.visual_angle)

#
## 获取Mesh模型本身的本地高度（模型Y方向尺寸，不受格子位置影响）
#func get_mesh_local_height(item_id:int) -> float:
	#var mesh_lib:MeshLibrary = map.mesh_library
	#var mesh:Mesh = mesh_lib.get_item_mesh(item_id)
	#if not mesh:
		#return 0.0
	#var aabb:AABB = mesh.get_aabb()
	#return aabb.size.y
#
#
## 遍历所有已使用cell，打印每个格子世界顶面高度
#func iterate_all_cells_height():
	#var used_cells:Array[Vector3i] = map.get_used_cells()
	#var pos: Vector3 = Vector3.ZERO
	#for cell_pos in used_cells:
		#var id = map.get_cell_item(cell_pos)
		#pos = map.map_to_local(cell_pos)
		#pos.y = get_mesh_local_height(id)
		##print("格子",cell_pos," 世界顶面Y=",top_y)
