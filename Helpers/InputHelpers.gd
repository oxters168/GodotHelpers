class_name InputHelpers

## If set to true will make the mouse invisible and trapped by the godot game window and when set to false returns the mouse to normal
static func block_mouse_input(enabled: bool):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE)