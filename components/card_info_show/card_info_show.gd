extends Node3D


@onready var card_image: Sprite3D = $CardImage
@onready var card_name: Label3D = $CardName
@onready var card_value: Label3D = $CardValue

var user: CardEntity = null

func _ready() -> void:
	# user = get_parent()
	GNetManager.game_status = GNetManager.GameStatus.ROOM
	Utils.get_current_scene().event_manager.subscribe("BATTLE_VISUAL_ANGLE_CHANGED", _battle_visual_angle_changed)


#！！！需要一个检测办法
#1. 需要在场上
#2. 需要正面朝上
func update() -> void:
	if not user:
		return
	if not Utils.is_battle_scene():
		hide()
		return
	if not user.is_front:
		hide()
		return
	var battle: Battle = Utils.get_current_scene()
	update_value()
	for key in battle.battle_data_bind_list.area_bind_cards:
		if user.name in battle.battle_data_bind_list.area_bind_cards[key]:
			var pid = ""
			for k in battle.battle_data_bind_list.player_bind_cards_of_controller:
				if user.name in battle.battle_data_bind_list.player_bind_cards_of_controller[k]:
					pid = k
					break
			var camp = ""
			for k in battle.battle_data_bind_list.camp_bind_players:
				if pid in battle.battle_data_bind_list.camp_bind_players[k]:
					camp = k
					break
			var color = Color("#fc4646") if camp == "RED" else Color("#7eabff")
			card_name.modulate = color
			show()
			return
	hide()


# x= -180 y=90  →
# x= -90 y=0  ↑
# x= 90 y=180  ↓
# x= 0 y=-90  ←
func _battle_visual_angle_changed(_arg: Dictionary) -> void:
	if not visible: return
	
	var visual_angle: Vector2i = _arg.visual_angle
	var camera = _arg.camera
	
	var euler_angles = Vector3.ZERO
	match Utils.calibration_direction(user.rotation_degrees.y):
		-180: euler_angles = Vector3(0, -90, 0)
		-90: euler_angles = Vector3(0, 0, 0)
		90: euler_angles = Vector3(0, 180, 0)
		0: euler_angles = Vector3(0, -90, 0)
	
	rotation_degrees = euler_angles
	
	match visual_angle:
		Vector2i.DOWN:
			card_image.position = Vector3(-0.32, 0.22, -0.065)
			card_name.position = Vector3(0.1, 0.24, 0)
			card_value.position = Vector3(0.40, 0.24, 0)
		Vector2i.LEFT:
			card_image.position = Vector3(-0.065, 0.22, 0.32)
			card_name.position = Vector3(0, 0.24, -0.1)
			card_value.position = Vector3(0, 0.24, -0.40)
		Vector2i.UP:
			card_image.position = Vector3(0.32, 0.22, 0.065)
			card_name.position = Vector3(-0.1, 0.24, 0)
			card_value.position = Vector3(-0.40, 0.24, 0)
		Vector2i.RIGHT:
			card_image.position = Vector3(0.065, 0.22, -0.32)
			card_name.position = Vector3(0, 0.24, 0.1)
			card_value.position = Vector3(0, 0.24, 0.40)
	
	card_image.global_rotation = camera.global_rotation
	card_name.global_rotation = camera.global_rotation
	card_value.global_rotation = camera.global_rotation


# 待修复
func adjust_card_rotation() -> void:
	if not visible: return
	var scene = Utils.get_current_scene()
	if scene is not Battle:
		return
	var battle: Battle = scene
	_battle_visual_angle_changed({
		"camera": battle.scene.camera,
		"visual_angle": battle.visual_angle
	})


func update_value() -> void:
	if not user:
		return

	# 先只做最简单的拼接工作
	var value_str = PackedStringArray()

	for k in user.entity.value_manager:
		var value = user.entity.value_manager[k]
		if value.config == null:
			continue
		# 获取各属性
		var __on_area_show_enable = value.config["show_enable"] if value.config.has("show_enable") else false
		if not __on_area_show_enable:
			continue
		pass
		var __on_area_show_color = value.config["show_color"] if value.config.has("show_color") else Color("#FFF")
		var __on_area_show_prefix = value.config["show_prefix"] if value.config.has("show_prefix") else ""
		var v = value.get_value(GApiManager.card_api.get_controller(user.name))
		value_str.append(__on_area_show_prefix + str(v) )
	
	card_value.text = "/".join(value_str)
