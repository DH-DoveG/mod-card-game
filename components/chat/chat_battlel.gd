extends Control


var on_off_state = false


func _on_on_off_pressed() -> void:
	on_off_state = !on_off_state
	$ColorRect.visible = on_off_state


func _on_line_edit_text_submitted(new_text: String) -> void:
	rpc("update_message", GNetManager.uid, new_text)
	$ColorRect/LineEdit.clear()

@rpc("any_peer", "call_local", "reliable")
func update_message(uid, message) -> void:
	$ColorRect/RichTextLabel.append_text("【%s】：%s\n" % [ GNetManager.players[uid]["nick"], message ])
