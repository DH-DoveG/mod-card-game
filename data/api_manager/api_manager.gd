extends Node
#class_name ApiManager

# 这个需要自动加载，并且他的作用只是为了将API挂载在场景树上而已
# 挂载后就可以 rpc 调用了，主要因为不同机子，对象的内存分布也不一样，收益通过节点数来找

var area_api: CoreAreaApi = null
#var animate_api: CoreAnimateApi = null
var async_api: CoreAsyncApi = null

var behavior_api: CoreBehaviorApi = null

var callback_api: CoreCallbackApi = null
var card_api: CoreCardApi = null
var card_set_api: CoreCardSetApi = null

var entity_api: CoreEntityApi = null

var game_api: CoreGameApi = null

var id_api: CoreIdApi = null
var interaction_api: CoreInteractionApi = null

var player_api: CorePlayerApi = null

var resource_api: CoreResourceApi = null
var round_api: CoreRoundApi = null
var rule_api: CoreRuleApi = null

var tag_api: CoreTagApi = null
#var timer_api: CoreTimerApi = null
#var toast_api: CoreToastApi = null

var view_api: CoreViewApi = null
var value_api: CoreValueApi = null



func _ready() -> void:
	
	area_api = CoreAreaApi.new()
	area_api.name = "AreaApi"
	add_child(area_api)
	#animate_api = CoreAnimateApi.new()
	#animate_api.name = "AnimateApi"
	#add_child(animate_api)
	async_api = CoreAsyncApi.new()
	async_api.name = "AsyncApi"
	add_child(async_api)

	behavior_api = CoreBehaviorApi.new()
	behavior_api.name = "BehaviorApi"
	add_child(behavior_api)

	callback_api = CoreCallbackApi.new()
	callback_api.name = "CallbackApi"
	add_child(callback_api)

	card_api = CoreCardApi.new()
	card_api.name = "CardApi"
	add_child(card_api)
	card_set_api = CoreCardSetApi.new()
	card_set_api.name = "CardSetApi"
	add_child(card_set_api)

	entity_api = CoreEntityApi.new()
	entity_api.name = "EntityApi"
	add_child(entity_api)

	game_api = CoreGameApi.new()
	game_api.name = "GameApi"
	add_child(game_api)

	id_api = CoreIdApi.new()
	id_api.name = "IDApi"
	add_child(id_api)
	interaction_api = CoreInteractionApi.new()
	interaction_api.name = "InteractionApi"
	add_child(interaction_api)

	player_api = CorePlayerApi.new()
	player_api.name = "PlayerApi"
	add_child(player_api)

	resource_api = CoreResourceApi.new()
	resource_api.name = "ResourceApi"
	add_child(resource_api)
	round_api = CoreRoundApi.new()
	round_api.name = "RoundApi"
	add_child(round_api)
	rule_api = CoreRuleApi.new()
	rule_api.name = "RuleApi"
	add_child(rule_api)

	tag_api = CoreTagApi.new()
	tag_api.name = "TagApi"
	add_child(tag_api)
	#timer_api = CoreTimerApi.new()
	#timer_api.name = "TimerApi"
	#add_child(timer_api)
	#toast_api = CoreToastApi.new()
	#toast_api.name = "ToastApi"
	#add_child(toast_api)

	view_api = CoreViewApi.new()
	view_api.name = "ViewApi"
	add_child(view_api)
	value_api = CoreValueApi.new()
	value_api.name = "ValueApi"
	add_child(value_api)
