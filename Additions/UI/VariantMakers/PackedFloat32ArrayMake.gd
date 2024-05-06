@tool
extends AbstractVariantMake
class_name PackedFloat32ArrayMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: PackedFloat32Array = PackedFloat32Array()
	return result