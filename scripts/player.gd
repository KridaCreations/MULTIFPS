extends KinematicBody

export var jump_velocity = 20
export var health = 200
export var speed = 30
export var lerp_duration = 0.5
export var gravity = Vector3(0,-10,0)

onready var recoil_node = $recoil
onready var guns = [get_node("upper_body/head_area/weapon").get_child(0)]
onready var timer = $Timer
onready var ray_front_point = $upper_body/head_area/Camera/rayendpoint
onready var gun_front_point = $upper_body/head_area/weapon
onready var ray = $upper_body/head_area/Camera/RayCast
onready var bullet = preload("res://Assets/bullet.tscn")
onready var left_point = $upper_body/torso_area/left
onready var front_point = $upper_body/torso_area/front
onready var back_point = $upper_body/torso_area/back 
onready var head = $upper_body/head_area
onready var torso = $upper_body
onready var lower_body = $lower_body

var tween_relax_time
var prev_rotation
var nearby_weapon 
var dead = false
var sense = true
var no_of_guns = 1
var present_gun = 0
var g_velocity = Vector3.ZERO
var bullet_instance = null 
var mouse_sensitivity = 3
var velocity = Vector3.ZERO
var aim_direction = Vector3.ZERO
var move_direction = Vector3.ZERO
var rng = RandomNumberGenerator.new()
	

func _ready():
#	guns[posmod(present_gun+1,no_of_guns)].disappear()
	guns[posmod(present_gun,no_of_guns)].appear()
	guns[posmod(present_gun,no_of_guns)].name = "pistol" + "first" + str(Client.data["id"])
	rng.randomize()
	global_transform.origin.x = rng.randi_range(-25, 25)
	rng.randomize()
	global_transform.origin.z = rng.randi_range(-25, 25)
	update_data()
	Client.world = get_parent()
	Client.initiated = false
	move_and_slide(Vector3(1,0,1))
	pass
	
func _input(event):
	if sense == true:
		if event is InputEventMouseMotion:
			torso.rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
			head.rotation_degrees.x = clamp(head.rotation_degrees.x + event.relative.y * mouse_sensitivity / 10, -70, 80)
func _physics_process(delta):
	if health <= 0 :
		return
	velocity = Vector3.ZERO
	var forward_dir = front_point.global_transform.origin - back_point.global_transform.origin
	forward_dir = forward_dir.normalized()	
	aim_direction = forward_dir
	var left_dir = left_point.global_transform.origin - back_point.global_transform.origin
	left_dir = left_dir.normalized()
	if Input.is_action_pressed("ui_up"):
		velocity += forward_dir
	if Input.is_action_pressed("ui_down"):
		velocity -= forward_dir
	if Input.is_action_pressed("ui_left"):
		velocity += left_dir
	if Input.is_action_pressed("ui_right"):
		velocity -= left_dir
	if Input.is_action_just_pressed("swap"):
		if nearby_weapon != null:
			if no_of_guns == 2:	
				swap()
			else:
				pickup()
	if Input.is_action_just_pressed("ui_focus_next"):
		sense = !sense
	if Input.is_action_just_pressed("change_left"):
		if no_of_guns == 2:
			guns[posmod(present_gun,no_of_guns)].disappear()
			present_gun += 1
			guns[posmod(present_gun,no_of_guns)].appear()
			var message = {
				"mes":"weapon_changed",
				"id":Client.data["id"],
				"info":{
					"id":Client.data["id"],
					"new_type":guns[posmod(present_gun,no_of_guns)].type,
					"new_name":guns[posmod(present_gun,no_of_guns)].name
				}
			}
			Client.send(message)
	if Input.is_action_just_pressed("change_right"):
		if no_of_guns == 2:
			guns[posmod(present_gun,no_of_guns)].disappear()
			present_gun -= 1
			guns[posmod(present_gun,no_of_guns)].appear()
			var message = {
				"mes":"weapon_changed",
				"id":Client.data["id"],
				"info":{
					"id":Client.data["id"],
					"new_type":guns[posmod(present_gun,no_of_guns)].type,
					"new_name":guns[posmod(present_gun,no_of_guns)].name
				}
			}
			Client.send(message)
	if Input.is_action_just_pressed("reload"):
		guns[posmod(present_gun,no_of_guns)].reload()
		var message = {
			"mes" : "weapon_reload",
			"id":Client.data["id"],
			"info":{
				"id":Client.data["id"]
			}
		}
		Client.send(message)
	if Input.is_action_just_pressed("ui_select") and is_on_floor(): #and $florr_ray.is_colliding():
		g_velocity.y = jump_velocity
	if Input.is_action_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("fullscreen"):
		if OS.window_fullscreen == false:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		OS.window_fullscreen = !OS.window_fullscreen
	velocity = velocity.normalized()
	
	var forward = global_transform.basis.z
	var forward2d = Vector2(forward.x,forward.z)
	var facing = torso.global_transform.basis.z
	
	if velocity != Vector3.ZERO:
		move_direction = lerp(move_direction,velocity,lerp_duration)
		var vec_move = Vector2(move_direction.x,move_direction.z)
		var angle = forward2d.angle_to(vec_move)
		lower_body.rotation.y = -angle
	else:
		move_direction = lerp(move_direction,facing,lerp_duration)
		var vec_move = Vector2(move_direction.x,move_direction.z)
		var angle = forward2d.angle_to(vec_move)
		lower_body.rotation.y = -angle
	move_and_slide(((move_direction*velocity.length()*speed)+(g_velocity))*delta,Vector3.UP)
