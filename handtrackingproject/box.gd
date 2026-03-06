extends RigidBody3D

var grabbed := false
var hand = null
var grab_offset := Vector3.ZERO

func grab(hand_node):

	grabbed = true
	hand = hand_node
	freeze = true

	grab_offset = global_position - hand.global_position


func release():

	grabbed = false
	freeze = false
	hand = null


func _process(delta):

	if grabbed and hand:
		global_position = hand.global_position + grab_offset
