@tool
extends Button
class_name IconButton

@export var btn_icon: Texture2D = null:
	set(new_icon):
		btn_icon = new_icon
		_icon_texture.texture = new_icon
var _icon_texture: TextureRect

func _init():
	var img_panel = PanelContainer.new()
	add_child(img_panel)
	img_panel.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	img_panel.set_size(Vector2(img_panel.size.y, img_panel.size.y))
	var panel_stylebox = StyleBoxFlat.new()
	panel_stylebox.bg_color = Color.TRANSPARENT
	panel_stylebox.set_content_margin_all(4)
	panel_stylebox.content_margin_left = 8
	img_panel.add_theme_stylebox_override("panel", panel_stylebox)
	img_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_icon_texture = TextureRect.new()
	img_panel.add_child(_icon_texture)
	_icon_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_icon_texture.size_flags_horizontal = Control.SIZE_FILL
	_icon_texture.size_flags_vertical = Control.SIZE_FILL
