extends CustomDialog


func set_value(param: Dictionary) -> void:
	
	var win_names = []
	for id in param["wins"]:
		win_names.append(FindUtils.find_player(id).player_name)
	var lose_names = []
	for id in param["loses"]:
		lose_names.append(FindUtils.find_player(id).player_name)
	
	$Dialog/Detail.text = """
本场游戏胜负已分

胜
%s


败
%s
""" % [str(win_names), str(lose_names)]


func _on_button_pressed() -> void:
	select_clicked.emit()
