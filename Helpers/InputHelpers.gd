class_name InputHelpers

## If set to true will make the mouse invisible and trapped by the godot game window and when set to false returns the mouse to normal
static func block_mouse_input(enabled: bool):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE)
	
## Gets the input action name from the input map actions ([member InputMap.get_actions()]) with the given [param index]
static func get_input_action(index: int, load_from_project_settings: bool = true) -> String:
	if load_from_project_settings:
		InputMap.load_from_project_settings()
	var actions: Array[StringName] = InputMap.get_actions()
	return actions[index]