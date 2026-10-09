extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var state := LuaState.new()
	state.open_libraries(LuaState.ALL_LIBS)
	
	state.globals["CALL_CORE_AWAIT"] = state.create_function(func():
		return get_tree().create_timer(2).timeout
	)
	
	state.do_string("""
	DDD = function()
		print("DDD")
	end
	""")
	
	var debug_info_CORE = state.globals["CALL_CORE_AWAIT"].get_debug_info()
	var debug_info_MOD = state.globals["DDD"].get_debug_info()
	print(debug_info_CORE.get_what())
	print(debug_info_MOD.get_what())
	
	# PASS
	# 通过在定义时包含到 coroutine.create 内
#	var a = state.do_string("""
#	return coroutine.create(function()
#		local function local_func()
#			await(CALL_CORE_AWAIT())
#		end
#		
#		print(1)
#		await(CALL_CORE_AWAIT())
#		print(2)
#		local_func()
#		print(3)
#	end)
#	""")
#	if a is LuaCoroutine:
#		a.resume()
	
	# PASS
	# 通过在调用方使用 LuaCoroutine 来调用方法
#	var a = state.do_string("""
#	local function local_func()
#		await(CALL_CORE_AWAIT())
#	end
#	
#	return function()
#		print(1)
#		await(CALL_CORE_AWAIT())
#		print(2)
#		local_func()
#		print(3)
#	end
#	""")
#	if a is LuaFunction:
#		var b := LuaCoroutine.create(a)
#		b.resume()

#	var a  = state.do_string("""
#		local a = {}
#		print(1)
#		if a.index then
#			print(2)
#		end
#		print(3)
#	""")
#	print("A: ", a)

	#var a = state.do_string("""
		#--return {1, 2} -- Returns Table
		#return 1, 2 -- Returns Array
	#""")
	#print(a)