#	print(g_velocity.y)
	if is_on_floor():
		g_velocity = Vector3.ZERO
	else:
		g_velocity += gravity * delta
	update_data()

func shoot():
#	print("///////////printing collision point/////////")
#	print(ray.get_collider())
#	print(ray.get_collider().name)
#	print(ray.get_collision_point())
#	return 
	if guns[posmod(present_gun,no_of_guns)].get_node("Timer").is_stopped():
#		print("///////////printing collision point/////////")
#		print(ray.get_collider())
#		print(ray.get_collider().name)
#		print(ray.get_collision_point())
		var recoil = guns[posmod(present_gun,no_of_guns)].recoil_value
		var target_point 
		if ray.is_colliding() == true:
			target_point = ray.get_collision_point()
		else:
			target_point = ray_front_point.global_transform.origin
		guns[posmod(present_gun,no_of_guns)].shoot(target_point)
	pass
	
func update_data():
	Client.data["position_x"] = global_transform.origin.x
	Client.data["position_y"] = global_transform.origin.y
	Client.data["position_z"] = global_transform.origin.z
	for i in Client.data["rotation_y"]:
		Client.data["rotation_y"][i] = get_node(i).rotation.y
	for j in Client.data["rotation_x"]:
		Client.data["rotation_x"][j] = get_node(j).rotation.x
	pass

func damage_health(damage,killer):
	if get_parent().match_started == false:
		return
	if dead == true:
		return
	if health > damage:
		health -= damage
		get_parent().get_node("player_detail").health_bar.value = health
	else:
		health = 0
		get_parent().get_node("player_detail").health_bar.value = health
		dead = true
		var message = {
			"mes":"player_dead",
			"id":Client.data["id"],
			"info":{
				"id":Client.data["id"],
				"dead":Client.data["id"],
				"shooter":killer
			}
		}
		Client.send(message)
#		timer.start()
		
