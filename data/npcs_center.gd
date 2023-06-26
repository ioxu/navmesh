extends Node3D

var centroid : Vector3
var furthest_distance := 0.0
var _tmp_l : float

func _ready():
	pass # Replace with function body.


func _process(delta):
	centroid = Vector3.ZERO
	furthest_distance = 0
	var g = get_tree().get_nodes_in_group("npcs")
	for p in g:
		centroid += p.global_transform.origin
		_tmp_l = (self.global_transform.origin - p.global_transform.origin).length() 
		if  _tmp_l > furthest_distance:
			furthest_distance = _tmp_l
	centroid = centroid / g.size()
	self.global_transform.origin = centroid
	furthest_distance *= 2
	$extent_sphere.set_scale( Vector3( furthest_distance, furthest_distance, furthest_distance ) )
