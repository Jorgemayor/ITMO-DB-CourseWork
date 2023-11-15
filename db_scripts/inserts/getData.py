from urllib.request import Request, urlopen
import json_repair
import json

types = {
	"normal": 1,
	"fire": 2,
	"water": 3,
	"electric": 4,
	"grass": 5,
	"ice": 6,
	"fighting": 7,
	"poison": 8,
	"ground": 9,
	"flying": 10,
	"psychic": 11,
	"bug": 12,
	"rock": 13,
	"ghost": 14,
	"dragon": 15,
	"steel": 16,
	"dark": 17,
	"fairy": 18
}

generations = {
	1: [1, 151],
	2: [152, 251],
	3: [252, 386],
	4: [387, 493],
	5: [494, 649],
	6: [650, 721],
	7: [722, 809],
	8: [810, 905],
	9: [906, 1017]
}

headers = {
	'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) '
	'AppleWebKit/537.11 (KHTML, like Gecko) '
	'Chrome/23.0.1271.64 Safari/537.11',
	'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
	'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
	'Accept-Encoding': 'none',
	'Accept-Language': 'en-US,en;q=0.8',
	'Connection': 'keep-alive'
}



def getItems():

	url = "https://play.pokemonshowdown.com/data/items.js"
	req = Request(url=url, headers=headers)
	response = urlopen(req).read()
	data = response.split(b'=')[1].strip().decode()
	items = json_repair.loads(data)

	query = "INSERT INTO items (name, description, generation) VALUES\n(\n"
	with open("insertItems.sql", "w") as q:
		for key in items.keys():
			item = items[key]
			try:
				name = item['name']
				desc = item['desc']
				gen = item['gen']
				if(name and desc and gen):
					query += f'\t("{name}", "{desc}", {gen}),\n'
				else:
					print("Attribute not defined\n", item)
			except KeyError:
				print("Exception\n", item)
		query = query[:-2] + "\n);\n"
		q.write(query)
	print("Items fetched")



def getPokemon():
	url = "https://play.pokemonshowdown.com/data/pokedex.json"
	req = Request(url=url, headers=headers)
	response = urlopen(req).read()
	pokemon = json.loads(response)
	
	query = "INSERT INTO pokemon (name, base_stats, id_type_1, id_type_2, id_ability_1, id_ability_2, id_hidden_ability, generation) VALUES\n(\n"
	
	with open("insertPokemon.sql", "w") as q:
		gen = 1
		for key in pokemon.keys():
			if key == "missingno":
				break
							
			pkmn = pokemon[key]
			try:
				name = pkmn["name"]
				base_stats = str(pkmn["baseStats"])
				pkmn_types = pkmn["types"]
				id_type_1 = types[pkmn_types[0].lower()]
				id_type_2 = "null" if len(pkmn_types) != 2 else types[pkmn_types[1].lower()]
				abilities = pkmn["abilities"]
				id_ability_1 = 1 # abilities["0"]
				id_ability_2 = "null" if "1" not in abilities.keys() else 1 # abilities["1"]
				id_hidden_ability = "null" if "H" not in abilities.keys() else 1 # abilities["H"]
				num = pkmn["num"]
				attributes = [name, base_stats, id_type_1, id_type_2, id_ability_1, id_ability_2, id_hidden_ability, gen]
				if not(generations[gen][0] <= num and num <= generations[gen][1]):
					gen += 1 
				if all(v is not None for v in attributes):
					query += f'\t("{name}", "{base_stats}", {id_type_1}, {id_type_2}, {id_ability_1}, {id_ability_2}, {id_hidden_ability}, {gen}),\n'
				else:
					print("Attribute not defined\n", pkmn)
			except KeyError:
				print("Exception\n", pkmn)
		query = query[:-2] + "\n);\n"
		q.write(query)
	print("Pokemon fetched")


def getAbilities():
	url = "https://play.pokemonshowdown.com/data/abilities.js"
	req = Request(url=url, headers=headers)
	response = urlopen(req).read()
	data = response.split(b"=")[1].strip().decode()
	abilities = json_repair.loads(data)
	
	query = "INSERT INTO abilities (name, description, generation) VALUES\n(\n"
	
	with open("insertAbilities.sql", "w") as q:
		for key in abilities.keys():
			ability = abilities[key]
			name = ability["name"]
			desc = ability["desc"]
			gen = 1
			attributes = [name, desc, gen]
			if all(v is not None for v in attributes):
				query += f'\t("{name}", "{desc}", {gen}),\n'
			else:
				print("Attirbute not defined\n", ability)
		query = query[:-2] + "\n);\n"
		q.write(query)
	print("Abilities fetched")
	return


def getMoves():
	url = "https://play.pokemonshowdown.com/data/moves.json"
	req = Request(url=url, headers=headers)
	response = urlopen(req).read()
	moves = json.loads(response)

	query = "INSERT INTO movements (name, description, power, accuracy, pp, id_type, category, generation, unavailable_from) VALUES\n(\n"
	with open("insertMoves.sql", "w") as q:
		for key in moves.keys():
			move = moves[key]
			try:
				name = move["name"]
				desc = move["desc"]
				power = move["basePower"]
				acc = int(move["accuracy"])
				pp = move["pp"]
				id_type = types[move["type"].lower()]
				cat = move["category"]
				# gen = 1
				# unavailable_from = 10

				query += f'\t"{name}", "{desc}", {power}, {acc}, {pp}, {id_type}, "{cat}", 1, 10),\n'
			except KeyError:
				print("Exception\n", move)
		query = query[:-2] + "\n);\n"
		q.write(query)
	print("Moves fetched")


def getLearnset():
	url = "https://play.pokemonshowdown.com/data/learnsets.json"
	return

if __name__ == "__main__":
	# getItems()
	# getPokemon()
	# getAbilities()
	# getMoves()
	getLearnset()

