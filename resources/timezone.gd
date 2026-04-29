@tool
class_name Timezone
extends Resource

enum Zone {
	UTC = 0,
	UTC_MINUS_12_00,
	UTC_MINUS_11_00,
	UTC_MINUS_10_00,
	UTC_MINUS_09_30,
	UTC_MINUS_09_00,
	UTC_MINUS_08_00,
	UTC_MINUS_07_00,
	UTC_MINUS_06_00,
	UTC_MINUS_05_00,
	UTC_MINUS_04_00,
	UTC_MINUS_03_30,
	UTC_MINUS_03_00,
	UTC_MINUS_02_00,
	UTC_MINUS_01_00,
	UTC_PLUS_01_00,
	UTC_PLUS_02_00,
	UTC_PLUS_03_00,
	UTC_PLUS_03_30,
	UTC_PLUS_04_00,
	UTC_PLUS_04_30,
	UTC_PLUS_05_00,
	UTC_PLUS_05_30,
	UTC_PLUS_05_45,
	UTC_PLUS_06_00,
	UTC_PLUS_06_30,
	UTC_PLUS_07_00,
	UTC_PLUS_08_00,
	UTC_PLUS_08_45,
	UTC_PLUS_09_00,
	UTC_PLUS_09_30,
	UTC_PLUS_10_00,
	UTC_PLUS_10_30,
	UTC_PLUS_11_00,
	UTC_PLUS_12_00,
	UTC_PLUS_12_45,
	UTC_PLUS_13_00,
	UTC_PLUS_13_45,
	UTC_PLUS_14_00,
	GMT,
	WET,
	WEST,
	CET,
	CEST,
	EET,
	EEST,
	MSK,
	BST,
	IST,
	CST_CHINA,
	JST,
	AEST,
	NZST,
	NZDT,
	AST,
	ADT,
	EST,
	EDT,
	CST,
	CDT,
	MST,
	MDT,
	PST,
	PDT,
	AKST,
	AKDT,
	HST,
}

