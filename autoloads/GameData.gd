extends Node
# GameData.gd — Autoload
# Central data definitions for SHARC.

# ─────────────────────────────────────────────
#  SHARK RARITY TIERS
# ─────────────────────────────────────────────
enum Rarity {
	LEAST_CONCERNED,       # 0
	NEAR_THREATENED,       # 1
	VULNERABLE,            # 2
	ENDANGERED,            # 3
	CRITICALLY_ENDANGERED, # 4
	SPECIAL                # 5
}

# ─────────────────────────────────────────────
#  EGG COSTS
# ─────────────────────────────────────────────
const EGG_COSTS: Dictionary = {
	0: 100,
	1: 300,
	2: 700,
	3: 1500,
	4: 3500,
	5: 8000,
}

# ─────────────────────────────────────────────
#  SHARK CATALOG
#  "weight" controls drop rate within the same egg tier.
#  Higher weight = more common. First shark in each tier
#  has the highest weight, last has the lowest.
# ─────────────────────────────────────────────
const SHARK_CATALOG: Array = [
	# LEAST CONCERNED
	{ "id": 0,  "name": "Leopard Shark",       "rarity": 0, "weight": 100, "description": "A beautifully patterned shark found along the Pacific coast.",     "affinity_group": "reef" },
	{ "id": 1,  "name": "Nurse Shark",         "rarity": 0, "weight": 85,  "description": "A sluggish bottom-dweller that rests in groups during the day.",   "affinity_group": "reef" },
	{ "id": 2,  "name": "Epaulette Shark",     "rarity": 0, "weight": 70,  "description": "Can walk on land using its fins to cross tide pools.",             "affinity_group": "reef" },
	{ "id": 3,  "name": "Cat Shark",           "rarity": 0, "weight": 55,  "description": "Small, spotted, and secretive — loves hiding in crevices.",        "affinity_group": "reef" },
	{ "id": 4,  "name": "Smoothhound",         "rarity": 0, "weight": 40,  "description": "A slender coastal shark with a preference for crustaceans.",       "affinity_group": "coastal" },
	{ "id": 5,  "name": "Whiskery Shark",      "rarity": 0, "weight": 25,  "description": "Named for its prominent nasal barbels that resemble whiskers.",    "affinity_group": "coastal" },
	{ "id": 6,  "name": "Horn Shark",          "rarity": 0, "weight": 10,  "description": "Sports two dorsal spines and a blunt pig-like snout.",             "affinity_group": "reef" },
	# NEAR THREATENED
	{ "id": 7,  "name": "Zebra Shark",         "rarity": 1, "weight": 100, "description": "Adults are spotted; juveniles have bold zebra stripes.",           "affinity_group": "reef" },
	{ "id": 8,  "name": "Angel Shark",         "rarity": 1, "weight": 82,  "description": "Flattened like a ray and ambushes prey from the seafloor.",        "affinity_group": "coastal" },
	{ "id": 9,  "name": "School Shark",        "rarity": 1, "weight": 64,  "description": "Travels in large schools and was once heavily fished.",            "affinity_group": "pelagic" },
	{ "id": 10, "name": "Silvertip Shark",     "rarity": 1, "weight": 46,  "description": "Recognisable by the white tips on all its fins.",                  "affinity_group": "pelagic" },
	{ "id": 11, "name": "Salmon Shark",        "rarity": 1, "weight": 28,  "description": "A fast warm-bodied shark that hunts Pacific salmon.",              "affinity_group": "pelagic" },
	{ "id": 12, "name": "Night Shark",         "rarity": 1, "weight": 16,  "description": "Large green eyes help it hunt at depth after dark.",               "affinity_group": "pelagic" },
	{ "id": 13, "name": "Milk Shark",          "rarity": 1, "weight": 6,   "description": "Folklore says its meat boosts milk production in nursing mothers.", "affinity_group": "coastal" },
	# VULNERABLE
	{ "id": 14, "name": "Hammerhead Shark",    "rarity": 2, "weight": 100, "description": "Its wide head gives it exceptional 360-degree vision.",            "affinity_group": "hammerhead" },
	{ "id": 15, "name": "Bull Shark",          "rarity": 2, "weight": 88,  "description": "Can survive in freshwater and is found far up rivers.",            "affinity_group": "coastal" },
	{ "id": 16, "name": "Lemon Shark",         "rarity": 2, "weight": 76,  "description": "Yellow-brown skin provides camouflage over sandy flats.",          "affinity_group": "coastal" },
	{ "id": 17, "name": "Sandbar Shark",       "rarity": 2, "weight": 64,  "description": "One of the largest coastal sharks in the world.",                  "affinity_group": "coastal" },
	{ "id": 18, "name": "Spinner Shark",       "rarity": 2, "weight": 52,  "description": "Leaps and spins out of the water when pursuing baitfish.",         "affinity_group": "pelagic" },
	{ "id": 19, "name": "Silky Shark",         "rarity": 2, "weight": 40,  "description": "Named for its unusually smooth skin texture.",                     "affinity_group": "pelagic" },
	{ "id": 20, "name": "Finetooth Shark",     "rarity": 2, "weight": 28,  "description": "Small and slender with very fine teeth.",                          "affinity_group": "coastal" },
	{ "id": 21, "name": "Hardnose Shark",      "rarity": 2, "weight": 16,  "description": "A tough cartilaginous snout earns this shark its name.",           "affinity_group": "coastal" },
	{ "id": 22, "name": "Kitefin Shark",       "rarity": 2, "weight": 8,   "description": "One of the largest bioluminescent vertebrates on Earth.",          "affinity_group": "deep" },
	{ "id": 23, "name": "Cookiecutter Shark",  "rarity": 2, "weight": 3,   "description": "Carves perfect circular plugs of flesh from much larger animals.", "affinity_group": "deep" },
	# ENDANGERED
	{ "id": 24, "name": "Dusky Shark",         "rarity": 3, "weight": 100, "description": "A wide-ranging ocean wanderer that matures very slowly.",          "affinity_group": "pelagic" },
	{ "id": 25, "name": "Goblin Shark",        "rarity": 3, "weight": 80,  "description": "Its jaw can shoot forward to snap up prey in an instant.",         "affinity_group": "deep" },
	{ "id": 26, "name": "Frilled Shark",       "rarity": 3, "weight": 60,  "description": "An ancient species with a snake-like body and frilly gill slits.", "affinity_group": "deep" },
	{ "id": 27, "name": "Gulper Shark",        "rarity": 3, "weight": 40,  "description": "A small deep-sea shark targeted for its liver oil.",               "affinity_group": "deep" },
	{ "id": 28, "name": "Sombre Catshark",     "rarity": 3, "weight": 22,  "description": "A rarely seen deep-water catshark with dark colouration.",         "affinity_group": "deep" },
	{ "id": 29, "name": "Velvet Dogfish",      "rarity": 3, "weight": 10,  "description": "Soft velvety skin and tiny photophores dot its underside.",        "affinity_group": "deep" },
	{ "id": 30, "name": "Mosaic Gulper Shark", "rarity": 3, "weight": 3,   "description": "Patterned like a mosaic tile — and just as hard to find.",         "affinity_group": "deep" },
	# CRITICALLY ENDANGERED
	{ "id": 31, "name": "Great White Shark",   "rarity": 4, "weight": 100, "description": "The ocean's apex predator and a symbol of the deep.",              "affinity_group": "pelagic" },
	{ "id": 32, "name": "Whale Shark",         "rarity": 4, "weight": 80,  "description": "The largest fish on Earth — and it only eats plankton.",           "affinity_group": "pelagic" },
	{ "id": 33, "name": "Basking Shark",       "rarity": 4, "weight": 60,  "description": "The second largest fish, filter-feeding at the surface.",          "affinity_group": "pelagic" },
	{ "id": 34, "name": "Greenland Shark",     "rarity": 4, "weight": 40,  "description": "Can live over 400 years — the oldest living vertebrate.",          "affinity_group": "deep" },
	{ "id": 35, "name": "Bahamas Sawshark",    "rarity": 4, "weight": 22,  "description": "Its long serrated rostrum is used to slash and stun prey.",        "affinity_group": "coastal" },
	{ "id": 36, "name": "Winghead Shark",      "rarity": 4, "weight": 10,  "description": "Its head is nearly half the width of its body.",                   "affinity_group": "hammerhead" },
	{ "id": 37, "name": "Slit-eye Shark",      "rarity": 4, "weight": 3,   "description": "Named for its distinctive narrow slit-like eyes.",                 "affinity_group": "deep" },
	# SPECIAL
	{ "id": 38, "name": "Megalodon",           "rarity": 5, "weight": 100, "description": "An extinct titan that ruled the prehistoric seas. How is it here?","affinity_group": "special" },
	{ "id": 39, "name": "Megamouth Shark",     "rarity": 5, "weight": 75,  "description": "Discovered in 1976. Still barely studied. Still mysterious.",      "affinity_group": "special" },
	{ "id": 40, "name": "Pacific Sleeper Shark","rarity": 5, "weight": 55,  "description": "A giant of the deep Pacific with almost no data on its life.",     "affinity_group": "deep" },
	{ "id": 41, "name": "Pinocchio Catshark",  "rarity": 5, "weight": 35,  "description": "Extremely rare sightings — some doubt it even exists.",            "affinity_group": "special" },
	{ "id": 42, "name": "Ornate Dogfish",      "rarity": 5, "weight": 20,  "description": "So little is known, its entry in the index is mostly blank.",      "affinity_group": "special" },
	{ "id": 43, "name": "Novaliches Shark",    "rarity": 5, "weight": 10,  "description": "Whispers of this shark echo through the sanctuary archives.",       "affinity_group": "special" },
	{ "id": 44, "name": "Tralalero Tralala",   "rarity": 5, "weight": 5,   "description": "No one can explain it. It simply appeared one day.",               "affinity_group": "special" },
	{ "id": 45, "name": "Plunket Shark",       "rarity": 5, "weight": 3,   "description": "A deep-sea relic that surfaces once in a generation.",              "affinity_group": "deep" },
	{ "id": 46, "name": "Frog Shark",          "rarity": 5, "weight": 1,   "description": "The rarest of all. Some say it never existed at all.",             "affinity_group": "special" },
]

