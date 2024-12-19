extends Resource 
class_name PC

# Properties
var hp: int = 10
var max_hp: int = 10
var level: int = 1

# Stats are 1-5, 2 being the standard/average
var strength: int = 2
var smarts: int = 2
var social: int = 2
var stealth: int = 2
var speed: int = 2
var stuff: Array[String] = []
var status: Array[String] = []
var pc_class: String = "commoner"

# Aesthetics 
var name: String 
var color: Color

# Constructor
func _init(pc_name: String, pc_class: String, pc_color: Color) -> void:
    self.name = pc_name
    self.pc_class = pc_class
    self.color = pc_color
