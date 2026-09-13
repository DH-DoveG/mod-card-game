extends Node3D
class_name Scene

@onready var card_mount: Node3D = $CardMount
@onready var area_mount: Node3D = $AreaMount
@onready var camera: Camera3D = $Camera3D
@onready var deep_ray: DeepRayCast3D = $Ray/DeepRayCast3D

var camera_direction_config = {
	Vector2i.UP: {
		"position": Vector3.ZERO,
		"rotation": Quaternion(0, 0.793353, 0.608761, 0)
	},
	Vector2i.DOWN: {
		"position": Vector3.ZERO,
		"rotation": Quaternion(-0.608761, 0, 0, 0.793353)
	},
	Vector2i.LEFT: {
		"position": Vector3.ZERO,
		"rotation": Quaternion(-0.430459, 0.560986, 0.430459, 0.560986)
	},
	Vector2i.RIGHT: {
		"position": Vector3.ZERO,
		"rotation": Quaternion(-0.430459, -0.560986, -0.430459, 0.560986)
	},
}

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

# ========== 长按拖拽摄像机 ==========
const LONG_PRESS_AWAIT_DURATION := 0.2 # 长按启动时间
const LONG_PRESS_DURATION := 0.3
const DRAG_SPEED := 0.015
const MOVE_CANCEL_THRESHOLD := 16.0  # 等待阶段鼠标移动超过该阈值则取消长按

var _pressing := false
var _await_duration := 0.0
var _press_elapsed := 0.0
var _is_long_press_dragging := false
var _last_mouse_pos := Vector2.ZERO
var _press_start_pos := Vector2.ZERO  # 按下时的初始鼠标位置，用于移动取消判断

var _progress_canvas: CanvasLayer
var _progress_rect: ColorRect
var _progress_material: ShaderMaterial

func _ready() -> void:
	# 动态创建长按进度条 UI
	_progress_canvas = CanvasLayer.new()
	_progress_canvas.layer = 100
	add_child(_progress_canvas)
	
	_progress_rect = ColorRect.new()
	var size := 56.0
	_progress_rect.size = Vector2(size, size)
	_progress_rect.color = Color.TRANSPARENT
	_progress_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_progress_rect.visible = false
	_progress_canvas.add_child(_progress_rect)
	
	var shader := load("res://assets/shader/canvas_item/long_press_progress.gdshader")
	_progress_material = ShaderMaterial.new()
	_progress_material.shader = shader
	_progress_material.set_shader_parameter("progress", 0.0)
	_progress_rect.material = _progress_material

