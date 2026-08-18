extends TextureButton


@onready var back: ColorRect = $Back
@onready var top_back: ColorRect = $TopBack

@onready var entry: Label = $TopBack/Entry
@onready var kind: Label = $TopBack/Kind
@onready var description: Label = $Description


var behavior_entry: Behavior


func set_behavior(behavior: Behavior) -> void:
	var info = behavior.get_info()
	entry.text = info["name"]
	kind.text = info["type"]
	description.text = info["description"]
	behavior_entry = behavior
	get_tree().process_frame.connect(func():
		# 动态变化占用宽度
		if info["description"].length():
			custom_minimum_size.y = 32 + description.size.y
			size.y = 32 + description.size.y
			# print("UPDATE cms: ", custom_minimum_size)
		else:
			custom_minimum_size.y = 32
	, CONNECT_ONE_SHOT)


func _on_pressed() -> void:
	var scene = get_tree().current_scene
	if scene is not Battle:
		return
	var battle: Battle = scene
	# 判断当前行动的是否是主机玩家
	# ？可能有人要问：鸽子鸽子，那那种在对方回合也可以发动的效果怎么办呀？
	# ！因为不是主机玩家的回合所以说主机玩家也没有第一时间的发动权，
	# ！也就是说不能够在对方什么也没做的时候像自己回合一样发效果，需要时点的
	if battle.host_player_id != battle.current_round_player:
		return
	if battle.in_option:
		return
	
	var check_launch = await behavior_entry.check_launch()
	var check_cost = await behavior_entry.check_cost()

	if !check_launch or !check_cost:
		return
	behavior_entry.launch({
		trigger = (get_tree().current_scene as Battle).host_player_id
	})


func _on_visibility_changed() -> void:
	if visible and behavior_entry:
		set_behavior(behavior_entry)
