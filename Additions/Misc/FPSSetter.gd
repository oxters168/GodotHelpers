extends Node
class_name FPSSetter

## The maximum number of frames per second that can be rendered. A value of 0 means "no limit". The actual number of frames per second may still be below this value if the CPU or GPU cannot keep up with the project logic and rendering.
## Limiting the FPS can be useful to reduce system power consumption, which reduces heat and noise emissions (and improves battery life on mobile devices).
## If ProjectSettings.display/window/vsync/vsync_mode is Enabled or Adaptive, it takes precedence and the forced FPS number cannot exceed the monitor's refresh rate.
## If ProjectSettings.display/window/vsync/vsync_mode is Enabled, on monitors with variable refresh rate enabled (G-Sync/FreeSync), using a FPS limit a few frames lower than the monitor's refresh rate will url=https://blurbusters.com/howto-low-lag-vsync-on/reduce input lag while avoiding tearing/url.
## If ProjectSettings.display/window/vsync/vsync_mode is Disabled, limiting the FPS to a high value that can be consistently reached on the system can reduce input lag compared to an uncapped framerate. Since this works by ensuring the GPU load is lower than 100%, this latency reduction is only effective in GPU-bottlenecked scenarios, not CPU-bottlenecked scenarios.
## See also physics_ticks_per_second and ProjectSettings.application/run/max_fps.
@export var fps: int = 0:
	set(new_fps):
		fps = new_fps
		Engine.max_fps = fps
@export var debug: bool = false

func _init():
	Engine.max_fps = fps
func _process(delta):
	if debug:
		var current_fps = 1 / delta
		DebugDraw.set_text("FPS", MathHelpers.to_decimal_places(current_fps, 2))