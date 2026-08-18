extends VBoxContainer


@onready var message = $Message/TextEdit
@onready var input_line = $Input/LineEdit


func emit_message(context: String) -> void:
	rpc("_rpc_emit_message", context.strip_edges())


func add_local_message(context: String) -> void:
	message.add_text(context.strip_edges() + "\n")


@rpc("any_peer", "call_local", "reliable")
func _rpc_emit_message(context: String) -> void:
	var id = multiplayer.get_remote_sender_id()
	if id == 0:
		message.add_text("<提示>: " + context + "\n")
	else:
		message.add_text("【" + GNetManager.players[id].nick + "】：" + context + "\n")


func _on_sumbit_pressed() -> void:
	var context: String = input_line.text.strip_edges()
	input_line.clear()
	emit_message(context)
