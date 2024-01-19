@tool
extends Control
class_name InvertedCircle

enum POSITION { CUSTOM, CENTER, TOP_LEFT, TOP_RIGHT, TOP_MIDDLE, MIDDLE_LEFT, BOTTOM_LEFT, BOTTOM_MIDDLE, BOTTOM_RIGHT, MIDDLE_RIGHT }

## The placement of the circle within the bounds of the control
@export var circle_placement: POSITION = POSITION.CENTER:
	set(new_placement):
		circle_placement = new_placement
		notify_property_list_changed()
		queue_redraw()
## How much to offset the circle from its placement in pixel measurement, only works if circle_placement is not set to custom
@export var circle_offset: Vector2 = Vector2.ZERO:
	set(new_offset):
		circle_offset = new_offset
		queue_redraw()
## The center position of the circle in pixel measurement
@export var center_pos: Vector2 = Vector2.ZERO:
	set(new_center_pos):
		circle_placement = POSITION.CUSTOM
		center_pos = new_center_pos
		queue_redraw()

## The diameter of the circle in pixel measurement
@export var diameter: float = 128:
	set(new_diameter):
		diameter = new_diameter
		queue_redraw()
## The color of the area surrounding the circle
@export var color: Color = Color.BLACK:
	set(new_color):
		color = new_color
		queue_redraw()

func _draw():
	center_pos = _calculate_circle_pos()
	var offset_amount = circle_offset if circle_placement != POSITION.CUSTOM else Vector2.ZERO

	var radius = diameter / 2
	var circle_top_left_corner = center_pos - Vector2(radius, radius) + offset_amount
	var circle_bottom_right_corner = center_pos + Vector2(radius, radius) + offset_amount
	if circle_top_left_corner.x > 0:
		draw_rect(Rect2(Vector2.ZERO, Vector2(circle_top_left_corner.x, size.y)), color)
	if circle_top_left_corner.y > 0:
		draw_rect(Rect2(Vector2(circle_top_left_corner.x, 0), Vector2(circle_bottom_right_corner.x - circle_top_left_corner.x, circle_top_left_corner.y)), color)
	if circle_bottom_right_corner.x < size.x:
		draw_rect(Rect2(Vector2(circle_bottom_right_corner.x, 0), Vector2(size.x - circle_bottom_right_corner.x, size.y)), color)
	if circle_bottom_right_corner.y < size.y:
		draw_rect(Rect2(Vector2(circle_top_left_corner.x, circle_bottom_right_corner.y), Vector2(circle_bottom_right_corner.x - circle_top_left_corner.x, size.y - circle_bottom_right_corner.y)), color)
	draw_texture_rect(preload("./Resources/inverted_circle.svg"), Rect2(circle_top_left_corner, Vector2(diameter, diameter)), false, color)

func _validate_property(property: Dictionary):
	if property.name == "center_pos" && circle_placement != POSITION.CUSTOM:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "circle_offset" && circle_placement == POSITION.CUSTOM:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _calculate_circle_pos() -> Vector2:
	var pos: Vector2 = center_pos
	var radius: float = diameter / 2
	if circle_placement == POSITION.CENTER:
		pos = Vector2(size.x / 2, size.y / 2)
	elif circle_placement == POSITION.TOP_LEFT:
		pos = Vector2(radius, radius)
	elif circle_placement == POSITION.TOP_RIGHT:
		pos = Vector2(size.x - radius, radius)
	elif circle_placement == POSITION.TOP_MIDDLE:
		pos = Vector2(size.x / 2, radius)
	elif circle_placement == POSITION.MIDDLE_LEFT:
		pos = Vector2(radius, size.y / 2)
	elif circle_placement == POSITION.BOTTOM_LEFT:
		pos = Vector2(radius, size.y - radius)
	elif circle_placement == POSITION.BOTTOM_MIDDLE:
		pos = Vector2(size.x / 2, size.y - radius)
	elif circle_placement == POSITION.BOTTOM_RIGHT:
		pos = Vector2(size.x - radius, size.y - radius)
	elif circle_placement == POSITION.MIDDLE_RIGHT:
		pos = Vector2(size.x - radius, size.y / 2)

	return pos
