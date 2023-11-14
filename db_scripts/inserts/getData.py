from urllib.request import Request, urlopen
import json_repair
import json


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
					query += f'\t("{item["name"]}", "{item["desc"]}", {item["gen"]}),\n'
				else:
					print("Attribute not defined\n", item)
			except KeyError:
				print("Exception\n", item)
		query = query[:-2] + "\n);"
		q.write(query)
	print("Items fetched")

if __name__ == "__main__":
	getItems()

