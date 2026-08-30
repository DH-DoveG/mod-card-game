extends StaticBody3D
class_name CardView3D


@onready var body: MeshInstance3D = $Body
var entity: CardEntity = null

var outline_color: Color

var origin_body_pos
var origin_body_ration
var origin_nciv_pos
var origin_nciv_ration

var origin_self_pos
var origin_self_ration

var origin_basis = null


func _ready() -> void:
	add_to_group(&"CardView3D")
	origin_body_pos = Vector3.ZERO
	origin_body_ration = Vector3(-90, 0, 0)
	origin_nciv_pos = Vector3.ZERO
	origin_nciv_ration = Vector3.ZERO


func _exit_tree() -> void:
	remove_from_group(&"CardView3D")


var in_free := false
func animate_free():
	in_free = true
	$CS3D.disabled = true
	queue_free()

var is_hightlight := false

func hightlight():
	var m: ShaderMaterial = body.get_active_material(0).next_pass
	var color := Color.from_hsv(outline_color.h, outline_color.s, 2, 1.0)
	var c = m.get_shader_parameter("color")
	var tween1: Tween = get_tree().create_tween()
	tween1.tween_method(func(value: Color):
		m.set_shader_parameter("color", value)
	, c, color, 0.2)
	pass
	if is_hightlight: return
	is_hightlight = true
	
	$NeoCardInfoView3D.set_rander_priority(4)
	
	#self.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 1, 0), true)
	#self.look_at(get_viewport().get_camera_3d().global_position, Vector3(0, 1, 0), true)
	#if origin_basis == null:
		#origin_basis = self.global_transform.basis
	#self.global_transform.basis = get_viewport().get_camera_3d().global_transform.basis
	#self.rotation_degrees.x += 90
	if origin_basis == null:
		origin_basis = self.global_transform.basis
	
	var dir = global_position.direction_to(get_viewport().get_camera_3d().global_position)
	print("DIR: ", dir)
	
	var nciv = $NeoCardInfoView3D
	
	#var bd = origin_body_pos
	#bd += Vector3(0.5, 0.5, 0.5)
	#bd += dir
	
	var _dir: Vector3 = (get_viewport().get_camera_3d().global_position - body.global_position).normalized()
	
	origin_body_pos = body.global_position
	origin_nciv_pos = nciv.global_position
	origin_basis = global_transform.basis
	
	var bd = body.global_position + _dir * 0.75
	var nd = nciv.global_position + _dir * 0.75
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(body, "global_position", bd, 0.2)
	tween.tween_property(nciv, "global_position", nd, 0.2)
	tween.tween_property(body, "scale", Vector3(100 * 1.2, 100 * 1.2, 100 * 1.2), 0.2)
	tween.tween_property(nciv, "scale", Vector3(1.2, 1.2, 1.2), 0.2)
	tween.tween_property(self, "global_transform:basis", get_viewport().get_camera_3d().global_transform.basis, 0.2)
	
	$NeoCardInfoView3D.change_x(false)
	
	await tween.finished
	
	var scene = get_tree().current_scene
	var pos = scene.scene.camera.unproject_position(global_position)
	pos.y -= 140
	
	#self.global_transform.basis = get_viewport().get_camera_3d().global_transform.basis
	var n = preload("res://dev/neo_behavior_popup_menu.tscn").instantiate()
	get_tree().current_scene.add_child(n)
	await n.set_popup(pos, entity.behavior_manager.behaviors, entity)
	if is_instance_valid(n):
		n.set_exp_mask(get_mesh_screen_rect())
		n.set_process(true)
		n.tree_exited.connect(func():
			print("退出")
			normallight()
		, ConnectFlags.CONNECT_ONE_SHOT)