const DATA = {
	Zone.UTC: {"label": "UTC +00:00", "offset_minutes": 0, "examples": ["UTC", "London", "Accra"]},
	Zone.UTC_MINUS_12_00: {"label": "UTC -12:00", "offset_minutes": -720, "examples": ["Baker Island", "Howland Island"]},
	Zone.UTC_MINUS_11_00: {"label": "UTC -11:00", "offset_minutes": -660, "examples": ["Pago Pago", "Niue"]},
	Zone.UTC_MINUS_10_00: {"label": "UTC -10:00", "offset_minutes": -600, "examples": ["Honolulu", "Tahiti"]},
	Zone.UTC_MINUS_09_30: {"label": "UTC -09:30", "offset_minutes": -570, "examples": ["Marquesas Islands"]},
	Zone.UTC_MINUS_09_00: {"label": "UTC -09:00", "offset_minutes": -540, "examples": ["Anchorage", "Gambier Islands"]},
	Zone.UTC_MINUS_08_00: {"label": "UTC -08:00", "offset_minutes": -480, "examples": ["Los Angeles", "Vancouver"]},
	Zone.UTC_MINUS_07_00: {"label": "UTC -07:00", "offset_minutes": -420, "examples": ["Denver", "Phoenix"]},
	Zone.UTC_MINUS_06_00: {"label": "UTC -06:00", "offset_minutes": -360, "examples": ["Mexico City", "Chicago"]},
	Zone.UTC_MINUS_05_00: {"label": "UTC -05:00", "offset_minutes": -300, "examples": ["New York", "Lima"]},
	Zone.UTC_MINUS_04_00: {"label": "UTC -04:00", "offset_minutes": -240, "examples": ["Santiago", "Caracas"]},
	Zone.UTC_MINUS_03_30: {"label": "UTC -03:30", "offset_minutes": -210, "examples": ["Newfoundland"]},
	Zone.UTC_MINUS_03_00: {"label": "UTC -03:00", "offset_minutes": -180, "examples": ["Buenos Aires", "Sao Paulo"]},
	Zone.UTC_MINUS_02_00: {"label": "UTC -02:00", "offset_minutes": -120, "examples": ["South Georgia"]},
	Zone.UTC_MINUS_01_00: {"label": "UTC -01:00", "offset_minutes": -60, "examples": ["Azores", "Cape Verde"]},
	Zone.UTC_PLUS_01_00: {"label": "UTC +01:00", "offset_minutes": 60, "examples": ["Lisbon", "Lagos"]},
	Zone.UTC_PLUS_02_00: {"label": "UTC +02:00", "offset_minutes": 120, "examples": ["Maputo", "Cairo"]},
	Zone.UTC_PLUS_03_00: {"label": "UTC +03:00", "offset_minutes": 180, "examples": ["Nairobi", "Moscow"]},
	Zone.UTC_PLUS_03_30: {"label": "UTC +03:30", "offset_minutes": 210, "examples": ["Tehran"]},
	Zone.UTC_PLUS_04_00: {"label": "UTC +04:00", "offset_minutes": 240, "examples": ["Dubai", "Baku"]},
	Zone.UTC_PLUS_04_30: {"label": "UTC +04:30", "offset_minutes": 270, "examples": ["Kabul"]},
	Zone.UTC_PLUS_05_00: {"label": "UTC +05:00", "offset_minutes": 300, "examples": ["Karachi", "Tashkent"]},
	Zone.UTC_PLUS_05_30: {"label": "UTC +05:30", "offset_minutes": 330, "examples": ["Mumbai", "Colombo"]},
	Zone.UTC_PLUS_05_45: {"label": "UTC +05:45", "offset_minutes": 345, "examples": ["Kathmandu"]},
	Zone.UTC_PLUS_06_00: {"label": "UTC +06:00", "offset_minutes": 360, "examples": ["Dhaka", "Almaty"]},
	Zone.UTC_PLUS_06_30: {"label": "UTC +06:30", "offset_minutes": 390, "examples": ["Yangon", "Cocos Islands"]},
	Zone.UTC_PLUS_07_00: {"label": "UTC +07:00", "offset_minutes": 420, "examples": ["Bangkok", "Jakarta"]},
	Zone.UTC_PLUS_08_00: {"label": "UTC +08:00", "offset_minutes": 480, "examples": ["Beijing", "Singapore"]},
	Zone.UTC_PLUS_08_45: {"label": "UTC +08:45", "offset_minutes": 525, "examples": ["Eucla"]},
	Zone.UTC_PLUS_09_00: {"label": "UTC +09:00", "offset_minutes": 540, "examples": ["Tokyo", "Seoul"]},
	Zone.UTC_PLUS_09_30: {"label": "UTC +09:30", "offset_minutes": 570, "examples": ["Adelaide", "Darwin"]},
	Zone.UTC_PLUS_10_00: {"label": "UTC +10:00", "offset_minutes": 600, "examples": ["Sydney", "Port Moresby"]},
	Zone.UTC_PLUS_10_30: {"label": "UTC +10:30", "offset_minutes": 630, "examples": ["Lord Howe Island"]},
	Zone.UTC_PLUS_11_00: {"label": "UTC +11:00", "offset_minutes": 660, "examples": ["Noumea", "Solomon Islands"]},
	Zone.UTC_PLUS_12_00: {"label": "UTC +12:00", "offset_minutes": 720, "examples": ["Auckland", "Fiji"]},
	Zone.UTC_PLUS_12_45: {"label": "UTC +12:45", "offset_minutes": 765, "examples": ["Chatham Islands"]},
	Zone.UTC_PLUS_13_00: {"label": "UTC +13:00", "offset_minutes": 780, "examples": ["Apia", "Tonga"]},
	Zone.UTC_PLUS_13_45: {"label": "UTC +13:45", "offset_minutes": 825, "examples": ["Chatham Islands daylight time"]},
	Zone.UTC_PLUS_14_00: {"label": "UTC +14:00", "offset_minutes": 840, "examples": ["Kiritimati"]},
	Zone.GMT: {"label": "GMT", "offset_minutes": 0, "examples": ["Greenwich Mean Time"]},
	Zone.WET: {"label": "WET", "offset_minutes": 0, "examples": ["Western European Time"]},
	Zone.WEST: {"label": "WEST", "offset_minutes": 60, "examples": ["Western European Summer Time"]},
	Zone.CET: {"label": "CET", "offset_minutes": 60, "examples": ["Central European Time"]},
	Zone.CEST: {"label": "CEST", "offset_minutes": 120, "examples": ["Central European Summer Time"]},
	Zone.EET: {"label": "EET", "offset_minutes": 120, "examples": ["Eastern European Time"]},
	Zone.EEST: {"label": "EEST", "offset_minutes": 180, "examples": ["Eastern European Summer Time"]},
	Zone.MSK: {"label": "MSK", "offset_minutes": 180, "examples": ["Moscow Time"]},
	Zone.BST: {"label": "BST", "offset_minutes": 60, "examples": ["British Summer Time"]},
	Zone.IST: {"label": "IST", "offset_minutes": 330, "examples": ["India Standard Time"]},
	Zone.CST_CHINA: {"label": "CST China", "offset_minutes": 480, "examples": ["China Standard Time"]},
	Zone.JST: {"label": "JST", "offset_minutes": 540, "examples": ["Japan Standard Time"]},
	Zone.AEST: {"label": "AEST", "offset_minutes": 600, "examples": ["Australian Eastern Standard Time"]},
	Zone.NZST: {"label": "NZST", "offset_minutes": 720, "examples": ["New Zealand Standard Time"]},
	Zone.NZDT: {"label": "NZDT", "offset_minutes": 780, "examples": ["New Zealand Daylight Time"]},
	Zone.AST: {"label": "AST", "offset_minutes": -240, "examples": ["Atlantic Standard Time"]},
	Zone.ADT: {"label": "ADT", "offset_minutes": -180, "examples": ["Atlantic Daylight Time"]},
	Zone.EST: {"label": "EST", "offset_minutes": -300, "examples": ["Eastern Standard Time"]},
	Zone.EDT: {"label": "EDT", "offset_minutes": -240, "examples": ["Eastern Daylight Time"]},
	Zone.CST: {"label": "CST", "offset_minutes": -360, "examples": ["Central Standard Time"]},
	Zone.CDT: {"label": "CDT", "offset_minutes": -300, "examples": ["Central Daylight Time"]},
	Zone.MST: {"label": "MST", "offset_minutes": -420, "examples": ["Mountain Standard Time"]},
	Zone.MDT: {"label": "MDT", "offset_minutes": -360, "examples": ["Mountain Daylight Time"]},
	Zone.PST: {"label": "PST", "offset_minutes": -480, "examples": ["Pacific Standard Time"]},
	Zone.PDT: {"label": "PDT", "offset_minutes": -420, "examples": ["Pacific Daylight Time"]},
	Zone.AKST: {"label": "AKST", "offset_minutes": -540, "examples": ["Alaska Standard Time"]},
	Zone.AKDT: {"label": "AKDT", "offset_minutes": -480, "examples": ["Alaska Daylight Time"]},
	Zone.HST: {"label": "HST", "offset_minutes": -600, "examples": ["Hawaii Standard Time"]},
}

