@tool
extends AbstractVariantMake
class_name Transform2DMake

@export var constructor_index: int
var param_makes: Array[AbstractVariantMake] = []

func _init(_constructor_index: int):
	constructor_index = _constructor_index
	# print_debug(PropertyHelpers.to_func_signature(get_constructors()[constructor_index]))
	_refresh_view()

func _clear_view():
	for child in get_children():
		remove_child(child)
		child.queue_free()
func _refresh_view():
	_clear_view()

	var v_panel: VBoxContainer = VBoxContainer.new()
	param_makes.clear()
	for param in get_constructors()[constructor_index]:
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

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Transform2D
	if constructor_index == 1:
		result = Transform2D(param_makes[0].get_value(), param_makes[1].get_value())
	elif constructor_index == 2:
		result = Transform2D(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value(), param_makes[3].get_value())
	elif constructor_index == 3:
		result = Transform2D(param_makes[0].get_value(), param_makes[1].get_value(), param_makes[2].get_value())
	else:
		result = Transform2D()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("rotation", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("position", Enums.VariantType.TYPE_VECTOR2)],
		[PropertyHelpers.create_property("rotation", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("scale", Enums.VariantType.TYPE_VECTOR2), PropertyHelpers.create_property("skew", Enums.VariantType.TYPE_FLOAT), PropertyHelpers.create_property("position", Enums.VariantType.TYPE_VECTOR2)],
		[PropertyHelpers.create_property("x_axis", Enums.VariantType.TYPE_VECTOR2), PropertyHelpers.create_property("y_axis", Enums.VariantType.TYPE_VECTOR2), PropertyHelpers.create_property("origin", Enums.VariantType.TYPE_VECTOR2)]
	]
