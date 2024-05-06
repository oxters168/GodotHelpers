@tool
extends AbstractVariantMake
class_name SignalMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: Signal
	if constructor_index == 1:
		result = Signal(param_makes[0].get_value(), param_makes[1].get_value())
	else:
		result = Signal()
	return result

func get_constructors() -> Array:
	return [
		[],
		[PropertyHelpers.create_property("object", Enums.VariantType.TYPE_OBJECT), PropertyHelpers.create_property("signal", Enums.VariantType.TYPE_STRING_NAME)],
	]