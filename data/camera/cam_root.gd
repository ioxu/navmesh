extends Node3D

var gtime := 0.0


func _ready():
	pass 


func _process(delta):
	gtime += delta
	global_rotate( Vector3.UP, 0.125*delta)
