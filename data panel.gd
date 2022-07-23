extends Control


onready var info_box = $HBoxContainer
onready var info_box_container = $VBoxContainer
var count
var info_boxes = {}

func _ready():
	pass 

func ready_client(id):
	info_boxes[id].get_node("state").text = "ready"
	
func update_state_box(id,state):
	print(state)
	print(state[str(id)])
	info_boxes[(id)].get_node("state").text = state[str(id)]

func add_box(id):
	var new_info_box = info_box.duplicate()
#	new_info_box.get_node("name").text = p_name
	new_info_box.visible = true
	new_info_box.get_node("id").text = str(id)
	info_box_container.add_child(new_info_box)
	info_boxes[id] = new_info_box

func remove_box(id):
	info_boxes[id].queue_free()
	info_boxes.erase(id)



func _on_Timer_timeout():
	if count > 0 :
		$Timer.start()
		count -= 1
		$timer.text = str(int($timer.text) + 1 )