func enabled_ray(state := true):
	deep_ray.enabled = state

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.y = clamp(camera.position.y - 0.5, 2.0, 8.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.y = clamp(camera.position.y + 0.5, 2.0, 8.0)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 开始长按
				_pressing = true
				_press_elapsed = 0.0
				_await_duration = 0.0
				_is_long_press_dragging = false
				_last_mouse_pos = event.position
				_press_start_pos = event.position
				_show_progress(event.position)
			else:
				# 释放左键
				_pressing = false
				_await_duration = 0.0
				if _is_long_press_dragging:
					_is_long_press_dragging = false
				_hide_progress()

func _physics_process(delta: float) -> void:
	# 射线高亮逻辑保持不变
	var mouse_pos := get_viewport().get_mouse_position()
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
	
	# ==== 长按 / 拖拽逻辑 ====
	if _pressing:
		if LONG_PRESS_AWAIT_DURATION > _await_duration:
			_await_duration += delta
			pass
		elif _is_long_press_dragging:
			_progress_rect.visible = true
			# 拖拽摄像机在 xz 平面移动
			var current_mouse := mouse_pos
			var delta_mouse := current_mouse - _last_mouse_pos
			_last_mouse_pos = current_mouse
			
			# 获取相机的右向量和前向量，投影到 xz 平面
			var right: Vector3 = camera.global_transform.basis.x
			var forward: Vector3 = camera.global_transform.basis.z
			right.y = 0.0
			forward.y = 0.0
			if right.length_squared() > 0.0:
				right = right.normalized()
			if forward.length_squared() > 0.0:
				forward = forward.normalized()
			
			var move: Vector3 = right * delta_mouse.x + forward * delta_mouse.y
			move *= DRAG_SPEED
			var new_pos := camera.position - move
			# XZ 平面边界限制（根据 area 范围 + 一些余量）
			var area_bound = max(max_x, max_y) * ConfigManager.AREA_SIZE * 0.5 + 4.0
			new_pos.x = clamp(new_pos.x, -area_bound, area_bound)
			new_pos.z = clamp(new_pos.z, -area_bound, area_bound)
			camera.position = new_pos
		else:
			# 等待阶段：如果鼠标移动超出阈值，取消长按
			var moved_distance := mouse_pos.distance_to(_press_start_pos)
			if moved_distance > MOVE_CANCEL_THRESHOLD:
				_press_elapsed = 0.0
				_hide_progress()
			else:
				# 计时进度
				_press_elapsed += delta
				var progress = clamp(_press_elapsed / LONG_PRESS_DURATION, 0.0, 1.0)
				_progress_material.set_shader_parameter("progress", progress)
				# 跟随鼠标位置
				_progress_rect.position = mouse_pos - _progress_rect.size * 0.5
				
				if _press_elapsed >= LONG_PRESS_DURATION:
					_is_long_press_dragging = true
					_last_mouse_pos = mouse_pos  # 防止拖拽起始跳跃
					_hide_progress()
	else:
		# 如果不在长按状态下，确保射线检查恢复（在 input 里释放时已重置 _is_long_press_dragging）
		pass
	
	# ==== 卡片 / 区域点击检查 ====
	# 如果长按拖拽中，跳过 click 触发，但保留高亮
	if check_click and deep_ray.get_collider_count() and Input.is_action_just_pressed("click") and not _is_long_press_dragging:
		#var first_card: CardView3D = null
		#var first_area: AreaView3D = null
		#for i in range(deep_ray.get_collider_count()):
			#var collider = deep_ray.get_collider(i)
			#if first_card == null and collider is CardView3D:
				#first_card = collider
			#elif first_area == null and collider is AreaView3D:
				#first_area = collider
			#if first_card and first_area:
				#break
		#if first_card:
			#first_card.trigger()
		#if first_area:
			#first_area.trigger()
		pass
	elif not _is_long_press_dragging:
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
		
		if first_area:
			Utils.get_current_scene().event_manager.emit("SHOW_AREA_INFO_IN_PANEL", {
				"params": first_area.entity
			})
			first_area.hightlight()
			if current_hight_area and current_hight_area != first_area:
				current_hight_area.normallight()
			current_hight_area = first_area
			if first_card:
				var ids = GApiManager.area_api.get_heap(first_area.entity.name)
				if ids.size() > 1:
					#多个卡片时的展示效果
					#Utils.get_current_scene().event_manager.emit("SHOW_CARD_LIST_IN_PANEL", {
						#"params": ids
					#})
					var clpm := preload("res://components/card_list_popup_menu/card_list_popup_menu.tscn").instantiate()
					get_tree().current_scene.add_child(clpm)
					var msr = first_card.get_mesh_screen_rect()
					#var qp = Utils.split_rect_center(msr, true)
					var pos = camera.unproject_position(first_card.global_position)
					pos.x -= msr.size.x / 2 # 160
					#pos.x -= qp[1].size.x / 2 # 160
					pos.x -= 40
					pos.y += 100
					print("msr:", msr)
					await clpm.set_popup(pos, ids)
					if is_instance_valid(clpm):
						clpm.set_exp_mask(msr)
						clpm.set_process(true)
					first_card.show_behavior(msr)
				elif ids.size() > 0:
					Utils.get_current_scene().event_manager.emit("SHOW_CARD_INFO_IN_PANEL", {
						"params": first_card.entity
					})
					first_card.show_behavior()
					#first_card.hightlight()
					#if current_hight_card and current_hight_card != first_card:
						#current_hight_card.normallight()
					#current_hight_card = first_card

func _show_progress(pos: Vector2) -> void:
	_progress_rect.position = pos - _progress_rect.size * 0.5
	_progress_material.set_shader_parameter("progress", 0.0)
	#_progress_rect.visible = true

func _hide_progress() -> void:
	_progress_rect.visible = false

func battle_visual_angle_changed(visual_angle: Vector2i) -> void:
	var config = camera_direction_config[visual_angle]
	camera.position = config["position"]
	camera.quaternion = config["rotation"]
	
	Utils.get_current_scene().event_manager.emit("BATTLE_VISUAL_ANGLE_CHANGED", {
		"visual_angle": visual_angle,
		"camera": camera
	})

func get_area_center() -> Dictionary:
	var width: float = max_x * ConfigManager.AREA_SIZE
	var height: float = max_y * ConfigManager.AREA_SIZE
	#    第一个除2是得到这个形成的矩形的中心点，减去 TILE_SIZE / 2 是为了修正偏移量
	var center_x = width / 2
	var center_y = height / 2
	var up_x = center_x
	var up_y = center_y - height / 2 + 0.5
	var down_x = center_x
	var down_y = center_y + height / 2 - 0.5 #+ #ConfigManager.AREA_SIZE
	var left_x = center_x + width / 2 - 0.5
	var left_y = center_y
	var right_x = center_x - width / 2 + 0.5
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
	camera_direction_config[Vector2i.UP]["position"] = Vector3(pos["up"].x, 4, pos["up"].y)
	camera_direction_config[Vector2i.DOWN]["position"] = Vector3(pos["down"].x, 4, pos["down"].y)
	camera_direction_config[Vector2i.LEFT]["position"] = Vector3(pos["left"].x, 4, pos["left"].y)
	camera_direction_config[Vector2i.RIGHT]["position"] = Vector3(pos["right"].x, 4, pos["right"].y)

# 调整位置（在添加Area后调用，用于调整相机、战场区域偏移、卡组手牌弃区位置偏移）
# 手牌、弃区、卡组都会靠近Area战场边缘
# 最大x||y / 2 * AREA_SIZE
func adjust_position() -> void:
	battle_visual_angle_changed(get_tree().current_scene.visual_angle)
