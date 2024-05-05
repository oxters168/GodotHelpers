@tool
extends AbstractVariantMake
class_name Rect2iMake

var pos_input: Vector2iMake
var size_input: Vector2iMake

func _init():
	pos_input = Vector2iMake.new()
	size_input = Vector2iMake.new()
	size_input.x_label.text = "w"
	size_input.y_label.text = "h"

	var v_panel: VBoxContainer = VBoxContainer.new()
	v_panel.add_child(pos_input)
	v_panel.add_child(size_input)
	add_child(v_panel)

func get_value() -> Variant:
	return Rect2i(pos_input.get_value(), size_input.get_value())