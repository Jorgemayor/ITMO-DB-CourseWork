DROP TRIGGER IF EXISTS "verifyteamavailable" ON trainers_tournaments;
CREATE TRIGGER VerifyTeamAvailable
	AFTER INSERT
	ON trainers_tournaments
	FOR EACH ROW
EXECUTE FUNCTION "verifytournamentformat"();


DROP TRIGGER IF EXISTS "verifyteammembers" ON selected_pokemon;
CREATE TRIGGER VerifyTeamMembers
	BEFORE INSERT
	ON selected_pokemon
	FOR EACH ROW
EXECUTE FUNCTION "verifyteammembers"();

