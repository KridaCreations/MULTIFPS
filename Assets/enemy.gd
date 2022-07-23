extends KinematicBody

onready var weapon_parent = $upper_body/head_area/weapon

func shoot(target_point,p_id):
	var weapon = weapon_parent.get_child(0)
	if weapon.timer.is_stopped() == true:# and a_player.is_playing() == false:
#		if get_parent().get_parent().get_parent().get_parent().name == "player":
#			get_parent().get_parent().get_parent().get_node("AnimationPlayer").play(weapon.type+"_recoil")
		weapon.timer.start(weapon.cooldown_time)
		if weapon.type == "sniper":
			shoot_sniper(target_point,p_id)
		elif weapon.type == "ak47":
			shoot_ak47(target_point,p_id)
		elif weapon.type == "pistol":
			shoot_pistol(target_point,p_id)
		elif weapon.type == "shotgun":
			shoot_shotgun(target_point,p_id)
		
func shoot_sniper(target_point,p_id):
	var weapon = weapon_parent.get_child(0)
	add_bullet(target_point,p_id)
	weapon.a_player.play("recoil")	
	pass

func shoot_ak47(target_point,p_id):
	var weapon = weapon_parent.get_child(0)
	add_bullet(target_point,p_id)
	weapon.a_player.play("recoil")
	pass

func shoot_pistol(target_point,p_id):
#	$Particles.emitting = false
#	$Particles2.emitting = false
#	$Particles.emitting = true
#	$Particles2.emitting = true
	var weapon = weapon_parent.get_child(0)
	weapon.a_player.play("recoil")
	add_bullet(target_point,p_id)
	pass

func shoot_shotgun(target_point,p_id):
	var weapon = weapon_parent.get_child(0)
	add_bullet(target_point,p_id)
	weapon.a_player.play("recoil")
	pass

func add_bullet(target_point,p_id):
	var weapon = weapon_parent.get_child(0)
	var bullet_instance = weapon.world.bullet_model.instance()
	var start_point = weapon.get_parent().get_parent().get_node("Camera").get_node("bullet_spawn").global_transform.origin
#	var start_point = weapon.get_node("front").global_transform.origin
	bullet_instance.parent = weapon.world.get_node("player")
	weapon.world.add_child(bullet_instance)
	bullet_instance.p_id = p_id
	bullet_instance.connect_signals_for_damage()
	bullet_instance.global_transform.origin = start_point
	bullet_instance.direction = (target_point - start_point).normalized()
	bullet_instance.look_at(target_point,Vector3.UP)
#	var message = {
#		"mes":"bullet_shot",
#		"info":{
#			"id":Client.data["id"],
#			"start_point":{
#				"x":start_point.x,
#				"y":start_point.y,
#				"z":start_point.z
#				},
#			"direction":{
#				"x":bullet_instance.direction.x,
#				"y":bullet_instance.direction.y,
#				"z":bullet_instance.direction.z
#			},
#			"target_point":{
#				"x":target_point.x,
#				"y":target_point.y,
#				"z":target_point.z
#			}
#		}
#	}
#	Client.send(message)
