extends TextureButton

@export var back_page = "res://pages/index.tscn"
@export var args = {}
@export var mount: Node

func _on_pressed() -> void:
	AsyncScene.new(
		back_page,
		AsyncScene.LoadingOperation.ReplaceImmediate,
		mount
	) \
	.with_parameters(args) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("4a2724ff")) \
	.start()
