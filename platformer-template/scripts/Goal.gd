extends Area2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		var hud = get_tree().root.get_node("Main/HUD")
		hud.show_message("Level Complete!")

# Load next level after a delay
#if body.name == "Player":
#    print("Level complete!")
#    await get_tree().create_timer(1).timeout
#    get_tree().change_scene_to_file("res://levels/Level02.tscn")
