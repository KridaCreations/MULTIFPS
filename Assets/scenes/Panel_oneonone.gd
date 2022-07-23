extends Panel

onready var num_input = $Node2D
onready var slider = $HSlider
onready var id = $id
onready var username_box = $username

func _on_Done_pressed():
	var err = (Client.client.connect_to_url("ws://" + "localhost:5000"))
	print(err)
	if err != OK:
		print("unable to connect")
	else:
		Client.connected = true
		Client.host = true
		Client.data["id"] = $id.value
		Client.match_info = {
			"no_of_matches":num_input.value,
			"match_type":"one_on_one",
			"max_players":2
		}
		get_tree().change_scene("res://Assets/levels/level_one_on_one.tscn")


func _on_HSlider_value_changed(value):
	num_input.value = value


func _on_Node2D_value_changed(value):
	slider.value = value
