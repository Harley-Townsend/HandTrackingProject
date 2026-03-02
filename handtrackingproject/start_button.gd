extends Area3D

var is_hovered := false

func on_hand_point():
	is_hovered = true
	scale = Vector3(1.2, 1.2, 1.2) # visual feedback
	if Input.is_action_just_pressed("ui_accept"):
		start_game()

func _process(_delta):
	if not is_hovered:
		scale = Vector3.ONE
	is_hovered = false

func start_game():
	print("Start Game Pressed")
	get_tree().change_scene_to_file("res://YourMainScene.tscn")
