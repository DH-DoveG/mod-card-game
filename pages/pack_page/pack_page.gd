extends Page


# 卡包，可以在这里模拟抽卡说是


var cards = {}


func _init() -> void:
	page_id = "PACK_PAGE"


func _ready() -> void:
	_build_view()


func _build_view() -> void:
	for key in GResourceManager.card_resource:
		var value = GResourceManager.card_resource[key]
		var res = ModManager.do_mod_file(value)
		if res is LuaError:
			ToastUtils.error(res.message)
			continue
		var fun: LuaFunction = res as LuaFunction
		var res2 = fun.invoke()
		if res2 is LuaError:
			ToastUtils.error(res.message)
			continue
		# 取： name    image    type
		var table: LuaTable = res2 as LuaTable
		cards[key] = table.to_dictionary()
	# print(cards)


func _on_close_pressed() -> void:
	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()
