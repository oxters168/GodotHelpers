@tool
extends AbstractVariantMake
class_name VariantMake

enum TypeType { Primitive, BuiltIn, Custom }
## Types to exclude to make from [enum VariantType] in primitives
const PRIMITIVE_EXCLUSIONS: Array[Enums.VariantType] = [Enums.VariantType.TYPE_NIL, Enums.VariantType.TYPE_OBJECT, Enums.VariantType.TYPE_MAX]

@export var show_type_picker: bool:
	set(value):
		show_type_picker = value
		_tabbed_view.visible = value

signal view_refreshed

var _type_type: int
var _primitive_index: int
var _builtin_index: int
var _custom_index: int

var _constructor_picker: MenuButton
# var _constructor_index: int
var _variant_maker: AbstractVariantMake
var _tabbed_view: TabContainer
var _primitive_opt_btn: OptionButton
var _builtin_opt_btn: OptionButton
var _custom_opt_btn: OptionButton
var _constructor_view: PanelContainer

func _get_property_list():
	var properties: Array = []
	properties.append(PropertyHelpers.create_enum_property("Type_Type", TypeType.keys()))
	var values: Array
	if _type_type == TypeType.Primitive:
		values = VariantMake.get_primitives().map(func(p_type): return type_string(p_type))
	elif _type_type == TypeType.BuiltIn:
		values = Array(ClassDB.get_class_list())
	elif _type_type == TypeType.Custom:
		values = ProjectSettings.get_global_class_list().map(func(clazz): return clazz.class)
	properties.append(PropertyHelpers.create_enum_property("Type", values))
	return properties
func _set(property, value):
	if property == "Type_Type":
		_type_type = value
		notify_property_list_changed()
		_refresh_view(constructor_index)
	if property == "Type":
		if _type_type == TypeType.Primitive:
			_primitive_index = value
		elif _type_type == TypeType.BuiltIn:
			_builtin_index = value
		elif _type_type == TypeType.Custom:
			_custom_index = value
		notify_property_list_changed()
		_refresh_view(constructor_index)
		
func _get(property):
	if property == "Type_Type":
		return _type_type
	if property == "Type":
		if _type_type == TypeType.Primitive:
			return _primitive_index
		elif _type_type == TypeType.BuiltIn:
			return _builtin_index
		elif _type_type == TypeType.Custom:
			return _custom_index

func get_value() -> Variant:
	return _variant_maker.get_value()
static func get_primitives() -> Array:
	var primitives: Array = [] # used to index from the popup menu to VariantType (since some types are excluded)
	for p_type in Enums.VariantType.values():
		if !PRIMITIVE_EXCLUSIONS.has(p_type):
			primitives.append(p_type)
	return primitives

func set_type_from_property(property: Dictionary):
	assert(property.has("type"), "Invalid property given: key 'type' is missing")
	assert(property.type != TYPE_NIL, "Invalid type given: TYPE_NIL")
	assert(property.type != TYPE_MAX, "Invalid type given: TYPE_MAX")

	if property.type == TYPE_OBJECT:
		assert(property.has("class_name"), "Invalid property given: key 'class_name' is missing")
		if ClassDB.class_exists(property.class_name):
			_type_type = TypeType.BuiltIn
			_builtin_index = ClassDB.get_class_list().find(property.class_name)
			_refresh_view(constructor_index)
		else:
			_type_type = TypeType.Custom
			var found_class: bool
			var global_class_list: Array = ProjectSettings.get_global_class_list()
			for i in global_class_list.size():
				if global_class_list[i].path == property.class_name || global_class_list[i].class == property.class_name:
					_custom_index = i
					found_class = true
					break
			if !found_class:
				push_error("Could not find custom class: ", property.class_name)
			_refresh_view(constructor_index)
	else:
		_type_type = TypeType.Primitive
		_primitive_index = VariantMake.get_primitives().find(property.type)
		_refresh_view(constructor_index)

func _init():
	# primitives tab
	var primitives: Array = VariantMake.get_primitives()
	_primitive_opt_btn = UIHelpers.option_btn_wicons(primitives.map(func(p_type): return type_string(p_type)), 0, primitives.map(func(p_type): return EditorInterface.get_editor_theme().get_icon(type_string(p_type), "EditorIcons")))
	_primitive_opt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_primitive_opt_btn.item_selected.connect(func(index):
		constructor_index = 0
		_primitive_index = index
		_refresh_view(constructor_index)
	)
	_primitive_opt_btn.name = "Primitive"

	# built ins tab
	var built_ins: Array = ClassDB.get_class_list()
	_builtin_opt_btn = UIHelpers.option_btn_wicons(built_ins, 0)
	_builtin_opt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_builtin_opt_btn.item_selected.connect(func(index):
		constructor_index = 0
		_builtin_index = index
		_refresh_view(constructor_index)
	)
	_builtin_opt_btn.name = "Built-In"

	# customs tab
	var customs: Array = ProjectSettings.get_global_class_list()
	_custom_opt_btn = UIHelpers.option_btn_wicons(customs.map(func(clazz): return clazz.class), 0)
	_custom_opt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_custom_opt_btn.item_selected.connect(func(index):
		constructor_index = 0
		_custom_index = index
		_refresh_view(constructor_index)
	)
	_custom_opt_btn.name = "Custom"

	_tabbed_view = TabContainer.new()
	_tabbed_view.tab_changed.connect(func(tab_index):
		_type_type = tab_index
		_refresh_view(constructor_index)
	)
	_tabbed_view.add_child(_primitive_opt_btn)
	_tabbed_view.add_child(_builtin_opt_btn)
	_tabbed_view.add_child(_custom_opt_btn)
	_tabbed_view.visible = show_type_picker

	_constructor_view = PanelContainer.new()

	_constructor_picker = MenuButton.new()
	_constructor_picker.size_flags_horizontal = Control.SIZE_SHRINK_END
	_constructor_picker.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_constructor_picker.icon = EditorInterface.get_editor_theme().get_icon("GuiTabMenu", "EditorIcons")
	_constructor_picker.get_popup().index_pressed.connect(func(index):
		constructor_index = index
		_refresh_view(constructor_index)
	)

	var v_panel: VBoxContainer = VBoxContainer.new()
	v_panel.add_child(_tabbed_view)
	v_panel.add_child(_constructor_picker)
	v_panel.add_child(_constructor_view)
	add_child(v_panel)
	
	_refresh_view(constructor_index)

