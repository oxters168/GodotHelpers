class_name ScriptHelpers

## Retrieves the global autoload node if it exists, otherwise prints an error and returns null
static func get_global_autoload(name: String) -> Node:
	return Engine.get_main_loop().root.get_node(name)

## Finds the script with the given class name in [ProjectSettings.get_global_class_list()] then loads
## the path listed if found and returns the loaded [GDScript], otherwise returns null
static func load_script(clazz_name: String) -> GDScript:
	var path: String = ""
	var class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for class_info in class_list:
		if class_info["class"] == clazz_name:
			path = class_info["path"]
	return null if path.is_empty() else load(path)