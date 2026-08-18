extends Panel


@onready var round_num: Label = $VBox/Num
@onready var current_player_name: Label = $VBox/CurrentVBox/CurrentPlayerName
@onready var next_player_name: Label = $VBox/NextVBox/NextPlayerName
@onready var btn = $VBox/MC/Btn

# 此按钮点击后可以选择要进入的阶段
# 参考md有一个弹窗
func _on_btn_pressed() -> void:
	var scene = get_tree().current_scene
	if scene is not Battle:
		return
	
	var battle: Battle = scene
	# 判断当前行动的是否是主机玩家
	if battle.host_player_id != battle.current_round_player:
		return
	
	if battle.in_option:
		return
	
	btn.disabled = true
	
	var player = FindUtils.find_player(battle.host_player_id)
	player.end_round()
	
	# 这里应该获取到数据判断当前的阶段状态
	get_tree().create_timer(0.5).timeout.connect(func():
		btn.disabled = false
	, ConnectFlags.CONNECT_ONE_SHOT)


#func _process(_delta: float) -> void:
func update() -> void:
	var battle: Battle = get_parent().get_parent()
	
	if not battle: return
	
	round_num.text = "第 " + str(battle.round_num) + " 回合"
	
	if battle.round_action_sequence.is_empty():
		return
	
	var current = battle.current_round_player
	var next
	if battle.round_index == 0:
		next = battle.round_action_sequence[battle.round_index]
	else:
		next = battle.round_action_sequence[battle.round_index % battle.round_action_sequence.size()]
	
	if not current.is_empty():
		current_player_name.text = FindUtils.find_player(current).player_name
	if not next.is_empty():
		next_player_name.text = FindUtils.find_player(next).player_name
	
	if battle.host_is_audience: return
	if battle.host_player.name == current:
		self_modulate = Color("#60ffff")
	else:
		self_modulate = Color("#FFF")
