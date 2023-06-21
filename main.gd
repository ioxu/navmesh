extends Node3D

var SHOW_NAVMESH = true

var navregion : NavigationRegion3D
var navmesh_vismesh : MeshInstance3D

@onready var target_indicator : MeshInstance3D = $target_indicator

@onready var npc : CharacterBody3D = $npc

@onready var vp_tex_material = preload("res://data/materials/simple_ground_material.tres")

var vp_tex : ViewportTexture

var start_bake_time : int

var oblock : MeshInstance3D
var pole : MeshInstance3D

func _ready():
	oblock = find_child("block")
	var _p = oblock.get_parent()
	var _rotxz = 75
	for i in range(5):
		var d = oblock.duplicate()
		_p.add_child( d )
		d.rotation_degrees = Vector3(randf_range(-_rotxz,_rotxz), randf_range(-180,180), randf_range(-_rotxz,_rotxz))
		d.global_transform.origin = Vector3( randf_range( -20, 20 ), randf_range(-3.0, 1.5), randf_range(-20, 20) )

	_rotxz = 15
	for i in range(120):
		var d = oblock.duplicate()
		_p.add_child( d )
		d.rotation_degrees = Vector3(randf_range(-_rotxz,_rotxz), randf_range(-180,180), randf_range(-_rotxz,_rotxz))
		d.scale = Vector3(1.5, 1.0, 1.5)
		d.global_transform.origin = Vector3( randf_range( -20, 20 ), 0.15, randf_range(-20, 20) )


	pole = find_child("pole")
	for i in range (12):
		var d = pole.duplicate()
		_p.add_child(d)
		d.rotation_degrees = Vector3(randf_range(-_rotxz,_rotxz), randf_range(-180,180), randf_range(-_rotxz,_rotxz))
		d.global_transform.origin = Vector3( randf_range( -20, 20 ), randf_range(-1.0, 2.5) , randf_range(-20, 20) )

	
	navregion = find_child("NavigationRegion3D")
	navregion.connect("bake_finished", _on_bake_finished)
	print("navregion: %s"%navregion)
	print("bake begin")
	start_bake_time = Time.get_ticks_usec()

	navmesh_vismesh = find_child("navmesh_visualisation")
	$target_timer.connect("timeout", _on_target_timer_timeout)

	_p = npc.get_parent()
	var npc_debug_color = npc.find_child("NavigationAgent3D").debug_path_custom_color
	for i in range(35):#35):
		var npc_copy = npc.duplicate()
		_p.add_child(npc_copy)
		npc_copy.global_transform.origin = Vector3( randf_range( -15, 15 ), npc.global_transform.origin.y, randf_range( -15, 15 ))
		var nav_agent : NavigationAgent3D = npc_copy.find_child("NavigationAgent3D") 
#		if nav_agent.is_target_reachable():
#			nav_agent.set_debug_path_custom_color( Color.from_hsv( .13 + randf_range( -0.15, 0.15 ), 1.0, 1.0, 0.001 ) )
#		else:
#			nav_agent.set_debug_path_custom_color( Color.from_hsv( (259/360.0) + randf_range( -0.15, 0.15 ), 1.0, 1.0, 0.001 ) )

	# need to pause because CSG combiner isn't ready :/
	await get_tree().create_timer(0.5).timeout
	navregion.bake_navigation_mesh()

	# material
	vp_tex = $SubViewport.get_texture() #ViewportTexture.new()
	print("vp_tex: %s"%vp_tex)
	#vp_tex.viewport_path = $SubViewport.get_path()
	print("vp_tex.get_viewport_path_in_scene(): %s"%vp_tex.get_viewport_path_in_scene())
	var mat = $"NavigationRegion3D/simple-ground_01-01/Plane".material_override
	print("mat: %s"%mat)
	#mat.albedo_color = Color(0.5564603805542, 0.07987264543772, 0.28704124689102) 
	#mat.albedo_texture = vp_tex
	#print("mat.albedo_texture: %s"%mat.albedo_texture)
	#mat.texture_albedo = vp_tex
	mat.set("shader_parameter/texture_albedo", vp_tex)
	mat.set("shader_parameter/texture_emission", vp_tex)
	print("mat.shader_parameter/texture_albedo: %s"%mat.get("shader_parameter/texture_albedo"))



func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _process(delta):
	pass


func _on_bake_finished() -> void:
	print("navregion bake finished: %s seconds"%( (Time.get_ticks_usec() - start_bake_time)/1e+6 ) )
	print("navregion: %s"%navregion)
	var navmesh = navregion.navigation_mesh
	print("navmesh: %s"%navmesh)
	print("  polygons: %s"%navmesh.get_polygon_count())
	print("  vertices: %s"%navmesh.get_vertices().size())
	
	if SHOW_NAVMESH:
		var arr_mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		var vertex_array = navmesh.get_vertices()
		arrays[Mesh.ARRAY_VERTEX] = vertex_array
		var index_array = PackedInt32Array()
		for ip in range(navmesh.get_polygon_count()):
			var pva = navmesh.get_polygon(ip)
			index_array += pva
		arrays[Mesh.ARRAY_INDEX ] = index_array
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		#------ WIREFRAME ----
		#arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays )
		#------ WIREFRAME ----
		navmesh_vismesh.mesh = arr_mesh


func _on_target_timer_timeout() -> void:
	#print("_on_target_timer_timeout")
	#var pos : Vector3 = Vector3( randf_range( -20, 20 ), 0.0, randf_range( -20, 20 ) )
	var pos : Vector3 = Vector3( randf_range( 18.0, 5.0 ), 0.0, 0.0 ).rotated( Vector3.UP, randf()*2*PI)
	target_indicator.global_transform.origin = pos
	#get_tree().call_group( "npcs", "update_target_location", pos + Vector3( randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0) ) )
	var npcs : Array = get_tree().get_nodes_in_group("npcs")
	for _npc in npcs:
		_npc.update_target_location(  pos + Vector3( randf_range(-1.5, 1.5), 0.0, randf_range(-1.5, 1.5) ) )