# ─────────────────────────────────────────────
#  WEIGHTED HATCH HELPER
#  Picks a shark from a rarity pool using weights.
#  Higher weight = more likely to be picked.
# ─────────────────────────────────────────────
static func pick_weighted_shark(rarity: int) -> Dictionary:
	var pool: Array = []
	for shark in SHARK_CATALOG:
		if shark.rarity == rarity:
			pool.append(shark)
	if pool.is_empty():
		return {}
	var total_weight: int = 0
	for shark in pool:
		total_weight += shark.weight
	var roll: int = randi() % total_weight
	var cumulative: int = 0
	for shark in pool:
		cumulative += shark.weight
		if roll < cumulative:
			return shark.duplicate()
	return pool[-1].duplicate()

# ─────────────────────────────────────────────
#  FOOD TYPES & EFFECTS
# ─────────────────────────────────────────────
const FOOD_CATALOG: Array = [
	{ "id": 0, "name": "Small Fish",  "cost": 20,  "currency_mult": 1.1, "happiness_bonus": 5  },
	{ "id": 1, "name": "Squid",       "cost": 50,  "currency_mult": 1.25,"happiness_bonus": 10 },
	{ "id": 2, "name": "Tuna",        "cost": 120, "currency_mult": 1.5, "happiness_bonus": 20 },
	{ "id": 3, "name": "Whale Meat",  "cost": 400, "currency_mult": 2.0, "happiness_bonus": 40 },
]

