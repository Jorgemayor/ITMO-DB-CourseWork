--CREATE OR REPLACE FUNCTION verify_pkmn() RETURN BOOLEAN
--BEGIN


-- END;

CREATE OR REPLACE FUNCTION VerifyTournamentFormat() RETURNS TRIGGER AS
$$
DECLARE
	format INTEGER;
BEGIN
	SELECT id_format into format FROM tournaments WHERE id = NEW.id_tournament;
	if (SELECT COUNT(*) 
		FROM teams
		WHERE id_trainer = NEW.id_trainer
		AND id_format = format) <= 0
	then
		DELETE FROM trainers_tournaments
		WHERE id_trainer = NEW.id_trainer
		AND id_tournament = NEW.id_tournament;
		
		RAISE EXCEPTION 'Trainer % has no teams for this format', NEW.id_trainer;
	end if;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;
