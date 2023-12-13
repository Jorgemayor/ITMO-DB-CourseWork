DROP TRIGGER IF EXISTS "VerifyTeamAvailable" ON "trainers_torunaments";
CREATE TRIGGER VerifyTeamAvailable
	AFTER INSERT
	ON "trainers_tournaments"
	FOR EACH ROW
EXECUTE FUNCTION "verifytournamentformat"();

