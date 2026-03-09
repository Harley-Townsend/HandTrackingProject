extends RigidBody3D

var grabbed := false
var hand : Node3D = null
var grab_offset := Vector3.ZERO
var grab_rotation_offset : Basis


@onready var cut_area = $Area3D


func _ready():
	cut_area.body_entered.connect(_on_cut_area_body_entered)


func grab(hand_node):

	grabbed = true
	hand = hand_node

	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	grab_offset = global_position - hand.global_position
	grab_rotation_offset = hand.global_transform.basis.inverse() * global_transform.basis


func release():

	grabbed = false
	freeze = false
	hand = null


func _physics_process(delta):

	if grabbed and hand:

		var target_pos = hand.global_position + grab_offset
		global_position = global_position.lerp(target_pos, 0.35)

		var target_rot = hand.global_transform.basis * grab_rotation_offset
		global_transform.basis = global_transform.basis.slerp(target_rot, 0.35)


func _on_cut_area_body_entered(body):

	# Only cut if the cutter is being held
	if grabbed and body.is_in_group("cuttable"):
		body.queue_free()
