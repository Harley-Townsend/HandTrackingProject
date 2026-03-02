extends Node3D

@onready var joints_root = $HandJoints
var udp := PacketPeerUDP.new()

var joints = []

var last_wrist := Vector3.ZERO
var has_last := false

func _ready():
	udp.bind(5555)
	print("Listening for 21-joint hand tracking...")

	for i in range(21):
		joints.append(joints_root.get_node("Joint" + str(i)))

func _process(_delta):
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet().get_string_from_utf8()
		update_hand(packet)

func update_hand(data: String):
	var v = data.split(",")
	if v.size() < 63:
		return

	# --- Wrist position from MediaPipe ---
	var wx = float(v[0])
	var wy = float(v[1])
	var wz = float(v[2])

	var wrist = Vector3(wx, wy, wz)

	# --- Convert to relative movement instead of absolute ---
	if has_last:
		var delta = wrist - last_wrist

		# Apply movement scaling (tweakable)
		var move = Vector3(
			delta.x * 6.0,
			-delta.y * 6.0,
			-delta.z * 6.0
		)

		position += move

	last_wrist = wrist
	has_last = true

	# --- Update finger joints normally ---
	for i in range(21):
		var x = float(v[i * 3 + 0])
		var y = float(v[i * 3 + 1])
		var z = float(v[i * 3 + 2])

		var pos = Vector3(
			(x - 0.5) * 4.0,
			(0.5 - y) * 4.0,
			-z * 2.0
		)

		joints[i].position = pos
