extends AbstractVariantMake
class_name FloatMake

var line_edit: RegExLineEdit

func _init():
	line_edit = RegExLineEdit.new(Constants.REG_EX_FLOAT)
	line_edit.placeholder_text = "value"
	line_edit.set_text_wregex("0")
	add_child(line_edit)

func get_value() -> Variant:
	return type_convert(line_edit.text, TYPE_FLOAT) as float