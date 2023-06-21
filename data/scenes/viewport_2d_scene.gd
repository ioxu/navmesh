extends Node2D

@export var target_indicator : MeshInstance3D
@onready var target_indicator_sprite : Sprite2D = $target_indicator_sprite
@onready var o_dot_sprite : Sprite2D = $dot_sprite

var sprites : Array
var agents : Array
var pos : Array

var res := Vector2(2048, 2048)
var dim := Vector2(-5, 5)

var ipos_jitter := 1.5

func _ready():
	
	await get_tree().create_timer(0.1).timeout
	

	agents = get_tree().get_nodes_in_group("npcs")
	for n in agents.size():
		var sp = o_dot_sprite.duplicate()
		o_dot_sprite.get_parent().add_child( sp )
		sprites.append( sp )
		pos.append( Vector2(-200,-200) )
	print("viewport_2d_scene: %s"%[sprites.size()])


func _process(delta):
	var v : Vector3
	var ipos : Vector2
	
	#var ti := target_indicator.global_transform.origin
	#target_indicator_sprite.position = Vector2(remap(ti.x, -20, 20, 0, 2048), remap(ti.z, -20, 20, 0, 2048))
	
	for i in range(agents.size()):
		v = agents[i].global_transform.origin
		ipos = Vector2( remap(v.x, -20, 20, 0, 2048), remap(v.z, -20, 20, 0, 2048) )
		
		# avoid drawing heavy dots when standing almost still
		if (pos[i] - ipos).length() > 1.0 and not agents[i].target_has_been_reached:
			pos[i] = ipos
			sprites[i].modulate = Color(1.0, 1.0, 1.0, randf_range(2.0/255.0, 3.0/255.0))
			sprites[i].position = ipos + Vector2(randf_range(-ipos_jitter, ipos_jitter), randf_range(-ipos_jitter, ipos_jitter))
		else:
			sprites[i].position = Vector2(-3000,-3000)
