extends Entity
class_name Player

var bt_agent_id = ""
var bt_table = null

var use_deck_config: Dictionary = {}
var player_name: String = ""
var id = null
var use_card_back = "DEFAULT_CARD_BACK" # 默认卡背资源ID
var player_avatar = "DEFAULT_AVATAR"

var round_timer_out_callback_rpc_id: int = 0
var round_timer_out_callback: String = ""
var round_timer_out = 120 # 轮次超时时间，单位秒

signal time_update(int)

@rpc("any_peer", "call_local", "reliable")
func set_timeout(timeout: int):
	round_timer_out = timeout
	time_update.emit(round_timer_out)

var _timer_active: bool = false
var _timer_node: Timer = null

func set_time(_key: bool):
	if _key:
		_timer_active = true
		if _timer_node == null:
			_timer_node = Timer.new()
			_timer_node.wait_time = 1.0
			_timer_node.timeout.connect(_on_timer_tick)
			Utils.get_current_scene().add_child(_timer_node)
			_timer_node.start()
			time_update.emit(round_timer_out)
	else:
		_timer_active = false
		if _timer_node:
			_timer_node.stop()
			_timer_node.queue_free()
			_timer_node = null

func _on_timer_tick():
	if not _timer_active:
		return
	round_timer_out -= 1
	time_update.emit(round_timer_out)
	if round_timer_out <= 0:
		_timer_active = false
		_timer_node.stop()
		_timer_node.queue_free()
		_timer_node = null
		if round_timer_out_callback != "":
			var battle = Utils.get_current_scene()
			if battle and battle.callback_cache:
				var cal = battle.callback_cache.caches.get(round_timer_out_callback)
				if cal:
					cal.call(null)

func set_info(param: Dictionary) -> void:
	id = param["uid"] # 玩家ID（唯一标识符，数字）
	player_name = param["name"]
	player_avatar = param["avatar"]

func start_round() -> Variant:
	return null

func end_round() -> Variant:
	return null

func event_processing(_param) -> Variant:
	return null

func interaction_processing(_param) -> Variant:
	return null
