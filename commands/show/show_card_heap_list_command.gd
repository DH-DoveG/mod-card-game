extends Command
class_name ShowCardHeapListCommand

func execute() -> void:
	# 参数检查
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("card") and typeof(_args["card"]) != TYPE_STRING:
		return
	if not _args.has("pos") and typeof(_args["pos"]) != TYPE_VECTOR2:
		return

	var cid = _args["card"]

	var area = GApiManager.card_api.get_area(cid)

	var battle: Battle = Utils.get_current_scene()
	var heap = []
	var title = ""
	if area["area_id"] == null:
		var _pid = GApiManager.card_api.get_ownership(cid)

	else:
		area = FindUtils.find_area(area["area_id"])
		if area:
			heap = GApiManager.area_api.get_heap(area.name)
			title = area.name

	if heap.size() > 1:
		# 显示列表
		battle.get_node("./UI/CardMiniList").update({
			"title": title,
			"list": heap,
			"show": true
		})
		return

	FindUtils.find_card(cid).trigger_behavior_menu()

func undo() -> void:
	pass
