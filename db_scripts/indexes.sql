CREATE INDEX team_idx ON teams USING HASH("id_trainer");

CREATE INDEX pokemon_type ON pokemon USING HASH("id_type_1");

CREATE INDEX movement_power ON  movements USING BTREE("power");

CREATE INDEX nature_idx ON natures USING HASH("stat_up");

CREATE INDEX selected_pokemon_idx ON selected_pokemon USING HASH("id_team");
