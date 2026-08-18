extends Node
class_name CoreRoundApi


@rpc("any_peer", "call_local", "reliable")
func set_current(round_num: int, player_id: String) -> void:
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	if player_id.is_empty():
		return
	if round_num != -1:
		battle.round_num = round_num
	if not player_id.is_empty():
		battle.current_round_player = player_id
	#scene.get_node("UI/RoundInfo").update()
	scene.get_node("UI/PlayerPanel").update(null)


@rpc("any_peer", "call_local", "reliable")
func set_action_sequence(list, index) -> void:
	print("[CORE] 1 SET ACTION SEQUENCE: ", list, " -- ", index)
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	print("[CORE] 2 SET ACTION SEQUENCE: ", list, " -- ", index)
	if list:
		battle.round_action_sequence = list
	if index:
		battle.round_index = index % battle.round_action_sequence.size()
	#scene.get_node("UI/RoundInfo").update()


@rpc("any_peer", "call_local", "reliable")
func start_round(player_id: String) -> void:
	var battle: Battle = get_tree().current_scene
	if battle.host_player_id == player_id:
		battle.in_option = false
	else:
		battle.in_option = true
