@tool
extends AbstractVariantMake
class_name ObjectMake

@export var clazz: String:
	set(value):
		clazz = value
		_refresh_view(constructor_index)

# to stop auto refresh since by default clazz will be null
func _init():
	pass

func get_value() -> Variant:
	return ObjectMake.call_init(clazz, param_makes.map(func(param_make): return param_make.get_value()))

func get_constructors() -> Array:
	var constructors: Array = []
	var methods: Array
	if ClassDB.class_exists(clazz):
		methods = ClassDB.class_get_method_list(clazz)
	else:
		methods = load(clazz).get_script_method_list()

	methods = methods.filter(func(method): return method.name == "_init")
	for method in methods:
		constructors.append(method.args)

	return constructors

static func call_init(_clazz: String, params: Array) -> Variant:
	var obj: Variant
	if ClassDB.class_exists(_clazz):
		obj = ClassDB.instantiate(_clazz)
	else:
		# I know, this is very hacky, but until we can pass arrays as varargs, this is the only way I can think of
		if params.size() == 0:
			obj = load(_clazz).new()
		elif params.size() == 1:
			obj = load(_clazz).new(params[0])
		elif params.size() == 2:
			obj = load(_clazz).new(params[0], params[1])
		elif params.size() == 3:
			obj = load(_clazz).new(params[0], params[1], params[2])
		elif params.size() == 4:
			obj = load(_clazz).new(params[0], params[1], params[2], params[3])
		elif params.size() == 5:
			obj = load(_clazz).new(params[0], params[1], params[2], params[3], params[4])
		elif params.size() == 6:
			obj = load(_clazz).new(params[0], params[1], params[2], params[3], params[4], params[5])
		elif params.size() == 7:
			obj = load(_clazz).new(params[0], params[1], params[2], params[3], params[4], params[5], params[6])
		elif params.size() == 8:
			obj = load(_clazz).new(params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7])
		elif params.size() == 9:
			obj = load(_clazz).new(params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
	return obj