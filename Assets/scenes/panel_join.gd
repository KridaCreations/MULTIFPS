extends Panel



func _ready():
	pass 





func _on_Done_pressed():
	var err = (Client.client.connect_to_url("ws://" + $ip_address.text))
	print(err)
	if err != OK:
		print("unable to connect")
	else:
		Client.connected = true
		Client.data["id"] = $id.value
		get_tree().change_scene("res://Assets/levels/level_one_on_one.tscn")
