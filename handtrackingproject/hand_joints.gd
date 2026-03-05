extends Node3D

@onready var joint8_area = $Joint8/Area3D
@onready var joint0 = $Joint0      # wrist
@onready var joint4 = $Joint4      # thumb tip
@onready var joint20 = $Joint20    # pinky tip

@onready var camera = $"../Camera3D"   # camera following the hand

var udp := PacketPeerUDP.new()
var joints = []
var smoothing_speed := 12.0

# Pinch control
var pinch_threshold := 0.08
var is_pinching := false
var last_hand_pos := Vector3.ZERO

func _ready():

	await get_tree().process_frame

	var err = udp.bind(5555)

	if err != OK:
		print("UDP bind failed")
	else:
		print("Listening for 21-joint hand tracking...")

	for i in range(21):
		joints.append(get_node("Joint" + str(i)))

	# reconnect fingertip detection
	joint8_area.area_entered.connect(_on_finger_enter)
	joint8_area.area_exited.connect(_on_finger_exit)


func _process(delta):

	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet().get_string_from_utf8()
		update_hand(packet)

	check_camera_control(delta)


func update_hand(data: String):

	var v = data.split(",")

	if v.size() < 63:
		return

	for i in range(21):

		var x = float(v[i * 3 + 0])
		var y = float(v[i * 3 + 1])
		var z = float(v[i * 3 + 2])

		var pos = Vector3(
			(x - 0.5) * 4.0,
			(0.5 - y) * 4.0,
			-z * 2.0
		)

		var t = 1.0 - exp(-smoothing_speed * get_process_delta_time())
		joints[i].position = joints[i].position.lerp(pos, t)


func check_camera_control(delta):

	if not joint4 or not joint20:
		return

	var pinch_distance = joint4.global_position.distance_to(joint20.global_position)

	# fingers touching = enable camera movement
	if pinch_distance < pinch_threshold:

		if not is_pinching:
			is_pinching = true
			last_hand_pos = joint0.global_position
			return

		var current_pos = joint0.global_position
		var movement = current_pos - last_hand_pos
		last_hand_pos = current_pos

		# rotate camera based on hand movement
		camera.rotate_y(-movement.x * 2.0)
		camera.rotate_x(-movement.y * 2.0)

		# prevent camera flipping
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

	else:
		is_pinching = false


func _on_finger_enter(area):

	if area.has_method("on_hand_touch_enter"):
		area.on_hand_touch_enter()


func _on_finger_exit(area):

	if area.has_method("on_hand_touch_exit"):
		area.on_hand_touch_exit()
