# Abstract class for pulls
extends Object
class_name GachaPullLogic


func pull(_banner: BannerData, _count: int) -> Array[AdventurerData]:
	push_error("Class %s did not override abstract pull()" % self)
	return []
