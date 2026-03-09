extends Node3D

@onready var joint8_area = $Joint8/Area3D
@onready var joint8 = $Joint8
@onready var joint9 = $Joint9
@onready var joint4 = $Joint4      # thumb
@onready var joint20 = $Joint20    # pinky
@onready var camera : Camera3D = get_parent() as Camera3D

var udp := PacketPeerUDP.new()
var joints = []

# tracking
var smoothing_speed := 24.0

# gestures
var grab_start_threshold := 0.2
var grab_release_threshold := 0.21
var rotate_threshold := 0.12

var rotate_anchor := Vector3.ZERO
var is_grabbing := false
var is_rotating := false

var last_hand_pos := Vector3.ZERO

# grabbing
var grabbed_object = null

# camera
var default_camera_transform : Transform3D

# camera rotation control
var rotation_sensitivity := 0.15
var deadzone := 0.002


func _ready():

	await get_tree().process_frame

	var err = udp.bind(5555)

	if err != OK:
		print("UDP bind failed")
	else:
		print("Listening for hand tracking...")

	for i in range(21):
		joints.append(get_node("Joint" + str(i)))

	joint8_area.monitoring = true
	joint8_area.monitorable = true

	joint8_area.area_entered.connect(_on_finger_enter)
	joint8_area.area_exited.connect(_on_finger_exit)

	if camera:
		default_camera_transform = camera.global_transform


func _process(delta):

	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet().get_string_from_utf8()
		update_hand(packet)

	handle_camera_rotation()

	if Input.is_key_pressed(KEY_R) and camera:
		camera.global_transform = default_camera_transform


func update_hand(data : String):

	var v = data.split(",")

	if v.size() < 63:
		return

	var raw_positions = []

	for i in range(21):

		var x = float(v[i * 3 + 0])
		var y = float(v[i * 3 + 1])
		var z = float(v[i * 3 + 2])

		var pos = Vector3(
			(x - 0.5) * 4.0,
			(0.5 - y) * 4.0,
			-z * 2.0
		)

		raw_positions.append(pos)

	var t = 1.0 - exp(-smoothing_speed * get_process_delta_time())

	for i in range(21):
		joints[i].position = joints[i].position.lerp(raw_positions[i], t)

	check_gestures()


func check_gestures():

	var thumb_pos = joint4.global_position
	var index_pos = joint8.global_position
	var pinky_pos = joint20.global_position

	var grab_distance = thumb_pos.distance_to(index_pos)
	var rotate_distance = thumb_pos.distance_to(pinky_pos)

	# ----- START GRAB -----
	if !is_grabbing and grab_distance < grab_start_threshold:

		is_grabbing = true
		try_grab()

	# ----- RELEASE GRAB -----
	if is_grabbing and grab_distance > grab_release_threshold:

		if grabbed_object:
			grabbed_object.release()
			grabbed_object = null

		is_grabbing = false


	# ----- ROTATE CAMERA -----
	if rotate_distance < rotate_threshold and !is_grabbing:
		if !is_rotating:
			is_rotating = true
			rotate_anchor = joint9.position
	else:
		is_rotating = false


func try_grab():
	print("Bodies touching:", joint8_area.get_overlapping_bodies())

	var bodies = joint8_area.get_overlapping_bodies()

	for body in bodies:

		if body.has_method("grab"):
			grabbed_object = body
			body.grab(joint8)
			print("Grabbed:", body.name)
			return


	var areas = joint8_area.get_overlapping_areas()

	for area in areas:

		var node = area.get_parent()

		if node and node.has_method("grab"):
			grabbed_object = node
			node.grab(joint8)
			print("Grabbed:", node.name)
			return


func handle_camera_rotation():

	if is_rotating and camera:

		var offset = joint9.position - rotate_anchor

		# smooth the offset heavily
		offset.x = lerp(0.0, offset.x, 0.2)
		offset.y = lerp(0.0, offset.y, 0.2)

		# joystick-style rotation
		var yaw_speed = offset.x * 1.5
		var pitch_speed = offset.y * 1.2

		camera.rotate_y(-yaw_speed * get_process_delta_time())
		camera.rotate_x(-pitch_speed * get_process_delta_time())

		# clamp vertical look
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)


func _on_finger_enter(area):

	if area.has_method("on_hand_touch_enter"):
		area.on_hand_touch_enter()


func _on_finger_exit(area):

	if area.has_method("on_hand_touch_exit"):
		area.on_hand_touch_exit()
