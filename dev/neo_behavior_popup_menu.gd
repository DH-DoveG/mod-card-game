extends CanvasLayer


@onready var vbox: VBoxContainer = $VBoxContainer
@onready var mask: ColorRect = $Mask

var behaviors = []

var mask_rect: Rect2

func _ready() -> void:
	set_process(false)
	pass # Replace with function body.


func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.scene.set_physics_process(true)
		scene.scene.enabled_ray(true)


func set_popup(pos, _behaviors, _entity: CardEntity):
	visible = true
	var id = 0
	behaviors = _behaviors
	for behavior: Behavior in behaviors:
		var info = behavior.get_info()
		var check_launch = await behavior.check_launch()
		var check_cost = await behavior.check_cost()
		#print("check_launch: ", check_launch, " | check_cost: ", check_cost)
		if check_launch and check_cost:
			add_item("【" + info["type"] + "】" + info["name"], id)
		id += 1
	pos.x -= vbox.size.x / 2
	pos.y -= vbox.size.y
	vbox.position = pos
	#print("UP vbox position: ", vbox.position)
	#print("vgcc: ", vbox.get_child_count())
	if vbox.get_child_count() == 0:
		#queue_free()
		#return false
		pass
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.scene.set_physics_process(false)
		scene.scene.enabled_ray(false)
	
	#var vgr = vbox.get_rect()
	#$ColorRect2.position = vgr.position
	#$ColorRect2.size = vgr.size


func add_item(title: String, id: int):
	var button := Button.new()
	vbox.add_child(button)
	button.text = title
	button.name = str(id)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(func():
		print("button pressed")
		var scene = get_tree().current_scene
		if scene is not Battle:
			return
		var battle: Battle = scene
		if battle.host_player_id != battle.current_round_player:
			return
		if battle.in_option:
			return
		var behavior_entry = behaviors[id]
		print("behavior entry : ", behavior_entry)
		behavior_entry.launch({
			trigger = (Utils.get_current_scene() as Battle).host_player_id
		})
		queue_free()
	)


func set_exp_mask(rect: Rect2):
	#var r =
	#print("set_exp_mask RECT: ", rect)
	#print("set_exp_mask VBOX: ", vbox.get_rect(), " | pos: ", vbox.position)
	var mr = make_b_touch_a(vbox.get_rect(), rect)
	#print(">>> mr: ", mr)
	
	mask_rect = mr
	#mask.position = mr.position
	#mask.size = mr.size
	#if cr:
	#mask.position = mask_rect.position
	#mask.size = mask_rect.size
	#else:
		#cr = ColorRect.new()
		#cr.color = Color(1, 0, 0, 0.25)
		#get_tree().current_scene.add_child(cr)
		#cr.position = rect.position
		#cr.size = rect.size


# a：上方Rect2，b：下方Rect2
# inset：允许侵入A内部的像素，0=刚好接触；>0=B钻进A里面
func make_b_touch_a(a:Rect2, b:Rect2, inset:float = 2.0) -> Rect2:
	# B的底边保持不变
	var b_bottom:float = b.end.y
	# A的底边，允许B往里侵入inset像素
	var target_top_y:float = a.end.y - inset
	
	# 新高度 = 底边 - 新的顶部y
	var new_height:float = b_bottom - target_top_y
	
	# 保护：高度不能小于0
	new_height = max(new_height, 0.0)
	
	# 构造新B：position.y被往上提，height变大，底部不变
	var new_b = Rect2()
	new_b.position.x = b.position.x
	new_b.position.y = target_top_y
	new_b.size.x = b.size.x
	new_b.size.y = new_height
	return new_b



#func _input(_event: InputEvent) -> void:
	#if visible:
		#get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if (not mask_rect.has_point(mouse_position)) and (not vbox.get_rect().has_point(mouse_position)):
		queue_free()