const ORDERED_ZONES = [
	Zone.UTC,
	Zone.UTC_MINUS_12_00,
	Zone.UTC_MINUS_11_00,
	Zone.UTC_MINUS_10_00,
	Zone.UTC_MINUS_09_30,
	Zone.UTC_MINUS_09_00,
	Zone.UTC_MINUS_08_00,
	Zone.UTC_MINUS_07_00,
	Zone.UTC_MINUS_06_00,
	Zone.UTC_MINUS_05_00,
	Zone.UTC_MINUS_04_00,
	Zone.UTC_MINUS_03_30,
	Zone.UTC_MINUS_03_00,
	Zone.UTC_MINUS_02_00,
	Zone.UTC_MINUS_01_00,
	Zone.UTC_PLUS_01_00,
	Zone.UTC_PLUS_02_00,
	Zone.UTC_PLUS_03_00,
	Zone.UTC_PLUS_03_30,
	Zone.UTC_PLUS_04_00,
	Zone.UTC_PLUS_04_30,
	Zone.UTC_PLUS_05_00,
	Zone.UTC_PLUS_05_30,
	Zone.UTC_PLUS_05_45,
	Zone.UTC_PLUS_06_00,
	Zone.UTC_PLUS_06_30,
	Zone.UTC_PLUS_07_00,
	Zone.UTC_PLUS_08_00,
	Zone.UTC_PLUS_08_45,
	Zone.UTC_PLUS_09_00,
	Zone.UTC_PLUS_09_30,
	Zone.UTC_PLUS_10_00,
	Zone.UTC_PLUS_10_30,
	Zone.UTC_PLUS_11_00,
	Zone.UTC_PLUS_12_00,
	Zone.UTC_PLUS_12_45,
	Zone.UTC_PLUS_13_00,
	Zone.UTC_PLUS_13_45,
	Zone.UTC_PLUS_14_00,
	Zone.GMT,
	Zone.WET,
	Zone.WEST,
	Zone.CET,
	Zone.CEST,
	Zone.EET,
	Zone.EEST,
	Zone.MSK,
	Zone.BST,
	Zone.IST,
	Zone.CST_CHINA,
	Zone.JST,
	Zone.AEST,
	Zone.NZST,
	Zone.NZDT,
	Zone.AST,
	Zone.ADT,
	Zone.EST,
	Zone.EDT,
	Zone.CST,
	Zone.CDT,
	Zone.MST,
	Zone.MDT,
	Zone.PST,
	Zone.PDT,
	Zone.AKST,
	Zone.AKDT,
	Zone.HST,
]

static func get_zones() -> Array:
	return ORDERED_ZONES.duplicate()

static func get_labels() -> Array[String]:
	var labels: Array[String] = []
	for zone in ORDERED_ZONES:
		labels.push_back(get_label(zone))
	return labels

static func get_labels_string(separator:= ", ") -> String:
	var text:= ""
	for label in get_labels():
		if !text.is_empty():
			text += separator
		text += label
	return text

static func get_zone_from_label(label: String) -> Zone:
	var normalized_label = _normalize_label(label)
	for zone in ORDERED_ZONES:
		if _normalize_label(get_label(zone)) == normalized_label:
			return zone
	return Zone.UTC

static func get_data(zone: Zone) -> Dictionary:
	return DATA.get(zone, DATA[Zone.UTC])

static func get_offset_minutes(zone: Zone) -> int:
	return get_data(zone)["offset_minutes"]

static func get_offset_seconds(zone: Zone) -> int:
	return get_offset_minutes(zone) * 60

static func get_label(zone: Zone) -> String:
	return get_data(zone)["label"]

static func get_examples(zone: Zone) -> Array:
	return get_data(zone)["examples"]

static func _normalize_label(label: String) -> String:
	return label.strip_edges().to_upper().replace(" ", "")
