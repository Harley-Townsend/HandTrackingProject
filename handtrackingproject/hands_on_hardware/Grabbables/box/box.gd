extends RigidBody3D

var grabbed := false
var hand : Node3D = null
var grab_offset := Vector3.ZERO


func grab(hand_node):

	grabbed = true
	hand = hand_node

	# disable physics while holding
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	grab_offset = global_position - hand.global_position


func release():

	grabbed = false
	freeze = false
	hand = null


func _physics_process(delta):

	if grabbed and hand:
		global_position = global_position.lerp(hand.global_position + grab_offset, 0.35)
