extends Camera2D

@export var camera_rect: Rect2
@export var camera_size: Vector2

@onready var player: CharacterBody2D

@export var move_speed = 0.5  # camera position lerp speed
@export var zoom_speed = 0.15  # camera zoom lerp speed
@export var min_zoom = 0.1  # camera won't zoom farther than this
@export var max_zoom = 0.7  # camera won't zoom closer than this
@export var margin = Vector2(400, 400)  # include some buffer area around targets
@export var drag_margin = Vector2(400, 300)

"""
@export var move_speed = 60
var move_direction = Vector2.ZERO
var can_move = false
"""
func _ready():
	"""
	move_direction = _get_move_direction()
	
	await get_tree().create_timer(1).timeout
	print("after timeour")
	can_move = true
	"""
	camera_size = get_viewport_rect().size * zoom # * camera.zoom
	camera_rect = Rect2(get_screen_center_position() - camera_size / 2, camera_size)

	player = %Character


func _process(delta):
	"""
	if can_move:
		position += move_direction * delta * move_speed
	"""
	camera_rect = Rect2(get_screen_center_position() - camera_size / 2, camera_size)

	# get ground under player
	var grounds = get_tree().get_nodes_in_group("ground")
	var ground_under_player = null
	for ground in grounds:
		var left_x = ground.global_position.x - ground.width / 2
		var right_x = ground.global_position.x + ground.width / 2
		if player.global_position.x < right_x and player.global_position.x > left_x:
			ground_under_player = ground
			break
	
	# change pos and zoom to show player + ground
	if ground_under_player:
		
		var player_pos = player.global_position
		var ground_pos = ground_under_player.global_position
		
		# is player within drag margins of screen?
		#print("camera_rect:", camera_rect)
		var center = get_screen_center_position()
		var drag_area: Rect2 = Rect2(center, drag_margin)
		if drag_area.has_point(player_pos):
			print("within drag area")
			return

		var midpoint_y = (ground_pos.y - ground_under_player.height/2 + player_pos.y - margin.y) * .5
		self.global_position = lerp(global_position, Vector2(player_pos.x, midpoint_y), move_speed)
		
		var zoom_factor_y = camera_size.y / abs(player_pos.y - ground_pos.y)
		var zoom_factor = min(max_zoom, max(min_zoom, zoom_factor_y))
		self.zoom = lerp(self.zoom, Vector2.ONE * zoom_factor, zoom_speed)
		
	else: 
		print("NO ground_under_player", ground_under_player)
		
"""
func _get_move_direction():
	var degrees = -10.0
	var radians = degrees * PI/180.0
	var run = 1.0
	var rise = tan(radians) * run
	return Vector2(run, rise)

"""		