func pickup():
	if !is_instance_valid(nearby_weapon):
		return
	var new_weapon
	var new_type = nearby_weapon.type
	var new_name = nearby_weapon.name
	if nearby_weapon.type == "ak47":
		new_weapon = get_parent().hand_gun_models["ak47"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(1,new_weapon)
	elif nearby_weapon.type == "sniper":
		new_weapon = get_parent().hand_gun_models["sniper"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(1,new_weapon)
	elif nearby_weapon.type == "pistol":
		new_weapon = get_parent().hand_gun_models["pistol"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(1,new_weapon)
	elif nearby_weapon.type == "shotgun":
		new_weapon = get_parent().hand_gun_models["shotgun"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(1,new_weapon)
	nearby_weapon.queue_free()
	no_of_guns += 1
	new_weapon.visible = false
	var message = {
		"mes":"pickup_weapon",
		"id":Client.data["id"],
		"info":{
			"id":Client.data["id"],
			"new_type":nearby_weapon.type,
			"new_name":nearby_weapon.name,
		}
	}
	Client.send(message)
		

func swap():
	if !is_instance_valid(nearby_weapon):
		return
	var curr_name = guns[posmod(present_gun,no_of_guns)].name
	var curr_type = guns[posmod(present_gun,no_of_guns)].type
	var cur_index = posmod(present_gun,no_of_guns)
	var new_type = nearby_weapon.type
	var new_name = nearby_weapon.name
	guns[posmod(present_gun,no_of_guns)].free()
	guns.remove(posmod(present_gun,no_of_guns))
	if nearby_weapon.type == "ak47":
		var new_weapon = get_parent().hand_gun_models["ak47"].instance()
		gun_front_point.add_child(new_weapon)	
		new_weapon.name = nearby_weapon.name
		guns.insert(posmod(present_gun,no_of_guns),new_weapon)
	elif nearby_weapon.type == "sniper":
		var new_weapon = get_parent().hand_gun_models["sniper"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(posmod(present_gun,no_of_guns),new_weapon)
	elif nearby_weapon.type == "pistol":
		var new_weapon = get_parent().hand_gun_models["pistol"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(posmod(present_gun,no_of_guns),new_weapon)
	elif nearby_weapon.type == "shotgun":
		var new_weapon = get_parent().hand_gun_models["shotgun"].instance()
		gun_front_point.add_child(new_weapon)
		new_weapon.name = nearby_weapon.name
		guns.insert(posmod(present_gun,no_of_guns),new_weapon)
	var new_drop = get_parent().drop_gun_models[curr_type].instance()
	get_parent().get_node("guns").add_child(new_drop)
	new_drop.name = curr_name
	var pos = nearby_weapon.global_transform.origin
	nearby_weapon.queue_free()
	new_drop.global_transform.origin = Vector3(pos.x,new_drop.dropped_height,pos.z)
	var message = {
		"mes":"swap_weapon",
		"id":Client.data["id"],
		"info":{
			"id":Client.data["id"],
			"curr_type":curr_type,
			"cur_index":cur_index,
			"cur_name":curr_name,
			"new_type":new_type,
			"new_name":new_name,
			"pos":{
				"x":pos.x,
				"y":new_drop.dropped_height,
				"z":pos.z
			}
		}
	}
	Client.send(message)

func reset_player_gun():
	for gun in gun_front_point.get_children():
		gun.free()
	var new_gun = get_parent().hand_gun_models["pistol"].instance()	
	new_gun.name = "pistol" + "first" + str(Client.data["id"])
	gun_front_point.add_child(new_gun)
	guns.clear()
	guns.append(new_gun)
	health = 200
	present_gun = 0
	no_of_guns = 1
	get_parent().get_node("player_detail").health_bar.value = health
	dead = false
#	get_parent().hand_gun_models["pistol"]

func _on_torso_area_area_entered(area):
	print(area.name + "area entered torso")
#	if "bullet" in area.name:
	if area.is_in_group("bullet"):
		print("hit torso")
		damage_health(50,area.p_id)


func _on_head_area_area_entered(area):
	print(area.name + "area entered head")
#	if "bullet" in area.name:
	if area.is_in_group("bullet"):
		
		print("hit head")
		damage_health(200,area.p_id)
		area.queue_free()


func _on_lower_area_area_entered(area):
	print(area.name + "area entered leg")
#	if "bullet" in area.name:
	if area.is_in_group("bullet"):
		damage_health(20,area.p_id)
		area.queue_free()
		print("hit leg")
		return
	if is_instance_valid(area):
		if area.is_in_group("drop_weapons"):
			nearby_weapon = area
			get_parent().get_node("data panel").get_node("notification_bar").text = "Press 'F' to pick up " + area.type
			get_parent().get_node("data panel").get_node("notification_bar").visible = true


func _on_lower_area_area_exited(area):
	if is_instance_valid(area):
		if area.is_in_group("drop_weapons"):
			nearby_weapon = null
			get_parent().get_node("data panel").get_node("notification_bar").visible = false


func _on_Timer_timeout():
	if dead == true:
		var message = {
			"mes":"new_match"
		}
		Client.send(message)



