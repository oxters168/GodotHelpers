extends AbstractVariantMake
class_name StringMake

var line_edit: LineEdit

func _init():
	line_edit = LineEdit.new()
	line_edit.placeholder_text = "value"
	add_child(line_edit)

func get_value() -> Variant:
	return line_edit.text