extends Resource 
class_name Party

# Properties
var silver: int = 0
var day: int = 0
var pcs: Array = []

func add_pc(pc) -> void:
    pcs.append(pc)