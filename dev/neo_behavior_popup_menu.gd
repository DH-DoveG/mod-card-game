extends CanvasLayer
class_name NeoBehaviorPopuopMenu

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var mask: ColorRect = $Mask

var behaviors = []
var card_entity: CardEntity

var mask_rect: Rect2

static var only = null

func _ready() -> void:
	set_process(false)
	if only:
		only.queue_free()
		only = null
	only = self

func _exit_tree() -> void:
	var scene = get_tree().current_scene
	if scene is Battle:
		scene.scene.set_physics_process(true)
		scene.scene.enabled_ray(true)
		scene.player_hand_view.get_node("Hand").set_process(true)

func set_popup(pos, _behaviors, _entity: CardEntity):
	visible = true
	behaviors = _behaviors
	card_entity = _entity
	var scene: Battle = get_tree().current_scene

	var id = 0
	if not scene.in_option:
		var bt = Behavior.BehaviorTrigger.new()
		bt.trigger = scene.host_player_id
		bt.origin = _entity.name
		for bname: String in behaviors:
			var behavior: Behavior = scene.behaviors[bname]
			bt.code = bname
			var info = behavior.get_info()
			var check_launch = await behavior.check_launch(bt, {})
			var check_cost = await behavior.check_cost(bt, {})
			if check_launch and check_cost:
				add_item("【" + info["type"] + "】" + info["name"], id)
			id += 1

	await get_tree().process_frame
	pos.x -= vbox.size.x / 2
	pos.y -= vbox.size.y
	vbox.position = pos

	if vbox.get_child_count() == 0:
		pass
	if scene is Battle:
		scene.scene.set_physics_process(false)
		scene.scene.enabled_ray(false)
		scene.player_hand_view.get_node("Hand").set_process(false)

	$ColorRect2.size = vbox.size
	$ColorRect2.position = vbox.position

func add_item(title: String, id: int):
	var button := Button.new()
	vbox.add_child(button)
	button.text = title
	button.name = str(id)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(func():
		var scene = get_tree().current_scene
		if scene is not Battle:
			return
		var battle: Battle = scene
		if battle.host_player_id != battle.current_round_player:
			return
		if battle.in_option:
			return
		var bcode = behaviors[id]
		var behavior_entry: Behavior = battle.behaviors[bcode]
		var bt = Behavior.BehaviorTrigger.new()
		bt.code = behavior_entry.get_info()["code"]
		bt.trigger = battle.host_player_id
		bt.origin = card_entity.name
		behavior_entry.launch(bt, {
			trigger = (Utils.get_current_scene() as Battle).host_player_id
		})
		queue_free()
	)

func set_exp_mask(rect: Rect2):

	var mr = make_b_touch_a(vbox.get_rect(), rect)
	mask_rect = mr

	$Mask.size = mr.size
	$Mask.position = mr.position

# inset：允许侵入A内部的像素，0=刚好接触；>0=B钻进A里面
func make_b_touch_a(a:Rect2, b:Rect2, inset:float = 2.0) -> Rect2:
	var b_bottom:float = b.end.y
	var target_top_y:float = a.end.y - inset

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

func _process(_delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	if (not mask_rect.has_point(mouse_position)) and (not vbox.get_rect().has_point(mouse_position)):
		queue_free()
		pass

func _on_color_rect_gui_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
