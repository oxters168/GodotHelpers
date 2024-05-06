@tool
extends AbstractVariantMake
class_name PackedInt32ArrayMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: PackedInt32Array = PackedInt32Array()
	return result