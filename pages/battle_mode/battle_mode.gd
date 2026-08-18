extends Page


func _init() -> void:
	page_id = "BATTLE_MODE_PAGE"

func _ready() -> void:
	super()
	# print(Utils.get_scene_tree().current_scene)


func on_scene_loaded(__) -> void:
	# print("1:", Utils.get_scene_tree().current_scene)
	pass


# TODO 点击PVE后，进入PVE的准备页面，这里可以选择要对战的Robot并且可以选择卡组
func _on_pve_pressed() -> void:
	AsyncScene.new(
		"res://pages/pve_ready/pve_ready.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_close_pressed() -> void:
	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_pvp_pressed() -> void:
	AsyncScene.new(
		"res://pages/multiplayer_hall/multiplayer_hall.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_story_pressed() -> void:
	pass # Replace with function body.
