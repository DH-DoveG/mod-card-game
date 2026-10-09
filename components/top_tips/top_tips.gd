extends ColorRect

@onready var title_label: Label = $Title

func set_text(text: String) -> void:
	title_label.text = text
