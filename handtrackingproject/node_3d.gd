extends Node3D

var server := TCPServer.new()
var peer : StreamPeerTCP

@onready var hand = $HandSphere

func _ready():
	server.listen(5555)
	print("Server listening on port 5555")

func _process(delta):
	if server.is_connection_available():
		peer = server.take_connection()
		print("Python connected!")

	if peer and peer.get_available_bytes() > 0:
		var msg = peer.get_utf8_string(peer.get_available_bytes())
		var parts = msg.strip_edges().split(",")

		if parts.size() == 2:
			var x = float(parts[0])
			var y = float(parts[1])

			# Convert normalized coords to 3D space
			hand.position.x = (x - 0.5) * 5.0
			hand.position.y = (0.5 - y) * 3.0