# ─────────────────────────────────────────────
#  SANCTUARY UPGRADES
# ─────────────────────────────────────────────
const UPGRADE_CATALOG: Array = [
	{ "id": 0, "name": "Tank Expansion",      "cost": 500,  "effect": "shark_capacity",     "value": 2   },
	{ "id": 1, "name": "Feeding Station",     "cost": 800,  "effect": "passive_currency",   "value": 50  },
	{ "id": 2, "name": "Coral Decoration",    "cost": 600,  "effect": "currency_mult",      "value": 1.1 },
	{ "id": 3, "name": "Inventory Expansion", "cost": 400,  "effect": "inventory_slots",    "value": 5   },
	{ "id": 4, "name": "Research Lab",        "cost": 2000, "effect": "egg_discovery_rate", "value": 1.2 },
]

# ─────────────────────────────────────────────
#  AFFINITY GROUPS
# ─────────────────────────────────────────────
const AFFINITY_BUFFS: Dictionary = {
	"reef":       { "currency_mult": 1.15, "description": "Reef sharks draw crowds of snorkelers."      },
	"coastal":    { "currency_mult": 1.10, "description": "Coastal sharks are fan favourites."           },
	"pelagic":    { "currency_mult": 1.20, "description": "Open-ocean sharks impress every visitor."     },
	"hammerhead": { "currency_mult": 1.25, "description": "Hammerheads are crowd favourites."            },
	"deep":       { "currency_mult": 1.30, "description": "Deep-sea rarities fascinate researchers."     },
	"special":    { "currency_mult": 2.00, "description": "A legendary presence energises the sanctuary!"},
}
