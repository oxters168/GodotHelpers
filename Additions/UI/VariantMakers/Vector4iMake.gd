@tool
extends Vector3iMake
class_name Vector4iMake

var w_input: IntMake
var w_label: Label

func _init():
	super._init()
	w_label = Label.new()
	w_label.text = "w"
	w_label.add_theme_color_override("font_color", Color.SKY_BLUE)
	w_input = IntMake.new()
	_h_panel.add_child(w_label)
	_h_panel.add_child(w_input)

func get_value() -> Variant:
	return Vector4i(x_input.get_value(), y_input.get_value(), z_input.get_value(), w_input.get_value())