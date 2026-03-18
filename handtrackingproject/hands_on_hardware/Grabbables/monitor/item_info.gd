extends RigidBody3D

@export var description : String = "Item description"
@export var text_height := 0.25
@export var text_duration := 4.0

var grabbed := false
var hand : Node3D = null
var grab_offset := Vector3.ZERO

var explanation_shown := false
var label : Label3D


func grab(hand_node):

	grabbed = true
	hand = hand_node

	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	grab_offset = global_position - hand.global_position

	# show explanation first time grabbed
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

	# keep text above item
	if label:
		label.position = Vector3(0, text_height, 0)


func show_text():

	label = Label3D.new()

	label.text = description
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 80  # smaller text
	label.position = Vector3(0, text_height, 26)

	add_child(label)   # attach to item so it follows

	await get_tree().create_timer(text_duration).timeout

	if label:
		label.queue_free()
