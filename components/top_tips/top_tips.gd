extends ColorRect

@onready var context: LabelAutoSizer = $Context
@onready var run_icon: TextureRect = $RunIcon

func _ready() -> void:
	add_to_group(&"TopTips")

func set_text(text: String) -> void:
	context.text = text

func set_data(config: Dictionary) -> void:
	var tips = get_tree().get_nodes_in_group(&"TopTips")
	for tip in tips:
		if tip != self:
			tip.queue_free()
	context.text = config.get("text", "")
