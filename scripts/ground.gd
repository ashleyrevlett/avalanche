extends StaticBody2D

@export var width: float = 1000
@export var height: float = 200

func _ready():
	$CollisionShape2D.shape.size = Vector2(width, height)
	$TextureRect.size = Vector2(width, height)
