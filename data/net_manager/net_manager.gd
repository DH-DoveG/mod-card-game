extends Node


var address: String = ""
var port: int = 11451
var max_players: int = 24

# 游戏状态
# GAMEPLAY 游戏中
# PVPROOM 房间中
# 这个游戏状态用于给后来的人指明要跳转到的位置
enum GameStatus {
	ROOM,
	GAMEPLAY
}
var game_status = GameStatus.ROOM

var players = {}
var player_info = {
	"nick": "",
	"avatar": "DEFAULT_AVATAR",
	"card_back": "DEFAULT_CARD_BACK"
}
var uid = 0

#var in_create_client = false
#signal create_client_result

signal add_player(id)
signal remove_player(id)
signal be_finished(k)


func _ready() -> void:
	
	## 客户端
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
	#multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
	## 共用（主机和客户端都会收到通知）
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	#multiplayer.peer_connected.connect(_on_peer_connected)
	pass


func close():
	multiplayer.multiplayer_peer = null


func clear():
	players = {}


func be_connect(mode: String, info: Dictionary, _port, _address):
	port = _port
	address = _address
	
	# print("port: ", port)
	# print("address: ", address)
	
	if mode == "Client":
		be_client(info)
		return await be_finished
	if mode == "Server":
		return be_host(info)



# 成为主机
func be_host(info: Dictionary) -> bool:
	close()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)
	if error != OK:
		return false
	#assert(error == OK, "服务器建立失败")
	multiplayer.multiplayer_peer = peer
	
	# 主机的 unique id 固定是 0
	set_player_info(info)
	# 因为主机的 unique id 固定是 1，所以直接把自己添加进 players 中即可
	players[1] = player_info
	uid = 1
	
	return true


# 成为客户端
func be_client(info: Dictionary):
	close()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	set_player_info(info)


func set_player_info(info: Dictionary):
	if !info["nick"] or info["nick"].strip_edges() == "":
		info["nick"] = "PLAYER_" + str(multiplayer.get_unique_id())
	player_info["nick"] = info["nick"]
	player_info["avatar"] = info["avatar"]
	player_info["card_back"] = info["card_back"]


func _on_server_disconnected():
	var scene = Utils.get_current_scene()
	if scene is Battle:
		# 如果是在战斗场景，而此时连接断开了那么需要退出场景
		# TODO
		pass
	pass # 服务器断开
	printerr("[Net Server][%s] 服务器断开" % uid)


func _on_connection_failed():
	# 这里是客户端连接时的失败信号，这里只需要提示一下用户即可
	pass # 连接失败
	be_finished.emit(false)
	printerr("[Net Server] 连接失败")


func _on_connected_to_server():
	# 这里是客户端连接时的成功信号，这里只需要提示一下用户并且跳转到战斗场景
	# 因为我们是客户端，所以我们这里才确定了自己的ID是多少
	# 知道ID后即可将自己放入 players 中了
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	uid = peer_id
	pass # 连接到服务器
	be_finished.emit(true)
	print("[Net Server] 连接成功")


func _on_peer_disconnected(id: int):
	remove_player.emit(id)
	players.erase(id)
	print("[Net Server] 断开连接：", id)


func _on_peer_connected(id: int):
	# 当有人连接成功后，需要将其发送自己的信息
	# 这个会让所有人都接收到
	# rpc_id 可以向指定ID的发送信息
	_register_player.rpc_id(id, player_info)
	print("[Net Server] 连接建立：", id)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	# 需要注意的是，对于 await 这类的延迟执行的函数可能调用这个方法不会获得正确的 id
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	add_player.emit(new_player_id)
