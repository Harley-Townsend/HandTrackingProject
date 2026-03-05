extends Area3D

@onready var ring = $ProgressRing
@onready var ring_material = ring.get_active_material(0)

var original_scale
var target_scale

var hover_time := 0.0
var required_time := 5.0
var is_hovered := false


func _ready():
	original_scale = scale
	target_scale = original_scale
	ring_material.set_shader_parameter("fill_amount", 0.0)


func _process(delta):

	# Smooth scale animation
	scale = scale.lerp(target_scale, 10.0 * delta)

	if is_hovered:
		hover_time += delta

		var fill = hover_time / required_time
		fill = clamp(fill, 0.0, 1.0)

		ring_material.set_shader_parameter("fill_amount", fill)

		# Trigger when ring visually finishes
		if fill >= 1.0:
			start_minigame()

	else:
		hover_time = 0.0
		ring_material.set_shader_parameter("fill_amount", 0.0)


func on_hand_touch_enter():
	is_hovered = true
	target_scale = original_scale * 1.15


func on_hand_touch_exit():
	is_hovered = false
	target_scale = original_scale


func start_minigame():
	get_tree().change_scene_to_file("res://hands_on_hardware.tscn")
