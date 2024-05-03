extends Vector2iMake
class_name Vector3iMake

var z_input: IntMake
var z_label: Label

func _init():
	super._init()
	z_label = Label.new()
	z_label.text = "z"
	z_label.add_theme_color_override("font_color", Color.SLATE_BLUE)
	z_input = IntMake.new()
	_h_panel.add_child(z_label)
	_h_panel.add_child(z_input)

func get_value() -> Variant:
	return Vector3i(x_input.get_value(), y_input.get_value(), z_input.get_value())