extends CharacterBody3D

var colour_default := Color(0.89527487754822, 0, 0.35892423987389)
var colour_reached_target := Color(0.06159999221563, 0.87999999523163, 0.08887995779514)
var colour_navigation_finished := Color(0.9200000166893, 0.5731600522995, 0.11959999799728)
var color_stick_timer_timeout := Color(0.17999997735023, 0.25200006365776, 0.89999997615814)

const SPEED = 10.0#15.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var previous_waypoint : Vector3
var jump := Vector3.ZERO
var do_jump := false

var target_has_been_reached := false


func _ready():
	var mat = $MeshInstance3D.get_surface_override_material(0)
	var new_mat = StandardMaterial3D.new()
	$MeshInstance3D.set_surface_override_material(0, new_mat )
	set_colour( colour_default )
	new_mat.emission_enabled = true
	new_mat.emission_energy_multiplier = 0.5
	
	previous_waypoint = self.global_transform.origin
	$stuck_timer.connect("timeout", _on_stuck_timer_timeout)


func _on_stuck_timer_timeout() -> void:
	$stuck_timer.wait_time = randf_range( 0.25, 1.5 )
	if not target_has_been_reached:
		set_colour( color_stick_timer_timeout )
		do_jump = true


func update_target_location( target_location ) -> void:
	target_has_been_reached = false
	$stuck_timer.start()
	nav_agent.set_target_position( target_location )
	if nav_agent.is_target_reachable():
		nav_agent.set_debug_path_custom_color( Color.from_hsv( .13 + randf_range( -0.05, 0.05 ), 1.0, 1.0, 0.001 ) )
	else:
		nav_agent.set_debug_path_custom_color( Color.from_hsv( (259/360.0) + randf_range( -0.03, 0.03 ), 0.65, 1.0, 0.001 ) )


func _physics_process(delta):
	var current_location = global_transform.origin
	var new_velocity : Vector3
	var next_location = nav_agent.get_next_path_position() + (Vector3.UP * 0.75)
	
	# restart stuck_timer
	if not next_location.is_equal_approx( previous_waypoint ):
		previous_waypoint = next_location
		$stuck_timer.start()

	$nav_indicator.end_point = next_location
	new_velocity = (next_location - current_location).normalized() * SPEED


	velocity = velocity.move_toward( new_velocity, 0.5) #0.75 )
	velocity += Vector3.UP * -9.8 *0.25
	if do_jump:
		velocity += Vector3.UP * 30.0
		do_jump = false
	move_and_slide()
	#nav_agent.set_velocity(velocity)


	if global_transform.origin.y < -50.0:
		print("RESPAWN")
		global_transform.origin = Vector3(randf_range(-10.0, 10.0), 15.0, randf_range(-10.0, 10.0))
		velocity = velocity * Vector3(1.0, 0.0, 1.0)
		update_target_location( nav_agent.target_position )


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward( safe_velocity, 0.8 )
	move_and_slide()


func set_colour( colour : Color  ) -> void:
	$MeshInstance3D.get_surface_override_material(0).albedo_color = colour
	$MeshInstance3D.get_surface_override_material(0).emission = colour


func _on_navigation_agent_3d_target_reached():
	#$stuck_timer.stop()
	target_has_been_reached = true
	set_colour( colour_reached_target )


func _on_navigation_agent_3d_path_changed():
	$stuck_timer.start()
	set_colour( colour_default )


func _on_navigation_agent_3d_navigation_finished():
	#$stuck_timer.stop()
	if not target_has_been_reached:
		set_colour( colour_navigation_finished )


func _on_navigation_agent_3d_waypoint_reached(details):
	if not target_has_been_reached:
		set_colour( colour_default )
