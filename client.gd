extends Node

export var socket_url = "ws://127.0.0.1:5000"

onready var enemy_model = preload("res://Assets/enemy.tscn")
onready var bullet = preload("res://Assets/bullet.tscn")

var match_info = {}
var host = false
var bullet_instance = null
var enemies = {}
var world
var client = WebSocketClient.new()
var connected = false
var initiated = null

var data = {
	"id":null,
	"position_x":null,
	"position_y":null,
	"rotation_x":{
		"upper_body/head_area":null
		}
	,
	"rotation_y":{
		"upper_body":null,
		"lower_body":null
		}
	
}

func _ready():
	("global_script")
	(client.connect("connection_closed",self,"on_connection_closed"))
	(client.connect("connection_established",self,"on_connection_establised"))
	(client.connect("connection_failed",self,"on_connection_failed"))
	(client.connect("connection_error",self,"on_connection_error"))
	(client.connect("data_received",self,"on_data_received"))
	

func _physics_process(delta):
	if connected == true:
		if initiated == false:
			var message = {
				"mes":"initiate",
				"info":data,
			}
			var err = send(message)
			if err == OK:
				initiated = true
				world.get_node("data panel").add_box(data["id"])
			if host == true:
				var new_message = {
					"mes":"setup_match",
					"info":match_info
				}
				send(new_message)
				
				
		else:
			var message = {
				"mes":"regular_log",
				"info":data
			}
			var err = send(message)
			if err != OK:
				print(err)
		client.poll()

func send(pack):
	return client.get_peer(1).put_packet(JSON.print(pack).to_utf8())

func on_connection_closed(type):
	print("connection_cut")
	connected = false
	get_tree().change_scene("res://Assets/scenes/first view.tscn")
	set_process(false)
	pass

func on_connection_establised(proto = ""):
	connected = true
	print("connected")
	pass

func on_connection_failed():
	pass
	
func on_connection_error():
	pass

func on_data_received():
	var payload = JSON.parse(client.get_peer(1).get_packet().get_string_from_utf8()).result
	perform(payload)
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		var message = {
				"mes":"enemy_deleted",
				"info":data
				} 
		var err = send(message)
		if err != OK:
			print(err)
		client.disconnect_from_host(1000, str(data["id"]))

func perform(payload):
	if payload["mes"] == "create_world":
		create_world(payload)
	elif payload["mes"] == "new_match":
		world.reload_scene(payload["pos"])
	elif payload["mes"] == "start_game":
		world.start_game(payload["pos"])
	elif payload["mes"] == "start_count":
		world.start_count()
	elif payload["mes"] == "stop_match":
		world.stop_match(payload["info"])
	elif payload["mes"] == "put_ip":
		world.get_node("data panel/ip_notice").text += str(payload["info"]["ip"])
	elif payload["mes"] == "ready_client":
		if payload["id"] != data["id"]:
			ready_client(payload["info"])
	elif payload["mes"] == "add_enemy":
		if payload["id"] != data["id"]:
			create_enemy(payload["info"],payload["state"])
	elif payload["mes"] == "update_enemy":
		if payload["id"] != data["id"]:
			update_enemy(payload["info"])
	elif payload["mes"] == "delete_enemy":
		if payload["id"] != data["id"]:
			delete_enemy(payload["info"])
	elif payload["mes"] == "bullet_shot":
		if payload["id"] != data["id"]:
			enemies[payload["info"]["id"]].shoot(dic_to_vec(payload["info"]["target_point"]),payload["info"]["id"])
#			enemies[payload["info"]["id"]].get_node("upper_body/head_area/weapon").get_child(0).shoot(dic_to_vec(payload["info"]["target_point"]))
#			add_bullet(payload["info"])
	elif payload["mes"] == "swap_weapon":
		if payload["id"] != data["id"]:
			swap_weapon(payload["info"])
	elif payload["mes"] == "pickup_weapon":
		if payload["id"] != data["id"]:
			pickup_weapon(payload["info"])
	elif payload["mes"] == "weapon_changed":
		if payload["id"] != data["id"]:
			change_weapon(payload["info"])
	elif payload["mes"] == "weapon_reload":
		if payload["id"] != data["id"]:
			reload_weapon(payload["info"])

