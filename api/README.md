mod/ 用于注册和存放lua可调用的方法，他接收到的参数会是 LuaTable 对象
	 但因 rpc 不可传递 LuaTable，所以需要转换格式，然后调用 core 的对应API

core/ 这里面的库需要能够调用 rpc 进行调用传递