func normallight():
	if not is_hightlight: return
	is_hightlight = false
	var m: ShaderMaterial = body.get_active_material(0).next_pass
	var current_color = m.get_shader_parameter("color")
	var tween1: Tween = get_tree().create_tween()
	tween1.tween_method(func(value: Color):
		m.set_shader_parameter("color", value)
	, current_color, outline_color, 0.2)
	
	#pass
	#scale = Vector3(1, 1, 1)
	#position.y -= 0.05
	#rotation_degrees.x -= 25
	$NeoCardInfoView3D.set_rander_priority(2)
	
	var nciv = $NeoCardInfoView3D
	#
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(body, "global_position", origin_body_pos, 0.2)
	tween.tween_property(nciv, "global_position", origin_nciv_pos, 0.2)
	tween.tween_property(body, "scale", Vector3(100, 100, 100), 0.2)
	tween.tween_property(nciv, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(self, "global_transform:basis", origin_basis, 0.2)
	#self.global_transform.basis = origin_basis
	$NeoCardInfoView3D.change_x(true)


func get_front() -> bool:
	var scene = get_tree().current_scene
	if scene is Battle:
		if (int(abs(rotation_degrees.x)) == 0 and int(abs(rotation_degrees.z)) == 0) or \
		   (int(abs(rotation_degrees.x)) == 180 and int(abs(rotation_degrees.z)) == 180):
			return true
		else:
			return false
	return false


func trigger(_pos := Vector2(-1, -1)):
	var scene = get_tree().current_scene
	var pos = _pos
	if pos == Vector2(-1, -1):
		pos = scene.scene.camera.unproject_position(global_position)
	if scene is Battle:
		# 1. 检查这张卡的持有者是否是主机玩家的（除非这张卡的 abs(x) 是 0）
		var battle: Battle = scene
		var controller = battle.battle_data_bind_list.player_bind_cards_of_controller
		var show_key = false
		var in_battle = false
		
		if (int(abs(rotation_degrees.x)) == 0 and int(abs(rotation_degrees.z)) == 0) or \
		   (int(abs(rotation_degrees.x)) == 180 and int(abs(rotation_degrees.z)) == 180):
			pass
		#if is_front:
			var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
			battle.add_child(menu)
			menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
			menu.popup_hide.connect(func():
				menu.queue_free()
			)
		else:
			# 如果卡是否在场上
			for area in battle.battle_data_bind_list.area_bind_cards:
				if entity.name in battle.battle_data_bind_list.area_bind_cards[area]:
					in_battle = true
			# 卡的持有者是不是主机玩家
			for c in controller:
				if entity.name in controller[c] and c == scene.host_player_id:
					show_key = true
					break
			# 卡片在场上，并且卡的持有者是主机玩家，玩家才可以在卡片处于盖放的状态下查看
			if show_key and in_battle:
				var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
				battle.add_child(menu)
				menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
				menu.popup_hide.connect(func():
					menu.queue_free()
				)


func set_entity(data: CardEntity):
	name = data.name
	entity = data
	var player: Player = FindUtils.find_player(GApiManager.card_api.get_ownership(entity.name))
	var front = GResourceManager.get_image_resoure(data.image)
	var back = GResourceManager.get_image_resoure(player.use_card_back)
	var uv = ImageUtils.make_card_criterion_card_uv(front.get_image(), back.get_image())
	var s: StandardMaterial3D = body.get_active_material(0)
	s.albedo_texture = uv
	
	# 获取 player 的 camp
	var camp = GApiManager.player_api.get_camp(player.name)
	if camp is Camp:
		set_outline_color(camp.color)


func set_outline_visible(_visible: bool) -> void:
	var shader: ShaderMaterial = body.get_active_material(0).next_pass
	if _visible:
		shader.set_shader_parameter("size", 1.02)
	else:
		shader.set_shader_parameter("size", 1)


func set_outline_color(color: Color) -> void:
	var shader: ShaderMaterial = body.get_active_material(0).next_pass
	shader.set_shader_parameter("color", color)
	outline_color = color













# 获取相当的一个2D区域，这个区域可以用于实现：
# 鼠标移在上方时：放大，并且显示出可操作项目

# 获取物体在相机屏幕上的Rect2（屏幕像素空间）
func get_mesh_screen_rect() -> Rect2:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var target: MeshInstance3D = body
	if not target or not camera:
		return Rect2()
	
	# 获取模型本地AABB包围盒
	var local_aabb: AABB = target.mesh.get_aabb()
	if not camera.is_visible_in_tree():
		var k := false
		for plane in camera.get_frustum():
			if local_aabb.intersects_plane(plane):
				k = true
				break
		if not k:
			return Rect2()
	
	# AABB的8个角点（本地空间）
	var corners = [local_aabb.get_endpoint(0), local_aabb.get_endpoint(1), local_aabb.get_endpoint(2),
	local_aabb.get_endpoint(3), local_aabb.get_endpoint(4), local_aabb.get_endpoint(5), local_aabb.get_endpoint(6),
	local_aabb.get_endpoint(7)]
	
	var screen_points: Array[Vector2] = []
	for corner in corners:
		# 本地 → 世界坐标
		var world_pos: Vector3 = target.global_transform * corner
		# 世界坐标投影到屏幕
		var screen_pos: Vector2 = camera.unproject_position(world_pos)
		screen_points.append(screen_pos)
	# 计算所有屏幕点的最小最大xy
	var min_p: Vector2 = screen_points[0]
	var max_p: Vector2 = screen_points[0]
	for p in screen_points:
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	# 构建Rect2：x,y是左上角，size宽高
	return Rect2(min_p, max_p - min_p)
