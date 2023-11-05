import json

def getItems():
	items = ""
	
	with open("items.json") as x:
		items = json.loads(x.read())
	
	query = "INSERT INTO items (name, description, generation) VALUES\n(\n"
	with open("insertItems.sql", "w") as q:
		for key in items.keys():
			item = items[key]
			try:
				name = item['name']
				desc = item['desc']
				gen = item['gen']
				if(name and desc and gen):
					query += f'\t("{item["name"]}", "{item["desc"]}", {item["gen"]}),\n'
				else:
					print("Attribute not defined\n", item)
			except KeyError:
				print("Exception\n", item)
		query = query[:-2] + "\n);"
		q.write(query)
	print("Items fetched")

