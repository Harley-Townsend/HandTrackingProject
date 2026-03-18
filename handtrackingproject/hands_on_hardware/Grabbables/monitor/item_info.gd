extends RigidBody3D

@export var description : String = "Item description"
@export var text_height := 0.2
@export var text_duration := 12.0

var grabbed := false
var hand : Node3D = null
var grab_offset := Vector3.ZERO

var explanation_shown := false
var label : Label3D

@onready var camera = get_viewport().get_camera_3d()


func grab(hand_node):

	grabbed = true
	hand = hand_node

	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	grab_offset = global_position - hand.global_position

	if !explanation_shown:
		show_text()
		explanation_shown = true


func release():

	grabbed = false
	freeze = false
	hand = null


func _physics_process(delta):

	if grabbed and hand:
		global_position = global_position.lerp(hand.global_position + grab_offset, 0.35)

	if label:
		label.position = Vector3(0, text_height, 0)

		# ⭐ SCALE WITH DISTANCE (this fixes readability)
		if camera:
			var dist = global_position.distance_to(camera.global_position)
			label.scale = Vector3.ONE * dist * 0.15


func show_text():

	var ui = get_tree().current_scene.get_node("CanvasLayer/InfoLabel")

	if ui == null:
		print("UI label not found!")
		return

	ui.text = description
	ui.visible = true

	await get_tree().create_timer(text_duration).timeout

	ui.visible = false
