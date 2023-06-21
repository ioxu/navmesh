extends MeshInstance3D

@export var end_point : Vector3

var p2 : Vector3

func _ready():
	var m = self.mesh.duplicate()
	self.mesh = m


func _process(delta):
	p2 = - self.get_parent().global_transform.origin + end_point 

	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(p2)
	mesh.surface_add_vertex(Vector3(0, 0, 0))
	mesh.surface_end()
