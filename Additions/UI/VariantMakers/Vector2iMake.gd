@tool
extends AbstractVariantMake
class_name Vector2iMake

var x_input: IntMake
var y_input: IntMake
var x_label: Label
var y_label: Label
var _h_panel: HBoxContainer

func _init():
	x_label = Label.new()
	x_label.add_theme_color_override("font_color", Color.PALE_VIOLET_RED)
	x_label.text = "x"
	x_input = IntMake.new()

	y_label = Label.new()
	y_label.add_theme_color_override("font_color", Color.PALE_GREEN)
	y_label.text = "y"
	y_input = IntMake.new()

	_h_panel = HBoxContainer.new()
	_h_panel.add_child(x_label)
	_h_panel.add_child(x_input)
	_h_panel.add_child(y_label)
	_h_panel.add_child(y_input)
	add_child(_h_panel)

func get_value() -> Variant:
	return Vector2i(x_input.get_value(), y_input.get_value())