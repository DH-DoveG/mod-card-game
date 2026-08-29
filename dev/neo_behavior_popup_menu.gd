extends CanvasLayer


@onready var vbox: VBoxContainer = $VBoxContainer
@onready var mask: ColorRect = $Mask


func _ready() -> void:
	pass # Replace with function body.


func set_popup(pos):
	pos.x -= vbox.size.x / 2
	pos.y -= vbox.size.y
	vbox.position = pos
	visible = true
	get_tree().paused = true

func set_exp_mask(rect: Rect2):
	var r = make_b_touch_a(vbox.get_rect(), rect)
	#if cr:
	mask.position = r.position
	mask.size = r.size
	#mask.position = rect.position
	#mask.size = rect.size
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



func _input(_event: InputEvent) -> void:
	if visible:
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if (not mask.get_rect().has_point(mouse_position)) and (not vbox.get_rect().has_point(mouse_position)):
		get_tree().paused = false
		queue_free()
