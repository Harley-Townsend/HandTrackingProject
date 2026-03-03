extends Node3D

@onready var joint0 = $Joint0   # wrist
@onready var joint8 = $Joint8   # index fingertip

@onready var ray = $RayCast3D

func _process(_delta):
	if joint0 and joint8:
		# Direction from wrist to fingertip
		var dir = (joint8.global_position - joint0.global_position).normalized()

		# Aim ray forward
		ray.global_position = joint8.global_position
		ray.target_position = dir * 5.0

		if ray.is_colliding():
			print("Hit: ", ray.get_collider())
			var hit = ray.get_collider()
			if hit and hit.has_method("on_hand_point"):
				hit.on_hand_point()
