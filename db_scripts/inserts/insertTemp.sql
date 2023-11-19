INSERT INTO trainers (id, username, password, email) VALUES (
	(1, "jorgemayor", "test123", "test@email.com"),
	(2, "gera", "test123", "test2@mail.com"),
	(3, "test", "test123", "test3@mail.com")
);


INSERT INTO formats (id, name, generation, year, rules) VALUES (
	(1, "Regulation A", 9, 2023, "{}"),
	(2, "Regulation B", 9, 2023, "{}")
);


INSERT INTO teams (id, id_trainer, id_format, name) VALUES (
	(1, 1, 1, "Raining team"),
	(2, 1, 2, "Trick room team", TRUE),
	(3, 2, 1, "All offensive team", TRUE),
	(4, 2, 2, "Water type team"),
	(5, 3, 1, "Champion's team")
	(6, 3, 2, "Stall team")
);

INSERT INTO tournaments (id, name, id_format) VALUES (
	(1, "Regional tournament", 1),
	(2, "San Diego's tournament", 2),
	(3, "Allin tournament", 1)
);

INSERT INTO trainers_tournaments (id_trainer, id_tournament) VALUES (
	(1, 1),
	(2, 1),
	(1, 2),
	(2, 2),
	(3, 2)
);

INSERT INTO matches (id_tournament, id_team_1, id_team_2) VALUES (
	(1, 1, 3),
	(2, 2, 4),
	(2, 2, 6),
	(2, 4, 6)
);

INSERT INTO pokemon_movements (id_pokemon, id_movement) VALUES (
	(1, 1),
	(1, 5),
	(1, 7),
	(2, 5),
	(2, 6),
	(3, 8),
	(3, 9),
	(6, 6),
	(7, 3),
	(7, 8),
	(8, 9)
);

INSERT INTO selected_pokemon (id_pokemon, id_team, ability, id_nature, id_item, moveset, IVs, EVs) VALUES (
	(100, 1, 0, 1, 8, "{}", "{}", "{}"),
	(608, 1, 0, 14, 20, "{}", "{}", "{}"),
	(306, 1, 0, 10, 16, "{}", "{}", "{}"),
	(208, 1, 0, 4, 2, "{}", "{}", "{}"),
	(137, 1, 0, 11, 5, "{}", "{}", "{}"),
	(504, 1, 0, 13, 7, "{}", "{}", "{}"),
	(406, 2, 0, 2, 16, "{}", "{}", "{}"),
	(208, 2, 0, 11, 12, "{}", "{}", "{}"),
	(104, 2, 0, 6, 19, "{}", "{}", "{}"),
	(76, 2, 0, 8, 17, "{}", "{}", "{}"),
	(809, 2, 0, 5, 2, "{}", "{}", "{}"),
	(246, 2, 0, 8, 6, "{}", "{}", "{}"),
);

