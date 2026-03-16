extends RigidBody3D

# ----- GRABBING -----
var grabbed := false
var hand : Node3D = null
var grab_offset := Vector3.ZERO

# ----- CONTENT SETTINGS -----
@export var contents : Array[PackedScene] = []
@export var content_scales : Array[Vector3] = []

@export var spawn_height := 1.0
@export var spawn_spread := 0.25

# impulse strength when box opens
@export var pop_force := 2.0


# ----- GRABBING LOGIC -----
func grab(hand_node):

	grabbed = true
	hand = hand_node

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


# ----- OPEN BOX -----
func open_box():

	print("BOX OPENED")

	if contents.is_empty():
		print("No contents assigned!")
		return


	for i in range(contents.size()):

		var scene = contents[i]

		if scene == null:
			continue

		var item = scene.instantiate()

		get_parent().add_child(item)

		# spawn slightly spread out
		var offset = Vector3(
			randf_range(-spawn_spread, spawn_spread),
			spawn_height,
			randf_range(-spawn_spread, spawn_spread)
		)

		item.global_position = global_position + offset


		# apply individual scale if provided
		if i < content_scales.size():
			item.scale = content_scales[i]


		# apply impulse if the item is physics based
		if item is RigidBody3D:

			var impulse = Vector3(
				randf_range(-pop_force, pop_force),
				pop_force * 1.0,
				randf_range(-pop_force, pop_force)
			)

			item.apply_impulse(impulse)


		print("Spawned:", item.name)


	queue_free()
