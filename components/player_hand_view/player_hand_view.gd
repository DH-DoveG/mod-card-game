extends Control


# 需要传入一个玩家作为参数，然后玩家发出卡片的更新信号时就刷新
# 如果手牌数小于等于7，那么启用 "dynamic_radius" 属性
# 否则关闭
# "dynamic_radius_factor": 228.5
# "radius": 1600

var user: String = ""
var bind_card_set = ""

var current_hoverd_card = null

var battle: Battle = null

#TODO: 让特殊配置生效


func set_battle(_battle: Battle):
	battle = _battle
	if battle.host_is_audience: return
	
	user = battle.host_player_id
	battle.event_manager.subscribe("CardSetUpdate", _update)


func _update(args: Dictionary):
	if args["player_id"] != user:
		return
	var sets = args["sets"]
	if sets["config"].has("system_hand_component") and sets["config"]["system_hand_component"] == true:
		update(sets)

func update(sets) -> void:
	var cards = sets["data"][user]
	var now_cards = $Hand.get_children()
	
	for i in range(now_cards.size() - 1, -1, -1):
		if now_cards[i].in_free:
			now_cards.remove_at(i)
	
	var save_cards = []
	var free_card_view_count = 0
	for card in now_cards:
		if str(card.name) in cards:
			save_cards.append(str(card.name))
		else:
			card.animate_free()
			free_card_view_count += 1
	var await_add_cards = []
	for card in cards:
		if card not in save_cards:
			await_add_cards.append(card)
	
	if free_card_view_count == 0 and await_add_cards.size() == 0:
		return
	
	for cid in await_add_cards:
		var ce := FindUtils.find_card(cid)
		
		var view: CardView2D = load("res://components/card_view_2d/card_view_2d.tscn").instantiate()
		view.custom_minimum_size = Vector2(78, 109)
		view.set_card(ce)
		$Hand.add_child(view)
		view.set_menu(true)
		view.set_outline(true)
		view.custom_minimum_size = Vector2(164, 228)
		
	
	if $Hand.get_child_count() >= 7:
		$Hand.dynamic_radius = false
	else:
		$Hand.dynamic_radius = true
