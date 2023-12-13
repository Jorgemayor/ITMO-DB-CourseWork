CREATE OR REPLACE FUNCTION GetTopOU() RETURNS TABLE(p_name TEXT, use BIGINT) AS
$$
BEGIN
	RETURN QUERY
	SELECT * FROM (
		SELECT name AS p_name, COUNT(*) AS use
		FROM selected_pokemon JOIN pokemon ON id_pokemon = pokemon.id
		GROUP BY name
	) AS sub
	ORDER BY use DESC
	LIMIT 5;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION VerifyTournamentFormat() RETURNS TRIGGER AS
$$
DECLARE
	format INTEGER;
BEGIN
	SELECT id_format into format FROM tournaments WHERE id = NEW.id_tournament;
	IF (SELECT COUNT(*) 
		FROM teams
		WHERE id_trainer = NEW.id_trainer
		AND id_format = format) <= 0
	THEN
		DELETE FROM trainers_tournaments
		WHERE id_trainer = NEW.id_trainer
		AND id_tournament = NEW.id_tournament;
		
		RAISE EXCEPTION 'Trainer % has no teams for this format', NEW.id_trainer;
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION VerifyTeamMembers() RETURNS TRIGGER AS
$$
BEGIN
	IF (SELECT COUNT(*)
		FROM selected_pokemon
		WHERE id_trainer = NEW.id_trainer) >= 6
	THEN
		RAISE EXCEPTION 'Team % already has 6 members', NEW.id_team;
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;
