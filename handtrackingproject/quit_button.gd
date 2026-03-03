extends Area3D

func on_hand_enter():
	scale = Vector3(1.2, 1.2, 1.2)

func on_hand_exit():
	scale = Vector3.ONE

func on_hand_click():
	get_tree().quit()
