extends Node3D

@onready var joint8_area = $Joint8/Area3D
var udp := PacketPeerUDP.new()
var joints = []

func _ready():
	udp.bind(5555)
	print("Listening for 21-joint hand tracking...")

	for i in range(21):
		joints.append(get_node("Joint" + str(i)))

	# Connect touch signals
	joint8_area.area_entered.connect(_on_finger_enter)
	joint8_area.area_exited.connect(_on_finger_exit)

func _process(_delta):

	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet().get_string_from_utf8()
		update_hand(packet)


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

		joints[i].position = joints[i].position.lerp(pos, 0.5)


func _on_finger_enter(area):
	if area.has_method("on_hand_touch_enter"):
		area.on_hand_touch_enter()

func _on_finger_exit(area):
	if area.has_method("on_hand_touch_exit"):
		area.on_hand_touch_exit()
