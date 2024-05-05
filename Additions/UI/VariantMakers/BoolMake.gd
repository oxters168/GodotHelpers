@tool
extends AbstractVariantMake
class_name BoolMake

var checkbox: CheckBox
## Do not set this value directly
var _value: bool

func _init():
	checkbox = CheckBox.new()
	checkbox.text = "Disabled"
	checkbox.toggled.connect(func(toggled_on):
		_value = toggled_on
		checkbox.text = "Enabled" if toggled_on else "Disabled"
	)
	add_child(checkbox)

func set_toggled(toggled_on: bool):
	checkbox.toggled.emit(toggled_on)

func get_value() -> Variant:
	return _value