extends Area3D

@onready var mesh = $MeshInstance3D

func on_hand_enter():
	scale = Vector3(1.2, 1.2, 1.2) # highlight

func on_hand_exit():
	scale = Vector3.ONE

func on_hand_click():
	start_game()

func start_game():
	print("Start Game Pressed")
	get_tree().change_scene_to_file("res://YourMainScene.tscn")
