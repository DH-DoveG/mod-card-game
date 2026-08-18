# 持久化工具
extends Object
class_name PersistenceUtils


## 在不同的平台下使用不同的路径
## 对于在 Windows 平台下，使用的目录应当是与程序同一级别的目录（不污染其他目录）
## 对于像 Windows 这样的系统，不应该使用 %APPDATA% 等目录，而应当使用与程序同一级别的目录
static func get_exec_path() -> String:
	if OS.get_name() == "Windows":
		return OS.get_executable_path().get_base_dir()
	return OS.get_user_data_dir()


static func find_file(file_path: String, file_name: String) -> bool:
	return FileAccess.file_exists(get_exec_path().path_join(file_path).path_join(file_name))


## 创建文件（文件路径是相对于 user:// 的路径，传入时应当不带 user:// 并且不应该由 / 符号作路径开头）
static func make_file(file_path: String, file_name: String) -> FileAccess:
	DirAccess.make_dir_recursive_absolute(get_exec_path().path_join(file_path))
	return FileAccess.open(get_exec_path().path_join(file_path).path_join(file_name), FileAccess.WRITE)


static func folder_all_files(file_path: String) -> Array:
	var path = get_exec_path().path_join(file_path)
	if DirAccess.dir_exists_absolute(path):
		var dir = DirAccess.open(path)
		return dir.get_files()
	return []


## 创建目录（目录路径是相对于 user:// 的路径，传入时应当不带 user:// 并且不应该由 / 符号作路径开头）
## 返回值不为 OK 时即为失败
static func make_folder(file_path: String) -> int:
	return DirAccess.make_dir_recursive_absolute(get_exec_path().path_join(file_path))


## 打开文件（文件路径是相对于 user:// 的路径，传入时应当不带 user:// 并且不应该由 / 符号作路径开头）
static func open_file(file_path: String) -> FileAccess:
	if not DirAccess.dir_exists_absolute(get_exec_path().path_join(file_path.get_base_dir())):
		make_folder(file_path.get_base_dir()) 
	if FileAccess.file_exists(get_exec_path().path_join(file_path)):
		return FileAccess.open(get_exec_path().path_join(file_path), FileAccess.READ_WRITE) # 读写，会先读再写，只适合文件已经存在的情况
	return FileAccess.open(get_exec_path().path_join(file_path), FileAccess.WRITE_READ) # 写读，会先写再读，如果没有这个文件会创建，如果有会覆盖内容（表现为打开后空白内容）
