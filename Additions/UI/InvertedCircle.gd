@tool
extends Control
class_name InvertedCircle

## The center position of the circle in pixel measurement
@export var center: Vector2 = Vector2.ZERO:
	set(new_center):
		center = new_center
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
	# print("Center: ", center, " Diameter: ", diameter, " Size: ", size)
	var circle_top_left_corner = center - Vector2.ONE * diameter / 2
	var circle_bottom_right_corner = center + Vector2.ONE * diameter / 2
	if circle_top_left_corner.x > 0:
		draw_rect(Rect2(Vector2.ZERO, Vector2(circle_top_left_corner.x, size.y)), color)
	if circle_top_left_corner.y > 0:
		draw_rect(Rect2(Vector2(circle_top_left_corner.x, 0), Vector2(circle_bottom_right_corner.x - circle_top_left_corner.x, circle_top_left_corner.y)), color)
	if circle_bottom_right_corner.x < size.x:
		draw_rect(Rect2(Vector2(circle_bottom_right_corner.x, 0), Vector2(size.x - circle_bottom_right_corner.x, size.y)), color)
	if circle_bottom_right_corner.y < size.y:
		draw_rect(Rect2(Vector2(circle_top_left_corner.x, circle_bottom_right_corner.y), Vector2(circle_bottom_right_corner.x - circle_top_left_corner.x, size.y - circle_bottom_right_corner.y)), color)
	draw_texture_rect(preload("./Resources/inverted_circle.svg"), Rect2(circle_top_left_corner, Vector2(diameter, diameter)), false, color)