func get_constructors() -> Array:
	return _variant_maker.get_constructors() if _variant_maker != null else []

func _clear_view():
	_variant_maker = null
	for child in _constructor_view.get_children():
		_constructor_view.remove_child(child)
		child.queue_free()
func _refresh_view(index: int):
	_tabbed_view.current_tab = _type_type
	_primitive_opt_btn.select(_primitive_index)
	_builtin_opt_btn.select(_builtin_index)
	_custom_opt_btn.select(_custom_index)

	_clear_view()
	if _type_type == TypeType.Primitive:
		var type_index = VariantMake.get_primitives()[_primitive_index]
		if type_index == TYPE_BOOL:
			_variant_maker = BoolMake.new()
		elif type_index == TYPE_INT:
			_variant_maker = IntMake.new()
		elif type_index == TYPE_FLOAT:
			_variant_maker = FloatMake.new()
		elif type_index == TYPE_STRING:
			_variant_maker = StringMake.new()
		elif type_index == TYPE_VECTOR2:
			_variant_maker = Vector2Make.new()
		elif type_index == TYPE_VECTOR2I:
			_variant_maker = Vector2iMake.new()
		elif type_index == TYPE_RECT2:
			_variant_maker = Rect2Make.new()
		elif type_index == TYPE_RECT2I:
			_variant_maker = Rect2iMake.new()
		elif type_index == TYPE_VECTOR3:
			_variant_maker = Vector3Make.new()
		elif type_index == TYPE_VECTOR3I:
			_variant_maker = Vector3iMake.new()
		elif type_index == TYPE_TRANSFORM2D:
			_variant_maker = Transform2DMake.new()
			_variant_maker.constructor_index = index
		elif type_index == TYPE_VECTOR4:
			_variant_maker = Vector4Make.new()
		elif type_index == TYPE_VECTOR4I:
			_variant_maker = Vector4iMake.new()
		elif type_index == TYPE_PLANE:
			_variant_maker = PlaneMake.new()
			_variant_maker.constructor_index = index
		elif type_index == TYPE_QUATERNION:
			_variant_maker = QuaternionMake.new()
			_variant_maker.constructor_index = index
		elif type_index == TYPE_AABB:
			pass
		elif type_index == TYPE_BASIS:
			pass
		elif type_index == TYPE_TRANSFORM3D:
			pass
		elif type_index == TYPE_PROJECTION:
			pass
		elif type_index == TYPE_COLOR:
			pass
		elif type_index == TYPE_STRING_NAME:
			pass
		elif type_index == TYPE_NODE_PATH:
			pass
		elif type_index == TYPE_RID:
			pass
		elif type_index == TYPE_CALLABLE:
			pass
		elif type_index == TYPE_SIGNAL:
			pass
		elif type_index == TYPE_DICTIONARY:
			pass
		elif type_index == TYPE_ARRAY:
			pass
		elif type_index == TYPE_PACKED_BYTE_ARRAY:
			pass
		elif type_index == TYPE_PACKED_INT32_ARRAY:
			pass
		elif type_index == TYPE_PACKED_INT64_ARRAY:
			pass
		elif type_index == TYPE_PACKED_FLOAT32_ARRAY:
			pass
		elif type_index == TYPE_PACKED_FLOAT64_ARRAY:
			pass
		elif type_index == TYPE_PACKED_STRING_ARRAY:
			pass
		elif type_index == TYPE_PACKED_VECTOR2_ARRAY:
			pass
		elif type_index == TYPE_PACKED_VECTOR3_ARRAY:
			pass
		elif type_index == TYPE_PACKED_COLOR_ARRAY:
			pass
	
	var constructors: Array = []
	if _variant_maker:
		constructors = _variant_maker.get_constructors()
		_constructor_view.add_child(_variant_maker)

	_constructor_picker.visible = constructors.size() > 1
	_constructor_picker.get_popup().clear()
	for constructor in constructors:
		_constructor_picker.get_popup().add_item(PropertyHelpers.to_func_signature(constructor))
	
	view_refreshed.emit()