extends OptionBase


var area_ids = []
var chooses = []
var btns = []

var _max = 1
var _min = 1
var _cancel = true

var _show_areas = []
var _choose_show_areas = []

#!不再点击mask，而是链接区域的点击事件


func set_data(param) -> void:
	# print("set_data: ", param)
	area_ids = param["areas"]
	btns = param["btns"]
	_max = param["max"]
	_min = param["min"]
	_cancel = param["can_cancel"]

	if not _cancel:
		$Side/HBox/Close.hide()
	
	build_btns()
	_set_area_height()


func build_btns() -> void:
	for config in btns:
		var btn = _build_btn_item($List, config["text"])
		btn.pressed.connect(_bind_btn_callback.bind(config))


func _bind_btn_callback(callback: Dictionary) -> void:
	var close: Dictionary = callback["callback"].call(chooses)
	if close["close"]:
		finished.emit(close["value"], "Confirm")


func _build_btn_item(parent: Node, text: String) -> Button:
	var btn = Button.new()
	parent.add_child(btn)
	btn.text = text
	btn.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
	btn.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
	return btn


func _set_area_height() -> void:
	# 设置区域高亮
	for id in area_ids:
		var area: AreaEntity = FindUtils.find_area(id)
		
		var pos := area.get_position()
		pos.y += 0.001
		
		var areamask: StaticBody3D = preload("res://components/area_mask/area_mask.tscn").instantiate()
		battle.scene.add_child(areamask)
		areamask.position = pos
		
		areamask.mouse_entered.connect(func():
			if id in chooses:
				return
			var mi: MeshInstance3D = areamask.get_node("MeshInstance3D")
			var sm: StandardMaterial3D = mi.get_active_material(0)
			var tween = get_tree().create_tween()
			tween.tween_property(sm, "albedo_color", Color("b0b0b07a"), 0.2)
		)
		areamask.mouse_exited.connect(func():
			if id in chooses:
				return
			var mi: MeshInstance3D = areamask.get_node("MeshInstance3D")
			var sm: StandardMaterial3D = mi.get_active_material(0)
			var tween = get_tree().create_tween()
			tween.tween_property(sm, "albedo_color", Color("7a7a7a7a"), 0.2)
		)
		areamask.input_event.connect(func(camera: Camera3D, event: InputEvent, _event_position, _normal, _shape_idx):
			if event.is_action_pressed("click"):
				if id in chooses:
					var index = chooses.find(id)
					chooses.remove_at(index)
					var _csa = _choose_show_areas[index]
					_choose_show_areas.remove_at(index)
					if _csa.get_node("Btn"):
						_csa.get_node("Btn").queue_free()
					var mi: MeshInstance3D = areamask.get_node("MeshInstance3D")
					var sm: StandardMaterial3D = mi.get_active_material(0)
					var tween = get_tree().create_tween()
					tween.tween_property(sm, "albedo_color", Color("7a7a7a7a"), 0.2)
					if areamask.get_node("Btn"):
						areamask.get_node("Btn").queue_free()
				else:
					chooses.append(id)
					_choose_show_areas.append(areamask)
					var mi: MeshInstance3D = areamask.get_node("MeshInstance3D")
					var sm: StandardMaterial3D = mi.get_active_material(0)
					var tween = get_tree().create_tween()
					tween.tween_property(sm, "albedo_color", Color("ffffffff"), 0.2)
					# 添加一个按钮
					var btn = TextureButton.new()
					btn.name = "Btn"
					areamask.add_child(btn)
					btn.ignore_texture_size = true
					btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
					btn.custom_minimum_size = Vector2(100, 100)
					btn.custom_maximum_size = Vector2(100, 100)
					btn.texture_normal = preload("res://assets/images/icon/right.png")
					btn.position = camera.unproject_position(areamask.position) - Vector2(50, 50)
					btn.pressed.connect(func():
						if chooses.size() < _min or chooses.size() > _max:
							return
						finished.emit(chooses, "Confirm")
					)
					
					var outline = ShaderMaterial.new()
					outline.shader = preload("res://assets/shader/canvas_item/2d_outline.gdshader")
					btn.material = outline
					outline.set_shader_parameter("thickness", 4)
					
					if chooses.size() > _max:
						chooses.pop_front()
						var first = _choose_show_areas.pop_front()
						mi = first.get_node("MeshInstance3D")
						sm = mi.get_active_material(0)
						tween = get_tree().create_tween()
						tween.tween_property(sm, "albedo_color", Color("7a7a7a7a"), 0.2)
						print("替换")
						if first.get_node("Btn"):
							first.get_node("Btn").queue_free()
		)
		
		_show_areas.append(areamask)


func _ready() -> void:
	get_tree().current_scene.scene.enabled_ray_click_check(false)


func _exit_tree() -> void:
	super()
	get_tree().current_scene.scene.enabled_ray_click_check(true)
	for area in _show_areas:
		area.queue_free()


func _on_confirmed_pressed() -> void:
	if chooses.size() < _min or chooses.size() > _max:
		return
	finished.emit(chooses, "Confirm")


func _on_close_pressed() -> void:
	if not _cancel:
		return
	finished.emit(chooses, "Cancel")
