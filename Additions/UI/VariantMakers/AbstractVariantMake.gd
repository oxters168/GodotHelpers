@tool
extends PanelContainer
class_name AbstractVariantMake

@export var constructor_index: int:
	set(value):
		constructor_index = value
		_refresh_view(value)
var param_makes: Array[AbstractVariantMake] = []

func _validate_property(property):
	if property.name == "constructor_index":
		property.hint = PROPERTY_HINT_ENUM
		var hint_string = get_constructors().map(func(properties): return PropertyHelpers.to_func_signature(properties).replace(",", " |"))
		property.hint_string = PropertyHelpers.to_enum_hint_string(hint_string)
		property.usage = PROPERTY_USAGE_DEFAULT if get_constructors().size() > 1 else PROPERTY_USAGE_NONE
func _init():
	_refresh_view(constructor_index)

func get_value() -> Variant:
	return null
func get_constructors() -> Array:
	return []

func _clear_view():
	for child in get_children():
		remove_child(child)
		child.queue_free()
func _refresh_view(index: int):
	if index >= 0 && index < get_constructors().size():
		_clear_view()

		var v_panel: VBoxContainer = VBoxContainer.new()
		param_makes.clear()
		for param in get_constructors()[index]:
			var label: Label = Label.new()
			label.text = param.name
			var param_make: VariantMake = VariantMake.new()
			param_make.set_type_from_property(param)
			param_make.show_type_picker = false
			param_makes.append(param_make)
			var h_panel: HBoxContainer = HBoxContainer.new()
			h_panel.add_child(label)
			h_panel.add_child(param_make)
			v_panel.add_child(h_panel)
			
		add_child(v_panel)