func ready_client(info):
	world.get_node("data panel").ready_client(info["id"])

func reload_weapon(info):
	enemies[info["id"]].get_node("upper_body/head_area/weapon").get_child(0).reload()

func change_weapon(info):
	var new_weapon = world.hand_gun_models[info["new_type"]].instance()
	enemies[info["id"]].get_node("upper_body/head_area/weapon").get_child(0).free()
	enemies[info["id"]].get_node("upper_body/head_area/weapon").add_child(new_weapon)
	new_weapon.appear()
#	new_weapon.name = info["new_name"]

func swap_weapon(info):
	var new_weapon = world.hand_gun_models[info["new_type"]].instance()
	enemies[info["id"]].get_node("upper_body/head_area/weapon").get_child(0).free()
	enemies[info["id"]].get_node("upper_body/head_area/weapon").add_child(new_weapon)
#	new_weapon.name = info["new_name"]
#	print(info)
	world.get_node("guns").get_node(info["new_name"]).free()
	
	var new_drop = world.drop_gun_models[info["curr_type"]].instance()
	world.get_node("guns").add_child(new_drop)
	new_drop.name = info["cur_name"]
	new_drop.global_transform.origin = dic_to_vec(info["pos"])
	
func pickup_weapon(info):
#	print("worlddebug")
#	print(info)
#	print(world.get_node("guns"))
	world.get_node("guns").get_node(info["new_name"]).free()
	
func add_bullet(info):
	bullet_instance = bullet.instance()
	world.add_child(bullet_instance)
	bullet_instance.p_id = info["id"]
	bullet_instance.connect_signals()
	bullet_instance.parent = enemies[info["id"]]
	bullet_instance.global_transform.origin = dic_to_vec(info["start_point"]) 
	bullet_instance.direction = dic_to_vec(info["direction"])
	bullet_instance.look_at(dic_to_vec(info["target_point"]),Vector3.UP)
	pass

func dic_to_vec(dic):
	return Vector3(dic["x"],dic["y"],dic["z"])

func delete_enemy(info):
	enemies[info["id"]].queue_free()
	enemies.erase(info["id"])
	world.get_node("data panel").remove_box(info["id"])

func create_world(payload):
	var data = payload["info"]
	var state = payload["state"]
#	print(payload)
	for i in data:
		create_enemy(data[i],state)
	
func update_enemy(info):
	if enemies.has(info["id"]):
		var target_enemy = enemies[info["id"]]
		target_enemy.global_transform.origin.x = info["position_x"]
		target_enemy.global_transform.origin.y = info["position_y"]
		target_enemy.global_transform.origin.z = info["position_z"]
		for i in info["rotation_y"]:
			target_enemy.get_node(i).rotation.y = info["rotation_y"][i] 
		for j in info["rotation_x"]:
			target_enemy.get_node(j).rotation.x = info["rotation_x"][j]
#		world.get_node("data panel").update_state_box(info["id"],state)
		
func create_enemy(info,state):
	var new_enemy = enemy_model.instance()
	world.add_child(new_enemy)
	enemies[info["id"]] = new_enemy
	new_enemy.global_transform.origin.x = info["position_x"]
	new_enemy.global_transform.origin.y = info["position_y"]
	new_enemy.global_transform.origin.z = info["position_z"]
	for i in info["rotation_y"]:
		new_enemy.get_node(i).rotation.y = info["rotation_y"][i] 
	for j in info["rotation_x"]:
		new_enemy.get_node(j).rotation.x = info["rotation_x"][j] 
	world.get_node("data panel").add_box(info["id"])
	world.get_node("data panel").update_state_box(info["id"],state)
