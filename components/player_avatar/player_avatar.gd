extends ColorRect
class_name PlayerAvatar

@onready var icon: TextureRect = $HBox/IconBox/Icon
@onready var nickname: Label = $HBox/Info/Nickname
@onready var value = $HBox/Info/Value

var use_player: Player = null

func set_player(player: Player) -> void:
	use_player = player
	icon.texture = GResourceManager.get_image_resoure(player.player_avatar)
	nickname.text = player.player_name
	use_player.time_update.connect(func(sec):
		$RoundTime/Label.text = str(sec) + "s"
	)

func update() -> void:
	if not is_instance_valid(use_player): return

	nickname.text = use_player.player_name

	# BUG: 这一部分会导致性能与占用急剧下滑？
	#      也有可能是 values
	var entity: Entity = use_player
		# 先只做最简单的拼接工作
	var value_str = PackedStringArray()

	# 如果当前回合是
	var battle: Battle = Utils.get_current_scene()
	if battle.current_round_player == use_player.name:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "offset_transform_position:x", 72, 0.2)
		$NeoOutline.show()
		$State.hide()

	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "offset_transform_position:x", 0, 0.2)
		$NeoOutline.hide()
		if battle.round_num != 0:
			$State.show()

	for k in entity.values:
		var _value: Value = entity.values[k]
		if _value.config == null:
			continue
		# 获取各属性
		var __on_area_show_enable = _value.config["show_enable"] if _value.config.has("show_enable") else false
		if not __on_area_show_enable:
			continue
		pass
		var __on_area_show_color = _value.config["show_color"] if _value.config.has("show_color") else Color("#FFF")
		var __on_area_show_prefix = _value.config["show_prefix"] if _value.config.has("show_prefix") else ""
		var __value = _value.get_value(use_player.name)
				##__value = _value["config"]["dynmic_get"].invoke(use_player.name, LuaUtils.dictionary_to_table(_value))

		value_str.append(__on_area_show_prefix + str(__value) )

	value.text = "/".join(value_str)
