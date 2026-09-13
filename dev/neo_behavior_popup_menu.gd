extends BasePopupMenu
class_name NeoBehaviorPopuopMenu

@onready var vbox: VBoxContainer = $VBoxContainer

var behaviors = []
var card_entity: CardEntity

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
	block_scene()
	claim_topmost()
	print("...")

	$ColorRect2.size = vbox.size
	$ColorRect2.position = vbox.position

func _get_panel_rect() -> Rect2:
	return vbox.get_rect()

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
