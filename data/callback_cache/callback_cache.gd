extends Node
class_name CallbackCache

var caches = {}

var card_info_show_method = null
var area_info_show_method = null

@rpc("any_peer", "call_remote", "reliable")
func call_cache(id, args) -> Variant:
	var c = caches.get(id)
	if c is Callable:
		return await c.call(args)
	if c is LuaFunction:
		return await ModManager.LuaAwaitWrapper.create_starter(c, args)
	return null
