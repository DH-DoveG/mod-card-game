extends Page


@onready var title = $Title


func _init() -> void:
	page_id = "INDEX_PAGE"


func _ready() -> void:
	super()
	
	if ConfigManager.page_index_title.is_empty():
		title.text = "Mod Card"
	else:
		title.text = ConfigManager.page_index_title
	# 这里断开网络连接
	multiplayer.multiplayer_peer = null


# mod 页
func _on_mod_pressed() -> void:
	AsyncScene.new(
		"res://pages/mod_page/mod_page.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


# 退出游戏
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_game_pressed() -> void:
	AsyncScene.new(
		"res://pages/battle_mode/battle_mode.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_deck_pressed() -> void:
	AsyncScene.new(
		"res://pages/deck_editor/deck_editor.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_pack_pressed() -> void:
	AsyncScene.new(
		"res://pages/pack_page/pack_page.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_setting_pressed() -> void:
	AsyncScene.new(
		"res://pages/setting_page/setting_page.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_resource_pressed() -> void:
		AsyncScene.new(
		"res://pages/resource_show/resource_show.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()
