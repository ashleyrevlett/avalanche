extends Camera2D

@export var camera_rect: Rect2
@export var altitude: float = 0 # y pos of ground below player


@onready var player: CharacterBody2D

@export var move_speed = 4  # camera position lerp speed
@export var zoom_speed = 4  # camera zoom lerp speed

# zoom : bigger numbers == zoom closer in
@export var min_zoom = 0.5  # camera won't zoom farther away than this
@export var max_zoom = 0.8 #  camera won't zoom closer than this 

@export var margin = Vector2(400, 300)  # include some buffer area around targets

var last_position: Vector2

func _ready():
	camera_rect = _get_camera_rect()
	player = %Character


func _process(delta):
	# get y position of ground under player,
	# adjust zoom and position so player and ground are both in camera frame

	# collide with ground on layer 3 / bit 2 / value 4
	var ground_mask = 0b00000000_00000000_00000000_00000100
	var ray_to = Vector2(player.global_position.x, player.global_position.y + 2000)
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var player_pos = player.global_position
	var query = PhysicsRayQueryParameters2D.create(player_pos, ray_to, ground_mask)
	var result = space_state.intersect_ray(query)
	if result:
		altitude = result.position.y
		# set zoom to try to see ground and player
		var ground_pos = result.position # in world space		
		var zoom_factor_y = camera_rect.size.y / abs((player_pos.y - margin.y) - (ground_pos.y + margin.y * 2))
		var zoom_factor = clamp(zoom_factor_y, min_zoom, max_zoom)
		#var zoom_factor = min(max_zoom, max(min_zoom, zoom_factor_y))
		zoom = lerp(self.zoom, Vector2.ONE * zoom_factor, zoom_speed * delta)
		#print("zoom_factor: ", zoom_factor, " : ", zoom_factor_y)
		
		# figure out where to position camera	
		var midpoint_y = (ground_pos.y + margin.y/4 + player_pos.y - margin.y) * .5
		var new_pos = Vector2(player_pos.x, midpoint_y)
				
		# if player is too far from ground, just focus on player
		if abs(ground_pos.y + margin.y - midpoint_y) > camera_rect.size.y - margin.y:
			#print("focusing on player only")
			new_pos.y = player_pos.y + margin.y

		# don't allow backwards movement
		#if (player_pos.x < last_position.x):
		#	new_pos.x = last_position.x
			
		global_position = lerp(global_position, new_pos, move_speed * delta)

	
	# if zoom has changed so will rect
	camera_rect = _get_camera_rect()
	last_position = global_position


func _get_camera_rect():
	var ctrans = get_canvas_transform()
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()

	# The maximum edge is obtained by adding the rectangle size.
	# Because it's a size it's only affected by zoom, so divide by scale too.
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size
	var r = Rect2(min_pos.x, min_pos.y, view_size.x, view_size.y)
	#print(r)
	return r

