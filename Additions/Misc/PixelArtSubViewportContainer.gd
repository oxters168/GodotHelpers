@tool
extends SubViewportContainer
class_name PixelArtSubViewportContainer

func _init():
	stretch = true
	stretch_shrink = 3
	set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	# hacky solution since set_anchors_preset was not working in editor
	size = get_viewport_rect().size
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
