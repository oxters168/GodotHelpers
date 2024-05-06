@tool
extends AbstractVariantMake
class_name PackedStringArrayMake

func get_value() -> Variant:
	# had to brute force it unfortunately, if anyone runs into this and knows an alternative, please let me know
	var result: PackedStringArray = PackedStringArray()
	return result