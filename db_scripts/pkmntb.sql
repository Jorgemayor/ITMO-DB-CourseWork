--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gettopou(); Type: FUNCTION; Schema: public; Owner: jorge
--

CREATE FUNCTION public.gettopou() RETURNS TABLE(p_name text, use bigint)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.gettopou() OWNER TO jorge;

--
-- Name: verifyteammembers(); Type: FUNCTION; Schema: public; Owner: jorge
--

CREATE FUNCTION public.verifyteammembers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (SELECT COUNT(*)
		FROM selected_pokemon
		WHERE id_trainer = NEW.id_trainer) >= 6
	THEN
		RAISE EXCEPTION 'Team % already has 6 members', NEW.id_team;
	END IF;
	RETURN NEW;
END
$$;


ALTER FUNCTION public.verifyteammembers() OWNER TO jorge;

--
-- Name: verifytournamentformat(); Type: FUNCTION; Schema: public; Owner: jorge
--

CREATE FUNCTION public.verifytournamentformat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.verifytournamentformat() OWNER TO jorge;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: abilities; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.abilities (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    description text NOT NULL,
    generation smallint NOT NULL
);


ALTER TABLE public.abilities OWNER TO jorge;

--
-- Name: abilities_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.abilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.abilities_id_seq OWNER TO jorge;

--
-- Name: abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.abilities_id_seq OWNED BY public.abilities.id;


--
-- Name: formats; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.formats (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    generation smallint NOT NULL,
    year smallint NOT NULL,
    rules json NOT NULL
);


ALTER TABLE public.formats OWNER TO jorge;

--
-- Name: formats_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.formats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.formats_id_seq OWNER TO jorge;

--
-- Name: formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.formats_id_seq OWNED BY public.formats.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    description text NOT NULL,
    generation smallint NOT NULL,
    unavailable_from smallint
);


ALTER TABLE public.items OWNER TO jorge;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO jorge;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.matches (
    id_tournament integer NOT NULL,
    id_team_1 integer NOT NULL,
    id_team_2 integer NOT NULL,
    winner smallint DEFAULT 0,
    CONSTRAINT matches_check CHECK ((id_team_1 <> id_team_2)),
    CONSTRAINT matches_winner_check CHECK ((winner = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE public.matches OWNER TO jorge;

--
-- Name: movements; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.movements (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    power smallint,
    accuracy smallint,
    pp smallint NOT NULL,
    id_type smallint NOT NULL,
    category text NOT NULL,
    generation smallint NOT NULL,
    unavailable_from smallint
);


ALTER TABLE public.movements OWNER TO jorge;

--
-- Name: movements_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movements_id_seq OWNER TO jorge;

--
-- Name: movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.movements_id_seq OWNED BY public.movements.id;


--
-- Name: natures; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.natures (
    id integer NOT NULL,
    name character varying(15) NOT NULL,
    stat_up character varying(3) NOT NULL,
    stat_down character varying(3) NOT NULL
);


ALTER TABLE public.natures OWNER TO jorge;

--
-- Name: natures_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.natures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.natures_id_seq OWNER TO jorge;

--
-- Name: natures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.natures_id_seq OWNED BY public.natures.id;


--
-- Name: pokemon; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.pokemon (
    id integer NOT NULL,
    name text NOT NULL,
    base_stats json NOT NULL,
    id_type_1 smallint NOT NULL,
    id_type_2 smallint,
    id_ability_1 integer NOT NULL,
    id_ability_2 integer,
    id_hidden_ability integer,
    generation smallint
);


ALTER TABLE public.pokemon OWNER TO jorge;

--
-- Name: pokemon_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.pokemon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pokemon_id_seq OWNER TO jorge;

--
-- Name: pokemon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.pokemon_id_seq OWNED BY public.pokemon.id;


--
-- Name: pokemon_movements; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.pokemon_movements (
    id_pokemon integer NOT NULL,
    id_movement integer NOT NULL
);


ALTER TABLE public.pokemon_movements OWNER TO jorge;

--
-- Name: pokemons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokemons (
    id integer NOT NULL,
    name text NOT NULL,
    "baseStats" json NOT NULL,
    "idType1" smallint NOT NULL,
    "idType2" smallint,
    "idAbility1" integer NOT NULL,
    "idAbility2" integer,
    "idHiddenAbility" integer,
    generation smallint
);


ALTER TABLE public.pokemons OWNER TO jorge;

--
-- Name: pokemons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pokemons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pokemons_id_seq OWNER TO jorge;

--
-- Name: pokemons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pokemons_id_seq OWNED BY public.pokemons.id;


--
-- Name: selected_pokemon; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.selected_pokemon (
    id integer NOT NULL,
    id_pokemon integer NOT NULL,
    id_team integer NOT NULL,
    ability smallint NOT NULL,
    id_nature integer NOT NULL,
    id_item integer NOT NULL,
    moveset json NOT NULL,
    ivs json NOT NULL,
    evs json NOT NULL,
    shiny boolean DEFAULT false,
    nickname character varying(20),
    CONSTRAINT selected_pokemon_ability_check CHECK ((ability = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE public.selected_pokemon OWNER TO jorge;

--
-- Name: selected_pokemon_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.selected_pokemon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.selected_pokemon_id_seq OWNER TO jorge;

--
-- Name: selected_pokemon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.selected_pokemon_id_seq OWNED BY public.selected_pokemon.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    id_trainer integer NOT NULL,
    id_format integer NOT NULL,
    name text NOT NULL,
    private boolean DEFAULT false
);


ALTER TABLE public.teams OWNER TO jorge;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO jorge;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.tournaments (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    id_format integer NOT NULL
);


ALTER TABLE public.tournaments OWNER TO jorge;

--
-- Name: tournaments_id_format_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.tournaments_id_format_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournaments_id_format_seq OWNER TO jorge;

--
-- Name: tournaments_id_format_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.tournaments_id_format_seq OWNED BY public.tournaments.id_format;


--
-- Name: tournaments_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.tournaments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournaments_id_seq OWNER TO jorge;

--
-- Name: tournaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.tournaments_id_seq OWNED BY public.tournaments.id;


--
-- Name: trainers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trainers (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.trainers OWNER TO jorge;

--
-- Name: trainers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trainers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trainers_id_seq OWNER TO jorge;

--
-- Name: trainers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trainers_id_seq OWNED BY public.trainers.id;


--
-- Name: trainers_tournaments; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.trainers_tournaments (
    id_trainer integer NOT NULL,
    id_tournament integer NOT NULL
);


ALTER TABLE public.trainers_tournaments OWNER TO jorge;

--
-- Name: types; Type: TABLE; Schema: public; Owner: jorge
--

CREATE TABLE public.types (
    id integer NOT NULL,
    name character varying(10) NOT NULL,
    generation smallint NOT NULL
);


ALTER TABLE public.types OWNER TO jorge;

--
-- Name: types_id_seq; Type: SEQUENCE; Schema: public; Owner: jorge
--

CREATE SEQUENCE public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.types_id_seq OWNER TO jorge;

--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: jorge
--

ALTER SEQUENCE public.types_id_seq OWNED BY public.types.id;


--
-- Name: abilities id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.abilities ALTER COLUMN id SET DEFAULT nextval('public.abilities_id_seq'::regclass);


--
-- Name: formats id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.formats ALTER COLUMN id SET DEFAULT nextval('public.formats_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: movements id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.movements ALTER COLUMN id SET DEFAULT nextval('public.movements_id_seq'::regclass);


--
-- Name: natures id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.natures ALTER COLUMN id SET DEFAULT nextval('public.natures_id_seq'::regclass);


--
-- Name: pokemon id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon ALTER COLUMN id SET DEFAULT nextval('public.pokemon_id_seq'::regclass);


--
-- Name: pokemons id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemons ALTER COLUMN id SET DEFAULT nextval('public.pokemons_id_seq'::regclass);


--
-- Name: selected_pokemon id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.selected_pokemon ALTER COLUMN id SET DEFAULT nextval('public.selected_pokemon_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: tournaments id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id SET DEFAULT nextval('public.tournaments_id_seq'::regclass);


--
-- Name: tournaments id_format; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id_format SET DEFAULT nextval('public.tournaments_id_format_seq'::regclass);


--
-- Name: trainers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainers ALTER COLUMN id SET DEFAULT nextval('public.trainers_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.types ALTER COLUMN id SET DEFAULT nextval('public.types_id_seq'::regclass);


--
-- Data for Name: abilities; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.abilities (id, name, description, generation) FROM stdin;
1	No Ability	Does nothing.	1
2	Adaptability	This Pokemon's moves that match one of its types have a same-type attack bonus (STAB) of 2 instead of 1.5.	1
3	Aerilate	This Pokemon's Normal-type moves become Flying-type moves and have their power multiplied by 1.2. This effect comes after other effects that change a move's type, but before Ion Deluge and Electrify's effects.	1
4	Aftermath	If this Pokemon is knocked out with a contact move, that move's user loses 1/4 of its maximum HP, rounded down. If any active Pokemon has the Damp Ability, this effect is prevented.	1
5	Air Lock	While this Pokemon is active, the effects of weather conditions are disabled.	1
6	Analytic	The power of this Pokemon's move is multiplied by 1.3 if it is the last to move in a turn. Does not affect Doom Desire and Future Sight.	1
7	Anger Point	If this Pokemon, but not its substitute, is struck by a critical hit, its Attack is raised by 12 stages.	1
8	Anger Shell	When this Pokemon has more than 1/2 its maximum HP and takes damage from an attack bringing it to 1/2 or less of its maximum HP, its Attack, Special Attack, and Speed are raised by 1 stage, and its Defense and Special Defense are lowered by 1 stage. This effect applies after all hits from a multi-hit move. This effect is prevented if the move had a secondary effect removed by the Sheer Force Ability.	1
9	Anticipation	On switch-in, this Pokemon is alerted if any opposing Pokemon has an attack that is super effective against this Pokemon, or an OHKO move. This effect considers any move that deals direct damage as an attacking move of its respective type, Hidden Power counts as its determined type, and Judgment, Multi-Attack, Natural Gift, Revelation Dance, Techno Blast, and Weather Ball are considered Normal-type moves.	1
10	Arena Trap	Prevents opposing Pokemon from choosing to switch out unless they are airborne, are holding a Shed Shell, or are a Ghost type.	1
11	Armor Tail	Priority moves used by opposing Pokemon targeting this Pokemon or its allies are prevented from having an effect.	1
12	Aroma Veil	This Pokemon and its allies cannot become affected by Attract, Disable, Encore, Heal Block, Taunt, or Torment.	1
13	As One (Glastrier)	Combination of the Unnerve and Chilling Neigh Abilities.	1
14	As One (Spectrier)	Combination of the Unnerve and Grim Neigh Abilities.	1
15	Aura Break	While this Pokemon is active, the effects of the Dark Aura and Fairy Aura Abilities are reversed, multiplying the power of Dark- and Fairy-type moves, respectively, by 3/4 instead of 1.33.	1
16	Bad Dreams	Causes opposing Pokemon to lose 1/8 of their maximum HP, rounded down, at the end of each turn if they are asleep.	1
17	Ball Fetch	No competitive use.	1
18	Battery	This Pokemon's allies have the power of their special attacks multiplied by 1.3.	1
19	Battle Armor	This Pokemon cannot be struck by a critical hit.	1
20	Battle Bond	If this Pokemon is a Greninja, its Attack, Special Attack, and Speed are raised by 1 stage if it attacks and knocks out another Pokemon. This effect can only happen once per battle.	1
21	Beads of Ruin	Active Pokemon without this Ability have their Special Defense multiplied by 0.75.	1
22	Beast Boost	This Pokemon's highest stat is raised by 1 stage if it attacks and knocks out another Pokemon. Stat stage changes are not considered. If multiple stats are tied, Attack, Defense, Special Attack, Special Defense, and Speed are prioritized in that order.	1
23	Berserk	When this Pokemon has more than 1/2 its maximum HP and takes damage from an attack bringing it to 1/2 or less of its maximum HP, its Special Attack is raised by 1 stage. This effect applies after all hits from a multi-hit move. This effect is prevented if the move had a secondary effect removed by the Sheer Force Ability.	1
24	Big Pecks	Prevents other Pokemon from lowering this Pokemon's Defense stat stage.	1
25	Blaze	When this Pokemon has 1/3 or less of its maximum HP, rounded down, its offensive stat is multiplied by 1.5 while using a Fire-type attack.	1
26	Bulletproof	This Pokemon is immune to bullet moves.	1
27	Cheek Pouch	If this Pokemon eats a held Berry, it restores 1/3 of its maximum HP, rounded down, in addition to the Berry's effect. This effect can also activate after the effects of Bug Bite, Fling, Pluck, Stuff Cheeks, and Teatime if the eaten Berry had an effect on this Pokemon.	1
28	Chilling Neigh	This Pokemon's Attack is raised by 1 stage if it attacks and knocks out another Pokemon.	1
29	Chlorophyll	If Sunny Day is active, this Pokemon's Speed is doubled. This effect is prevented if this Pokemon is holding a Utility Umbrella.	1
30	Clear Body	Prevents other Pokemon from lowering this Pokemon's stat stages.	1
31	Cloud Nine	While this Pokemon is active, the effects of weather conditions are disabled.	1
32	Color Change	This Pokemon's type changes to match the type of the last move that hit it, unless that type is already one of its types. This effect applies after all hits from a multi-hit move. This effect is prevented if the move had a secondary effect removed by the Sheer Force Ability.	1
33	Comatose	This Pokemon is considered to be asleep and cannot become affected by a non-volatile status condition or Yawn.	1
34	Commander	If this Pokemon is a Tatsugiri and a Dondozo is an active ally, this Pokemon goes into the Dondozo's mouth. The Dondozo has its Attack, Special Attack, Speed, Defense, and Special Defense raised by 2 stages. During the effect, the Dondozo cannot be switched out, this Pokemon cannot select an action, and attacks targeted at this Pokemon will be avoided but it will still take indirect damage. If this Pokemon faints during the effect, a Pokemon can be switched in as a replacement but the Dondozo remains unable to be switched out. If the Dondozo faints during the effect, this Pokemon regains the ability to select an action.	1
35	Competitive	This Pokemon's Special Attack is raised by 2 stages for each of its stat stages that is lowered by an opposing Pokemon.	1
36	Compound Eyes	This Pokemon's moves have their accuracy multiplied by 1.3.	1
37	Contrary	If this Pokemon has a stat stage raised it is lowered instead, and vice versa.	1
38	Corrosion	This Pokemon can poison or badly poison a Pokemon regardless of its typing.	1
39	Costar	On switch-in, this Pokemon copies all of its ally's stat stage changes.	1
40	Cotton Down	When this Pokemon is hit by an attack, the Speed of all other Pokemon on the field is lowered by 1 stage.	1
41	Cud Chew	If this Pokemon eats a Berry, it will eat that Berry again at the end of the next turn.	1
42	Curious Medicine	On switch-in, this Pokemon's allies have their stat stages reset to 0.	1
43	Cursed Body	If this Pokemon is hit by an attack, there is a 30% chance that move gets disabled unless one of the attacker's moves is already disabled.	1
44	Cute Charm	There is a 30% chance a Pokemon making contact with this Pokemon will become infatuated if it is of the opposite gender.	1
45	Damp	While this Pokemon is active, Explosion, Mind Blown, Misty Explosion, Self-Destruct, and the Aftermath Ability are prevented from having an effect.	1
46	Dancer	After another Pokemon uses a dance move, this Pokemon uses the same move. The copied move is subject to all effects that can prevent a move from being executed. A move used through this Ability cannot be copied again by other Pokemon with this Ability.	1
47	Dark Aura	While this Pokemon is active, the power of Dark-type moves used by active Pokemon is multiplied by 1.33.	1
48	Dauntless Shield	On switch-in, this Pokemon's Defense is raised by 1 stage. Once per battle.	1
49	Dazzling	Priority moves used by opposing Pokemon targeting this Pokemon or its allies are prevented from having an effect.	1
50	Defeatist	While this Pokemon has 1/2 or less of its maximum HP, its Attack and Special Attack are halved.	1
51	Defiant	This Pokemon's Attack is raised by 2 stages for each of its stat stages that is lowered by an opposing Pokemon.	1
52	Delta Stream	On switch-in, the weather becomes Delta Stream, which removes the weaknesses of the Flying type from Flying-type Pokemon. This weather remains in effect until this Ability is no longer active for any Pokemon, or the weather is changed by the Desolate Land or Primordial Sea Abilities.	1
53	Desolate Land	On switch-in, the weather becomes Desolate Land, which includes all the effects of Sunny Day and prevents damaging Water-type moves from executing. This weather remains in effect until this Ability is no longer active for any Pokemon, or the weather is changed by the Delta Stream or Primordial Sea Abilities.	1
54	Disguise	If this Pokemon is a Mimikyu, the first hit it takes in battle deals 0 neutral damage. Its disguise is then broken, it changes to Busted Form, and it loses 1/8 of its max HP. Confusion damage also breaks the disguise.	1
55	Download	On switch-in, this Pokemon's Attack or Special Attack is raised by 1 stage based on the weaker combined defensive stat of all opposing Pokemon. Attack is raised if their Defense is lower, and Special Attack is raised if their Special Defense is the same or lower.	1
56	Dragon's Maw	This Pokemon's offensive stat is multiplied by 1.5 while using a Dragon-type attack.	1
57	Drizzle	On switch-in, this Pokemon summons Rain Dance.	1
58	Drought	On switch-in, this Pokemon summons Sunny Day.	1
59	Dry Skin	This Pokemon is immune to Water-type moves and restores 1/4 of its maximum HP, rounded down, when hit by a Water-type move. The power of Fire-type moves is multiplied by 1.25 when used on this Pokemon. At the end of each turn, this Pokemon restores 1/8 of its maximum HP, rounded down, if the weather is Rain Dance, and loses 1/8 of its maximum HP, rounded down, if the weather is Sunny Day. The weather effects are prevented if this Pokemon is holding a Utility Umbrella.	1
60	Early Bird	This Pokemon's sleep counter drops by 2 instead of 1.	1
61	Earth Eater	This Pokemon is immune to Ground-type moves and restores 1/4 of its maximum HP, rounded down, when hit by a Ground-type move.	1
62	Effect Spore	30% chance a Pokemon making contact with this Pokemon will be poisoned, paralyzed, or fall asleep.	1
63	Electric Surge	On switch-in, this Pokemon summons Electric Terrain.	1
64	Electromorphosis	This Pokemon gains the Charge effect when it takes a hit from an attack.	1
65	Embody Aspect (Cornerstone)	On switch-in, this Pokemon's Defense is raised by 1 stage.	1
66	Embody Aspect (Hearthflame)	On switch-in, this Pokemon's Attack is raised by 1 stage.	1
67	Embody Aspect (Teal)	On switch-in, this Pokemon's Speed is raised by 1 stage.	1
68	Embody Aspect (Wellspring)	On switch-in, this Pokemon's Special Defense is raised by 1 stage.	1
69	Emergency Exit	When this Pokemon has more than 1/2 its maximum HP and takes damage bringing it to 1/2 or less of its maximum HP, it immediately switches out to a chosen ally. This effect applies after all hits from a multi-hit move. This effect is prevented if the move had a secondary effect removed by the Sheer Force Ability. This effect applies to both direct and indirect damage, except Curse and Substitute on use, Belly Drum, Pain Split, and confusion damage.	1
70	Fairy Aura	While this Pokemon is active, the power of Fairy-type moves used by active Pokemon is multiplied by 1.33.	1
71	Filter	This Pokemon receives 3/4 damage from supereffective attacks.	1
72	Flame Body	30% chance a Pokemon making contact with this Pokemon will be burned.	1
73	Flare Boost	While this Pokemon is burned, the power of its special attacks is multiplied by 1.5.	1
74	Flash Fire	This Pokemon is immune to Fire-type moves. The first time it is hit by a Fire-type move, its offensive stat is multiplied by 1.5 while using a Fire-type attack as long as it remains active and has this Ability. If this Pokemon is frozen, it cannot be defrosted by Fire-type attacks.	1
75	Flower Gift	If this Pokemon is a Cherrim and Sunny Day is active, it changes to Sunshine Form and the Attack and Special Defense of it and its allies are multiplied by 1.5. These effects are prevented if the Pokemon is holding a Utility Umbrella.	1
76	Flower Veil	Grass-type Pokemon on this Pokemon's side cannot have their stat stages lowered by other Pokemon or have a non-volatile status condition inflicted on them by other Pokemon.	1
77	Fluffy	This Pokemon receives 1/2 damage from contact moves, but double damage from Fire moves.	1
78	Forecast	If this Pokemon is a Castform, its type changes to the current weather condition's type, except Sandstorm. This effect is prevented if this Pokemon is holding a Utility Umbrella and the weather is Rain Dance or Sunny Day.	1
79	Forewarn	On switch-in, this Pokemon is alerted to the move with the highest power, at random, known by an opposing Pokemon. This effect considers OHKO moves to have 150 power, Counter, Mirror Coat, and Metal Burst to have 120 power, every other attacking move with an unspecified power to have 80 power, and non-damaging moves to have 1 power.	1
80	Friend Guard	This Pokemon's allies receive 3/4 damage from other Pokemon's attacks.	1
81	Frisk	On switch-in, this Pokemon identifies the held items of all opposing Pokemon.	1
82	Full Metal Body	Prevents other Pokemon from lowering this Pokemon's stat stages.	1
83	Fur Coat	This Pokemon's Defense is doubled.	1
84	Gale Wings	If this Pokemon is at full HP, its Flying-type moves have their priority increased by 1.	1
85	Galvanize	This Pokemon's Normal-type moves become Electric-type moves and have their power multiplied by 1.2. This effect comes after other effects that change a move's type, but before Ion Deluge and Electrify's effects.	1
86	Gluttony	When this Pokemon is holding a Berry that usually activates with 1/4 or less of its maximum HP, it is eaten at 1/2 or less of its maximum HP instead.	1
87	Good as Gold	This Pokemon is immune to Status moves.	1
88	Gooey	Pokemon making contact with this Pokemon have their Speed lowered by 1 stage.	1
89	Gorilla Tactics	This Pokemon's Attack is multiplied by 1.5, but it can only select the first move it executes. These effects are prevented while this Pokemon is Dynamaxed.	1
90	Grass Pelt	If Grassy Terrain is active, this Pokemon's Defense is multiplied by 1.5.	1
91	Grassy Surge	On switch-in, this Pokemon summons Grassy Terrain.	1
92	Grim Neigh	This Pokemon's Special Attack is raised by 1 stage if it attacks and knocks out another Pokemon.	1
93	Guard Dog	This Pokemon is immune to the effect of the Intimidate Ability and raises its Attack by 1 stage instead. This Pokemon cannot be forced to switch out by another Pokemon's attack or item.	1
94	Gulp Missile	If this Pokemon is a Cramorant, it changes forme when it hits a target with Surf or uses the first turn of Dive successfully. It becomes Gulping Form with an Arrokuda in its mouth if it has more than 1/2 of its maximum HP remaining, or Gorging Form with a Pikachu in its mouth if it has 1/2 or less of its maximum HP remaining. If Cramorant gets hit in Gulping or Gorging Form, it spits the Arrokuda or Pikachu at its attacker, even if it has no HP remaining. The projectile deals damage equal to 1/4 of the target's maximum HP, rounded down; this damage is blocked by the Magic Guard Ability but not by a substitute. An Arrokuda also lowers the target's Defense by 1 stage, and a Pikachu paralyzes the target. Cramorant will return to normal if it spits out a projectile, switches out, or Dynamaxes.	1
95	Guts	If this Pokemon has a non-volatile status condition, its Attack is multiplied by 1.5. This Pokemon's physical attacks ignore the burn effect of halving damage.	1
96	Hadron Engine	On switch-in, summons Electric Terrain. During Electric Terrain, Sp. Atk is 1.3333x.	1
97	Harvest	If the last item this Pokemon used is a Berry, there is a 50% chance it gets restored at the end of each turn. If Sunny Day is active, this chance is 100%.	1
98	Healer	30% chance this Pokemon's ally has its non-volatile status condition cured at the end of each turn.	1
99	Heatproof	If a Pokemon uses a Fire-type attack against this Pokemon, that Pokemon's offensive stat is halved when calculating the damage to this Pokemon. This Pokemon takes half of the usual burn damage, rounded down.	1
100	Heavy Metal	This Pokemon's weight is doubled. This effect is calculated after the effect of Autotomize, and before the effect of Float Stone.	1
101	Honey Gather	No competitive use.	1
102	Hospitality	On switch-in, this Pokemon restores 1/4 of its ally's maximum HP, rounded down.	1
103	Huge Power	This Pokemon's Attack is doubled.	1
104	Hunger Switch	If this Pokemon is a Morpeko, it changes formes between its Full Belly Mode and Hangry Mode at the end of each turn.	1
105	Hustle	This Pokemon's Attack is multiplied by 1.5 and the accuracy of its physical attacks is multiplied by 0.8.	1
106	Hydration	This Pokemon has its non-volatile status condition cured at the end of each turn if Rain Dance is active. This effect is prevented if this Pokemon is holding a Utility Umbrella.	1
107	Hyper Cutter	Prevents other Pokemon from lowering this Pokemon's Attack stat stage.	1
108	Ice Body	If Snow is active, this Pokemon restores 1/16 of its maximum HP, rounded down, at the end of each turn.	1
109	Ice Face	If this Pokemon is an Eiscue, the first physical hit it takes in battle deals 0 neutral damage. Its ice face is then broken and it changes forme to Noice Face. Eiscue regains its Ice Face forme when Snow begins or when Eiscue switches in while Snow is active. Confusion damage also breaks the ice face.	1
110	Ice Scales	This Pokemon receives 1/2 damage from special attacks.	1
111	Illuminate	Prevents other Pokemon from lowering this Pokemon's accuracy stat stage. This Pokemon ignores a target's evasiveness stat stage.	1
112	Illusion	When this Pokemon switches in, it appears as the last unfainted Pokemon in its party until it takes direct damage from another Pokemon's attack. This Pokemon's actual level and HP are displayed instead of those of the mimicked Pokemon.	1
113	Immunity	This Pokemon cannot be poisoned. Gaining this Ability while poisoned cures it.	1
114	Imposter	On switch-in, this Pokemon Transforms into the opposing Pokemon that is facing it. If there is no Pokemon at that position, this Pokemon does not Transform.	1
115	Infiltrator	This Pokemon's moves ignore substitutes and the opposing side's Reflect, Light Screen, Safeguard, Mist, and Aurora Veil.	1
116	Innards Out	If this Pokemon is knocked out with a move, that move's user loses HP equal to the amount of damage inflicted on this Pokemon.	1
117	Inner Focus	This Pokemon cannot be made to flinch. This Pokemon is immune to the effect of the Intimidate Ability.	1
118	Insomnia	This Pokemon cannot fall asleep. Gaining this Ability while asleep cures it.	1
119	Intimidate	On switch-in, this Pokemon lowers the Attack of opposing Pokemon by 1 stage. Pokemon with the Inner Focus, Oblivious, Own Tempo, or Scrappy Abilities and Pokemon behind a substitute are immune.	1
120	Intrepid Sword	On switch-in, this Pokemon's Attack is raised by 1 stage. Once per battle.	1
121	Iron Barbs	Pokemon making contact with this Pokemon lose 1/8 of their maximum HP, rounded down.	1
122	Iron Fist	This Pokemon's punch-based attacks have their power multiplied by 1.2.	1
123	Justified	This Pokemon's Attack is raised by 1 stage after it is damaged by a Dark-type move.	1
124	Keen Eye	Prevents other Pokemon from lowering this Pokemon's accuracy stat stage. This Pokemon ignores a target's evasiveness stat stage.	1
125	Klutz	This Pokemon's held item has no effect. This Pokemon cannot use Fling successfully. Macho Brace, Power Anklet, Power Band, Power Belt, Power Bracer, Power Lens, and Power Weight still have their effects.	1
126	Leaf Guard	If Sunny Day is active, this Pokemon cannot become affected by a non-volatile status condition or Yawn, and Rest will fail for it. This effect is prevented if this Pokemon is holding a Utility Umbrella.	1
158	Neuroforce	This Pokemon's attacks that are super effective against the target have their damage multiplied by 1.25.	1
127	Levitate	This Pokemon is immune to Ground-type attacks and the effects of Spikes, Toxic Spikes, Sticky Web, and the Arena Trap Ability. The effects of Gravity, Ingrain, Smack Down, Thousand Arrows, and Iron Ball nullify the immunity. Thousand Arrows can hit this Pokemon as if it did not have this Ability.	1
128	Libero	This Pokemon's type changes to match the type of the move it is about to use. This effect comes after all effects that change a move's type. This effect can only happen once per switch-in, and only if this Pokemon is not Terastallized.	1
129	Light Metal	This Pokemon's weight is halved, rounded down to a tenth of a kilogram. This effect is calculated after the effect of Autotomize, and before the effect of Float Stone. A Pokemon's weight will not drop below 0.1 kg.	1
130	Lightning Rod	This Pokemon is immune to Electric-type moves and raises its Special Attack by 1 stage when hit by an Electric-type move. If this Pokemon is not the target of a single-target Electric-type move used by another Pokemon, this Pokemon redirects that move to itself if it is within the range of that move. If multiple Pokemon could redirect with this Ability, it goes to the one with the highest Speed, or in the case of a tie to the one that has had this Ability active longer.	1
131	Limber	This Pokemon cannot be paralyzed. Gaining this Ability while paralyzed cures it.	1
132	Lingering Aroma	Pokemon making contact with this Pokemon have their Ability changed to Lingering Aroma. Does not affect Pokemon with the As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Lingering Aroma, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode, or Zero to Hero Abilities.	1
133	Liquid Ooze	This Pokemon damages those draining HP from it for as much as they would heal.	1
134	Liquid Voice	This Pokemon's sound-based moves become Water-type moves. This effect comes after other effects that change a move's type, but before Ion Deluge and Electrify's effects.	1
135	Long Reach	This Pokemon's attacks do not make contact with the target.	1
136	Magic Bounce	This Pokemon is unaffected by certain non-damaging moves directed at it and will instead use such moves against the original user. Moves reflected in this way are unable to be reflected again by this or Magic Coat's effect. Spikes, Stealth Rock, Sticky Web, and Toxic Spikes can only be reflected once per side, by the leftmost Pokemon under this or Magic Coat's effect. The Lightning Rod and Storm Drain Abilities redirect their respective moves before this Ability takes effect.	1
137	Magic Guard	This Pokemon can only be damaged by direct attacks. Curse and Substitute on use, Belly Drum, Pain Split, Struggle recoil, and confusion damage are considered direct damage.	1
138	Magician	If this Pokemon has no item, it steals the item off a Pokemon it hits with an attack. Does not affect Doom Desire and Future Sight.	1
139	Magma Armor	This Pokemon cannot be frozen. Gaining this Ability while frozen cures it.	1
140	Magnet Pull	Prevents opposing Steel-type Pokemon from choosing to switch out, unless they are holding a Shed Shell or are a Ghost type.	1
141	Marvel Scale	If this Pokemon has a non-volatile status condition, its Defense is multiplied by 1.5.	1
142	Mega Launcher	This Pokemon's pulse moves have their power multiplied by 1.5. Heal Pulse restores 3/4 of a target's maximum HP, rounded half down.	1
143	Merciless	This Pokemon's attacks are critical hits if the target is poisoned.	1
144	Mimicry	This Pokemon's types change to match the active Terrain when this Pokemon acquires this Ability, or whenever a Terrain begins. Electric type during Electric Terrain, Grass type during Grassy Terrain, Fairy type during Misty Terrain, and Psychic type during Psychic Terrain. If this Ability is acquired without an active Terrain, or a Terrain ends, this Pokemon's types become the original types for its species.	1
145	Mind's Eye	This Pokemon can hit Ghost types with Normal- and Fighting-type moves. Prevents other Pokemon from lowering this Pokemon's accuracy stat stage. This Pokemon ignores a target's evasiveness stat stage.	1
146	Minus	If an active ally has this Ability or the Plus Ability, this Pokemon's Special Attack is multiplied by 1.5.	1
147	Mirror Armor	When one of this Pokemon's stat stages would be lowered by another Pokemon, that Pokemon's stat stage is lowered instead. This effect does not happen if this Pokemon's stat stage was already -6. If the other Pokemon has a substitute, neither Pokemon has its stat stage lowered.	1
148	Misty Surge	On switch-in, this Pokemon summons Misty Terrain.	1
149	Mold Breaker	This Pokemon's moves and their effects ignore certain Abilities of other Pokemon. The Abilities that can be negated are Aroma Veil, Aura Break, Battle Armor, Big Pecks, Bulletproof, Clear Body, Contrary, Damp, Dazzling, Disguise, Dry Skin, Filter, Flash Fire, Flower Gift, Flower Veil, Fluffy, Friend Guard, Fur Coat, Grass Pelt, Heatproof, Heavy Metal, Hyper Cutter, Ice Face, Ice Scales, Immunity, Inner Focus, Insomnia, Keen Eye, Leaf Guard, Levitate, Light Metal, Lightning Rod, Limber, Magic Bounce, Magma Armor, Marvel Scale, Mirror Armor, Motor Drive, Multiscale, Oblivious, Overcoat, Own Tempo, Pastel Veil, Punk Rock, Queenly Majesty, Sand Veil, Sap Sipper, Shell Armor, Shield Dust, Simple, Snow Cloak, Solid Rock, Soundproof, Sticky Hold, Storm Drain, Sturdy, Suction Cups, Sweet Veil, Tangled Feet, Telepathy, Thick Fat, Unaware, Vital Spirit, Volt Absorb, Water Absorb, Water Bubble, Water Veil, White Smoke, Wonder Guard, and Wonder Skin. This affects every other Pokemon on the field, whether or not it is a target of this Pokemon's move, and whether or not their Ability is beneficial to this Pokemon.	1
150	Moody	This Pokemon has a random stat, other than accuracy or evasiveness, raised by 2 stages and another stat lowered by 1 stage at the end of each turn.	1
151	Motor Drive	This Pokemon is immune to Electric-type moves and raises its Speed by 1 stage when hit by an Electric-type move.	1
152	Moxie	This Pokemon's Attack is raised by 1 stage if it attacks and knocks out another Pokemon.	1
153	Multiscale	If this Pokemon is at full HP, damage taken from attacks is halved.	1
154	Multitype	If this Pokemon is an Arceus, its type changes to match its held Plate.	1
155	Mummy	Pokemon making contact with this Pokemon have their Ability changed to Mummy. Does not affect Pokemon with the As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Mummy, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode, or Zero to Hero Abilities.	1
156	Mycelium Might	This Pokemon's Status moves ignore certain Abilities of other Pokemon, and go last among Pokemon using the same or greater priority moves.	1
157	Natural Cure	This Pokemon has its non-volatile status condition cured when it switches out.	1
159	Neutralizing Gas	While this Pokemon is active, Abilities have no effect. This Ability activates before hazards and other Abilities take effect. Does not affect the As One, Battle Bond, Comatose, Disguise, Gulp Missile, Ice Face, Multitype, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode or Zero to Hero Abilities.	1
160	No Guard	Every move used by or against this Pokemon will always hit.	1
161	Normalize	This Pokemon's moves are changed to be Normal type and have their power multiplied by 1.2. This effect comes before other effects that change a move's type.	1
162	Oblivious	This Pokemon cannot be infatuated or taunted. Gaining this Ability while infatuated or taunted cures it. This Pokemon is immune to the effect of the Intimidate Ability.	1
163	Opportunist	When an opposing Pokemon has a stat stage raised, this Pokemon copies the effect.	1
164	Orichalcum Pulse	On switch-in, summons Sunny Day. During Sunny Day, Attack is 1.3333x.	1
165	Overcoat	This Pokemon is immune to powder moves, damage from Sandstorm, and the effects of Rage Powder and the Effect Spore Ability.	1
166	Overgrow	When this Pokemon has 1/3 or less of its maximum HP, rounded down, its offensive stat is multiplied by 1.5 while using a Grass-type attack.	1
167	Own Tempo	This Pokemon cannot be confused. Gaining this Ability while confused cures it. This Pokemon is immune to the effect of the Intimidate Ability.	1
168	Parental Bond	This Pokemon's damaging moves become multi-hit moves that hit twice. The second hit has its damage quartered. Does not affect Doom Desire, Dragon Darts, Dynamax Cannon, Endeavor, Explosion, Final Gambit, Fling, Future Sight, Ice Ball, Rollout, Self-Destruct, any multi-hit move, any move that has multiple targets, or any two-turn move.	1
169	Pastel Veil	This Pokemon and its allies cannot be poisoned. Gaining this Ability while this Pokemon or its ally is poisoned cures them. If this Ability is being ignored during an effect that causes poison, this Pokemon is cured immediately but its ally is not.	1
170	Perish Body	Making contact with this Pokemon starts the Perish Song effect for it and the attacker. This effect does not happen for this Pokemon if the attacker already has a perish count.	1
171	Pickpocket	If this Pokemon has no item and is hit by a contact move, it steals the attacker's item. This effect applies after all hits from a multi-hit move. This effect is prevented if the move had a secondary effect removed by the Sheer Force Ability.	1
172	Pickup	If this Pokemon has no item, it finds one used by an adjacent Pokemon this turn.	1
173	Pixilate	This Pokemon's Normal-type moves become Fairy-type moves and have their power multiplied by 1.2. This effect comes after other effects that change a move's type, but before Ion Deluge and Electrify's effects.	1
174	Plus	If an active ally has this Ability or the Minus Ability, this Pokemon's Special Attack is multiplied by 1.5.	1
175	Poison Heal	If this Pokemon is poisoned, it restores 1/8 of its maximum HP, rounded down, at the end of each turn instead of losing HP.	1
176	Poison Point	30% chance a Pokemon making contact with this Pokemon will be poisoned.	1
177	Poison Touch	This Pokemon's contact moves have a 30% chance of poisoning. This effect comes after a move's inherent secondary effect chance.	1
178	Power Construct	If this Pokemon is a Zygarde in its 10% or 50% Forme, it changes to Complete Forme when it has 1/2 or less of its maximum HP at the end of the turn.	1
179	Power of Alchemy	This Pokemon copies the Ability of an ally that faints. Abilities that cannot be copied are As One, Battle Bond, Comatose, Commander, Disguise, Flower Gift, Forecast, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Imposter, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Power of Alchemy, Protosynthesis, Quark Drive, Receiver, RKS System, Schooling, Shields Down, Stance Change, Trace, Wonder Guard, Zen Mode, and Zero to Hero.	1
180	Power Spot	This Pokemon's allies have the power of their moves multiplied by 1.3. This affects Doom Desire and Future Sight, even if the user is not on the field.	1
181	Prankster	This Pokemon's non-damaging moves have their priority increased by 1. Opposing Dark-type Pokemon are immune to these moves, and any move called by these moves, if the resulting user of the move has this Ability.	1
182	Pressure	If this Pokemon is the target of an opposing Pokemon's move, that move loses one additional PP. Imprison, Snatch, and Tera Blast also lose one additional PP when used by an opposing Pokemon, but Sticky Web does not.	1
183	Primordial Sea	On switch-in, the weather becomes Primordial Sea, which includes all the effects of Rain Dance and prevents damaging Fire-type moves from executing. This weather remains in effect until this Ability is no longer active for any Pokemon, or the weather is changed by the Delta Stream or Desolate Land Abilities.	1
184	Prism Armor	This Pokemon receives 3/4 damage from supereffective attacks.	1
185	Propeller Tail	This Pokemon's moves cannot be redirected to a different target by any effect.	1
186	Protean	This Pokemon's type changes to match the type of the move it is about to use. This effect comes after all effects that change a move's type. This effect can only happen once per switch-in, and only if this Pokemon is not Terastallized.	1
187	Protosynthesis	If Sunny Day is active or this Pokemon uses a held Booster Energy, this Pokemon's highest stat is multiplied by 1.3, or by 1.5 if the highest stat is Speed. Stat stage changes are considered at the time this Ability activates. If multiple stats are tied, Attack, Defense, Special Attack, Special Defense, and Speed are prioritized in that order. If this effect was started by Sunny Day, a held Booster Energy will not activate and the effect ends when Sunny Day is no longer active. If this effect was started by a held Booster Energy, it ends when this Pokemon is no longer active.	1
188	Psychic Surge	On switch-in, this Pokemon summons Psychic Terrain.	1
189	Punk Rock	This Pokemon's sound-based moves have their power multiplied by 1.3. This Pokemon takes halved damage from sound-based moves.	1
190	Pure Power	This Pokemon's Attack is doubled.	1
191	Purifying Salt	This Pokemon cannot become affected by a non-volatile status condition or Yawn. If a Pokemon uses a Ghost-type attack against this Pokemon, that Pokemon's offensive stat is halved when calculating the damage to this Pokemon.	1
232	Sniper	If this Pokemon strikes with a critical hit, the damage is multiplied by 1.5.	1
233	Snow Cloak	If Snow is active, the accuracy of moves used against this Pokemon is multiplied by 0.8.	1
234	Snow Warning	On switch-in, this Pokemon summons Snow.	1
277	Toxic Boost	While this Pokemon is poisoned, the power of its physical attacks is multiplied by 1.5.	1
192	Quark Drive	If Electric Terrain is active or this Pokemon uses a held Booster Energy, this Pokemon's highest stat is multiplied by 1.3, or by 1.5 if the highest stat is Speed. Stat stage changes are considered at the time this Ability activates. If multiple stats are tied, Attack, Defense, Special Attack, Special Defense, and Speed are prioritized in that order. If this effect was started by Electric Terrain, a held Booster Energy will not activate and the effect ends when Electric Terrain is no longer active. If this effect was started by a held Booster Energy, it ends when this Pokemon is no longer active.	1
193	Queenly Majesty	Priority moves used by opposing Pokemon targeting this Pokemon or its allies are prevented from having an effect.	1
194	Quick Draw	This Pokemon has a 30% chance to move first in its priority bracket with attacking moves.	1
195	Quick Feet	If this Pokemon has a non-volatile status condition, its Speed is multiplied by 1.5. This Pokemon ignores the paralysis effect of halving Speed.	1
196	Rain Dish	If Rain Dance is active, this Pokemon restores 1/16 of its maximum HP, rounded down, at the end of each turn. This effect is prevented if this Pokemon is holding a Utility Umbrella.	1
197	Rattled	This Pokemon's Speed is raised by 1 stage if hit by a Bug-, Dark-, or Ghost-type attack, or if an opposing Pokemon affected this Pokemon with the Intimidate Ability.	1
198	Receiver	This Pokemon copies the Ability of an ally that faints. Abilities that cannot be copied are As One, Battle Bond, Comatose, Commander, Disguise, Flower Gift, Forecast, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Imposter, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Power of Alchemy, Protosynthesis, Quark Drive, Receiver, RKS System, Schooling, Shields Down, Stance Change, Trace, Wonder Guard, Zen Mode, and Zero to Hero.	1
199	Reckless	This Pokemon's attacks with recoil or crash damage have their power multiplied by 1.2. Does not affect Struggle.	1
200	Refrigerate	This Pokemon's Normal-type moves become Ice-type moves and have their power multiplied by 1.2. This effect comes after other effects that change a move's type, but before Ion Deluge and Electrify's effects.	1
201	Regenerator	This Pokemon restores 1/3 of its maximum HP, rounded down, when it switches out.	1
202	Ripen	When this Pokemon eats certain Berries, the effects are doubled. Berries that restore HP or PP have the amount doubled, Berries that raise stat stages have the amount doubled, Berries that halve damage taken quarter it instead, and a Jaboca Berry or Rowap Berry has the attacker lose 1/4 of its maximum HP, rounded down.	1
203	Rivalry	This Pokemon's attacks have their power multiplied by 1.25 against targets of the same gender or multiplied by 0.75 against targets of the opposite gender. There is no modifier if either this Pokemon or the target is genderless.	1
204	RKS System	If this Pokemon is a Silvally, its type changes to match its held Memory.	1
205	Rock Head	This Pokemon does not take recoil damage, except Struggle. Does not affect Life Orb damage or crash damage.	1
206	Rocky Payload	This Pokemon's offensive stat is multiplied by 1.5 while using a Rock-type attack.	1
207	Rough Skin	Pokemon making contact with this Pokemon lose 1/8 of their maximum HP, rounded down.	1
208	Run Away	No competitive use.	1
209	Sand Force	If Sandstorm is active, this Pokemon's Ground-, Rock-, and Steel-type attacks have their power multiplied by 1.3. This Pokemon takes no damage from Sandstorm.	1
210	Sand Rush	If Sandstorm is active, this Pokemon's Speed is doubled. This Pokemon takes no damage from Sandstorm.	1
211	Sand Spit	When this Pokemon is hit by an attack, the effect of Sandstorm begins.	1
212	Sand Stream	On switch-in, this Pokemon summons Sandstorm.	1
213	Sand Veil	If Sandstorm is active, the accuracy of moves used against this Pokemon is multiplied by 0.8. This Pokemon takes no damage from Sandstorm.	1
214	Sap Sipper	This Pokemon is immune to Grass-type moves and raises its Attack by 1 stage when hit by a Grass-type move.	1
215	Schooling	On switch-in, if this Pokemon is a Wishiwashi that is level 20 or above and has more than 1/4 of its maximum HP left, it changes to School Form. If it is in School Form and its HP drops to 1/4 of its maximum HP or less, it changes to Solo Form at the end of the turn. If it is in Solo Form and its HP is greater than 1/4 its maximum HP at the end of the turn, it changes to School Form.	1
216	Scrappy	This Pokemon can hit Ghost types with Normal- and Fighting-type moves. This Pokemon is immune to the effect of the Intimidate Ability.	1
217	Screen Cleaner	On switch-in, the effects of Aurora Veil, Light Screen, and Reflect end for both sides.	1
218	Seed Sower	When this Pokemon is hit by an attack, the effect of Grassy Terrain begins.	1
219	Serene Grace	This Pokemon's moves have their secondary effect chance doubled. This effect stacks with the Rainbow effect, except for secondary effects that cause the target to flinch.	1
220	Shadow Shield	If this Pokemon is at full HP, damage taken from attacks is halved.	1
221	Shadow Tag	Prevents opposing Pokemon from choosing to switch out, unless they are holding a Shed Shell, are a Ghost type, or also have this Ability.	1
222	Sharpness	This Pokemon's slicing moves have their power multiplied by 1.5.	1
223	Shed Skin	This Pokemon has a 33% chance to have its non-volatile status condition cured at the end of each turn.	1
224	Sheer Force	This Pokemon's attacks with secondary effects have their power multiplied by 1.3, but the secondary effects are removed. If a secondary effect was removed, it also removes the user's Life Orb recoil and Shell Bell recovery, and prevents the target's Anger Shell, Berserk, Color Change, Emergency Exit, Pickpocket, Wimp Out, Red Card, Eject Button, Kee Berry, and Maranga Berry from activating.	1
225	Shell Armor	This Pokemon cannot be struck by a critical hit.	1
226	Shield Dust	This Pokemon is not affected by the secondary effect of another Pokemon's attack.	1
227	Shields Down	If this Pokemon is a Minior, it changes to its Core forme if it has 1/2 or less of its maximum HP, and changes to Meteor Form if it has more than 1/2 its maximum HP. This check is done on switch-in and at the end of each turn. While in its Meteor Form, it cannot become affected by a non-volatile status condition or Yawn.	1
228	Simple	When one of this Pokemon's stat stages is raised or lowered, the amount is doubled.	1
229	Skill Link	This Pokemon's multi-hit attacks always hit the maximum number of times. Triple Kick and Triple Axel do not check accuracy for the second and third hits.	1
230	Slow Start	On switch-in, this Pokemon's Attack and Speed are halved for 5 turns.	1
231	Slush Rush	If Snow is active, this Pokemon's Speed is doubled.	1
235	Solar Power	If Sunny Day is active, this Pokemon's Special Attack is multiplied by 1.5 and it loses 1/8 of its maximum HP, rounded down, at the end of each turn. These effects are prevented if the Pokemon is holding a Utility Umbrella.	1
236	Solid Rock	This Pokemon receives 3/4 damage from supereffective attacks.	1
237	Soul-Heart	This Pokemon's Special Attack is raised by 1 stage when another Pokemon faints.	1
238	Soundproof	This Pokemon is immune to sound-based moves, unless it used the move.	1
239	Speed Boost	This Pokemon's Speed is raised by 1 stage at the end of each full turn it has been on the field.	1
240	Stakeout	This Pokemon's offensive stat is doubled against a target that switched in this turn.	1
241	Stall	This Pokemon moves last among Pokemon using the same or greater priority moves.	1
242	Stalwart	This Pokemon's moves cannot be redirected to a different target by any effect.	1
243	Stamina	This Pokemon's Defense is raised by 1 stage after it is damaged by a move.	1
244	Stance Change	If this Pokemon is an Aegislash, it changes to Blade Forme before using an attacking move, and changes to Shield Forme before using King's Shield.	1
245	Static	30% chance a Pokemon making contact with this Pokemon will be paralyzed.	1
246	Steadfast	If this Pokemon flinches, its Speed is raised by 1 stage.	1
247	Steam Engine	This Pokemon's Speed is raised by 6 stages after it is damaged by a Fire- or Water-type move.	1
248	Steelworker	This Pokemon's offensive stat is multiplied by 1.5 while using a Steel-type attack.	1
249	Steely Spirit	This Pokemon and its allies' Steel-type moves have their power multiplied by 1.5. This affects Doom Desire even if the user is not on the field.	1
250	Stench	This Pokemon's attacks without a chance to make the target flinch gain a 10% chance to make the target flinch.	1
251	Sticky Hold	This Pokemon cannot lose its held item due to another Pokemon's Ability or attack, unless the attack knocks out this Pokemon. A Sticky Barb will be transferred to other Pokemon regardless of this Ability.	1
252	Storm Drain	This Pokemon is immune to Water-type moves and raises its Special Attack by 1 stage when hit by a Water-type move. If this Pokemon is not the target of a single-target Water-type move used by another Pokemon, this Pokemon redirects that move to itself if it is within the range of that move. If multiple Pokemon could redirect with this Ability, it goes to the one with the highest Speed, or in the case of a tie to the one that has had this Ability active longer.	1
253	Strong Jaw	This Pokemon's bite-based attacks have their power multiplied by 1.5.	1
254	Sturdy	If this Pokemon is at full HP, it survives one hit with at least 1 HP. OHKO moves fail when used against this Pokemon.	1
255	Suction Cups	This Pokemon cannot be forced to switch out by another Pokemon's attack or item.	1
256	Super Luck	This Pokemon's critical hit ratio is raised by 1 stage.	1
257	Supersweet Syrup	On switch-in, this Pokemon lowers the evasiveness of opponents 1 stage. Once per battle.	1
258	Supreme Overlord	This Pokemon's moves have their power multiplied by 1+(X*0.1), where X is the total number of times any Pokemon has fainted on the user's side when this Ability became active, and X cannot be greater than 5.	1
259	Surge Surfer	If Electric Terrain is active, this Pokemon's Speed is doubled.	1
260	Swarm	When this Pokemon has 1/3 or less of its maximum HP, rounded down, its offensive stat is multiplied by 1.5 while using a Bug-type attack.	1
261	Sweet Veil	This Pokemon and its allies cannot fall asleep, but those already asleep do not wake up immediately. This Pokemon and its allies cannot use Rest successfully or become affected by Yawn, and those previously affected will not fall asleep.	1
262	Swift Swim	If Rain Dance is active, this Pokemon's Speed is doubled. This effect is prevented if this Pokemon is holding a Utility Umbrella.	1
263	Symbiosis	If an ally uses its item, this Pokemon gives its item to that ally immediately. Does not activate if the ally's item was stolen or knocked off, or if the ally used an Eject Button or Eject Pack.	1
264	Synchronize	If another Pokemon burns, paralyzes, poisons, or badly poisons this Pokemon, that Pokemon receives the same non-volatile status condition.	1
265	Sword of Ruin	Active Pokemon without this Ability have their Defense multiplied by 0.75.	1
266	Tablets of Ruin	Active Pokemon without this Ability have their Attack multiplied by 0.75.	1
267	Tangled Feet	This Pokemon's evasiveness is doubled as long as it is confused.	1
268	Tangling Hair	Pokemon making contact with this Pokemon have their Speed lowered by 1 stage.	1
269	Technician	This Pokemon's moves of 60 power or less have their power multiplied by 1.5, including Struggle. This effect comes after a move's effect changes its own power.	1
270	Telepathy	This Pokemon does not take damage from attacks made by its allies.	1
271	Teravolt	This Pokemon's moves and their effects ignore certain Abilities of other Pokemon. The Abilities that can be negated are Aroma Veil, Aura Break, Battle Armor, Big Pecks, Bulletproof, Clear Body, Contrary, Damp, Dazzling, Disguise, Dry Skin, Filter, Flash Fire, Flower Gift, Flower Veil, Fluffy, Friend Guard, Fur Coat, Grass Pelt, Heatproof, Heavy Metal, Hyper Cutter, Ice Face, Ice Scales, Immunity, Inner Focus, Insomnia, Keen Eye, Leaf Guard, Levitate, Light Metal, Lightning Rod, Limber, Magic Bounce, Magma Armor, Marvel Scale, Mirror Armor, Motor Drive, Multiscale, Oblivious, Overcoat, Own Tempo, Pastel Veil, Punk Rock, Queenly Majesty, Sand Veil, Sap Sipper, Shell Armor, Shield Dust, Simple, Snow Cloak, Solid Rock, Soundproof, Sticky Hold, Storm Drain, Sturdy, Suction Cups, Sweet Veil, Tangled Feet, Telepathy, Thick Fat, Unaware, Vital Spirit, Volt Absorb, Water Absorb, Water Bubble, Water Veil, White Smoke, Wonder Guard, and Wonder Skin. This affects every other Pokemon on the field, whether or not it is a target of this Pokemon's move, and whether or not their Ability is beneficial to this Pokemon.	1
272	Thermal Exchange	This Pokemon's Attack is raised 1 stage after it is damaged by a Fire-type move. This Pokemon cannot be burned. Gaining this Ability while burned cures it.	1
273	Thick Fat	If a Pokemon uses a Fire- or Ice-type attack against this Pokemon, that Pokemon's offensive stat is halved when calculating the damage to this Pokemon.	1
274	Tinted Lens	This Pokemon's attacks that are not very effective on a target deal double damage.	1
275	Torrent	When this Pokemon has 1/3 or less of its maximum HP, rounded down, its offensive stat is multiplied by 1.5 while using a Water-type attack.	1
276	Tough Claws	This Pokemon's contact moves have their power multiplied by 1.3.	1
278	Toxic Chain	This Pokemon's moves have a 30% chance of badly poisoning. This effect comes after a move's inherent secondary effect chance.	1
279	Toxic Debris	If this Pokemon is hit by a physical attack, Toxic Spikes are set on the opposing side.	1
280	Trace	On switch-in, this Pokemon copies a random opposing Pokemon's Ability. Abilities that cannot be copied are As One, Battle Bond, Comatose, Commander, Disguise, Flower Gift, Forecast, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Imposter, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Power of Alchemy, Protosynthesis, Quark Drive, Receiver, RKS System, Schooling, Shields Down, Stance Change, Trace, Zen Mode, and Zero to Hero. If no opposing Pokemon has an Ability that can be copied, this Ability will activate as soon as one does.	1
281	Transistor	This Pokemon's offensive stat is multiplied by 1.3 while using an Electric-type attack.	1
282	Triage	This Pokemon's healing moves have their priority increased by 3.	1
283	Truant	This Pokemon skips every other turn instead of using a move.	1
284	Turboblaze	This Pokemon's moves and their effects ignore certain Abilities of other Pokemon. The Abilities that can be negated are Aroma Veil, Aura Break, Battle Armor, Big Pecks, Bulletproof, Clear Body, Contrary, Damp, Dazzling, Disguise, Dry Skin, Filter, Flash Fire, Flower Gift, Flower Veil, Fluffy, Friend Guard, Fur Coat, Grass Pelt, Heatproof, Heavy Metal, Hyper Cutter, Ice Face, Ice Scales, Immunity, Inner Focus, Insomnia, Keen Eye, Leaf Guard, Levitate, Light Metal, Lightning Rod, Limber, Magic Bounce, Magma Armor, Marvel Scale, Mirror Armor, Motor Drive, Multiscale, Oblivious, Overcoat, Own Tempo, Pastel Veil, Punk Rock, Queenly Majesty, Sand Veil, Sap Sipper, Shell Armor, Shield Dust, Simple, Snow Cloak, Solid Rock, Soundproof, Sticky Hold, Storm Drain, Sturdy, Suction Cups, Sweet Veil, Tangled Feet, Telepathy, Thick Fat, Unaware, Vital Spirit, Volt Absorb, Water Absorb, Water Bubble, Water Veil, White Smoke, Wonder Guard, and Wonder Skin. This affects every other Pokemon on the field, whether or not it is a target of this Pokemon's move, and whether or not their Ability is beneficial to this Pokemon.	1
285	Unaware	This Pokemon ignores other Pokemon's Attack, Special Attack, and accuracy stat stages when taking damage, and ignores other Pokemon's Defense, Special Defense, and evasiveness stat stages when dealing damage.	1
286	Unburden	If this Pokemon loses its held item for any reason, its Speed is doubled as long as it remains active, has this Ability, and is not holding an item.	1
287	Unnerve	While this Pokemon is active, it prevents opposing Pokemon from using their Berries. This Ability activates before hazards and other Abilities take effect.	1
288	Unseen Fist	This Pokemon's contact moves ignore the target's protection, except Max Guard.	1
289	Vessel of Ruin	Active Pokemon without this Ability have their Special Attack multiplied by 0.75.	1
290	Victory Star	This Pokemon and its allies' moves have their accuracy multiplied by 1.1.	1
291	Vital Spirit	This Pokemon cannot fall asleep. Gaining this Ability while asleep cures it.	1
292	Volt Absorb	This Pokemon is immune to Electric-type moves and restores 1/4 of its maximum HP, rounded down, when hit by an Electric-type move.	1
293	Wandering Spirit	Pokemon making contact with this Pokemon have their Ability swapped with this one. Does not affect Pokemon with the As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Wonder Guard, Zen Mode, or Zero to Hero Abilities.	1
294	Water Absorb	This Pokemon is immune to Water-type moves and restores 1/4 of its maximum HP, rounded down, when hit by a Water-type move.	1
295	Water Bubble	This Pokemon's offensive stat is doubled while using a Water-type attack. If a Pokemon uses a Fire-type attack against this Pokemon, that Pokemon's offensive stat is halved when calculating the damage to this Pokemon. This Pokemon cannot be burned. Gaining this Ability while burned cures it.	1
296	Water Compaction	This Pokemon's Defense is raised 2 stages after it is damaged by a Water-type move.	1
297	Water Veil	This Pokemon cannot be burned. Gaining this Ability while burned cures it.	1
298	Weak Armor	If a physical attack hits this Pokemon, its Defense is lowered by 1 stage and its Speed is raised by 2 stages.	1
299	Well-Baked Body	This Pokemon is immune to Fire-type moves and raises its Defense by 2 stages when hit by a Fire-type move.	1
300	White Smoke	Prevents other Pokemon from lowering this Pokemon's stat stages.	1
301	Wimp Out	When this Pokemon has more than 1/2 its maximum HP and takes damage bringing it to 1/2 or less of its maximum HP, it immediately switches out to a chosen ally. This effect applies after all hits from a multi-hit move. This effect is prevented if the move had a secondary effect removed by the Sheer Force Ability. This effect applies to both direct and indirect damage, except Curse and Substitute on use, Belly Drum, Pain Split, and confusion damage.	1
302	Wind Power	This Pokemon gains the Charge effect when it takes a hit from a wind move or when Tailwind begins on this Pokemon's side.	1
303	Wind Rider	This Pokemon is immune to wind moves and raises its Attack by 1 stage when hit by a wind move or when Tailwind begins on this Pokemon's side.	1
304	Wonder Guard	This Pokemon can only be damaged by supereffective moves and indirect damage.	1
305	Wonder Skin	Non-damaging moves that check accuracy have their accuracy changed to 50% when used against this Pokemon. This effect comes before other effects that modify accuracy.	1
306	Zen Mode	If this Pokemon is a Darmanitan or Galarian Darmanitan, it changes to Zen Mode if it has 1/2 or less of its maximum HP at the end of a turn. If Darmanitan's HP is above 1/2 of its maximum HP at the end of a turn, it changes back to Standard Mode.	1
307	Zero to Hero	If this Pokemon is a Palafin in Zero Form, switching out has it change to Hero Form.	1
308	Mountaineer	On switch-in, this Pokemon avoids all Rock-type attacks and Stealth Rock.	1
309	Rebound	On switch-in, this Pokemon blocks certain status moves and instead uses the move against the original user.	1
310	Persistent	The duration of Gravity, Heal Block, Magic Room, Safeguard, Tailwind, Trick Room, and Wonder Room is increased by 2 turns if the effect is started by this Pokemon.	1
\.


--
-- Data for Name: formats; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.formats (id, name, generation, year, rules) FROM stdin;
1	Regulation A	9	2023	{}
2	Regulation B	9	2023	{}
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.items (id, name, description, generation, unavailable_from) FROM stdin;
1	Ability Shield	Holder's Ability cannot be changed by any effect.	9	\N
2	Abomasite	If held by an Abomasnow, this item allows it to Mega Evolve in battle.	6	\N
3	Absolite	If held by an Absol, this item allows it to Mega Evolve in battle.	6	\N
4	Absorb Bulb	Raises holder's Sp. Atk by 1 stage if hit by a Water-type attack. Single use.	5	\N
5	Adamant Crystal	If held by a Dialga, its Steel- and Dragon-type attacks have 1.2x power.	8	\N
6	Adamant Orb	If held by a Dialga, its Steel- and Dragon-type attacks have 1.2x power.	4	\N
7	Adrenaline Orb	Raises holder's Speed by 1 stage if it gets affected by Intimidate. Single use.	7	\N
8	Aerodactylite	If held by an Aerodactyl, this item allows it to Mega Evolve in battle.	6	\N
9	Aggronite	If held by an Aggron, this item allows it to Mega Evolve in battle.	6	\N
10	Aguav Berry	Restores 1/3 max HP at 1/4 max HP or less; confuses if -SpD Nature. Single use.	3	\N
11	Air Balloon	Holder is immune to Ground-type attacks. Pops when holder is hit.	5	\N
12	Alakazite	If held by an Alakazam, this item allows it to Mega Evolve in battle.	6	\N
13	Aloraichium Z	If held by an Alolan Raichu with Thunderbolt, it can use Stoked Sparksurfer.	7	\N
14	Altarianite	If held by an Altaria, this item allows it to Mega Evolve in battle.	6	\N
15	Ampharosite	If held by an Ampharos, this item allows it to Mega Evolve in battle.	6	\N
16	Apicot Berry	Raises holder's Sp. Def by 1 stage when at 1/4 max HP or less. Single use.	3	\N
17	Armor Fossil	Can be revived into Shieldon.	4	\N
18	Aspear Berry	Holder is cured if it is frozen. Single use.	3	\N
19	Assault Vest	Holder's Sp. Def is 1.5x, but it can only select damaging moves.	6	\N
20	Audinite	If held by an Audino, this item allows it to Mega Evolve in battle.	6	\N
21	Auspicious Armor	Evolves Charcadet into Armarouge when used.	9	\N
22	Babiri Berry	Halves damage taken from a supereffective Steel-type attack. Single use.	4	\N
23	Banettite	If held by a Banette, this item allows it to Mega Evolve in battle.	6	\N
24	Beast Ball	A special Poke Ball designed to catch Ultra Beasts.	7	\N
25	Beedrillite	If held by a Beedrill, this item allows it to Mega Evolve in battle.	6	\N
26	Belue Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
27	Berry Juice	Restores 20 HP when at 1/2 max HP or less. Single use.	2	\N
28	Berry Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
29	Big Nugget	A big nugget of pure gold that gives off a lustrous gleam.	5	\N
30	Big Root	Holder gains 1.3x HP from draining/Aqua Ring/Ingrain/Leech Seed/Strength Sap.	4	\N
31	Binding Band	Holder's partial-trapping moves deal 1/6 max HP per turn instead of 1/8.	5	\N
32	Black Belt	Holder's Fighting-type attacks have 1.2x power.	2	\N
33	Black Glasses	Holder's Dark-type attacks have 1.2x power.	2	\N
34	Black Sludge	Each turn, if holder is a Poison type, restores 1/16 max HP; loses 1/8 if not.	4	\N
35	Blastoisinite	If held by a Blastoise, this item allows it to Mega Evolve in battle.	6	\N
36	Blazikenite	If held by a Blaziken, this item allows it to Mega Evolve in battle.	6	\N
37	Blue Orb	If held by a Kyogre, this item triggers its Primal Reversion in battle.	6	\N
38	Bluk Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
39	Blunder Policy	If the holder misses due to accuracy, its Speed is raised by 2 stages. Single use.	8	\N
40	Booster Energy	Activates the Protosynthesis or Quark Drive Abilities. Single use.	9	\N
41	Bottle Cap	Used for Hyper Training. One of a Pokemon's stats is calculated with an IV of 31.	7	\N
42	Bright Powder	The accuracy of attacks against the holder is 0.9x.	2	\N
43	Bug Gem	Holder's first successful Bug-type attack will have 1.3x power. Single use.	5	\N
44	Bug Memory	Holder's Multi-Attack is Bug type.	7	\N
45	Buginium Z	If holder has a Bug move, this item allows it to use a Bug Z-Move.	7	\N
46	Burn Drive	Holder's Techno Blast is Fire type.	5	\N
47	Cameruptite	If held by a Camerupt, this item allows it to Mega Evolve in battle.	6	\N
48	Cell Battery	Raises holder's Attack by 1 if hit by an Electric-type attack. Single use.	5	\N
49	Charcoal	Holder's Fire-type attacks have 1.2x power.	2	\N
50	Charizardite X	If held by a Charizard, this item allows it to Mega Evolve in battle.	6	\N
51	Charizardite Y	If held by a Charizard, this item allows it to Mega Evolve in battle.	6	\N
52	Charti Berry	Halves damage taken from a supereffective Rock-type attack. Single use.	4	\N
53	Cheri Berry	Holder cures itself if it is paralyzed. Single use.	3	\N
54	Cherish Ball	A rare Poke Ball that has been crafted to commemorate an occasion.	4	\N
55	Chesto Berry	Holder wakes up if it is asleep. Single use.	3	\N
56	Chilan Berry	Halves damage taken from a Normal-type attack. Single use.	4	\N
57	Chill Drive	Holder's Techno Blast is Ice type.	5	\N
58	Chipped Pot	Evolves Sinistea-Antique into Polteageist-Antique when used.	8	\N
59	Choice Band	Holder's Attack is 1.5x, but it can only select the first move it executes.	3	\N
60	Choice Scarf	Holder's Speed is 1.5x, but it can only select the first move it executes.	4	\N
61	Choice Specs	Holder's Sp. Atk is 1.5x, but it can only select the first move it executes.	4	\N
62	Chople Berry	Halves damage taken from a supereffective Fighting-type attack. Single use.	4	\N
63	Claw Fossil	Can be revived into Anorith.	3	\N
64	Clear Amulet	Prevents other Pokemon from lowering the holder's stat stages.	9	\N
65	Clover Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
66	Coba Berry	Halves damage taken from a supereffective Flying-type attack. Single use.	4	\N
67	Colbur Berry	Halves damage taken from a supereffective Dark-type attack. Single use.	4	\N
68	Cornerstone Mask	Ogerpon-Cornerstone: 1.2x power attacks; Terastallize to gain Embody Aspect.	9	\N
69	Cornn Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
70	Cover Fossil	Can be revived into Tirtouga.	5	\N
71	Covert Cloak	Holder is not affected by the secondary effect of another Pokemon's attack.	9	\N
72	Cracked Pot	Evolves Sinistea into Polteageist when used.	8	\N
73	Custap Berry	Holder moves first in its priority bracket when at 1/4 max HP or less. Single use.	4	\N
74	Damp Rock	Holder's use of Rain Dance lasts 8 turns instead of 5.	4	\N
75	Dark Gem	Holder's first successful Dark-type attack will have 1.3x power. Single use.	5	\N
76	Dark Memory	Holder's Multi-Attack is Dark type.	7	\N
77	Darkinium Z	If holder has a Dark move, this item allows it to use a Dark Z-Move.	7	\N
78	Dawn Stone	Evolves male Kirlia into Gallade and female Snorunt into Froslass when used.	4	\N
79	Decidium Z	If held by a Decidueye with Spirit Shackle, it can use Sinister Arrow Raid.	7	\N
80	Deep Sea Scale	If held by a Clamperl, its Sp. Def is doubled. Evolves Clamperl into Gorebyss when traded.	3	\N
81	Deep Sea Tooth	If held by a Clamperl, its Sp. Atk is doubled. Evolves Clamperl into Huntail when traded.	3	\N
82	Destiny Knot	If holder becomes infatuated, the other Pokemon also becomes infatuated.	4	\N
83	Diancite	If held by a Diancie, this item allows it to Mega Evolve in battle.	6	\N
84	Dive Ball	A Poke Ball that works especially well on Pokemon that live underwater.	3	\N
85	Dome Fossil	Can be revived into Kabuto.	3	\N
86	Douse Drive	Holder's Techno Blast is Water type.	5	\N
87	Draco Plate	Holder's Dragon-type attacks have 1.2x power. Judgment is Dragon type.	4	\N
88	Dragon Fang	Holder's Dragon-type attacks have 1.2x power.	2	\N
89	Dragon Gem	Holder's first successful Dragon-type attack will have 1.3x power. Single use.	5	\N
90	Dragon Memory	Holder's Multi-Attack is Dragon type.	7	\N
91	Dragon Scale	Evolves Seadra into Kingdra when traded.	2	\N
92	Dragonium Z	If holder has a Dragon move, this item allows it to use a Dragon Z-Move.	7	\N
93	Dread Plate	Holder's Dark-type attacks have 1.2x power. Judgment is Dark type.	4	\N
94	Dream Ball	A Poke Ball that makes it easier to catch wild Pokémon while they're asleep.	5	\N
95	Dubious Disc	Evolves Porygon2 into Porygon-Z when traded.	4	\N
96	Durin Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
97	Dusk Ball	A Poke Ball that makes it easier to catch wild Pokemon at night or in caves.	4	\N
98	Dusk Stone	Evolves Murkrow into Honchkrow, Misdreavus into Mismagius, Lampent into Chandelure, and Doublade into Aegislash when used.	4	\N
99	Earth Plate	Holder's Ground-type attacks have 1.2x power. Judgment is Ground type.	4	\N
100	Eevium Z	If held by an Eevee with Last Resort, it can use Extreme Evoboost.	7	\N
101	Eject Button	If holder survives a hit, it immediately switches out to a chosen ally. Single use.	5	\N
102	Eject Pack	If the holder's stat stages are lowered, it switches to a chosen ally. Single use.	8	\N
103	Electirizer	Evolves Electabuzz into Electivire when traded.	4	\N
104	Electric Gem	Holder's first successful Electric-type attack will have 1.3x power. Single use.	5	\N
105	Electric Memory	Holder's Multi-Attack is Electric type.	7	\N
106	Electric Seed	If the terrain is Electric Terrain, raises holder's Defense by 1 stage. Single use.	7	\N
107	Electrium Z	If holder has an Electric move, this item allows it to use an Electric Z-Move.	7	\N
108	Enigma Berry	Restores 1/4 max HP after holder is hit by a supereffective move. Single use.	3	\N
109	Eviolite	If holder's species can evolve, its Defense and Sp. Def are 1.5x.	5	\N
110	Expert Belt	Holder's attacks that are super effective against the target do 1.2x damage.	4	\N
111	Fairium Z	If holder has a Fairy move, this item allows it to use a Fairy Z-Move.	7	\N
112	Fairy Feather	Holder's Fairy-type attacks have 1.2x power.	9	\N
113	Fairy Gem	Holder's first successful Fairy-type attack will have 1.3x power. Single use.	6	\N
114	Fairy Memory	Holder's Multi-Attack is Fairy type.	7	\N
115	Fast Ball	A Poke Ball that makes it easier to catch Pokemon which are quick to run away.	2	\N
116	Fighting Gem	Holder's first successful Fighting-type attack will have 1.3x power. Single use.	5	\N
117	Fighting Memory	Holder's Multi-Attack is Fighting type.	7	\N
118	Fightinium Z	If holder has a Fighting move, this item allows it to use a Fighting Z-Move.	7	\N
119	Figy Berry	Restores 1/3 max HP at 1/4 max HP or less; confuses if -Atk Nature. Single use.	3	\N
120	Fire Gem	Holder's first successful Fire-type attack will have 1.3x power. Single use.	5	\N
121	Fire Memory	Holder's Multi-Attack is Fire type.	7	\N
122	Fire Stone	Evolves Vulpix into Ninetales, Growlithe into Arcanine, Eevee into Flareon, and Pansear into Simisear when used.	1	\N
123	Firium Z	If holder has a Fire move, this item allows it to use a Fire Z-Move.	7	\N
124	Fist Plate	Holder's Fighting-type attacks have 1.2x power. Judgment is Fighting type.	4	\N
125	Flame Orb	At the end of every turn, this item attempts to burn the holder.	4	\N
126	Flame Plate	Holder's Fire-type attacks have 1.2x power. Judgment is Fire type.	4	\N
127	Float Stone	Holder's weight is halved.	5	\N
128	Flower Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
129	Flying Gem	Holder's first successful Flying-type attack will have 1.3x power. Single use.	5	\N
130	Flying Memory	Holder's Multi-Attack is Flying type.	7	\N
131	Flyinium Z	If holder has a Flying move, this item allows it to use a Flying Z-Move.	7	\N
132	Focus Band	Holder has a 10% chance to survive an attack that would KO it with 1 HP.	2	\N
133	Focus Sash	If holder's HP is full, will survive an attack that would KO it with 1 HP. Single use.	4	\N
134	Fossilized Bird	Can revive into Dracozolt with Fossilized Drake or Arctozolt with Fossilized Dino.	8	\N
135	Fossilized Dino	Can revive into Arctovish with Fossilized Fish or Arctozolt with Fossilized Bird.	8	\N
136	Fossilized Drake	Can revive into Dracozolt with Fossilized Bird or Dracovish with Fossilized Fish.	8	\N
137	Fossilized Fish	Can revive into Dracovish with Fossilized Drake or Arctovish with Fossilized Dino.	8	\N
138	Friend Ball	A Poke Ball that makes caught Pokemon more friendly.	2	\N
139	Full Incense	Holder moves last in its priority bracket.	4	\N
140	Galarica Cuff	Evolves Galarian Slowpoke into Galarian Slowbro when used.	8	\N
345	Sea Incense	Holder's Water-type attacks have 1.2x power.	3	\N
141	Galarica Wreath	Evolves Galarian Slowpoke into Galarian Slowking when used.	8	\N
142	Galladite	If held by a Gallade, this item allows it to Mega Evolve in battle.	6	\N
143	Ganlon Berry	Raises holder's Defense by 1 stage when at 1/4 max HP or less. Single use.	3	\N
144	Garchompite	If held by a Garchomp, this item allows it to Mega Evolve in battle.	6	\N
145	Gardevoirite	If held by a Gardevoir, this item allows it to Mega Evolve in battle.	6	\N
146	Gengarite	If held by a Gengar, this item allows it to Mega Evolve in battle.	6	\N
147	Ghost Gem	Holder's first successful Ghost-type attack will have 1.3x power. Single use.	5	\N
148	Ghost Memory	Holder's Multi-Attack is Ghost type.	7	\N
149	Ghostium Z	If holder has a Ghost move, this item allows it to use a Ghost Z-Move.	7	\N
150	Glalitite	If held by a Glalie, this item allows it to Mega Evolve in battle.	6	\N
151	Gold Bottle Cap	Used for Hyper Training. All of a Pokemon's stats are calculated with an IV of 31.	7	\N
152	Grass Gem	Holder's first successful Grass-type attack will have 1.3x power. Single use.	5	\N
153	Grass Memory	Holder's Multi-Attack is Grass type.	7	\N
154	Grassium Z	If holder has a Grass move, this item allows it to use a Grass Z-Move.	7	\N
155	Grassy Seed	If the terrain is Grassy Terrain, raises holder's Defense by 1 stage. Single use.	7	\N
156	Great Ball	A high-performance Ball that provides a higher catch rate than a Poke Ball.	1	\N
157	Grepa Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
158	Grip Claw	Holder's partial-trapping moves always last 7 turns.	4	\N
159	Griseous Core	If held by a Giratina, its Ghost- and Dragon-type attacks have 1.2x power.	8	\N
160	Griseous Orb	If held by a Giratina, its Ghost- and Dragon-type attacks have 1.2x power.	4	\N
161	Ground Gem	Holder's first successful Ground-type attack will have 1.3x power. Single use.	5	\N
162	Ground Memory	Holder's Multi-Attack is Ground type.	7	\N
163	Groundium Z	If holder has a Ground move, this item allows it to use a Ground Z-Move.	7	\N
164	Gyaradosite	If held by a Gyarados, this item allows it to Mega Evolve in battle.	6	\N
165	Haban Berry	Halves damage taken from a supereffective Dragon-type attack. Single use.	4	\N
166	Hard Stone	Holder's Rock-type attacks have 1.2x power.	2	\N
167	Heal Ball	A remedial Poke Ball that restores the caught Pokemon's HP and status problem.	4	\N
168	Hearthflame Mask	Ogerpon-Hearthflame: 1.2x power attacks; Terastallize to gain Embody Aspect.	9	\N
169	Heat Rock	Holder's use of Sunny Day lasts 8 turns instead of 5.	4	\N
170	Heavy Ball	A Poke Ball for catching very heavy Pokemon.	2	\N
171	Heavy-Duty Boots	When switching in, the holder is unaffected by hazards on its side of the field.	8	\N
172	Helix Fossil	Can be revived into Omanyte.	3	\N
173	Heracronite	If held by a Heracross, this item allows it to Mega Evolve in battle.	6	\N
174	Hondew Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
175	Houndoominite	If held by a Houndoom, this item allows it to Mega Evolve in battle.	6	\N
176	Iapapa Berry	Restores 1/3 max HP at 1/4 max HP or less; confuses if -Def Nature. Single use.	3	\N
177	Ice Gem	Holder's first successful Ice-type attack will have 1.3x power. Single use.	5	\N
178	Ice Memory	Holder's Multi-Attack is Ice type.	7	\N
179	Ice Stone	Evolves Alolan Sandshrew into Alolan Sandslash, Alolan Vulpix into Alolan Ninetales, Eevee into Glaceon, and Galarian Darumaka into Galarian Darmanitan when used.	7	\N
180	Icicle Plate	Holder's Ice-type attacks have 1.2x power. Judgment is Ice type.	4	\N
181	Icium Z	If holder has an Ice move, this item allows it to use an Ice Z-Move.	7	\N
182	Icy Rock	Holder's use of Hail lasts 8 turns instead of 5.	4	\N
183	Incinium Z	If held by an Incineroar with Darkest Lariat, it can use Malicious Moonsault.	7	\N
184	Insect Plate	Holder's Bug-type attacks have 1.2x power. Judgment is Bug type.	4	\N
185	Iron Ball	Holder is grounded, Speed halved. If Flying type, takes neutral Ground damage.	4	\N
186	Iron Plate	Holder's Steel-type attacks have 1.2x power. Judgment is Steel type.	4	\N
187	Jaboca Berry	If holder is hit by a physical move, attacker loses 1/8 of its max HP. Single use.	4	\N
188	Jaw Fossil	Can be revived into Tyrunt.	6	\N
189	Kasib Berry	Halves damage taken from a supereffective Ghost-type attack. Single use.	4	\N
190	Kebia Berry	Halves damage taken from a supereffective Poison-type attack. Single use.	4	\N
191	Kee Berry	Raises holder's Defense by 1 stage after it is hit by a physical attack. Single use.	6	\N
192	Kelpsy Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
193	Kangaskhanite	If held by a Kangaskhan, this item allows it to Mega Evolve in battle.	6	\N
194	King's Rock	Holder's attacks without a chance to make the target flinch gain a 10% chance to make the target flinch. Evolves Poliwhirl into Politoed and Slowpoke into Slowking when traded.	2	\N
195	Kommonium Z	If held by a Kommo-o with Clanging Scales, it can use Clangorous Soulblaze.	7	\N
196	Lagging Tail	Holder moves last in its priority bracket.	4	\N
197	Lansat Berry	Holder gains the Focus Energy effect when at 1/4 max HP or less. Single use.	3	\N
198	Latiasite	If held by a Latias, this item allows it to Mega Evolve in battle.	6	\N
199	Latiosite	If held by a Latios, this item allows it to Mega Evolve in battle.	6	\N
200	Lax Incense	The accuracy of attacks against the holder is 0.9x.	3	\N
201	Leaf Stone	Evolves Gloom into Vileplume, Weepinbell into Victreebel, Exeggcute into Exeggutor or Alolan Exeggutor, Eevee into Leafeon, Nuzleaf into Shiftry, and Pansage into Simisage when used.	1	\N
202	Leek	If held by a Farfetch’d or Sirfetch’d, its critical hit ratio is raised by 2 stages.	8	\N
203	Leftovers	At the end of every turn, holder restores 1/16 of its max HP.	2	\N
204	Leppa Berry	Restores 10 PP to the first of the holder's moves to reach 0 PP. Single use.	3	\N
205	Level Ball	A Poke Ball for catching Pokemon that are a lower level than your own.	2	\N
206	Liechi Berry	Raises holder's Attack by 1 stage when at 1/4 max HP or less. Single use.	3	\N
207	Life Orb	Holder's attacks do 1.3x damage, and it loses 1/10 its max HP after the attack.	4	\N
208	Light Ball	If held by a Pikachu, its Attack and Sp. Atk are doubled.	2	\N
209	Light Clay	Holder's use of Aurora Veil, Light Screen, or Reflect lasts 8 turns instead of 5.	4	\N
210	Loaded Dice	Holder's moves that hit 2-5 times hit 4-5 times; Population Bomb hits 4-10 times.	9	\N
211	Lopunnite	If held by a Lopunny, this item allows it to Mega Evolve in battle.	6	\N
212	Love Ball	Poke Ball for catching Pokemon that are the opposite gender of your Pokemon.	2	\N
213	Love Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
214	Lucarionite	If held by a Lucario, this item allows it to Mega Evolve in battle.	6	\N
215	Lucky Punch	If held by a Chansey, its critical hit ratio is raised by 2 stages.	2	\N
216	Lum Berry	Holder cures itself if it has a non-volatile status or is confused. Single use.	3	\N
217	Luminous Moss	Raises holder's Sp. Def by 1 stage if hit by a Water-type attack. Single use.	6	\N
218	Lunalium Z	Lunala or Dawn Wings Necrozma with Moongeist Beam can use a special Z-Move.	7	\N
219	Lure Ball	A Poke Ball for catching Pokemon hooked by a Rod when fishing.	2	\N
220	Lustrous Globe	If held by a Palkia, its Water- and Dragon-type attacks have 1.2x power.	8	\N
221	Lustrous Orb	If held by a Palkia, its Water- and Dragon-type attacks have 1.2x power.	4	\N
222	Luxury Ball	A comfortable Poke Ball that makes a caught wild Pokemon quickly grow friendly.	3	\N
223	Lycanium Z	If held by a Lycanroc forme with Stone Edge, it can use Splintered Stormshards.	7	\N
224	Macho Brace	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	3	\N
225	Magmarizer	Evolves Magmar into Magmortar when traded.	4	\N
226	Magnet	Holder's Electric-type attacks have 1.2x power.	2	\N
227	Mago Berry	Restores 1/3 max HP at 1/4 max HP or less; confuses if -Spe Nature. Single use.	3	\N
228	Magost Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
229	Mail	Cannot be given to or taken from a Pokemon, except by Covet/Knock Off/Thief.	2	\N
230	Malicious Armor	Evolves Charcadet into Ceruledge when used.	9	\N
231	Manectite	If held by a Manectric, this item allows it to Mega Evolve in battle.	6	\N
232	Maranga Berry	Raises holder's Sp. Def by 1 stage after it is hit by a special attack. Single use.	6	\N
233	Marshadium Z	If held by Marshadow with Spectral Thief, it can use Soul-Stealing 7-Star Strike.	7	\N
234	Master Ball	The best Ball with the ultimate performance. It will catch any wild Pokemon.	1	\N
235	Masterpiece Teacup	Evolves Poltchageist-Artisan into Sinistcha-Masterpiece when used.	9	\N
236	Mawilite	If held by a Mawile, this item allows it to Mega Evolve in battle.	6	\N
237	Meadow Plate	Holder's Grass-type attacks have 1.2x power. Judgment is Grass type.	4	\N
238	Medichamite	If held by a Medicham, this item allows it to Mega Evolve in battle.	6	\N
239	Mental Herb	Cures holder of Attract, Disable, Encore, Heal Block, Taunt, Torment. Single use.	3	\N
240	Metagrossite	If held by a Metagross, this item allows it to Mega Evolve in battle.	6	\N
241	Metal Coat	Holder's Steel-type attacks have 1.2x power. Evolves Onix into Steelix and Scyther into Scizor when traded.	2	\N
242	Metal Powder	If held by a Ditto that hasn't Transformed, its Defense is doubled.	2	\N
243	Metronome	Damage of moves used on consecutive turns is increased. Max 2x after 5 turns.	4	\N
244	Mewnium Z	If held by a Mew with Psychic, it can use Genesis Supernova.	7	\N
245	Mewtwonite X	If held by a Mewtwo, this item allows it to Mega Evolve in battle.	6	\N
246	Mewtwonite Y	If held by a Mewtwo, this item allows it to Mega Evolve in battle.	6	\N
247	Micle Berry	Holder's next move has 1.2x accuracy when at 1/4 max HP or less. Single use.	4	\N
248	Mimikium Z	If held by a Mimikyu with Play Rough, it can use Let's Snuggle Forever.	7	\N
249	Mind Plate	Holder's Psychic-type attacks have 1.2x power. Judgment is Psychic type.	4	\N
250	Miracle Seed	Holder's Grass-type attacks have 1.2x power.	2	\N
251	Mirror Herb	When an opposing Pokemon raises a stat stage, the holder copies it. Single use.	9	\N
252	Misty Seed	If the terrain is Misty Terrain, raises holder's Sp. Def by 1 stage. Single use.	7	\N
253	Moon Ball	A Poke Ball for catching Pokemon that evolve using the Moon Stone.	2	\N
254	Moon Stone	Evolves Nidorina into Nidoqueen, Nidorino into Nidoking, Clefairy into Clefable, Jigglypuff into Wigglytuff, Skitty into Delcatty, and Munna into Musharna when used.	1	\N
255	Muscle Band	Holder's physical attacks have 1.1x power.	4	\N
256	Mystic Water	Holder's Water-type attacks have 1.2x power.	2	\N
257	Nanab Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
258	Nest Ball	A Poke Ball that works especially well on weaker Pokemon in the wild.	3	\N
259	Net Ball	A Poke Ball that works especially well on Water- and Bug-type Pokemon.	3	\N
260	Never-Melt Ice	Holder's Ice-type attacks have 1.2x power.	2	\N
261	Nomel Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
262	Normal Gem	Holder's first successful Normal-type attack will have 1.3x power. Single use.	5	\N
263	Normalium Z	If holder has a Normal move, this item allows it to use a Normal Z-Move.	7	\N
264	Occa Berry	Halves damage taken from a supereffective Fire-type attack. Single use.	4	\N
265	Odd Incense	Holder's Psychic-type attacks have 1.2x power.	4	\N
266	Old Amber	Can be revived into Aerodactyl.	3	\N
267	Oran Berry	Restores 10 HP when at 1/2 max HP or less. Single use.	3	\N
268	Oval Stone	Evolves Happiny into Chansey when held and leveled up during the day.	4	\N
269	Pamtre Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
270	Park Ball	A special Poke Ball for the Pal Park.	4	\N
271	Passho Berry	Halves damage taken from a supereffective Water-type attack. Single use.	4	\N
272	Payapa Berry	Halves damage taken from a supereffective Psychic-type attack. Single use.	4	\N
273	Pecha Berry	Holder is cured if it is poisoned. Single use.	3	\N
274	Persim Berry	Holder is cured if it is confused. Single use.	3	\N
275	Petaya Berry	Raises holder's Sp. Atk by 1 stage when at 1/4 max HP or less. Single use.	3	\N
346	Sharp Beak	Holder's Flying-type attacks have 1.2x power.	2	\N
276	Pidgeotite	If held by a Pidgeot, this item allows it to Mega Evolve in battle.	6	\N
277	Pikanium Z	If held by a Pikachu with Volt Tackle, it can use Catastropika.	7	\N
278	Pikashunium Z	If held by cap Pikachu with Thunderbolt, it can use 10,000,000 Volt Thunderbolt.	7	\N
279	Pinap Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
280	Pinsirite	If held by a Pinsir, this item allows it to Mega Evolve in battle.	6	\N
281	Pixie Plate	Holder's Fairy-type attacks have 1.2x power. Judgment is Fairy type.	6	\N
282	Plume Fossil	Can be revived into Archen.	5	\N
283	Poison Barb	Holder's Poison-type attacks have 1.2x power.	2	\N
284	Poison Gem	Holder's first successful Poison-type attack will have 1.3x power. Single use.	5	\N
285	Poison Memory	Holder's Multi-Attack is Poison type.	7	\N
286	Poisonium Z	If holder has a Poison move, this item allows it to use a Poison Z-Move.	7	\N
287	Poke Ball	A device for catching wild Pokemon. It is designed as a capsule system.	1	\N
288	Pomeg Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
289	Power Anklet	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	4	\N
290	Power Band	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	4	\N
291	Power Belt	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	4	\N
292	Power Bracer	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	4	\N
293	Power Herb	Holder's two-turn moves complete in one turn (except Sky Drop). Single use.	4	\N
294	Power Lens	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	4	\N
295	Power Weight	Holder's Speed is halved. The Klutz Ability does not ignore this effect.	4	\N
296	Premier Ball	A rare Poke Ball that has been crafted to commemorate an event.	3	\N
297	Primarium Z	If held by a Primarina with Sparkling Aria, it can use Oceanic Operetta.	7	\N
298	Prism Scale	Evolves Feebas into Milotic when traded.	5	\N
299	Protective Pads	Holder's moves are protected from adverse contact effects, except Pickpocket.	7	\N
300	Protector	Evolves Rhydon into Rhyperior when traded.	4	\N
301	Psychic Gem	Holder's first successful Psychic-type attack will have 1.3x power. Single use.	5	\N
302	Psychic Memory	Holder's Multi-Attack is Psychic type.	7	\N
303	Psychic Seed	If the terrain is Psychic Terrain, raises holder's Sp. Def by 1 stage. Single use.	7	\N
304	Psychium Z	If holder has a Psychic move, this item allows it to use a Psychic Z-Move.	7	\N
305	Punching Glove	Holder's punch-based attacks have 1.1x power and do not make contact.	9	\N
306	Qualot Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
307	Quick Ball	A Poke Ball that provides a better catch rate at the start of a wild encounter.	4	\N
308	Quick Claw	Each turn, holder has a 20% chance to move first in its priority bracket.	2	\N
309	Quick Powder	If held by a Ditto that hasn't Transformed, its Speed is doubled.	4	\N
310	Rabuta Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
311	Rare Bone	No competitive use other than when used with Fling.	4	\N
312	Rawst Berry	Holder is cured if it is burned. Single use.	3	\N
313	Razor Claw	Holder's critical hit ratio is raised by 1 stage. Evolves Sneasel into Weavile when held and leveled up during the night.	4	\N
314	Razor Fang	Holder's attacks without a chance to make the target flinch gain a 10% chance to make the target flinch. Evolves Gligar into Gliscor when held and leveled up during the night.	4	\N
315	Razz Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
316	Reaper Cloth	Evolves Dusclops into Dusknoir when traded.	4	\N
317	Red Card	If holder survives a hit, attacker is forced to switch to a random ally. Single use.	5	\N
318	Red Orb	If held by a Groudon, this item triggers its Primal Reversion in battle.	6	\N
319	Repeat Ball	A Poke Ball that works well on Pokemon species that were previously caught.	3	\N
320	Ribbon Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
321	Rindo Berry	Halves damage taken from a supereffective Grass-type attack. Single use.	4	\N
322	Ring Target	The holder's type immunities granted solely by its typing are negated.	5	\N
323	Rock Gem	Holder's first successful Rock-type attack will have 1.3x power. Single use.	5	\N
324	Rock Incense	Holder's Rock-type attacks have 1.2x power.	4	\N
325	Rock Memory	Holder's Multi-Attack is Rock type.	7	\N
326	Rockium Z	If holder has a Rock move, this item allows it to use a Rock Z-Move.	7	\N
327	Rocky Helmet	If holder is hit by a contact move, the attacker loses 1/6 of its max HP.	5	\N
328	Room Service	If Trick Room is active, the holder's Speed is lowered by 1 stage. Single use.	8	\N
329	Root Fossil	Can be revived into Lileep.	3	\N
330	Rose Incense	Holder's Grass-type attacks have 1.2x power.	4	\N
331	Roseli Berry	Halves damage taken from a supereffective Fairy-type attack. Single use.	6	\N
332	Rowap Berry	If holder is hit by a special move, attacker loses 1/8 of its max HP. Single use.	4	\N
333	Rusted Shield	If held by a Zamazenta, this item changes its forme to Crowned Shield.	8	\N
334	Rusted Sword	If held by a Zacian, this item changes its forme to Crowned Sword.	8	\N
335	Sablenite	If held by a Sableye, this item allows it to Mega Evolve in battle.	6	\N
336	Sachet	Evolves Spritzee into Aromatisse when traded.	6	\N
337	Safari Ball	A special Poke Ball that is used only in the Safari Zone and Great Marsh.	1	\N
338	Safety Goggles	Holder is immune to powder moves and damage from Sandstorm or Hail.	6	\N
339	Sail Fossil	Can be revived into Amaura.	6	\N
340	Salac Berry	Raises holder's Speed by 1 stage when at 1/4 max HP or less. Single use.	3	\N
341	Salamencite	If held by a Salamence, this item allows it to Mega Evolve in battle.	6	\N
342	Sceptilite	If held by a Sceptile, this item allows it to Mega Evolve in battle.	6	\N
343	Scizorite	If held by a Scizor, this item allows it to Mega Evolve in battle.	6	\N
344	Scope Lens	Holder's critical hit ratio is raised by 1 stage.	2	\N
347	Sharpedonite	If held by a Sharpedo, this item allows it to Mega Evolve in battle.	6	\N
348	Shed Shell	Holder may switch out even when trapped by another Pokemon, or by Ingrain.	4	\N
349	Shell Bell	After an attack, holder gains 1/8 of the damage in HP dealt to other Pokemon.	3	\N
350	Shiny Stone	Evolves Togetic into Togekiss, Roselia into Roserade, Minccino into Cinccino, and Floette into Florges when used.	4	\N
351	Shock Drive	Holder's Techno Blast is Electric type.	5	\N
352	Shuca Berry	Halves damage taken from a supereffective Ground-type attack. Single use.	4	\N
353	Silk Scarf	Holder's Normal-type attacks have 1.2x power.	3	\N
354	Silver Powder	Holder's Bug-type attacks have 1.2x power.	2	\N
355	Sitrus Berry	Restores 1/4 max HP when at 1/2 max HP or less. Single use.	3	\N
356	Skull Fossil	Can be revived into Cranidos.	4	\N
357	Sky Plate	Holder's Flying-type attacks have 1.2x power. Judgment is Flying type.	4	\N
358	Slowbronite	If held by a Slowbro, this item allows it to Mega Evolve in battle.	6	\N
359	Smooth Rock	Holder's use of Sandstorm lasts 8 turns instead of 5.	4	\N
360	Snorlium Z	If held by a Snorlax with Giga Impact, it can use Pulverizing Pancake.	7	\N
361	Snowball	Raises holder's Attack by 1 if hit by an Ice-type attack. Single use.	6	\N
362	Soft Sand	Holder's Ground-type attacks have 1.2x power.	2	\N
363	Solganium Z	Solgaleo or Dusk Mane Necrozma with Sunsteel Strike can use a special Z-Move.	7	\N
364	Soul Dew	If held by a Latias/Latios, its Dragon- and Psychic-type moves have 1.2x power.	3	\N
365	Spell Tag	Holder's Ghost-type attacks have 1.2x power.	2	\N
366	Spelon Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
367	Splash Plate	Holder's Water-type attacks have 1.2x power. Judgment is Water type.	4	\N
368	Spooky Plate	Holder's Ghost-type attacks have 1.2x power. Judgment is Ghost type.	4	\N
369	Sport Ball	A special Poke Ball for the Bug-Catching Contest.	2	\N
370	Starf Berry	Raises a random stat by 2 when at 1/4 max HP or less (not acc/eva). Single use.	3	\N
371	Star Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
372	Steelixite	If held by a Steelix, this item allows it to Mega Evolve in battle.	6	\N
373	Steel Gem	Holder's first successful Steel-type attack will have 1.3x power. Single use.	5	\N
374	Steel Memory	Holder's Multi-Attack is Steel type.	7	\N
375	Steelium Z	If holder has a Steel move, this item allows it to use a Steel Z-Move.	7	\N
376	Stick	If held by a Farfetch’d, its critical hit ratio is raised by 2 stages.	2	\N
377	Sticky Barb	Each turn, holder loses 1/8 max HP. An attacker making contact can receive it.	4	\N
378	Stone Plate	Holder's Rock-type attacks have 1.2x power. Judgment is Rock type.	4	\N
379	Strawberry Sweet	Evolves Milcery into Alcremie when held and spun around.	8	\N
380	Sun Stone	Evolves Gloom into Bellossom, Sunkern into Sunflora, Cottonee into Whimsicott, Petilil into Lilligant, and Helioptile into Heliolisk when used.	2	\N
381	Swampertite	If held by a Swampert, this item allows it to Mega Evolve in battle.	6	\N
382	Sweet Apple	Evolves Applin into Appletun when used.	8	\N
383	Syrupy Apple	Evolves Applin into Dipplin when used.	9	\N
384	Tamato Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
385	Tanga Berry	Halves damage taken from a supereffective Bug-type attack. Single use.	4	\N
386	Tapunium Z	If held by a Tapu with Nature's Madness, it can use Guardian of Alola.	7	\N
387	Tart Apple	Evolves Applin into Flapple when used.	8	\N
388	Terrain Extender	Holder's use of Electric/Grassy/Misty/Psychic Terrain lasts 8 turns instead of 5.	7	\N
389	Thick Club	If held by a Cubone or a Marowak, its Attack is doubled.	2	\N
390	Throat Spray	Raises holder's Special Attack by 1 stage after it uses a sound move. Single use.	8	\N
391	Thunder Stone	Evolves Pikachu into Raichu or Alolan Raichu, Eevee into Jolteon, Eelektrik into Eelektross, and Charjabug into Vikavolt when used.	1	\N
392	Timer Ball	A Poke Ball that becomes better the more turns there are in a battle.	3	\N
393	Toxic Orb	At the end of every turn, this item attempts to badly poison the holder.	4	\N
394	Toxic Plate	Holder's Poison-type attacks have 1.2x power. Judgment is Poison type.	4	\N
395	TR00	Teaches certain Pokemon the move Swords Dance. One use.	8	\N
396	TR01	Teaches certain Pokemon the move Body Slam. One use.	8	\N
397	TR02	Teaches certain Pokemon the move Flamethrower. One use.	8	\N
398	TR03	Teaches certain Pokemon the move Hydro Pump. One use.	8	\N
399	TR04	Teaches certain Pokemon the move Surf. One use.	8	\N
400	TR05	Teaches certain Pokemon the move Ice Beam. One use.	8	\N
401	TR06	Teaches certain Pokemon the move Blizzard. One use.	8	\N
402	TR07	Teaches certain Pokemon the move Low Kick. One use.	8	\N
403	TR08	Teaches certain Pokemon the move Thunderbolt. One use.	8	\N
404	TR09	Teaches certain Pokemon the move Thunder. One use.	8	\N
405	TR10	Teaches certain Pokemon the move Earthquake. One use.	8	\N
406	TR11	Teaches certain Pokemon the move Psychic. One use.	8	\N
407	TR12	Teaches certain Pokemon the move Agility. One use.	8	\N
408	TR13	Teaches certain Pokemon the move Focus Energy. One use.	8	\N
409	TR14	Teaches certain Pokemon the move Metronome. One use.	8	\N
410	TR15	Teaches certain Pokemon the move Fire Blast. One use.	8	\N
411	TR16	Teaches certain Pokemon the move Waterfall. One use.	8	\N
412	TR17	Teaches certain Pokemon the move Amnesia. One use.	8	\N
413	TR18	Teaches certain Pokemon the move Leech Life. One use.	8	\N
414	TR19	Teaches certain Pokemon the move Tri Attack. One use.	8	\N
415	TR20	Teaches certain Pokemon the move Substitute. One use.	8	\N
416	TR21	Teaches certain Pokemon the move Reversal. One use.	8	\N
417	TR22	Teaches certain Pokemon the move Sludge Bomb. One use.	8	\N
418	TR23	Teaches certain Pokemon the move Spikes. One use.	8	\N
419	TR24	Teaches certain Pokemon the move Outrage. One use.	8	\N
420	TR25	Teaches certain Pokemon the move Psyshock. One use.	8	\N
421	TR26	Teaches certain Pokemon the move Endure. One use.	8	\N
422	TR27	Teaches certain Pokemon the move Sleep Talk. One use.	8	\N
423	TR28	Teaches certain Pokemon the move Megahorn. One use.	8	\N
424	TR29	Teaches certain Pokemon the move Baton Pass. One use.	8	\N
425	TR30	Teaches certain Pokemon the move Encore. One use.	8	\N
426	TR31	Teaches certain Pokemon the move Iron Tail. One use.	8	\N
427	TR32	Teaches certain Pokemon the move Crunch. One use.	8	\N
428	TR33	Teaches certain Pokemon the move Shadow Ball. One use.	8	\N
429	TR34	Teaches certain Pokemon the move Future Sight. One use.	8	\N
430	TR35	Teaches certain Pokemon the move Uproar. One use.	8	\N
431	TR36	Teaches certain Pokemon the move Heat Wave. One use.	8	\N
432	TR37	Teaches certain Pokemon the move Taunt. One use.	8	\N
433	TR38	Teaches certain Pokemon the move Trick. One use.	8	\N
434	TR39	Teaches certain Pokemon the move Superpower. One use.	8	\N
435	TR40	Teaches certain Pokemon the move Skill Swap. One use.	8	\N
436	TR41	Teaches certain Pokemon the move Blaze Kick. One use.	8	\N
437	TR42	Teaches certain Pokemon the move Hyper Voice. One use.	8	\N
438	TR43	Teaches certain Pokemon the move Overheat. One use.	8	\N
439	TR44	Teaches certain Pokemon the move Cosmic Power. One use.	8	\N
440	TR45	Teaches certain Pokemon the move Muddy Water. One use.	8	\N
441	TR46	Teaches certain Pokemon the move Iron Defense. One use.	8	\N
442	TR47	Teaches certain Pokemon the move Dragon Claw. One use.	8	\N
443	TR48	Teaches certain Pokemon the move Bulk Up. One use.	8	\N
444	TR49	Teaches certain Pokemon the move Calm Mind. One use.	8	\N
445	TR50	Teaches certain Pokemon the move Leaf Blade. One use.	8	\N
446	TR51	Teaches certain Pokemon the move Dragon Dance. One use.	8	\N
447	TR52	Teaches certain Pokemon the move Gyro Ball. One use.	8	\N
448	TR53	Teaches certain Pokemon the move Close Combat. One use.	8	\N
449	TR54	Teaches certain Pokemon the move Toxic Spikes. One use.	8	\N
450	TR55	Teaches certain Pokemon the move Flare Blitz. One use.	8	\N
451	TR56	Teaches certain Pokemon the move Aura Sphere. One use.	8	\N
452	TR57	Teaches certain Pokemon the move Poison Jab. One use.	8	\N
453	TR58	Teaches certain Pokemon the move Dark Pulse. One use.	8	\N
454	TR59	Teaches certain Pokemon the move Seed Bomb. One use.	8	\N
455	TR60	Teaches certain Pokemon the move X-Scissor. One use.	8	\N
456	TR61	Teaches certain Pokemon the move Bug Buzz. One use.	8	\N
457	TR62	Teaches certain Pokemon the move Dragon Pulse. One use.	8	\N
458	TR63	Teaches certain Pokemon the move Power Gem. One use.	8	\N
459	TR64	Teaches certain Pokemon the move Focus Blast. One use.	8	\N
460	TR65	Teaches certain Pokemon the move Energy Ball. One use.	8	\N
461	TR66	Teaches certain Pokemon the move Brave Bird. One use.	8	\N
462	TR67	Teaches certain Pokemon the move Earth Power. One use.	8	\N
463	TR68	Teaches certain Pokemon the move Nasty Plot. One use.	8	\N
464	TR69	Teaches certain Pokemon the move Zen Headbutt. One use.	8	\N
465	TR70	Teaches certain Pokemon the move Flash Cannon. One use.	8	\N
466	TR71	Teaches certain Pokemon the move Leaf Storm. One use.	8	\N
467	TR72	Teaches certain Pokemon the move Power Whip. One use.	8	\N
468	TR73	Teaches certain Pokemon the move Gunk Shot. One use.	8	\N
469	TR74	Teaches certain Pokemon the move Iron Head. One use.	8	\N
470	TR75	Teaches certain Pokemon the move Stone Edge. One use.	8	\N
471	TR76	Teaches certain Pokemon the move Stealth Rock. One use.	8	\N
472	TR77	Teaches certain Pokemon the move Grass Knot. One use.	8	\N
473	TR78	Teaches certain Pokemon the move Sludge Wave. One use.	8	\N
474	TR79	Teaches certain Pokemon the move Heavy Slam. One use.	8	\N
475	TR80	Teaches certain Pokemon the move Electro Ball. One use.	8	\N
476	TR81	Teaches certain Pokemon the move Foul Play. One use.	8	\N
477	TR82	Teaches certain Pokemon the move Stored Power. One use.	8	\N
478	TR83	Teaches certain Pokemon the move Ally Switch. One use.	8	\N
479	TR84	Teaches certain Pokemon the move Scald. One use.	8	\N
480	TR85	Teaches certain Pokemon the move Work Up. One use.	8	\N
481	TR86	Teaches certain Pokemon the move Wild Charge. One use.	8	\N
482	TR87	Teaches certain Pokemon the move Drill Run. One use.	8	\N
483	TR88	Teaches certain Pokemon the move Heat Crash. One use.	8	\N
484	TR89	Teaches certain Pokemon the move Hurricane. One use.	8	\N
485	TR90	Teaches certain Pokemon the move Play Rough. One use.	8	\N
486	TR91	Teaches certain Pokemon the move Venom Drench. One use.	8	\N
487	TR92	Teaches certain Pokemon the move Dazzling Gleam. One use.	8	\N
488	TR93	Teaches certain Pokemon the move Darkest Lariat. One use.	8	\N
489	TR94	Teaches certain Pokemon the move High Horsepower. One use.	8	\N
490	TR95	Teaches certain Pokemon the move Throat Chop. One use.	8	\N
491	TR96	Teaches certain Pokemon the move Pollen Puff. One use.	8	\N
492	TR97	Teaches certain Pokemon the move Psychic Fangs. One use.	8	\N
493	TR98	Teaches certain Pokemon the move Liquidation. One use.	8	\N
494	TR99	Teaches certain Pokemon the move Body Press. One use.	8	\N
495	Twisted Spoon	Holder's Psychic-type attacks have 1.2x power.	2	\N
496	Tyranitarite	If held by a Tyranitar, this item allows it to Mega Evolve in battle.	6	\N
497	Ultra Ball	An ultra-performance Ball that provides a higher catch rate than a Great Ball.	1	\N
498	Ultranecrozium Z	Dusk Mane/Dawn Wings Necrozma: Ultra Burst, then Z-Move w/ Photon Geyser.	7	\N
499	Unremarkable Teacup	Evolves Poltchageist into Sinistcha when used.	9	\N
500	Up-Grade	Evolves Porygon into Porygon2 when traded.	2	\N
501	Utility Umbrella	The holder ignores rain- and sun-based effects. Damage and accuracy calculations from attacks used by the holder are affected by rain and sun, but not attacks used against the holder.	8	\N
502	Venusaurite	If held by a Venusaur, this item allows it to Mega Evolve in battle.	6	\N
503	Wacan Berry	Halves damage taken from a supereffective Electric-type attack. Single use.	4	\N
504	Water Gem	Holder's first successful Water-type attack will have 1.3x power. Single use.	5	\N
505	Water Memory	Holder's Multi-Attack is Water type.	7	\N
506	Water Stone	Evolves Poliwhirl into Poliwrath, Shellder into Cloyster, Staryu into Starmie, Eevee into Vaporeon, Lombre into Ludicolo, and Panpour into Simipour when used.	1	\N
507	Waterium Z	If holder has a Water move, this item allows it to use a Water Z-Move.	7	\N
508	Watmel Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
509	Wave Incense	Holder's Water-type attacks have 1.2x power.	4	\N
510	Weakness Policy	If holder is hit super effectively, raises Attack, Sp. Atk by 2 stages. Single use.	6	\N
511	Wellspring Mask	Ogerpon-Wellspring: 1.2x power attacks; Terastallize to gain Embody Aspect.	9	\N
512	Wepear Berry	Cannot be eaten by the holder. No effect when eaten with Bug Bite or Pluck.	3	\N
513	Whipped Dream	Evolves Swirlix into Slurpuff when traded.	6	\N
514	White Herb	Restores all lowered stat stages to 0 when one is less than 0. Single use.	3	\N
515	Wide Lens	The accuracy of attacks by the holder is 1.1x.	4	\N
516	Wiki Berry	Restores 1/3 max HP at 1/4 max HP or less; confuses if -SpA Nature. Single use.	3	\N
517	Wise Glasses	Holder's special attacks have 1.1x power.	4	\N
518	Yache Berry	Halves damage taken from a supereffective Ice-type attack. Single use.	4	\N
519	Zap Plate	Holder's Electric-type attacks have 1.2x power. Judgment is Electric type.	4	\N
520	Zoom Lens	The accuracy of attacks by the holder is 1.2x if it moves after its target.	4	\N
521	Berserk Gene	(Gen 2) On switch-in, raises holder's Attack by 2 and confuses it. Single use.	2	\N
522	Berry	(Gen 2) Restores 10 HP when at 1/2 max HP or less. Single use.	2	\N
523	Bitter Berry	(Gen 2) Holder is cured if it is confused. Single use.	2	\N
524	Burnt Berry	(Gen 2) Holder is cured if it is frozen. Single use.	2	\N
525	Gold Berry	(Gen 2) Restores 30 HP when at 1/2 max HP or less. Single use.	2	\N
526	Ice Berry	(Gen 2) Holder is cured if it is burned. Single use.	2	\N
527	Mint Berry	(Gen 2) Holder wakes up if it is asleep. Single use.	2	\N
528	Miracle Berry	(Gen 2) Holder cures itself if it is confused or has a status condition. Single use.	2	\N
529	Mystery Berry	(Gen 2) Restores 5 PP to the first of the holder's moves to reach 0 PP. Single use.	2	\N
530	Pink Bow	(Gen 2) Holder's Normal-type attacks have 1.1x power.	2	\N
531	Polkadot Bow	(Gen 2) Holder's Normal-type attacks have 1.1x power.	2	\N
532	PRZ Cure Berry	(Gen 2) Holder cures itself if it is paralyzed. Single use.	2	\N
533	PSN Cure Berry	(Gen 2) Holder is cured if it is poisoned. Single use.	2	\N
534	Crucibellite	If held by a Crucibelle, this item allows it to Mega Evolve in battle.	6	\N
535	Vile Vial	If held by a Venomicon, its Poison- and Flying-type attacks have 1.2x power.	8	\N
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.matches (id_tournament, id_team_1, id_team_2, winner) FROM stdin;
1	1	3	0
2	2	4	0
2	2	6	0
2	4	6	0
\.


--
-- Data for Name: movements; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.movements (id, name, description, power, accuracy, pp, id_type, category, generation, unavailable_from) FROM stdin;
1	10,000,000 Volt Thunderbolt	Has a very high chance for a critical hit.	195	1	1	4	Special	1	10
2	Absorb	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	20	100	25	5	Special	1	10
3	Accelerock	No additional effect.	40	100	20	13	Physical	1	10
4	Acid	Has a 10% chance to lower the target's Special Defense by 1 stage.	40	100	30	8	Special	1	10
5	Acid Armor	Raises the user's Defense by 2 stages.	0	1	20	8	Status	1	10
6	Acid Downpour	Power is equal to the base move's Z-Power.	1	1	1	8	Physical	1	10
7	Acid Spray	Has a 100% chance to lower the target's Special Defense by 2 stages.	40	100	20	8	Special	1	10
8	Acrobatics	Power doubles if the user has no held item.	55	100	15	10	Physical	1	10
9	Acupressure	Raises a random stat by 2 stages as long as the stat is not already at stage 6. The user can choose to use this move on itself or an adjacent ally. Fails if no stat stage can be raised or if used on an ally with a substitute.	0	1	30	1	Status	1	10
10	Aerial Ace	This move does not check accuracy.	60	1	20	10	Physical	1	10
11	Aeroblast	Has a higher chance for a critical hit.	100	95	5	10	Special	1	10
12	After You	The target makes its move immediately after the user this turn, no matter the priority of its selected move. Fails if the target would have moved next anyway, or if the target already moved this turn.	0	1	15	1	Status	1	10
13	Agility	Raises the user's Speed by 2 stages.	0	1	30	11	Status	1	10
14	Air Cutter	Has a higher chance for a critical hit.	60	95	25	10	Special	1	10
15	Air Slash	Has a 30% chance to make the target flinch.	75	95	15	10	Special	1	10
16	All-Out Pummeling	Power is equal to the base move's Z-Power.	1	1	1	7	Physical	1	10
17	Ally Switch	The user swaps positions with its ally. Fails if the user is the only Pokemon on its side. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails or if the user's last move used is not Ally Switch.	0	1	15	11	Status	1	10
18	Amnesia	Raises the user's Special Defense by 2 stages.	0	1	20	11	Status	1	10
19	Anchor Shot	Prevents the target from switching out. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	80	100	20	16	Physical	1	10
20	Ancient Power	Has a 10% chance to raise the user's Attack, Defense, Special Attack, Special Defense, and Speed by 1 stage.	60	100	5	13	Special	1	10
21	Apple Acid	Has a 100% chance to lower the target's Special Defense by 1 stage.	80	100	10	5	Special	1	10
22	Aqua Cutter	Has a higher chance for a critical hit.	70	100	20	3	Physical	1	10
23	Aqua Jet	No additional effect.	40	100	20	3	Physical	1	10
24	Aqua Ring	The user has 1/16 of its maximum HP, rounded down, restored at the end of each turn while it remains active. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down. If the user uses Baton Pass, the replacement will receive the healing effect.	0	1	20	3	Status	1	10
25	Aqua Step	Has a 100% chance to raise the user's Speed by 1 stage.	80	100	10	3	Physical	1	10
26	Aqua Tail	No additional effect.	90	90	10	3	Physical	1	10
27	Armor Cannon	Lowers the user's Defense and Special Defense by 1 stage.	120	100	5	2	Special	1	10
28	Arm Thrust	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	15	100	20	7	Physical	1	10
29	Aromatherapy	Every Pokemon in the user's party is cured of its non-volatile status condition. Active Pokemon with the Sap Sipper Ability are not cured, unless they are the user.	0	1	5	5	Status	1	10
30	Aromatic Mist	Raises the target's Special Defense by 1 stage. Fails if there is no ally adjacent to the user.	0	1	20	18	Status	1	10
31	Assist	A random move among those known by the user's party members is selected for use. Does not select Assist, Baneful Bunker, Beak Blast, Belch, Bestow, Blazing Torque, Bounce, Celebrate, Chatter, Circle Throw, Combat Torque, Copycat, Counter, Covet, Destiny Bond, Detect, Dig, Dive, Dragon Tail, Endure, Feint, Fly, Focus Punch, Follow Me, Helping Hand, Hold Hands, King's Shield, Magical Torque, Mat Block, Me First, Metronome, Mimic, Mirror Coat, Mirror Move, Nature Power, Noxious Torque, Phantom Force, Protect, Rage Powder, Roar, Shadow Force, Shell Trap, Sketch, Sky Drop, Sleep Talk, Snatch, Spiky Shield, Spotlight, Struggle, Switcheroo, Thief, Transform, Trick, Whirlwind, or Wicked Torque.	0	1	20	1	Status	1	10
32	Assurance	Power doubles if the target has already taken damage this turn, other than direct damage from Belly Drum, confusion, Curse, or Pain Split.	60	100	10	17	Physical	1	10
33	Astonish	Has a 30% chance to make the target flinch.	30	100	15	14	Physical	1	10
34	Astral Barrage	No additional effect.	120	100	5	14	Special	1	10
35	Attack Order	Has a higher chance for a critical hit.	90	100	15	12	Physical	1	10
36	Attract	Causes the target to become infatuated, making it unable to attack 50% of the time. Fails if both the user and the target are the same gender, if either is genderless, or if the target is already infatuated. The effect ends when either the user or the target is no longer active. Pokemon with the Oblivious Ability or protected by the Aroma Veil Ability are immune.	0	100	15	1	Status	1	10
37	Aura Sphere	This move does not check accuracy.	80	1	20	7	Special	1	10
38	Aura Wheel	Has a 100% chance to raise the user's Speed by 1 stage. If the user is a Morpeko in Full Belly Mode, this move is Electric type. If the user is a Morpeko in Hangry Mode, this move is Dark type. This move cannot be used successfully unless the user's current form, while considering Transform, is Full Belly or Hangry Mode Morpeko.	110	100	10	4	Physical	1	10
39	Aurora Beam	Has a 10% chance to lower the target's Attack by 1 stage.	65	100	20	6	Special	1	10
40	Aurora Veil	For 5 turns, the user and its party members take 0.5x damage from physical and special attacks, or 0.66x damage if in a Double Battle; does not reduce damage further with Reflect or Light Screen. Critical hits ignore this protection. It is removed from the user's side if the user or an ally is successfully hit by Brick Break, Psychic Fangs, or Defog. Brick Break and Psychic Fangs remove the effect before damage is calculated. Lasts for 8 turns if the user is holding Light Clay. Fails unless the weather is Hail.	0	1	20	6	Status	1	10
738	Smart Strike	This move does not check accuracy.	70	1	10	16	Physical	1	10
41	Autotomize	Raises the user's Speed by 2 stages. If the user's Speed was changed, the user's weight is reduced by 100 kg as long as it remains active. This effect is stackable but cannot reduce the user's weight to less than 0.1 kg.	0	1	15	16	Status	1	10
42	Avalanche	Power doubles if the user was hit by the target this turn.	60	100	10	6	Physical	1	10
43	Axe Kick	Has a 30% chance to confuse the target. If this attack is not successful, the user loses half of its maximum HP, rounded down, as crash damage. Pokemon with the Magic Guard Ability are unaffected by crash damage.	120	90	10	7	Physical	1	10
44	Baby-Doll Eyes	Lowers the target's Attack by 1 stage.	0	100	30	18	Status	1	10
45	Baddy Bad	This move summons Reflect for 5 turns upon use.	80	95	15	17	Special	1	10
46	Baneful Bunker	The user is protected from most attacks made by other Pokemon during this turn, and Pokemon making contact with the user become poisoned. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	8	Status	1	10
47	Barb Barrage	Has a 50% chance to poison the target. Power doubles if the target is already poisoned.	60	100	10	8	Physical	1	10
48	Barrage	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	15	85	20	1	Physical	1	10
49	Barrier	Raises the user's Defense by 2 stages.	0	1	20	11	Status	1	10
50	Baton Pass	The user is replaced with another Pokemon in its party. The selected Pokemon has the user's stat stage changes, confusion, and certain move effects transferred to it.	0	1	40	1	Status	1	10
51	Beak Blast	If the user is hit by a contact move this turn before it can execute this move, the attacker is burned.	100	100	15	10	Physical	1	10
52	Beat Up	Hits one time for the user and one time for each unfainted Pokemon without a non-volatile status condition in the user's party. The power of each hit is equal to 5+(X/10), where X is each participating Pokemon's base Attack; each hit is considered to come from the user.	0	100	10	17	Physical	1	10
53	Behemoth Bash	No additional effect.	100	100	5	16	Physical	1	10
54	Behemoth Blade	No additional effect.	100	100	5	16	Physical	1	10
55	Belch	This move cannot be selected until the user eats a Berry, either by eating one that was held, stealing and eating one off another Pokemon with Bug Bite or Pluck, or eating one that was thrown at it with Fling. Once the condition is met, this move can be selected and used for the rest of the battle even if the user gains or uses another item or switches out. Consuming a Berry with Natural Gift does not count for the purposes of eating one.	120	90	10	8	Special	1	10
56	Belly Drum	Raises the user's Attack by 12 stages in exchange for the user losing 1/2 of its maximum HP, rounded down. Fails if the user would faint or if its Attack stat stage is 6.	0	1	10	1	Status	1	10
57	Bestow	The target receives the user's held item. Fails if the user has no item or is holding a Mail or Z-Crystal, if the target is already holding an item, if the user is a Kyogre holding a Blue Orb, a Groudon holding a Red Orb, a Giratina holding a Griseous Orb, an Arceus holding a Plate, a Genesect holding a Drive, a Silvally holding a Memory, a Pokemon that can Mega Evolve holding the Mega Stone for its species, or if the target is one of those Pokemon and the user is holding the respective item.	0	1	15	1	Status	1	10
58	Bide	The user spends two turns locked into this move and then, on the second turn after using this move, the user attacks the last Pokemon that hit it, inflicting double the damage in HP it lost to attacks during the two turns. If the last Pokemon that hit it is no longer active, the user attacks a random opposing Pokemon instead. If the user is prevented from moving during this move's use, the effect ends. This move does not check accuracy and does not ignore type immunity.	0	1	10	1	Physical	1	10
59	Bind	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	15	85	20	1	Physical	1	10
60	Bite	Has a 30% chance to make the target flinch.	60	100	25	17	Physical	1	10
61	Bitter Blade	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	90	100	10	2	Physical	1	10
62	Bitter Malice	Has a 100% chance to lower the target's Attack by 1 stage.	75	100	10	14	Special	1	10
63	Black Hole Eclipse	Power is equal to the base move's Z-Power.	1	1	1	17	Physical	1	10
64	Blast Burn	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	2	Special	1	10
65	Blaze Kick	Has a 10% chance to burn the target and a higher chance for a critical hit.	85	90	10	2	Physical	1	10
66	Blazing Torque	Has a 30% chance to burn the target.	80	100	10	2	Physical	1	10
67	Bleakwind Storm	Has a 30% chance to lower the target's Speed by 1 stage. If the weather is Primordial Sea or Rain Dance, this move does not check accuracy. If this move is used against a Pokemon holding Utility Umbrella, this move's accuracy remains at 80%.	100	80	10	10	Special	1	10
68	Blizzard	Has a 10% chance to freeze the target. If the weather is Snow, this move does not check accuracy.	110	70	5	6	Special	1	10
69	Block	Prevents the target from switching out. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	0	1	5	1	Status	1	10
70	Blood Moon	Cannot be used twice in a row.	140	100	5	1	Special	1	10
71	Bloom Doom	Power is equal to the base move's Z-Power.	1	1	1	5	Physical	1	10
72	Blue Flare	Has a 20% chance to burn the target.	130	85	5	2	Special	1	10
73	Body Press	Damage is calculated using the user's Defense stat as its Attack, including stat stage changes. Other effects that modify the Attack stat are used as normal.	80	100	10	7	Physical	1	10
74	Body Slam	Has a 30% chance to paralyze the target. Damage doubles and no accuracy check is done if the target has used Minimize while active.	85	100	15	1	Physical	1	10
75	Bolt Beak	Power doubles if the user moves before the target.	85	100	10	4	Physical	1	10
76	Bolt Strike	Has a 20% chance to paralyze the target.	130	85	5	4	Physical	1	10
77	Bone Club	Has a 10% chance to make the target flinch.	65	85	20	9	Physical	1	10
78	Bonemerang	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	50	90	10	9	Physical	1	10
79	Bone Rush	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	90	10	9	Physical	1	10
80	Boomburst	No additional effect.	140	100	10	1	Special	1	10
81	Bounce	Has a 30% chance to paralyze the target. This attack charges on the first turn and executes on the second. On the first turn, the user avoids all attacks other than Gust, Hurricane, Sky Uppercut, Smack Down, Thousand Arrows, Thunder, and Twister, and Gust and Twister have doubled power when used against it. If the user is holding a Power Herb, the move completes in one turn.	85	85	5	10	Physical	1	10
82	Bouncy Bubble	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	60	100	20	3	Special	1	10
83	Branch Poke	No additional effect.	40	100	40	5	Physical	1	10
84	Brave Bird	If the target lost HP, the user takes recoil damage equal to 33% the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	15	10	Physical	1	10
85	Breaking Swipe	Has a 100% chance to lower the target's Attack by 1 stage.	60	100	15	15	Physical	1	10
86	Breakneck Blitz	Power is equal to the base move's Z-Power.	1	1	1	1	Physical	1	10
87	Brick Break	If this attack does not miss, the effects of Reflect, Light Screen, and Aurora Veil end for the target's side of the field before damage is calculated.	75	100	15	7	Physical	1	10
88	Brine	Power doubles if the target has less than or equal to half of its maximum HP remaining.	65	100	10	3	Special	1	10
89	Brutal Swing	No additional effect.	60	100	20	17	Physical	1	10
90	Bubble	Has a 10% chance to lower the target's Speed by 1 stage.	40	100	30	3	Special	1	10
91	Bubble Beam	Has a 10% chance to lower the target's Speed by 1 stage.	65	100	20	3	Special	1	10
92	Bug Bite	If this move is successful and the user has not fainted, it steals the target's held Berry if it is holding one and eats it immediately, gaining its effects even if the user's item is being ignored. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	60	100	20	12	Physical	1	10
93	Bug Buzz	Has a 10% chance to lower the target's Special Defense by 1 stage.	90	100	10	12	Special	1	10
94	Bulk Up	Raises the user's Attack and Defense by 1 stage.	0	1	20	7	Status	1	10
95	Bulldoze	Has a 100% chance to lower the target's Speed by 1 stage.	60	100	20	9	Physical	1	10
96	Bullet Punch	No additional effect.	40	100	30	16	Physical	1	10
97	Bullet Seed	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	100	30	5	Physical	1	10
98	Burning Jealousy	Has a 100% chance to burn the target if it had a stat stage raised this turn.	70	100	5	2	Special	1	10
99	Burn Up	Fails unless the user is a Fire type. If this move is successful and the user is not Terastallized, the user's Fire type becomes typeless as long as it remains active.	130	100	5	2	Special	1	10
100	Buzzy Buzz	Has a 100% chance to paralyze the foe.	60	100	20	4	Special	1	10
101	Calm Mind	Raises the user's Special Attack and Special Defense by 1 stage.	0	1	20	11	Status	1	10
102	Camouflage	The user's type changes based on the battle terrain. Normal type on the regular Wi-Fi terrain, Electric type during Electric Terrain, Fairy type during Misty Terrain, Grass type during Grassy Terrain, and Psychic type during Psychic Terrain. Fails if the user's type cannot be changed or if the user is already purely that type.	0	1	20	1	Status	1	10
103	Captivate	Lowers the target's Special Attack by 2 stages. The target is unaffected if both the user and the target are the same gender, or if either is genderless. Pokemon with the Oblivious Ability are immune.	0	100	20	1	Status	1	10
104	Catastropika	No additional effect.	210	1	1	4	Physical	1	10
105	Ceaseless Edge	If this move is successful, it sets up a hazard on the opposing side of the field, damaging each opposing Pokemon that switches in, unless it is a Flying-type Pokemon or has the Levitate Ability. A maximum of three layers may be set, and opponents lose 1/8 of their maximum HP with one layer, 1/6 of their maximum HP with two layers, and 1/4 of their maximum HP with three layers, all rounded down. Can be removed from the opposing side if any opposing Pokemon uses Mortal Spin, Rapid Spin, or Defog successfully, or is hit by Defog.	65	90	15	17	Physical	1	10
106	Celebrate	No competitive use.	0	1	40	1	Status	1	10
107	Charge	Raises the user's Special Defense by 1 stage. The user's next Electric-type attack will have its power doubled; the effect ends when the user is no longer active, or after the user attempts to use any Electric-type move besides Charge, even if it is not successful.	0	1	20	4	Status	1	10
108	Charge Beam	Has a 70% chance to raise the user's Special Attack by 1 stage.	50	90	10	4	Special	1	10
109	Charm	Lowers the target's Attack by 2 stages.	0	100	20	18	Status	1	10
110	Chatter	Has a 100% chance to confuse the target.	65	100	20	10	Special	1	10
111	Chilling Water	Has a 100% chance to lower the target's Attack by 1 stage.	50	100	20	3	Special	1	10
112	Chilly Reception	For 5 turns, the weather becomes Snow. The user switches out even if it is trapped and is replaced immediately by a selected party member. The user does not switch out if there are no unfainted party members.	0	1	10	6	Status	1	10
113	Chip Away	Ignores the target's stat stage changes, including evasiveness.	70	100	20	1	Physical	1	10
114	Chloroblast	If this move is successful, the user loses 1/2 of its maximum HP, rounded up, unless the user has the Magic Guard Ability.	150	95	5	5	Special	1	10
115	Circle Throw	If both the user and the target have not fainted, the target is forced to switch out and be replaced with a random unfainted ally. This effect fails if the target is under the effect of Ingrain, has the Suction Cups Ability, or this move hit a substitute.	60	90	10	7	Physical	1	10
116	Clamp	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	35	85	15	3	Physical	1	10
117	Clanging Scales	Lowers the user's Defense by 1 stage.	110	100	5	15	Special	1	10
118	Clangorous Soul	Raises the user's Attack, Defense, Special Attack, Special Defense, and Speed by 1 stage in exchange for the user losing 33% of its maximum HP, rounded down. Fails if the user would faint or if its Attack, Defense, Special Attack, Special Defense, and Speed stat stages would not change.	0	100	5	15	Status	1	10
119	Clangorous Soulblaze	Raises the user's Attack, Defense, Special Attack, Special Defense, and Speed by 1 stage.	185	1	1	15	Special	1	10
120	Clear Smog	Resets all of the target's stat stages to 0.	50	1	15	8	Special	1	10
121	Close Combat	Lowers the user's Defense and Special Defense by 1 stage.	120	100	5	7	Physical	1	10
122	Coaching	Raises the target's Attack and Defense by 1 stage. Fails if there is no ally adjacent to the user.	0	1	10	7	Status	1	10
123	Coil	Raises the user's Attack, Defense, and accuracy by 1 stage.	0	1	20	8	Status	1	10
124	Collision Course	Damage is multiplied by 1.3333 if this move is super effective against the target.	100	100	5	7	Physical	1	10
125	Combat Torque	Has a 30% chance to paralyze the target.	100	100	10	7	Physical	1	10
126	Comet Punch	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	18	85	15	1	Physical	1	10
127	Comeuppance	Deals damage to the last opposing Pokemon to hit the user with a physical or special attack this turn equal to 1.5 times the HP lost by the user from that attack, rounded down. If the user did not lose HP from that attack, this move deals 1 HP of damage instead. If that opposing Pokemon's position is no longer in use and there is another opposing Pokemon on the field, the damage is done to it instead. Only the last hit of a multi-hit attack is counted. Fails if the user was not hit by an opposing Pokemon's physical or special attack this turn.	0	100	10	17	Physical	1	10
128	Confide	Lowers the target's Special Attack by 1 stage.	0	1	20	1	Status	1	10
129	Confuse Ray	Causes the target to become confused.	0	100	10	14	Status	1	10
130	Confusion	Has a 10% chance to confuse the target.	50	100	25	11	Special	1	10
131	Constrict	Has a 10% chance to lower the target's Speed by 1 stage.	10	100	35	1	Physical	1	10
132	Continental Crush	Power is equal to the base move's Z-Power.	1	1	1	13	Physical	1	10
133	Conversion	The user's type changes to match the original type of the move in its first move slot. Fails if the user cannot change its type, or if the type is one of the user's current types.	0	1	30	1	Status	1	10
134	Conversion 2	The user's type changes to match a type that resists or is immune to the type of the last move used by the target, but not either of its current types. The determined type of the move is used rather than the original type. Fails if the target has not made a move, if the user cannot change its type, or if this move would only be able to select one of the user's current types.	0	1	30	1	Status	1	10
135	Copycat	The user uses the last move used by any Pokemon, including itself. Fails if no move has been used, or if the last move used was Assist, Baneful Bunker, Beak Blast, Behemoth Bash, Behemoth Blade, Belch, Bestow, Blazing Torque, Celebrate, Chatter, Circle Throw, Combat Torque, Copycat, Counter, Covet, Destiny Bond, Detect, Dragon Tail, Dynamax Cannon, Endure, Feint, Focus Punch, Follow Me, Helping Hand, Hold Hands, King's Shield, Magical Torque, Mat Block, Me First, Metronome, Mimic, Mirror Move, Nature Power, Noxious Torque, Protect, Rage Powder, Roar, Shell Trap, Sketch, Sleep Talk, Snatch, Spiky Shield, Spotlight, Struggle, Switcheroo, Thief, Transform, Trick, Whirlwind, or Wicked Torque.	0	1	20	1	Status	1	10
136	Core Enforcer	If the user moves after the target, the target's Ability is rendered ineffective as long as it remains active. If the target uses Baton Pass, the replacement will remain under this effect. If the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode, or Zero to Hero, this effect does not happen, and receiving the effect through Baton Pass ends the effect immediately.	100	100	10	15	Special	1	10
137	Corkscrew Crash	Power is equal to the base move's Z-Power.	1	1	1	16	Physical	1	10
138	Corrosive Gas	The target loses its held item. This move cannot cause Pokemon with the Sticky Hold Ability to lose their held item or cause a Kyogre, a Groudon, a Giratina, an Arceus, a Genesect, a Silvally, a Zacian, or a Zamazenta to lose their Blue Orb, Red Orb, Griseous Orb, Plate, Drive, Memory, Rusted Sword, or Rusted Shield respectively. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	0	100	40	8	Status	1	10
139	Cosmic Power	Raises the user's Defense and Special Defense by 1 stage.	0	1	20	11	Status	1	10
140	Cotton Guard	Raises the user's Defense by 3 stages.	0	1	10	5	Status	1	10
141	Cotton Spore	Lowers the target's Speed by 2 stages.	0	100	40	5	Status	1	10
142	Counter	Deals damage to the last opposing Pokemon to hit the user with a physical attack this turn equal to twice the HP lost by the user from that attack. If the user did not lose HP from the attack, this move deals 1 HP of damage instead. If that opposing Pokemon's position is no longer in use and there is another opposing Pokemon on the field, the damage is done to it instead. Only the last hit of a multi-hit attack is counted. Fails if the user was not hit by an opposing Pokemon's physical attack this turn.	0	100	20	7	Physical	1	10
143	Court Change	Switches the Mist, Light Screen, Reflect, Spikes, Safeguard, Tailwind, Toxic Spikes, Stealth Rock, Water Pledge, Fire Pledge, Grass Pledge, Sticky Web, Aurora Veil, G-Max Steelsurge, G-Max Cannonade, G-Max Vine Lash, and G-Max Wildfire effects from the user's side to the opposing side and vice versa.	0	100	10	1	Status	1	10
175	Double-Edge	If the target lost HP, the user takes recoil damage equal to 33% the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	15	1	Physical	1	10
176	Double Hit	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	35	90	10	1	Physical	1	10
144	Covet	If this attack was successful and the user has not fainted, it steals the target's held item if the user is not holding one. The target's item is not stolen if it is a Mail or Z-Crystal, or if the target is a Kyogre holding a Blue Orb, a Groudon holding a Red Orb, a Giratina holding a Griseous Orb, an Arceus holding a Plate, a Genesect holding a Drive, a Silvally holding a Memory, or a Pokemon that can Mega Evolve holding the Mega Stone for its species. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	60	100	25	1	Physical	1	10
145	Crabhammer	Has a higher chance for a critical hit.	100	90	10	3	Physical	1	10
146	Crafty Shield	The user and its party members are protected from non-damaging attacks made by other Pokemon, including allies, during this turn. Fails if the user moves last this turn or if this move is already in effect for the user's side.	0	1	10	18	Status	1	10
147	Cross Chop	Has a higher chance for a critical hit.	100	80	5	7	Physical	1	10
148	Cross Poison	Has a 10% chance to poison the target and a higher chance for a critical hit.	70	100	20	8	Physical	1	10
149	Crunch	Has a 20% chance to lower the target's Defense by 1 stage.	80	100	15	17	Physical	1	10
150	Crush Claw	Has a 50% chance to lower the target's Defense by 1 stage.	75	95	10	1	Physical	1	10
151	Crush Grip	Power is equal to 120 * (target's current HP / target's maximum HP), rounded half down, but not less than 1.	0	100	5	1	Physical	1	10
152	Curse	If the user is not a Ghost type, lowers the user's Speed by 1 stage and raises the user's Attack and Defense by 1 stage. If the user is a Ghost type, the user loses 1/2 of its maximum HP, rounded down and even if it would cause fainting, in exchange for the target losing 1/4 of its maximum HP, rounded down, at the end of each turn while it is active. If the target uses Baton Pass, the replacement will continue to be affected. Fails if there is no target or if the target is already affected.	0	1	10	14	Status	1	10
153	Cut	No additional effect.	50	95	30	1	Physical	1	10
154	Darkest Lariat	Ignores the target's stat stage changes, including evasiveness.	85	100	10	17	Physical	1	10
155	Dark Pulse	Has a 20% chance to make the target flinch.	80	100	15	17	Special	1	10
156	Dark Void	Causes the target to fall asleep. This move cannot be used successfully unless the user's current form, while considering Transform, is Darkrai.	0	50	10	17	Status	1	10
157	Dazzling Gleam	No additional effect.	80	100	10	18	Special	1	10
158	Decorate	Raises the target's Attack and Special Attack by 2 stages.	0	1	15	18	Status	1	10
159	Defend Order	Raises the user's Defense and Special Defense by 1 stage.	0	1	10	12	Status	1	10
160	Defense Curl	Raises the user's Defense by 1 stage. As long as the user remains active, the power of the user's Ice Ball and Rollout will be doubled (this effect is not stackable).	0	1	40	1	Status	1	10
161	Defog	Lowers the target's evasiveness by 1 stage. If this move is successful and whether or not the target's evasiveness was affected, the effects of Reflect, Light Screen, Aurora Veil, Safeguard, Mist, Spikes, Toxic Spikes, Stealth Rock, and Sticky Web end for the target's side, and the effects of Spikes, Toxic Spikes, Stealth Rock, and Sticky Web end for the user's side. Ignores a target's substitute, although a substitute will still block the lowering of evasiveness. If there is a terrain active and this move is successful, the terrain will be cleared.	0	1	15	10	Status	1	10
162	Destiny Bond	Until the user's next move, if an opposing Pokemon's attack knocks the user out, that Pokemon faints as well, unless the attack was Doom Desire or Future Sight. Fails if the user used this move successfully as its last move, disregarding moves used through the Dancer Ability.	0	1	5	14	Status	1	10
163	Detect	The user is protected from most attacks made by other Pokemon during this turn. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	5	7	Status	1	10
164	Devastating Drake	Power is equal to the base move's Z-Power.	1	1	1	15	Physical	1	10
165	Diamond Storm	Has a 50% chance to raise the user's Defense by 2 stages.	100	95	5	13	Physical	1	10
166	Dig	This attack charges on the first turn and executes on the second. On the first turn, the user avoids all attacks other than Earthquake and Magnitude but takes double damage from them, and is also unaffected by weather. If the user is holding a Power Herb, the move completes in one turn.	80	100	10	9	Physical	1	10
167	Disable	For 4 turns, the target's last move used becomes disabled. Fails if one of the target's moves is already disabled, if the target has not made a move, if the target no longer knows the move, or if the move was a Max or G-Max Move.	0	100	20	1	Status	1	10
168	Disarming Voice	This move does not check accuracy.	40	1	15	18	Special	1	10
169	Discharge	Has a 30% chance to paralyze the target.	80	100	15	4	Special	1	10
170	Dire Claw	Has a 50% chance to cause the target to either fall asleep, become poisoned, or become paralyzed.	80	100	15	8	Physical	1	10
171	Dive	This attack charges on the first turn and executes on the second. On the first turn, the user avoids all attacks other than Surf and Whirlpool but takes double damage from them, and is also unaffected by weather. If the user is holding a Power Herb, the move completes in one turn.	80	100	10	3	Physical	1	10
172	Dizzy Punch	Has a 20% chance to confuse the target.	70	100	10	1	Physical	1	10
173	Doodle	The user and its ally's Abilities change to match the target's Ability. Does not change Ability if the user's or its ally's is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode, Zero to Hero, or already matches the target. Fails if both the user and its ally's Ability already matches the target, or if the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Flower Gift, Forecast, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Imposter, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Power of Alchemy, Protosynthesis, Quark Drive, Receiver, RKS System, Schooling, Shields Down, Stance Change, Trace, Wonder Guard, Zen Mode, or Zero to Hero.	0	100	10	1	Status	1	10
174	Doom Desire	Deals damage two turns after this move is used. At the end of that turn, the damage is calculated at that time and dealt to the Pokemon at the position the target had when the move was used. If the user is no longer active at the time, damage is calculated based on the user's natural Special Attack stat, types, and level, with no boosts from its held item or Ability. Fails if this move or Future Sight is already in effect for the target's position.	140	100	5	16	Special	1	10
177	Double Iron Bash	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit. Has a 30% chance to make the target flinch.	60	100	5	16	Physical	1	10
178	Double Kick	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	30	100	30	7	Physical	1	10
179	Double Shock	Fails unless the user is an Electric type. If this move is successful and the user is not Terastallized, the user's Electric type becomes typeless as long as it remains active.	120	100	5	4	Physical	1	10
180	Double Slap	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	15	85	10	1	Physical	1	10
181	Double Team	Raises the user's evasiveness by 1 stage.	0	1	15	1	Status	1	10
182	Draco Meteor	Lowers the user's Special Attack by 2 stages.	130	90	5	15	Special	1	10
183	Dragon Ascent	Lowers the user's Defense and Special Defense by 1 stage.	120	100	5	10	Physical	1	10
184	Dragon Breath	Has a 30% chance to paralyze the target.	60	100	20	15	Special	1	10
185	Dragon Claw	No additional effect.	80	100	15	15	Physical	1	10
186	Dragon Dance	Raises the user's Attack and Speed by 1 stage.	0	1	20	15	Status	1	10
187	Dragon Darts	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit. In Double Battles, this move attempts to hit the targeted Pokemon and its ally once each. If hitting one of these Pokemon would be prevented by immunity, protection, semi-invulnerability, an Ability, or accuracy, it attempts to hit the other Pokemon twice instead. If this move is redirected, it hits that target twice.	50	100	10	15	Physical	1	10
188	Dragon Energy	Power is equal to (user's current HP * 150 / user's maximum HP), rounded down, but not less than 1.	150	100	5	15	Special	1	10
189	Dragon Hammer	No additional effect.	90	100	15	15	Physical	1	10
190	Dragon Pulse	No additional effect.	85	100	10	15	Special	1	10
191	Dragon Rage	Deals 40 HP of damage to the target.	0	100	10	15	Special	1	10
192	Dragon Rush	Has a 20% chance to make the target flinch. Damage doubles and no accuracy check is done if the target has used Minimize while active.	100	75	10	15	Physical	1	10
193	Dragon Tail	If both the user and the target have not fainted, the target is forced to switch out and be replaced with a random unfainted ally. This effect fails if the target used Ingrain previously, has the Suction Cups Ability, or this move hit a substitute.	60	90	10	15	Physical	1	10
194	Draining Kiss	The user recovers 3/4 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	50	100	10	18	Special	1	10
195	Drain Punch	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	75	100	10	7	Physical	1	10
196	Dream Eater	The target is unaffected by this move unless it is asleep. The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	100	100	15	11	Special	1	10
197	Drill Peck	No additional effect.	80	100	20	10	Physical	1	10
198	Drill Run	Has a higher chance for a critical hit.	80	95	10	9	Physical	1	10
199	Drum Beating	Has a 100% chance to lower the target's Speed by 1 stage.	80	100	10	5	Physical	1	10
200	Dual Chop	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	40	90	15	15	Physical	1	10
201	Dual Wingbeat	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	40	90	10	10	Physical	1	10
202	Dynamax Cannon	No additional effect.	100	100	5	15	Special	1	10
203	Dynamic Punch	Has a 100% chance to confuse the target.	100	50	5	7	Physical	1	10
204	Earth Power	Has a 10% chance to lower the target's Special Defense by 1 stage.	90	100	10	9	Special	1	10
205	Earthquake	Damage doubles if the target is using Dig.	100	100	10	9	Physical	1	10
206	Echoed Voice	For every consecutive turn that this move is used by at least one Pokemon, this move's power is multiplied by the number of turns to pass, but not more than 5.	40	100	15	1	Special	1	10
207	Eerie Impulse	Lowers the target's Special Attack by 2 stages.	0	100	15	4	Status	1	10
208	Eerie Spell	If this move is successful and the user has not fainted, the target loses 3 PP from its last move.	80	100	5	11	Special	1	10
209	Egg Bomb	No additional effect.	100	75	10	1	Physical	1	10
210	Electric Terrain	For 5 turns, the terrain becomes Electric Terrain. During the effect, the power of Electric-type attacks made by grounded Pokemon is multiplied by 1.3 and grounded Pokemon cannot fall asleep; Pokemon already asleep do not wake up. Grounded Pokemon cannot become affected by Yawn or fall asleep from its effect. Camouflage transforms the user into an Electric type, Nature Power becomes Thunderbolt, and Secret Power has a 30% chance to cause paralysis. Fails if the current terrain is Electric Terrain.	0	1	10	4	Status	1	10
211	Electrify	Causes the target's move to become Electric type this turn. Among effects that can change a move's type, this effect happens last. Fails if the target already moved this turn.	0	1	20	4	Status	1	10
212	Electro Ball	The power of this move depends on (user's current Speed / target's current Speed), rounded down. Power is equal to 150 if the result is 4 or more, 120 if 3, 80 if 2, 60 if 1, 40 if less than 1. If the target's current Speed is 0, this move's power is 40.	0	100	10	4	Special	1	10
213	Electro Drift	Damage is multiplied by 1.3333 if this move is super effective against the target.	100	100	5	4	Special	1	10
214	Electroweb	Has a 100% chance to lower the target's Speed by 1 stage.	55	95	15	4	Special	1	10
215	Embargo	For 5 turns, the target's held item has no effect. An item's effect of causing forme changes is unaffected, but any other effects from such items are negated. During the effect, Fling and Natural Gift are prevented from being used by the target. Items thrown at the target with Fling will still activate for it. If the target uses Baton Pass, the replacement will remain unable to use items.	0	100	15	17	Status	1	10
216	Ember	Has a 10% chance to burn the target.	40	100	25	2	Special	1	10
217	Encore	For its next 3 turns, the target is forced to repeat its last move used. If the affected move runs out of PP, the effect ends. Fails if the target is already under this effect, if it has not made a move, if the move has 0 PP, or if the move is Assist, Blazing Torque, Combat Torque, Copycat, Dynamax Cannon, Encore, Magical Torque, Me First, Metronome, Mimic, Mirror Move, Nature Power, Noxious Torque, Sketch, Sleep Talk, Struggle, Transform, or Wicked Torque.	0	100	5	1	Status	1	10
218	Endeavor	Deals damage to the target equal to (target's current HP - user's current HP). The target is unaffected if its current HP is less than or equal to the user's current HP.	0	100	5	1	Physical	1	10
219	Endure	The user will survive attacks made by other Pokemon during this turn with at least 1 HP. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	1	Status	1	10
220	Energy Ball	Has a 10% chance to lower the target's Special Defense by 1 stage.	90	100	10	5	Special	1	10
221	Entrainment	Causes the target's Ability to become the same as the user's. Fails if the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Truant, Zen Mode, Zero to Hero, or the same Ability as the user, or if the user's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Flower Gift, Forecast, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Imposter, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Power of Alchemy, Protosynthesis, Quark Drive, Receiver, RKS System, Schooling, Shields Down, Stance Change, Trace, Zen Mode, or Zero to Hero.	0	100	15	1	Status	1	10
222	Eruption	Power is equal to (user's current HP * 150 / user's maximum HP), rounded down, but not less than 1.	150	100	5	2	Special	1	10
223	Esper Wing	Has a 100% chance to raise the user's Speed by 1 stage and a higher chance for a critical hit.	80	100	10	11	Special	1	10
224	Eternabeam	If this move is successful, the user must recharge on the following turn and cannot select a move.	160	90	5	15	Special	1	10
225	Expanding Force	If the current terrain is Psychic Terrain and the user is grounded, this move hits all opposing Pokemon and has its power multiplied by 1.5.	80	100	10	11	Special	1	10
226	Explosion	The user faints after using this move, even if this move fails for having no target. This move is prevented from executing if any active Pokemon has the Damp Ability.	250	100	5	1	Physical	1	10
227	Extrasensory	Has a 10% chance to make the target flinch.	80	100	20	11	Special	1	10
228	Extreme Evoboost	Raises the user's Attack, Defense, Special Attack, Special Defense, and Speed by 2 stages.	0	1	1	1	Status	1	10
229	Extreme Speed	No additional effect.	80	100	5	1	Physical	1	10
230	Facade	Power doubles if the user is burned, paralyzed, or poisoned. The physical damage halving effect from the user's burn is ignored.	70	100	20	1	Physical	1	10
231	Fairy Lock	Prevents all active Pokemon from switching next turn. A Pokemon can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. Fails if the effect is already active.	0	1	10	18	Status	1	10
232	Fairy Wind	No additional effect.	40	100	30	18	Special	1	10
233	Fake Out	Has a 100% chance to make the target flinch. Fails unless it is the user's first turn on the field.	40	100	10	1	Physical	1	10
234	Fake Tears	Lowers the target's Special Defense by 2 stages.	0	100	20	17	Status	1	10
235	False Surrender	This move does not check accuracy.	80	1	10	17	Physical	1	10
236	False Swipe	Leaves the target with at least 1 HP.	40	100	40	1	Physical	1	10
237	Feather Dance	Lowers the target's Attack by 2 stages.	0	100	15	10	Status	1	10
238	Feint	If this move is successful, it breaks through the target's Baneful Bunker, Detect, King's Shield, Protect, or Spiky Shield for this turn, allowing other Pokemon to attack the target normally. If the target's side is protected by Crafty Shield, Mat Block, Quick Guard, or Wide Guard, that protection is also broken for this turn and other Pokemon may attack the target's side normally.	30	100	10	1	Physical	1	10
239	Feint Attack	This move does not check accuracy.	60	1	20	17	Physical	1	10
240	Fell Stinger	Raises the user's Attack by 3 stages if this move knocks out the target.	50	100	25	12	Physical	1	10
241	Fiery Dance	Has a 50% chance to raise the user's Special Attack by 1 stage.	80	100	10	2	Special	1	10
242	Fiery Wrath	Has a 20% chance to make the target flinch.	90	100	10	17	Special	1	10
243	Fillet Away	Raises the user's Attack, Special Attack, and Speed by 2 stages in exchange for the user losing 1/2 of its maximum HP, rounded down. Fails if the user would faint or if its Attack, Special Attack, and Speed stat stages would not change.	0	1	10	1	Status	1	10
244	Final Gambit	Deals damage to the target equal to the user's current HP. If this move is successful, the user faints.	0	100	5	7	Special	1	10
245	Fire Blast	Has a 10% chance to burn the target.	110	85	5	2	Special	1	10
246	Fire Fang	Has a 10% chance to burn the target and a 10% chance to make it flinch.	65	95	15	2	Physical	1	10
247	Fire Lash	Has a 100% chance to lower the target's Defense by 1 stage.	80	100	15	2	Physical	1	10
248	Fire Pledge	If one of the user's allies chose to use Grass Pledge or Water Pledge this turn and has not moved yet, it takes its turn immediately after the user and the user's move does nothing. If combined with Grass Pledge, the ally uses Fire Pledge with 150 power and a sea of fire appears on the target's side for 4 turns, which causes damage to non-Fire types equal to 1/8 of their maximum HP, rounded down, at the end of each turn during effect, including the last turn. If combined with Water Pledge, the ally uses Water Pledge with 150 power and a rainbow appears on the user's side for 4 turns, which doubles secondary effect chances and stacks with the Serene Grace Ability, except effects that cause flinching can only have their chance doubled once. When used as a combined move, this move gains STAB no matter what the user's type is. This move does not consume the user's Fire Gem.	80	100	10	2	Special	1	10
249	Fire Punch	Has a 10% chance to burn the target.	75	100	15	2	Physical	1	10
250	Fire Spin	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	35	85	15	2	Special	1	10
251	First Impression	Fails unless it is the user's first turn on the field.	90	100	10	12	Physical	1	10
252	Fishious Rend	Power doubles if the user moves before the target.	85	100	10	3	Physical	1	10
253	Fissure	Deals damage to the target equal to the target's maximum HP. Ignores accuracy and evasiveness modifiers. This attack's accuracy is equal to (user's level - target's level + 30)%, and fails if the target is at a higher level. Pokemon with the Sturdy Ability are immune.	0	30	5	9	Physical	1	10
254	Flail	The power of this move is 20 if X is 33 to 48, 40 if X is 17 to 32, 80 if X is 10 to 16, 100 if X is 5 to 9, 150 if X is 2 to 4, and 200 if X is 0 or 1, where X is equal to (user's current HP * 48 / user's maximum HP), rounded down.	0	100	15	1	Physical	1	10
255	Flame Burst	If this move is successful, the target's ally loses 1/16 of its maximum HP, rounded down, unless it has the Magic Guard Ability.	70	100	15	2	Special	1	10
256	Flame Charge	Has a 100% chance to raise the user's Speed by 1 stage.	50	100	20	2	Physical	1	10
257	Flame Wheel	Has a 10% chance to burn the target.	60	100	25	2	Physical	1	10
258	Flamethrower	Has a 10% chance to burn the target.	90	100	15	2	Special	1	10
259	Flare Blitz	Has a 10% chance to burn the target. If the target lost HP, the user takes recoil damage equal to 33% the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	15	2	Physical	1	10
260	Flash	Lowers the target's accuracy by 1 stage.	0	100	20	1	Status	1	10
261	Flash Cannon	Has a 10% chance to lower the target's Special Defense by 1 stage.	80	100	10	16	Special	1	10
262	Flatter	Raises the target's Special Attack by 1 stage and confuses it.	0	100	15	17	Status	1	10
263	Fleur Cannon	Lowers the user's Special Attack by 2 stages.	130	90	5	18	Special	1	10
264	Fling	The power of this move is based on the user's held item. The held item is lost and it activates for the target if applicable. If there is no target or the target avoids this move by protecting itself, the user's held item is still lost. The user can regain a thrown item with Recycle or the Harvest Ability. Fails if the user has no held item, if the held item cannot be thrown, if the user is under the effect of Embargo or Magic Room, or if the user has the Klutz Ability.	0	100	10	17	Physical	1	10
265	Flip Turn	If this move is successful and the user has not fainted, the user switches out even if it is trapped and is replaced immediately by a selected party member. The user does not switch out if there are no unfainted party members, or if the target switched out using an Eject Button or through the effect of the Emergency Exit or Wimp Out Abilities.	60	100	20	3	Physical	1	10
266	Floaty Fall	Has a 30% chance to make the target flinch.	90	95	15	10	Physical	1	10
267	Floral Healing	The target restores 1/2 of its maximum HP, rounded half up. If the terrain is Grassy Terrain, the target instead restores 2/3 of its maximum HP, rounded half down.	0	1	10	18	Status	1	10
268	Flower Shield	Raises the Defense of all active Grass-type Pokemon by 1 stage. Fails if there are no active Grass-type Pokemon.	0	1	10	18	Status	1	10
269	Flower Trick	This move is always a critical hit unless the target is under the effect of Lucky Chant or has the Battle Armor or Shell Armor Abilities. This move does not check accuracy.	70	1	10	5	Physical	1	10
270	Fly	This attack charges on the first turn and executes on the second. On the first turn, the user avoids all attacks other than Gust, Hurricane, Sky Uppercut, Smack Down, Thousand Arrows, Thunder, and Twister, and Gust and Twister have doubled power when used against it. If the user is holding a Power Herb, the move completes in one turn.	90	95	15	10	Physical	1	10
271	Flying Press	This move combines Flying in its type effectiveness against the target. Damage doubles and no accuracy check is done if the target has used Minimize while active.	100	95	10	7	Physical	1	10
272	Focus Blast	Has a 10% chance to lower the target's Special Defense by 1 stage.	120	70	5	7	Special	1	10
273	Focus Energy	Raises the user's chance for a critical hit by 2 stages. Fails if the user already has the effect. Baton Pass can be used to transfer this effect to an ally.	0	1	30	1	Status	1	10
274	Focus Punch	The user loses its focus and does nothing if it is hit by a damaging attack this turn before it can execute the move.	150	100	20	7	Physical	1	10
275	Follow Me	Until the end of the turn, all single-target attacks from the opposing side are redirected to the user. Such attacks are redirected to the user before they can be reflected by Magic Coat or the Magic Bounce Ability, or drawn in by the Lightning Rod or Storm Drain Abilities. Fails if it is not a Double Battle or Battle Royal. This effect is ignored while the user is under the effect of Sky Drop.	0	1	20	1	Status	1	10
276	Force Palm	Has a 30% chance to paralyze the target.	60	100	10	7	Physical	1	10
277	Foresight	As long as the target remains active, its evasiveness stat stage is ignored during accuracy checks against it if it is greater than 0, and Normal- and Fighting-type attacks can hit the target if it is a Ghost type. Fails if the target is already affected, or affected by Miracle Eye or Odor Sleuth.	0	1	40	1	Status	1	10
278	Forest's Curse	Causes the Grass type to be added to the target, effectively making it have two or three types. Fails if the target is already a Grass type. If Trick-or-Treat adds a type to the target, it replaces the type added by this move and vice versa.	0	100	20	5	Status	1	10
279	Foul Play	Damage is calculated using the target's Attack stat, including stat stage changes. The user's Ability, item, and burn are used as normal.	95	100	15	17	Physical	1	10
280	Freeze-Dry	Has a 10% chance to freeze the target. This move's type effectiveness against Water is changed to be super effective no matter what this move's type is.	70	100	20	6	Special	1	10
281	Freeze Shock	Has a 30% chance to paralyze the target. This attack charges on the first turn and executes on the second. If the user is holding a Power Herb, the move completes in one turn.	140	90	5	6	Physical	1	10
282	Freezing Glare	Has a 10% chance to freeze the target.	90	100	10	11	Special	1	10
283	Freezy Frost	Resets the stat stages of all active Pokemon to 0.	100	90	10	6	Special	1	10
284	Frenzy Plant	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	5	Special	1	10
285	Frost Breath	This move is always a critical hit unless the target is under the effect of Lucky Chant or has the Battle Armor or Shell Armor Abilities.	60	90	10	6	Special	1	10
286	Frustration	Power is equal to the greater of ((255 - user's Happiness) * 2/5), rounded down, or 1.	0	100	20	1	Physical	1	10
287	Fury Attack	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	15	85	20	1	Physical	1	10
288	Fury Cutter	Power doubles with each successful hit, up to a maximum of 160 power. The power is reset if this move misses or another move is used.	40	95	20	12	Physical	1	10
289	Fury Swipes	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	18	80	15	1	Physical	1	10
290	Fusion Bolt	Power doubles if the last move used by any Pokemon this turn was Fusion Flare.	100	100	5	4	Physical	1	10
291	Fusion Flare	Power doubles if the last move used by any Pokemon this turn was Fusion Bolt.	100	100	5	2	Special	1	10
292	Future Sight	Deals damage two turns after this move is used. At the end of that turn, the damage is calculated at that time and dealt to the Pokemon at the position the target had when the move was used. If the user is no longer active at the time, damage is calculated based on the user's natural Special Attack stat, types, and level, with no boosts from its held item or Ability. Fails if this move or Doom Desire is already in effect for the target's position.	120	100	10	11	Special	1	10
293	Gastro Acid	Causes the target's Ability to be rendered ineffective as long as it remains active. If the target uses Baton Pass, the replacement will remain under this effect. If the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode, or Zero to Hero, this move fails, and receiving the effect through Baton Pass ends the effect immediately.	0	100	10	8	Status	1	10
294	Gear Grind	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	50	85	15	16	Physical	1	10
295	Gear Up	Raises the Attack and Special Attack of Pokemon on the user's side with the Plus or Minus Abilities by 1 stage.	0	1	20	16	Status	1	10
296	Genesis Supernova	If this move is successful, the terrain becomes Psychic Terrain.	185	1	1	11	Special	1	10
297	Geomancy	Raises the user's Special Attack, Special Defense, and Speed by 2 stages. This attack charges on the first turn and executes on the second. If the user is holding a Power Herb, the move completes in one turn.	0	1	10	18	Status	1	10
298	Giga Drain	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	75	100	10	5	Special	1	10
299	Giga Impact	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	1	Physical	1	10
300	Gigaton Hammer	Cannot be used twice in a row.	160	100	5	16	Physical	1	10
301	Gigavolt Havoc	Power is equal to the base move's Z-Power.	1	1	1	4	Physical	1	10
302	Glacial Lance	No additional effect.	120	100	5	6	Physical	1	10
303	Glaciate	Has a 100% chance to lower the target's Speed by 1 stage.	65	95	10	6	Special	1	10
304	Glaive Rush	If this move is successful, moves targeted at the user deal double damage and do not check accuracy until the user's next turn.	120	100	5	15	Physical	1	10
305	Glare	Paralyzes the target.	0	100	30	1	Status	1	10
306	Glitzy Glow	This move summons Light Screen for 5 turns upon use.	80	95	15	11	Special	1	10
307	G-Max Befuddle	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side either falls asleep, becomes poisoned, or becomes paralyzed, even if they have a substitute.	10	1	5	12	Physical	1	10
308	G-Max Cannonade	Power is equal to the base move's Max Move power. If this move is successful, for 4 turns each non-Water-type Pokemon on the opposing side takes damage equal to 1/6 of its maximum HP, rounded down, at the end of each turn during effect, including the last turn.	10	1	10	3	Physical	1	10
309	G-Max Centiferno	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side is prevented from switching for four or five turns (seven turns if the user is holding Grip Claw), even if they have a substitute. Causes damage equal to 1/8 of their maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. They can still switch out if they are holding Shed Shell or use Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. The effect ends for a target if it leaves the field, or if it uses Rapid Spin or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	10	1	5	2	Physical	1	10
310	G-Max Chi Strike	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the user's side has their critical hit ratio raised by 1 stage, even if they have a substitute.	10	1	5	7	Physical	1	10
311	G-Max Cuddle	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side becomes infatuated, even if they have a substitute. This effect does not happen for a target if both it and the user are the same gender, if either is genderless, or if the target is already infatuated.	10	1	5	1	Physical	1	10
312	G-Max Depletion	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side loses 2 PP from its last move used, even if they have a substitute.	10	1	5	15	Physical	1	10
313	G-Max Drum Solo	Power is 160 regardless of the base move's Max Move power. This move and its effects ignore the Abilities of other Pokemon.	160	1	5	5	Physical	1	10
314	G-Max Finale	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the user's side restores 1/6 of its current maximum HP, even if they have a substitute.	10	1	5	18	Physical	1	10
315	G-Max Fireball	Power is 160 regardless of the base move's Max Move power. This move and its effects ignore the Abilities of other Pokemon.	160	1	5	2	Physical	1	10
316	G-Max Foam Burst	Power is equal to the base move's Max Move power. If this move is successful, the Speed of each Pokemon on the opposing side is lowered by 2 stages, even if they have a substitute.	10	1	5	3	Physical	1	10
317	G-Max Gold Rush	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side becomes confused, even if they have a substitute.	10	1	5	1	Physical	1	10
318	G-Max Gravitas	Power is equal to the base move's Max Move power. If this move is successful, the effect of Gravity begins.	10	1	5	11	Physical	1	10
319	G-Max Hydrosnipe	Power is 160 regardless of the base move's Max Move power. This move and its effects ignore the Abilities of other Pokemon.	160	1	5	3	Physical	1	10
320	G-Max Malodor	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side becomes poisoned, even if they have a substitute.	10	1	5	8	Physical	1	10
321	G-Max Meltdown	Power is equal to the base move's Max Move power. If this move is successful, the effect of Torment begins for each Pokemon on the opposing side, even if they have a substitute.	10	1	5	16	Physical	1	10
322	G-Max One Blow	Power is equal to the base move's Max Move power. This move bypasses all protection effects, including Max Guard.	10	1	5	17	Physical	1	10
323	G-Max Rapid Flow	Power is equal to the base move's Max Move power. This move bypasses all protection effects, including Max Guard.	10	1	5	3	Physical	1	10
324	G-Max Replenish	Power is equal to the base move's Max Move power. If this move is successful, there is a 50% chance every Pokemon on the user's side has its Berry restored, even if they have a substitute.	10	1	5	1	Physical	1	10
325	G-Max Resonance	Power is equal to the base move's Max Move power. If this move is successful, the effect of Aurora Veil begins on the user's side.	10	1	5	6	Physical	1	10
326	G-Max Sandblast	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side is prevented from switching for four or five turns (seven turns if the user is holding Grip Claw), even if they have a substitute. Causes damage equal to 1/8 of their maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. They can still switch out if they are holding Shed Shell or use Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. The effect ends for a target if it leaves the field, or if it uses Rapid Spin or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	10	1	5	9	Physical	1	10
327	G-Max Smite	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side becomes confused, even if they have a substitute.	10	1	5	18	Physical	1	10
328	G-Max Snooze	Power is equal to the base move's Max Move power. If this move is successful, there is a 50% chance the effect of Yawn begins on the target, even if it has a substitute.	10	1	5	17	Physical	1	10
329	G-Max Steelsurge	Power is equal to the base move's Max Move power. If this move is successful, it sets up a hazard on the opposing side of the field, damaging each opposing Pokemon that switches in. Foes lose 1/32, 1/16, 1/8, 1/4, or 1/2 of their maximum HP, rounded down, based on their weakness to the Steel type; 0.25x, 0.5x, neutral, 2x, or 4x, respectively. Can be removed from the opposing side if any opposing Pokemon uses Rapid Spin or Defog successfully, or is hit by Defog.	10	1	5	16	Physical	1	10
330	G-Max Stonesurge	Power is equal to the base move's Max Move power. If this move is successful, it sets up a hazard on the opposing side of the field, damaging each opposing Pokemon that switches in. Foes lose 1/32, 1/16, 1/8, 1/4, or 1/2 of their maximum HP, rounded down, based on their weakness to the Rock type; 0.25x, 0.5x, neutral, 2x, or 4x, respectively. Can be removed from the opposing side if any opposing Pokemon uses Rapid Spin or Defog successfully, or is hit by Defog.	10	1	5	3	Physical	1	10
331	G-Max Stun Shock	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side either becomes poisoned or paralyzed, even if they have a substitute.	10	1	10	4	Physical	1	10
332	G-Max Sweetness	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the user's side has its status condition cured, even if they have a substitute.	10	1	10	5	Physical	1	10
333	G-Max Tartness	Power is equal to the base move's Max Move power. If this move is successful, the evasiveness of each Pokemon on the opposing side is lowered by 1 stage, even if they have a substitute.	10	1	10	5	Physical	1	10
334	G-Max Terror	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side is prevented from switching out, even if they have a substitute. They can still switch out if they are holding Shed Shell or use Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If a target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	10	1	10	14	Physical	1	10
335	G-Max Vine Lash	Power is equal to the base move's Max Move power. If this move is successful, for 4 turns each non-Grass-type Pokemon on the opposing side takes damage equal to 1/6 of its maximum HP, rounded down, at the end of each turn during effect, including the last turn.	10	1	10	5	Physical	1	10
336	G-Max Volcalith	Power is equal to the base move's Max Move power. If this move is successful, for 4 turns each non-Rock-type Pokemon on the opposing side takes damage equal to 1/6 of its maximum HP, rounded down, at the end of each turn during effect, including the last turn.	10	1	10	13	Physical	1	10
337	G-Max Volt Crash	Power is equal to the base move's Max Move power. If this move is successful, each Pokemon on the opposing side becomes paralyzed, even if they have a substitute.	10	1	10	4	Physical	1	10
338	G-Max Wildfire	Power is equal to the base move's Max Move power. If this move is successful, for 4 turns each non-Fire-type Pokemon on the opposing side takes damage equal to 1/6 of its maximum HP, rounded down, at the end of each turn during effect, including the last turn.	10	1	10	2	Physical	1	10
339	G-Max Wind Rage	Power is equal to the base move's Max Move power. If this move is successful, the effects of Electric Terrain, Grassy Terrain, Misty Terrain, and Psychic Terrain end, the effects of Reflect, Light Screen, Aurora Veil, Safeguard, Mist, G-Max Steelsurge, Spikes, Toxic Spikes, Stealth Rock, and Sticky Web end for the target's side, and the effects of G-Max Steelsurge, Spikes, Toxic Spikes, Stealth Rock, and Sticky Web end for the user's side.	10	1	10	10	Physical	1	10
340	Grass Knot	This move's power is 20 if the target weighs less than 10 kg, 40 if less than 25 kg, 60 if less than 50 kg, 80 if less than 100 kg, 100 if less than 200 kg, and 120 if greater than or equal to 200 kg.	0	100	20	5	Special	1	10
341	Grass Pledge	If one of the user's allies chose to use Fire Pledge or Water Pledge this turn and has not moved yet, it takes its turn immediately after the user and the user's move does nothing. If combined with Fire Pledge, the ally uses Fire Pledge with 150 power and a sea of fire appears on the target's side for 4 turns, which causes damage to non-Fire types equal to 1/8 of their maximum HP, rounded down, at the end of each turn during effect, including the last turn. If combined with Water Pledge, the ally uses Grass Pledge with 150 power and a swamp appears on the target's side for 4 turns, which quarters the Speed of each Pokemon on that side. When used as a combined move, this move gains STAB no matter what the user's type is. This move does not consume the user's Grass Gem.	80	100	10	5	Special	1	10
342	Grass Whistle	Causes the target to fall asleep.	0	55	15	5	Status	1	10
343	Grassy Glide	If the current terrain is Grassy Terrain and the user is grounded, this move has its priority increased by 1.	55	100	20	5	Physical	1	10
378	Hidden Power	This move's type depends on the user's individual values (IVs), and can be any type but Fairy and Normal.	60	100	15	1	Special	1	10
379	High Horsepower	No additional effect.	95	95	10	9	Physical	1	10
510	Meteor Assault	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	100	5	7	Physical	1	10
344	Grassy Terrain	For 5 turns, the terrain becomes Grassy Terrain. During the effect, the power of Grass-type attacks used by grounded Pokemon is multiplied by 1.3, the power of Bulldoze, Earthquake, and Magnitude used against grounded Pokemon is multiplied by 0.5, and grounded Pokemon have 1/16 of their maximum HP, rounded down, restored at the end of each turn, including the last turn. Camouflage transforms the user into a Grass type, Nature Power becomes Energy Ball, and Secret Power has a 30% chance to cause sleep. Fails if the current terrain is Grassy Terrain.	0	1	10	5	Status	1	10
345	Grav Apple	Has a 100% chance to lower the target's Defense by 1 stage. Power is multiplied by 1.5 during Gravity's effect.	80	100	10	5	Physical	1	10
346	Gravity	For 5 turns, the evasiveness of all active Pokemon is multiplied by 0.6. At the time of use, Bounce, Fly, Magnet Rise, Sky Drop, and Telekinesis end immediately for all active Pokemon. During the effect, Bounce, Fly, Flying Press, High Jump Kick, Jump Kick, Magnet Rise, Sky Drop, Splash, and Telekinesis are prevented from being used by all active Pokemon. Ground-type attacks, Spikes, Toxic Spikes, Sticky Web, and the Arena Trap Ability can affect Flying types or Pokemon with the Levitate Ability. Fails if this move is already in effect.	0	1	5	11	Status	1	10
347	Growl	Lowers the target's Attack by 1 stage.	0	100	40	1	Status	1	10
348	Growth	Raises the user's Attack and Special Attack by 1 stage. If the weather is Sunny Day or Desolate Land, this move raises the user's Attack and Special Attack by 2 stages. If the user is holding Utility Umbrella, this move will only raise the user's Attack and Special Attack by 1 stage, even if the weather is Sunny Day or Desolate Land.	0	1	20	1	Status	1	10
349	Grudge	Until the user's next turn, if an opposing Pokemon's attack knocks the user out, that move loses all its remaining PP.	0	1	5	14	Status	1	10
350	Guardian of Alola	Deals damage to the target equal to 3/4 of its current HP, rounded down, but not less than 1 HP.	0	1	1	18	Special	1	10
351	Guard Split	The user and the target have their Defense and Special Defense stats set to be equal to the average of the user and the target's Defense and Special Defense stats, respectively, rounded down. Stat stage changes are unaffected.	0	1	10	11	Status	1	10
352	Guard Swap	The user swaps its Defense and Special Defense stat stage changes with the target.	0	1	10	11	Status	1	10
353	Guillotine	Deals damage to the target equal to the target's maximum HP. Ignores accuracy and evasiveness modifiers. This attack's accuracy is equal to (user's level - target's level + 30)%, and fails if the target is at a higher level. Pokemon with the Sturdy Ability are immune.	0	30	5	1	Physical	1	10
354	Gunk Shot	Has a 30% chance to poison the target.	120	80	5	8	Physical	1	10
355	Gust	Power doubles if the target is using Bounce, Fly, or Sky Drop, or is under the effect of Sky Drop.	40	100	35	10	Special	1	10
356	Gyro Ball	Power is equal to (25 * target's current Speed / user's current Speed) + 1, rounded down, but not more than 150. If the user's current Speed is 0, this move's power is 1.	0	100	5	16	Physical	1	10
357	Hail	For 5 turns, the weather becomes Hail. At the end of each turn except the last, all active Pokemon lose 1/16 of their maximum HP, rounded down, unless they are an Ice type or have the Ice Body, Magic Guard, Overcoat, or Snow Cloak Abilities. Lasts for 8 turns if the user is holding Icy Rock. Fails if the current weather is Hail.	0	1	10	6	Status	1	10
358	Hammer Arm	Lowers the user's Speed by 1 stage.	100	90	10	7	Physical	1	10
359	Happy Hour	No competitive use.	0	1	30	1	Status	1	10
360	Harden	Raises the user's Defense by 1 stage.	0	1	30	1	Status	1	10
361	Haze	Resets the stat stages of all active Pokemon to 0.	0	1	30	6	Status	1	10
362	Headbutt	Has a 30% chance to make the target flinch.	70	100	15	1	Physical	1	10
363	Head Charge	If the target lost HP, the user takes recoil damage equal to 1/4 the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	15	1	Physical	1	10
364	Headlong Rush	Lowers the user's Defense and Special Defense by 1 stage.	120	100	5	9	Physical	1	10
365	Head Smash	If the target lost HP, the user takes recoil damage equal to 1/2 the HP lost by the target, rounded half up, but not less than 1 HP.	150	80	5	13	Physical	1	10
366	Heal Bell	Every Pokemon in the user's party is cured of its non-volatile status condition. Active Pokemon with the Soundproof Ability are not cured, unless they are the user.	0	1	5	1	Status	1	10
367	Heal Block	For 5 turns, the target is prevented from restoring any HP as long as it remains active. During the effect, healing and draining moves are unusable, and Abilities and items that grant healing will not heal the user. If an affected Pokemon uses Baton Pass, the replacement will remain unable to restore its HP. Pain Split and the Regenerator Ability are unaffected.	0	100	15	11	Status	1	10
368	Healing Wish	The user faints, and if the Pokemon brought out to replace it does not have full HP or has a non-volatile status condition, its HP is fully restored along with having any non-volatile status condition cured. The replacement is sent out at the end of the turn, and the healing happens before hazards take effect. This effect continues until a Pokemon that meets either of these conditions switches in at the user's position or gets swapped into the position with Ally Switch. Fails if the user is the last unfainted Pokemon in its party.	0	1	10	11	Status	1	10
369	Heal Order	The user restores 1/2 of its maximum HP, rounded half up.	0	1	10	12	Status	1	10
370	Heal Pulse	The target restores 1/2 of its maximum HP, rounded half up. If the user has the Mega Launcher Ability, the target instead restores 3/4 of its maximum HP, rounded half down.	0	1	10	11	Status	1	10
371	Heart Stamp	Has a 30% chance to make the target flinch.	60	100	25	11	Physical	1	10
372	Heart Swap	The user swaps all its stat stage changes with the target.	0	1	10	11	Status	1	10
373	Heat Crash	The power of this move depends on (user's weight / target's weight), rounded down. Power is equal to 120 if the result is 5 or more, 100 if 4, 80 if 3, 60 if 2, and 40 if 1 or less. Damage doubles and no accuracy check is done if the target has used Minimize while active.	0	100	10	2	Physical	1	10
374	Heat Wave	Has a 10% chance to burn the target.	95	90	10	2	Special	1	10
375	Heavy Slam	The power of this move depends on (user's weight / target's weight), rounded down. Power is equal to 120 if the result is 5 or more, 100 if 4, 80 if 3, 60 if 2, and 40 if 1 or less. Damage doubles and no accuracy check is done if the target has used Minimize while active.	0	100	10	16	Physical	1	10
376	Helping Hand	The power of the target's attack this turn is multiplied by 1.5 (this effect is stackable). Fails if there is no ally adjacent to the user or if the ally already moved this turn, but does not fail if the ally is using a two-turn move.	0	1	20	1	Status	1	10
377	Hex	Power doubles if the target has a non-volatile status condition.	65	100	10	14	Special	1	10
380	High Jump Kick	If this attack is not successful, the user loses half of its maximum HP, rounded down, as crash damage. Pokemon with the Magic Guard Ability are unaffected by crash damage.	130	90	10	7	Physical	1	10
381	Hold Back	Leaves the target with at least 1 HP.	40	100	40	1	Physical	1	10
382	Hold Hands	No competitive use. Fails if there is no ally adjacent to the user.	0	1	40	1	Status	1	10
383	Hone Claws	Raises the user's Attack and accuracy by 1 stage.	0	1	15	17	Status	1	10
384	Horn Attack	No additional effect.	65	100	25	1	Physical	1	10
385	Horn Drill	Deals damage to the target equal to the target's maximum HP. Ignores accuracy and evasiveness modifiers. This attack's accuracy is equal to (user's level - target's level + 30)%, and fails if the target is at a higher level. Pokemon with the Sturdy Ability are immune.	0	30	5	1	Physical	1	10
386	Horn Leech	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	75	100	10	5	Physical	1	10
387	Howl	Raises the Attack of the user and all allies 1 stage.	0	1	40	1	Status	1	10
388	Hurricane	Has a 30% chance to confuse the target. This move can hit a target using Bounce, Fly, or Sky Drop, or is under the effect of Sky Drop. If the weather is Primordial Sea or Rain Dance, this move does not check accuracy. If the weather is Desolate Land or Sunny Day, this move's accuracy is 50%. If this move is used against a Pokemon holding Utility Umbrella, this move's accuracy remains at 70%.	110	70	10	10	Special	1	10
389	Hydro Cannon	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	3	Special	1	10
390	Hydro Pump	No additional effect.	110	80	5	3	Special	1	10
391	Hydro Steam	If the current weather is Sunny Day and the user is not holding Utility Umbrella, this move's damage is multiplied by 1.5 instead of halved for being Water type.	80	100	15	3	Special	1	10
392	Hydro Vortex	Power is equal to the base move's Z-Power.	1	1	1	3	Physical	1	10
393	Hyper Beam	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	1	Special	1	10
394	Hyper Drill	Bypasses protection without breaking it.	100	100	5	1	Physical	1	10
395	Hyper Fang	Has a 10% chance to make the target flinch.	80	90	15	1	Physical	1	10
396	Hyperspace Fury	Lowers the user's Defense by 1 stage. This move cannot be used successfully unless the user's current form, while considering Transform, is Hoopa Unbound. If this move is successful, it breaks through the target's Baneful Bunker, Detect, King's Shield, Protect, or Spiky Shield for this turn, allowing other Pokemon to attack the target normally. If the target's side is protected by Crafty Shield, Mat Block, Quick Guard, or Wide Guard, that protection is also broken for this turn and other Pokemon may attack the target's side normally.	100	1	5	17	Physical	1	10
397	Hyperspace Hole	If this move is successful, it breaks through the target's Baneful Bunker, Detect, King's Shield, Protect, or Spiky Shield for this turn, allowing other Pokemon to attack the target normally. If the target's side is protected by Crafty Shield, Mat Block, Quick Guard, or Wide Guard, that protection is also broken for this turn and other Pokemon may attack the target's side normally.	80	1	5	11	Special	1	10
398	Hyper Voice	No additional effect.	90	100	10	1	Special	1	10
399	Hypnosis	Causes the target to fall asleep.	0	60	20	11	Status	1	10
400	Ice Ball	If this move is successful, the user is locked into this move and cannot make another move until it misses, 5 turns have passed, or the attack cannot be used. Power doubles with each successful hit of this move and doubles again if Defense Curl was used previously by the user. If this move is called by Sleep Talk, the move is used for one turn.	30	90	20	6	Physical	1	10
401	Ice Beam	Has a 10% chance to freeze the target.	90	100	10	6	Special	1	10
402	Ice Burn	Has a 30% chance to burn the target. This attack charges on the first turn and executes on the second. If the user is holding a Power Herb, the move completes in one turn.	140	90	5	6	Special	1	10
403	Ice Fang	Has a 10% chance to freeze the target and a 10% chance to make it flinch.	65	95	15	6	Physical	1	10
404	Ice Hammer	Lowers the user's Speed by 1 stage.	100	90	10	6	Physical	1	10
405	Ice Punch	Has a 10% chance to freeze the target.	75	100	15	6	Physical	1	10
406	Ice Shard	No additional effect.	40	100	30	6	Physical	1	10
407	Ice Spinner	Ends the effects of Electric Terrain, Grassy Terrain, Misty Terrain, and Psychic Terrain.	80	100	15	6	Physical	1	10
408	Icicle Crash	Has a 30% chance to make the target flinch.	85	90	10	6	Physical	1	10
409	Icicle Spear	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	100	30	6	Physical	1	10
410	Icy Wind	Has a 100% chance to lower the target's Speed by 1 stage.	55	95	15	6	Special	1	10
411	Imprison	The user prevents all opposing Pokemon from using any moves that the user also knows as long as the user remains active.	0	1	10	11	Status	1	10
412	Incinerate	The target loses its held item if it is a Berry or a Gem. This move cannot cause Pokemon with the Sticky Hold Ability to lose their held item. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	60	100	15	2	Special	1	10
413	Infernal Parade	Has a 30% chance to burn the target. Power doubles if the target has a non-volatile status condition.	60	100	15	14	Special	1	10
414	Inferno	Has a 100% chance to burn the target.	100	50	5	2	Special	1	10
415	Inferno Overdrive	Power is equal to the base move's Z-Power.	1	1	1	2	Physical	1	10
416	Infestation	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	20	100	20	12	Special	1	10
452	Light That Burns the Sky	This move becomes a physical attack if the user's Attack is greater than its Special Attack, including stat stage changes. This move and its effects ignore the Abilities of other Pokemon.	200	1	1	11	Special	1	10
453	Liquidation	Has a 20% chance to lower the target's Defense by 1 stage.	85	100	10	3	Physical	1	10
417	Ingrain	The user has 1/16 of its maximum HP restored at the end of each turn, but it is prevented from switching out and other Pokemon cannot force the user to switch out. The user can still switch out if it uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the user leaves the field using Baton Pass, the replacement will remain trapped and still receive the healing effect. During the effect, the user can be hit normally by Ground-type attacks and be affected by Spikes, Toxic Spikes, and Sticky Web, even if the user is a Flying type or has the Levitate Ability.	0	1	20	5	Status	1	10
418	Instruct	The target immediately uses its last used move. Fails if the target has not made a move, if the move has 0 PP, if the target is preparing to use Beak Blast, Focus Punch, or Shell Trap, or if the move is Assist, Beak Blast, Belch, Bide, Blazing Torque, Celebrate, Chatter, Combat Torque, Copycat, Dynamax Cannon, Focus Punch, Hold Hands, Ice Ball, Instruct, King's Shield, Magical Torque, Me First, Metronome, Mimic, Mirror Move, Nature Power, Noxious Torque, Obstruct, Outrage, Petal Dance, Rollout, Shell Trap, Sketch, Sleep Talk, Struggle, Thrash, Transform, Uproar, Wicked Torque, any two-turn move, or any recharge move.	0	1	15	11	Status	1	10
419	Ion Deluge	Causes Normal-type moves to become Electric type this turn. The effect happens after other effects that change a move's type.	0	1	25	4	Status	1	10
420	Iron Defense	Raises the user's Defense by 2 stages.	0	1	15	16	Status	1	10
421	Iron Head	Has a 30% chance to make the target flinch.	80	100	15	16	Physical	1	10
422	Iron Tail	Has a 30% chance to lower the target's Defense by 1 stage.	100	75	15	16	Physical	1	10
423	Ivy Cudgel	Has a higher chance for a critical hit. If the user is an Ogerpon holding a mask, this move's type changes to match. Water type for Wellspring Mask, Fire type for Hearthflame Mask, and Rock type for Cornerstone Mask.	100	100	10	5	Physical	1	10
424	Jaw Lock	Prevents the user and the target from switching out. The user and the target can still switch out if either of them is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field.	80	100	10	17	Physical	1	10
425	Jet Punch	No additional effect.	60	100	15	3	Physical	1	10
426	Judgment	This move's type depends on the user's held Plate.	100	100	10	1	Special	1	10
427	Jump Kick	If this attack is not successful, the user loses half of its maximum HP, rounded down, as crash damage. Pokemon with the Magic Guard Ability are unaffected by crash damage.	100	95	10	7	Physical	1	10
428	Jungle Healing	Each Pokemon on the user's side restores 1/4 of its maximum HP, rounded half up, and has its status condition cured.	0	1	10	5	Status	1	10
429	Karate Chop	Has a higher chance for a critical hit.	50	100	25	7	Physical	1	10
430	Kinesis	Lowers the target's accuracy by 1 stage.	0	80	15	11	Status	1	10
431	King's Shield	The user is protected from most attacks made by other Pokemon during this turn, and Pokemon trying to make contact with the user have their Attack lowered by 1 stage. Non-damaging moves go through this protection. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	16	Status	1	10
432	Knock Off	If the target is holding an item that can be removed from it, ignoring the Sticky Hold Ability, this move's power is multiplied by 1.5. If the user has not fainted, the target loses its held item. This move cannot cause Pokemon with the Sticky Hold Ability to lose their held item or cause a Kyogre, a Groudon, a Giratina, an Arceus, a Genesect, a Silvally, a Zacian, or a Zamazenta to lose their Blue Orb, Red Orb, Griseous Orb, Plate, Drive, Memory, Rusted Sword, or Rusted Shield respectively. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	65	100	20	17	Physical	1	10
433	Kowtow Cleave	This move does not check accuracy.	85	1	10	17	Physical	1	10
434	Land's Wrath	No additional effect.	90	100	10	9	Physical	1	10
435	Laser Focus	Until the end of the next turn, the user's attacks will be critical hits.	0	1	30	1	Status	1	10
436	Lash Out	Power doubles if the user had a stat stage lowered this turn.	75	100	5	17	Physical	1	10
437	Last Resort	This move fails unless the user knows this move and at least one other move, and has used all the other moves it knows at least once each since it became active or Transformed.	140	100	5	1	Physical	1	10
438	Last Respects	Power is equal to 50+(X*50), where X is the total number of times any Pokemon has fainted on the user's side, and X cannot be greater than 100.	50	100	10	14	Physical	1	10
439	Lava Plume	Has a 30% chance to burn the target.	80	100	15	2	Special	1	10
440	Leafage	No additional effect.	40	100	40	5	Physical	1	10
441	Leaf Blade	Has a higher chance for a critical hit.	90	100	15	5	Physical	1	10
442	Leaf Storm	Lowers the user's Special Attack by 2 stages.	130	90	5	5	Special	1	10
443	Leaf Tornado	Has a 50% chance to lower the target's accuracy by 1 stage.	65	90	10	5	Special	1	10
444	Leech Life	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	80	100	10	12	Physical	1	10
445	Leech Seed	The Pokemon at the user's position steals 1/8 of the target's maximum HP, rounded down, at the end of each turn. If Big Root is held by the recipient, the HP recovered is 1.3x normal, rounded half down. If the target uses Baton Pass, the replacement will continue being leeched. If the target switches out or uses Mortal Spin or Rapid Spin successfully, the effect ends. Grass-type Pokemon are immune to this move on use, but not its effect.	0	90	10	5	Status	1	10
446	Leer	Lowers the target's Defense by 1 stage.	0	100	30	1	Status	1	10
447	Let's Snuggle Forever	No additional effect.	190	1	1	18	Physical	1	10
448	Lick	Has a 30% chance to paralyze the target.	30	100	30	14	Physical	1	10
449	Life Dew	Each Pokemon on the user's side restores 1/4 of its maximum HP, rounded half up.	0	1	10	3	Status	1	10
450	Light of Ruin	If the target lost HP, the user takes recoil damage equal to 1/2 the HP lost by the target, rounded half up, but not less than 1 HP.	140	90	5	18	Special	1	10
451	Light Screen	For 5 turns, the user and its party members take 0.5x damage from special attacks, or 0.66x damage if in a Double Battle. Damage is not reduced further with Aurora Veil. Critical hits ignore this effect. It is removed from the user's side if the user or an ally is successfully hit by Brick Break, Psychic Fangs, or Defog. Lasts for 8 turns if the user is holding Light Clay. Fails if the effect is already active on the user's side.	0	1	30	11	Status	1	10
454	Lock-On	Until the end of the next turn, the target cannot avoid the user's moves, even if the target is in the middle of a two-turn move. The effect ends if either the user or the target leaves the field. Fails if this effect is active for the user.	0	1	5	1	Status	1	10
455	Lovely Kiss	Causes the target to fall asleep.	0	75	10	1	Status	1	10
456	Low Kick	This move's power is 20 if the target weighs less than 10 kg, 40 if less than 25 kg, 60 if less than 50 kg, 80 if less than 100 kg, 100 if less than 200 kg, and 120 if greater than or equal to 200 kg.	0	100	20	7	Physical	1	10
457	Low Sweep	Has a 100% chance to lower the target's Speed by 1 stage.	65	100	20	7	Physical	1	10
458	Lucky Chant	For 5 turns, the user and its party members cannot be struck by a critical hit. Fails if the effect is already active on the user's side.	0	1	30	1	Status	1	10
459	Lumina Crash	Has a 100% chance to lower the target's Special Defense by 2 stages.	80	100	10	11	Special	1	10
460	Lunar Blessing	Each Pokemon on the user's side restores 1/4 of its maximum HP, rounded half up, and has its status condition cured.	0	1	5	11	Status	1	10
461	Lunar Dance	The user faints, and if the Pokemon brought out to replace it does not have full HP or PP, or has a non-volatile status condition, its HP and PP are fully restored along with having any non-volatile status condition cured. The replacement is sent out at the end of the turn, and the healing happens before hazards take effect. This effect continues until a Pokemon that meets any of these conditions switches in at the user's position or gets swapped into the position with Ally Switch. Fails if the user is the last unfainted Pokemon in its party.	0	1	10	11	Status	1	10
462	Lunge	Has a 100% chance to lower the target's Attack by 1 stage.	80	100	15	12	Physical	1	10
463	Luster Purge	Has a 50% chance to lower the target's Special Defense by 1 stage.	70	100	5	11	Special	1	10
464	Mach Punch	No additional effect.	40	100	30	7	Physical	1	10
465	Magical Leaf	This move does not check accuracy.	60	1	20	5	Special	1	10
466	Magical Torque	Has a 30% chance to confuse the target.	100	100	10	18	Physical	1	10
467	Magic Coat	Until the end of the turn, the user is unaffected by certain non-damaging moves directed at it and will instead use such moves against the original user. Moves reflected in this way are unable to be reflected again by this or the Magic Bounce Ability's effect. Spikes, Stealth Rock, Sticky Web, and Toxic Spikes can only be reflected once per side, by the leftmost Pokemon under this or the Magic Bounce Ability's effect. The Lightning Rod and Storm Drain Abilities redirect their respective moves before this move takes effect.	0	1	15	11	Status	1	10
468	Magic Powder	Causes the target to become a Psychic type. Fails if the target is an Arceus or a Silvally, if the target is already purely Psychic type, or if the target is Terastallized.	0	100	20	11	Status	1	10
469	Magic Room	For 5 turns, the held items of all active Pokemon have no effect. An item's effect of causing forme changes is unaffected, but any other effects from such items are negated. During the effect, Fling and Natural Gift are prevented from being used by all active Pokemon. If this move is used during the effect, the effect ends.	0	1	10	11	Status	1	10
470	Magma Storm	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	100	75	5	2	Special	1	10
471	Magnet Bomb	This move does not check accuracy.	60	1	20	16	Physical	1	10
472	Magnetic Flux	Raises the Defense and Special Defense of Pokemon on the user's side with the Plus or Minus Abilities by 1 stage.	0	1	20	4	Status	1	10
473	Magnet Rise	For 5 turns, the user is immune to Ground-type attacks and the effects of Spikes, Toxic Spikes, Sticky Web, and the Arena Trap Ability as long as it remains active. If the user uses Baton Pass, the replacement will gain the effect. Ingrain, Smack Down, Thousand Arrows, and Iron Ball override this move if the user is under any of their effects. Fails if the user is already under this effect or the effects of Ingrain, Smack Down, or Thousand Arrows.	0	1	10	4	Status	1	10
474	Magnitude	The power of this move varies; 5% chances for 10 and 150 power, 10% chances for 30 and 110 power, 20% chances for 50 and 90 power, and 30% chance for 70 power. Damage doubles if the target is using Dig.	0	100	30	9	Physical	1	10
475	Make It Rain	Lowers the user's Special Attack by 1 stage.	120	100	5	16	Special	1	10
476	Malicious Moonsault	Damage doubles and no accuracy check is done if the target has used Minimize while active.	180	1	1	17	Physical	1	10
477	Mat Block	The user and its party members are protected from damaging attacks made by other Pokemon, including allies, during this turn. Fails unless it is the user's first turn on the field, if the user moves last this turn, or if this move is already in effect for the user's side.	0	1	10	7	Status	1	10
478	Matcha Gotcha	Has a 20% chance to burn the target. The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down. The target thaws out if it is frozen.	80	90	15	5	Special	1	10
479	Max Airstream	Power is equal to the base move's Max Move power. If this move is successful, the Speed of each Pokemon on the user's side is raised by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	10	Physical	1	10
480	Max Darkness	Power is equal to the base move's Max Move power. If this move is successful, the Special Defense of each Pokemon on the opposing side is lowered by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	17	Physical	1	10
481	Max Flare	Power is equal to the base move's Max Move power. If this move is successful, the effect of Sunny Day begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	100	1	10	2	Physical	1	10
482	Max Flutterby	Power is equal to the base move's Max Move power. If this move is successful, the Special Attack of each Pokemon on the opposing side is lowered by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	12	Physical	1	10
509	Metal Sound	Lowers the target's Special Defense by 2 stages.	0	85	40	16	Status	1	10
483	Max Geyser	Power is equal to the base move's Max Move power. If this move is successful, the effect of Rain Dance begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	3	Physical	1	10
484	Max Guard	The user is protected from nearly all attacks made by other Pokemon during this turn, including Max and G-Max Moves. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	1	Status	1	10
485	Max Hailstorm	Power is equal to the base move's Max Move power. If this move is successful, the effect of Hail begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	6	Physical	1	10
486	Max Knuckle	Boosts the user and its allies' Attack by 1 stage. BP scales with the base move's BP. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	7	Physical	1	10
487	Max Lightning	Power is equal to the base move's Max Move power. If this move is successful, the effect of Electric Terrain begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	4	Physical	1	10
488	Max Mindstorm	Power is equal to the base move's Max Move power. If this move is successful, the effect of Psychic Terrain begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	11	Physical	1	10
489	Max Ooze	Power is equal to the base move's Max Move power. If this move is successful, the Special Attack of each Pokemon on the user's side is raised by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	8	Physical	1	10
490	Max Overgrowth	Power is equal to the base move's Max Move power. If this move is successful, the effect of Grassy Terrain begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	5	Physical	1	10
491	Max Phantasm	Power is equal to the base move's Max Move power. If this move is successful, the Defense of each Pokemon on the opposing side is lowered by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	14	Physical	1	10
492	Max Quake	Power is equal to the base move's Max Move power. If this move is successful, the Special Defense of each Pokemon on the user's side is raised by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	9	Physical	1	10
493	Max Rockfall	Power is equal to the base move's Max Move power. If this move is successful, the effect of Sandstorm begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	13	Physical	1	10
494	Max Starfall	Power is equal to the base move's Max Move power. If this move is successful, the effect of Misty Terrain begins. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	18	Physical	1	10
495	Max Steelspike	Power is equal to the base move's Max Move power. If this move is successful, the Defense of each Pokemon on the user's side is raised by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	16	Physical	1	10
496	Max Strike	Power is equal to the base move's Max Move power. If this move is successful, the Speed of each Pokemon on the opposing side is lowered by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	1	Physical	1	10
497	Max Wyrmwind	Power is equal to the base move's Max Move power. If this move is successful, the Attack of each Pokemon on the opposing side is lowered by 1 stage, even if they have a substitute. This effect does not happen if the user is not Dynamaxed. If this move is used as a base move, it deals damage with a power of 0.	10	1	10	15	Physical	1	10
498	Mean Look	Prevents the target from switching out. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	0	1	5	1	Status	1	10
499	Meditate	Raises the user's Attack by 1 stage.	0	1	40	11	Status	1	10
500	Me First	The user uses the move the target chose for use this turn against it, if possible, with its power multiplied by 1.5. The move must be a damaging move other than Beak Blast, Belch, Blazing Torque, Combat Torque, Comeuppance, Counter, Covet, Focus Punch, Magical Torque, Me First, Metal Burst, Mirror Coat, Noxious Torque, Shell Trap, Struggle, Thief, or Wicked Torque. Fails if the target moves before the user. Ignores the target's substitute for the purpose of copying the move.	0	1	20	1	Status	1	10
501	Mega Drain	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	40	100	15	5	Special	1	10
502	Megahorn	No additional effect.	120	85	10	12	Physical	1	10
503	Mega Kick	No additional effect.	120	75	5	1	Physical	1	10
504	Mega Punch	No additional effect.	80	85	20	1	Physical	1	10
505	Memento	Lowers the target's Attack and Special Attack by 2 stages. The user faints unless this move misses or there is no target. Fails entirely if this move hits a substitute, but does not fail if the target's stats cannot be changed.	0	100	10	17	Status	1	10
506	Menacing Moonraze Maelstrom	This move and its effects ignore the Abilities of other Pokemon.	200	1	1	14	Special	1	10
507	Metal Burst	Deals damage to the last opposing Pokemon to hit the user with a physical or special attack this turn equal to 1.5 times the HP lost by the user from that attack, rounded down. If the user did not lose HP from that attack, this move deals 1 HP of damage instead. If that opposing Pokemon's position is no longer in use and there is another opposing Pokemon on the field, the damage is done to it instead. Only the last hit of a multi-hit attack is counted. Fails if the user was not hit by an opposing Pokemon's physical or special attack this turn.	0	100	10	16	Physical	1	10
508	Metal Claw	Has a 10% chance to raise the user's Attack by 1 stage.	50	95	35	16	Physical	1	10
511	Meteor Beam	This attack charges on the first turn and executes on the second. Raises the user's Special Attack by 1 stage on the first turn. If the user is holding a Power Herb, the move completes in one turn.	120	90	10	13	Special	1	10
512	Meteor Mash	Has a 20% chance to raise the user's Attack by 1 stage.	90	90	10	16	Physical	1	10
513	Metronome	A random move is selected for use, other than After You, Apple Acid, Armor Cannon, Assist, Astral Barrage, Aura Wheel, Baneful Bunker, Beak Blast, Behemoth Bash, Behemoth Blade, Belch, Bestow, Blazing Torque, Body Press, Branch Poke, Breaking Swipe, Celebrate, Chatter, Chilling Water, Chilly Reception, Clangorous Soul, Collision Course, Combat Torque, Comeuppance, Copycat, Counter, Covet, Crafty Shield, Decorate, Destiny Bond, Detect, Diamond Storm, Doodle, Double Iron Bash, Double Shock, Dragon Ascent, Dragon Energy, Drum Beating, Dynamax Cannon, Electro Drift, Endure, Eternabeam, False Surrender, Feint, Fiery Wrath, Fillet Away, Fleur Cannon, Focus Punch, Follow Me, Freeze Shock, Freezing Glare, Glacial Lance, Grav Apple, Helping Hand, Hold Hands, Hyper Drill, Hyperspace Fury, Hyperspace Hole, Ice Burn, Instruct, Jet Punch, Jungle Healing, King's Shield, Life Dew, Light of Ruin, Magical Torque, Make It Rain, Mat Block, Me First, Meteor Assault, Metronome, Mimic, Mind Blown, Mirror Coat, Mirror Move, Moongeist Beam, Nature Power, Nature's Madness, Noxious Torque, Obstruct, Order Up, Origin Pulse, Overdrive, Photon Geyser, Plasma Fists, Population Bomb, Pounce, Power Shift, Precipice Blades, Protect, Pyro Ball, Quash, Quick Guard, Rage Fist, Rage Powder, Raging Bull, Raging Fury, Relic Song, Revival Blessing, Ruination, Salt Cure, Secret Sword, Shed Tail, Shell Trap, Silk Trap, Sketch, Sleep Talk, Snap Trap, Snarl, Snatch, Snore, Snowscape, Spectral Thief, Spicy Extract, Spiky Shield, Spirit Break, Spotlight, Springtide Storm, Steam Eruption, Steel Beam, Strange Steam, Struggle, Sunsteel Strike, Surging Strikes, Switcheroo, Techno Blast, Thief, Thousand Arrows, Thousand Waves, Thunder Cage, Thunderous Kick, Tidy Up, Trailblaze, Transform, Trick, Twin Beam, V-create, Wicked Blow, Wicked Torque, or Wide Guard.	0	1	10	1	Status	1	10
514	Milk Drink	The user restores 1/2 of its maximum HP, rounded half up.	0	1	5	1	Status	1	10
515	Mimic	While the user remains active, this move is replaced by the last move used by the target. The copied move has the maximum PP for that move. Fails if the target has not made a move, if the user has Transformed, if the user already knows the move, or if the move is Assist, Behemoth Bash, Behemoth Blade, Belch, Blazing Torque, Celebrate, Chatter, Combat Torque, Copycat, Dynamax Cannon, Hold Hands, Magical Torque, Me First, Metronome, Mimic, Mirror Move, Nature Power, Noxious Torque, Sketch, Sleep Talk, Struggle, Transform, or Wicked Torque.	0	1	10	1	Status	1	10
516	Mind Blown	Whether or not this move is successful and even if it would cause fainting, the user loses 1/2 of its maximum HP, rounded up, unless the user has the Magic Guard Ability. This move is prevented from executing and the user does not lose HP if any active Pokemon has the Damp Ability, or if this move is Fire type and the user is affected by Powder or the weather is Primordial Sea.	150	100	5	2	Special	1	10
517	Mind Reader	Until the end of the next turn, the target cannot avoid the user's moves, even if the target is in the middle of a two-turn move. The effect ends if either the user or the target leaves the field. Fails if this effect is active for the user.	0	1	5	1	Status	1	10
518	Minimize	Raises the user's evasiveness by 2 stages. Whether or not the user's evasiveness was changed, Body Slam, Dragon Rush, Flying Press, Heat Crash, Heavy Slam, Malicious Moonsault, Steamroller, and Stomp will not check accuracy and have their damage doubled if used against the user while it is active.	0	1	10	1	Status	1	10
519	Miracle Eye	As long as the target remains active, its evasiveness stat stage is ignored during accuracy checks against it if it is greater than 0, and Psychic-type attacks can hit the target if it is a Dark type. Fails if the target is already affected, or affected by Foresight or Odor Sleuth.	0	1	40	11	Status	1	10
520	Mirror Coat	Deals damage to the last opposing Pokemon to hit the user with a special attack this turn equal to twice the HP lost by the user from that attack. If the user did not lose HP from the attack, this move deals 1 HP of damage instead. If that opposing Pokemon's position is no longer in use and there is another opposing Pokemon on the field, the damage is done to it instead. Only the last hit of a multi-hit attack is counted. Fails if the user was not hit by an opposing Pokemon's special attack this turn.	0	100	20	11	Special	1	10
521	Mirror Move	The user uses the last move used by the target. The copied move is used against that target, if possible. Fails if the target has not made a move, or if the last move used cannot be copied by this move.	0	1	20	10	Status	1	10
522	Mirror Shot	Has a 30% chance to lower the target's accuracy by 1 stage.	65	85	10	16	Special	1	10
523	Mist	For 5 turns, the user and its party members are protected from having their stat stages lowered by other Pokemon. Fails if the effect is already active on the user's side.	0	1	30	6	Status	1	10
524	Mist Ball	Has a 50% chance to lower the target's Special Attack by 1 stage.	70	100	5	11	Special	1	10
525	Misty Explosion	If the current terrain is Misty Terrain and the user is grounded, this move's power is multiplied by 1.5. The user faints after using this move, even if this move fails for having no target. This move is prevented from executing if any active Pokemon has the Damp Ability.	100	100	5	18	Special	1	10
526	Misty Terrain	For 5 turns, the terrain becomes Misty Terrain. During the effect, the power of Dragon-type attacks used against grounded Pokemon is multiplied by 0.5 and grounded Pokemon cannot be inflicted with a non-volatile status condition nor confusion. Grounded Pokemon can become affected by Yawn but cannot fall asleep from its effect. Camouflage transforms the user into a Fairy type, Nature Power becomes Moonblast, and Secret Power has a 30% chance to lower Special Attack by 1 stage. Fails if the current terrain is Misty Terrain.	0	1	10	18	Status	1	10
527	Moonblast	Has a 30% chance to lower the target's Special Attack by 1 stage.	95	100	15	18	Special	1	10
528	Moongeist Beam	This move and its effects ignore the Abilities of other Pokemon.	100	100	5	14	Special	1	10
529	Moonlight	The user restores 1/2 of its maximum HP if Delta Stream or no weather conditions are in effect or if the user is holding Utility Umbrella, 2/3 of its maximum HP if the weather is Desolate Land or Sunny Day, and 1/4 of its maximum HP if the weather is Primordial Sea, Rain Dance, Sandstorm, or Snow, all rounded half down.	0	1	5	18	Status	1	10
530	Morning Sun	The user restores 1/2 of its maximum HP if Delta Stream or no weather conditions are in effect or if the user is holding Utility Umbrella, 2/3 of its maximum HP if the weather is Desolate Land or Sunny Day, and 1/4 of its maximum HP if the weather is Primordial Sea, Rain Dance, Sandstorm, or Snow, all rounded half down.	0	1	5	1	Status	1	10
569	Parabolic Charge	The user recovers 1/2 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	65	100	20	4	Special	1	10
531	Mortal Spin	If this move is successful and the user has not fainted, the effects of Leech Seed and binding moves end for the user, and all hazards are removed from the user's side of the field. Has a 100% chance to poison the target.	30	100	15	8	Physical	1	10
532	Mountain Gale	Has a 30% chance to make the target flinch.	100	85	10	6	Physical	1	10
533	Mud Bomb	Has a 30% chance to lower the target's accuracy by 1 stage.	65	85	10	9	Special	1	10
534	Mud Shot	Has a 100% chance to lower the target's Speed by 1 stage.	55	95	15	9	Special	1	10
535	Mud-Slap	Has a 100% chance to lower the target's accuracy by 1 stage.	20	100	10	9	Special	1	10
536	Mud Sport	For 5 turns, all Electric-type attacks used by any active Pokemon have their power multiplied by 0.33. Fails if this effect is already active.	0	1	15	9	Status	1	10
537	Muddy Water	Has a 30% chance to lower the target's accuracy by 1 stage.	90	85	10	3	Special	1	10
538	Multi-Attack	This move's type depends on the user's held Memory.	120	100	10	1	Physical	1	10
539	Mystical Fire	Has a 100% chance to lower the target's Special Attack by 1 stage.	75	100	10	2	Special	1	10
540	Mystical Power	Has a 100% chance to raise the user's Special Attack by 1 stage.	70	90	10	11	Special	1	10
541	Nasty Plot	Raises the user's Special Attack by 2 stages.	0	1	20	17	Status	1	10
542	Natural Gift	The type and power of this move depend on the user's held Berry, and the Berry is lost. Fails if the user is not holding a Berry, if the user has the Klutz Ability, or if Embargo or Magic Room is in effect for the user.	0	100	15	1	Physical	1	10
543	Nature Power	This move calls another move for use based on the battle terrain. Tri Attack on the regular Wi-Fi terrain, Thunderbolt during Electric Terrain, Moonblast during Misty Terrain, Energy Ball during Grassy Terrain, and Psychic during Psychic Terrain.	0	1	20	1	Status	1	10
544	Nature's Madness	Deals damage to the target equal to half of its current HP, rounded down, but not less than 1 HP.	0	90	10	18	Special	1	10
545	Needle Arm	Has a 30% chance to make the target flinch.	60	100	15	5	Physical	1	10
546	Never-Ending Nightmare	Power is equal to the base move's Z-Power.	1	1	1	14	Physical	1	10
547	Night Daze	Has a 40% chance to lower the target's accuracy by 1 stage.	85	95	10	17	Special	1	10
548	Nightmare	Causes the target to lose 1/4 of its maximum HP, rounded down, at the end of each turn as long as it is asleep. This move does not affect the target unless it is asleep. The effect ends when the target wakes up, even if it falls asleep again in the same turn.	0	100	15	14	Status	1	10
549	Night Shade	Deals damage to the target equal to the user's level.	0	100	15	14	Special	1	10
550	Night Slash	Has a higher chance for a critical hit.	70	100	15	17	Physical	1	10
551	Noble Roar	Lowers the target's Attack and Special Attack by 1 stage.	0	100	30	1	Status	1	10
552	No Retreat	Raises the user's Attack, Defense, Special Attack, Special Defense, and Speed by 1 stage, but it becomes prevented from switching out. The user can still switch out if it uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the user leaves the field using Baton Pass, the replacement will remain trapped. Fails if the user has already been prevented from switching by this effect.	0	1	5	7	Status	1	10
553	Noxious Torque	Has a 30% chance to poison the target.	100	100	10	8	Physical	1	10
554	Nuzzle	Has a 100% chance to paralyze the target.	20	100	20	4	Physical	1	10
555	Oblivion Wing	The user recovers 3/4 the HP lost by the target, rounded half up. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down.	80	100	10	10	Special	1	10
556	Obstruct	The user is protected from most attacks made by other Pokemon during this turn, and Pokemon trying to make contact with the user have their Defense lowered by 2 stages. Non-damaging moves go through this protection. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	100	10	17	Status	1	10
557	Oceanic Operetta	No additional effect.	195	1	1	3	Special	1	10
558	Octazooka	Has a 50% chance to lower the target's accuracy by 1 stage.	65	85	10	3	Special	1	10
559	Octolock	Prevents the target from switching out. At the end of each turn during effect, the target's Defense and Special Defense are lowered by 1 stage. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	0	100	15	7	Status	1	10
560	Odor Sleuth	As long as the target remains active, its evasiveness stat stage is ignored during accuracy checks against it if it is greater than 0, and Normal- and Fighting-type attacks can hit the target if it is a Ghost type. Fails if the target is already affected, or affected by Foresight or Miracle Eye.	0	1	40	1	Status	1	10
561	Ominous Wind	Has a 10% chance to raise the user's Attack, Defense, Special Attack, Special Defense, and Speed by 1 stage.	60	100	5	14	Special	1	10
562	Order Up	If an ally Tatsugiri has activated its Commander Ability, this move raises the user's Attack by 1 stage if the Tatsugiri is Curly Form, Defense by 1 stage if Droopy Form, or Speed by 1 stage if Stretchy Form. The effect happens whether or not this move is successful, and even if the Tatsugiri that activated the effect has since fainted.	80	100	10	15	Physical	1	10
563	Origin Pulse	No additional effect.	110	85	10	3	Special	1	10
564	Outrage	The user spends two or three turns locked into this move and becomes confused immediately after its move on the last turn of the effect if it is not already. This move targets an opposing Pokemon at random on each turn. If the user is prevented from moving, is asleep at the beginning of a turn, or the attack is not successful against the target on the first turn of the effect or the second turn of a three-turn effect, the effect ends without causing confusion. If this move is called by Sleep Talk and the user is asleep, the move is used for one turn and does not confuse the user.	120	100	10	15	Physical	1	10
565	Overdrive	No additional effect.	80	100	10	4	Special	1	10
566	Overheat	Lowers the user's Special Attack by 2 stages.	130	90	5	2	Special	1	10
567	Pain Split	The user and the target's HP become the average of their current HP, rounded down, but not more than the maximum HP of either one.	0	1	20	1	Status	1	10
568	Paleo Wave	Has a 20% chance to lower the target's Attack by 1 stage.	85	100	15	13	Special	1	10
606	Precipice Blades	No additional effect.	120	85	10	9	Physical	1	10
570	Parting Shot	Lowers the target's Attack and Special Attack by 1 stage. If this move is successful, the user switches out even if it is trapped and is replaced immediately by a selected party member. The user does not switch out if the target's Attack and Special Attack stat stages were both unchanged, or if there are no unfainted party members.	0	100	20	17	Status	1	10
571	Payback	Power doubles if the user moves after the target this turn, including actions taken through Instruct or the Dancer Ability. Switching in does not count as an action.	50	100	10	17	Physical	1	10
572	Pay Day	No additional effect.	40	100	20	1	Physical	1	10
573	Peck	No additional effect.	35	100	35	10	Physical	1	10
574	Perish Song	Each active Pokemon receives a perish count of 4 if it doesn't already have a perish count. At the end of each turn including the turn used, the perish count of all active Pokemon lowers by 1 and Pokemon faint if the number reaches 0. The perish count is removed from Pokemon that switch out. If a Pokemon uses Baton Pass while it has a perish count, the replacement will gain the perish count and continue to count down.	0	1	5	1	Status	1	10
575	Petal Blizzard	No additional effect.	90	100	15	5	Physical	1	10
576	Petal Dance	The user spends two or three turns locked into this move and becomes confused immediately after its move on the last turn of the effect if it is not already. This move targets an opposing Pokemon at random on each turn. If the user is prevented from moving, is asleep at the beginning of a turn, or the attack is not successful against the target on the first turn of the effect or the second turn of a three-turn effect, the effect ends without causing confusion. If this move is called by Sleep Talk and the user is asleep, the move is used for one turn and does not confuse the user.	120	100	10	5	Special	1	10
577	Phantom Force	If this move is successful, it breaks through the target's Baneful Bunker, Detect, King's Shield, Protect, or Spiky Shield for this turn, allowing other Pokemon to attack the target normally. If the target's side is protected by Crafty Shield, Mat Block, Quick Guard, or Wide Guard, that protection is also broken for this turn and other Pokemon may attack the target's side normally. This attack charges on the first turn and executes on the second. On the first turn, the user avoids all attacks. If the user is holding a Power Herb, the move completes in one turn.	90	100	10	14	Physical	1	10
578	Photon Geyser	This move becomes a physical attack if the user's Attack is greater than its Special Attack, including stat stage changes. This move and its effects ignore the Abilities of other Pokemon.	100	100	5	11	Special	1	10
579	Pika Papow	Power is equal to the greater of (user's Happiness * 2/5), rounded down, or 1.	0	1	20	4	Special	1	10
580	Pin Missile	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	95	20	12	Physical	1	10
581	Plasma Fists	If this move is successful, causes Normal-type moves to become Electric type this turn.	100	100	15	4	Physical	1	10
582	Play Nice	Lowers the target's Attack by 1 stage.	0	1	20	1	Status	1	10
583	Play Rough	Has a 10% chance to lower the target's Attack by 1 stage.	90	90	10	18	Physical	1	10
584	Pluck	If this move is successful and the user has not fainted, it steals the target's held Berry if it is holding one and eats it immediately, gaining its effects even if the user's item is being ignored. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	60	100	20	10	Physical	1	10
585	Poison Fang	Has a 50% chance to badly poison the target.	50	100	15	8	Physical	1	10
586	Poison Gas	Poisons the target.	0	90	40	8	Status	1	10
587	Poison Jab	Has a 30% chance to poison the target.	80	100	20	8	Physical	1	10
588	Poison Powder	Poisons the target.	0	75	35	8	Status	1	10
589	Poison Sting	Has a 30% chance to poison the target.	15	100	35	8	Physical	1	10
590	Poison Tail	Has a 10% chance to poison the target and a higher chance for a critical hit.	50	100	25	8	Physical	1	10
591	Pollen Puff	If the target is an ally, this move restores 1/2 of its maximum HP, rounded down, instead of dealing damage.	90	100	15	12	Special	1	10
592	Poltergeist	Fails if the target has no held item.	110	90	5	14	Physical	1	10
593	Population Bomb	Hits ten times. This move checks accuracy for each hit, and the attack ends if the target avoids a hit. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit ten times. If the user is holding Loaded Dice, this move hits four to ten times at random without checking accuracy between hits.	20	90	10	1	Physical	1	10
594	Pounce	Has a 100% chance to lower the target's Speed by 1 stage.	50	100	20	12	Physical	1	10
595	Pound	No additional effect.	40	100	35	1	Physical	1	10
596	Powder	If the target uses a Fire-type move this turn, it is prevented from executing and the target loses 1/4 of its maximum HP, rounded half up. This effect does not happen if the Fire-type move is prevented by Primordial Sea.	0	100	20	12	Status	1	10
597	Powder Snow	Has a 10% chance to freeze the target.	40	100	25	6	Special	1	10
598	Power Gem	No additional effect.	80	100	20	13	Special	1	10
599	Power Shift	The user swaps its Attack and Defense stats, and stat stage changes remain on their respective stats. This move can be used again to swap the stats back. If the user uses Baton Pass, the replacement will have its Attack and Defense stats swapped if the effect is active. If the user has its stats recalculated by changing forme while its stats are swapped, this effect is ignored but is still active for the purposes of Baton Pass.	0	1	10	1	Status	1	10
600	Power Split	The user and the target have their Attack and Special Attack stats set to be equal to the average of the user and the target's Attack and Special Attack stats, respectively, rounded down. Stat stage changes are unaffected.	0	1	10	11	Status	1	10
601	Power Swap	The user swaps its Attack and Special Attack stat stage changes with the target.	0	1	10	11	Status	1	10
602	Power Trick	The user swaps its Attack and Defense stats, and stat stage changes remain on their respective stats. This move can be used again to swap the stats back. If the user uses Baton Pass, the replacement will have its Attack and Defense stats swapped if the effect is active. If the user has its stats recalculated by changing forme while its stats are swapped, this effect is ignored but is still active for the purposes of Baton Pass.	0	1	10	11	Status	1	10
603	Power Trip	Power is equal to 20+(X*20), where X is the user's total stat stage changes that are greater than 0.	20	100	10	17	Physical	1	10
604	Power-Up Punch	Has a 100% chance to raise the user's Attack by 1 stage.	40	100	20	7	Physical	1	10
605	Power Whip	No additional effect.	120	85	10	5	Physical	1	10
607	Present	If this move is successful, it deals damage or heals the target. 40% chance for 40 power, 30% chance for 80 power, 10% chance for 120 power, and 20% chance to heal the target by 1/4 of its maximum HP, rounded down.	0	90	15	1	Physical	1	10
608	Prismatic Laser	If this move is successful, the user must recharge on the following turn and cannot select a move.	160	100	10	11	Special	1	10
609	Protect	The user is protected from most attacks made by other Pokemon during this turn. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	1	Status	1	10
610	Psybeam	Has a 10% chance to confuse the target.	65	100	20	11	Special	1	10
611	Psyblade	If the current terrain is Electric Terrain, this move's power is multiplied by 1.5.	80	100	15	11	Physical	1	10
612	Psych Up	The user copies all of the target's current stat stage changes.	0	1	10	1	Status	1	10
613	Psychic	Has a 10% chance to lower the target's Special Defense by 1 stage.	90	100	10	11	Special	1	10
614	Psychic Fangs	If this attack does not miss, the effects of Reflect, Light Screen, and Aurora Veil end for the target's side of the field before damage is calculated.	85	100	10	11	Physical	1	10
615	Psychic Terrain	For 5 turns, the terrain becomes Psychic Terrain. During the effect, the power of Psychic-type attacks made by grounded Pokemon is multiplied by 1.3 and grounded Pokemon cannot be hit by moves with priority greater than 0, unless the target is an ally. Camouflage transforms the user into a Psychic type, Nature Power becomes Psychic, and Secret Power has a 30% chance to lower the target's Speed by 1 stage. Fails if the current terrain is Psychic Terrain.	0	1	10	11	Status	1	10
616	Psycho Boost	Lowers the user's Special Attack by 2 stages.	140	90	5	11	Special	1	10
617	Psycho Cut	Has a higher chance for a critical hit.	70	100	20	11	Physical	1	10
618	Psycho Shift	The user's non-volatile status condition is transferred to the target, and the user is then cured. Fails if the user has no non-volatile status condition or if the target already has one.	0	100	10	11	Status	1	10
619	Psyshield Bash	Has a 100% chance to raise the user's Defense by 1 stage.	70	90	10	11	Physical	1	10
620	Psyshock	Deals damage to the target based on its Defense instead of Special Defense.	80	100	10	11	Special	1	10
621	Psystrike	Deals damage to the target based on its Defense instead of Special Defense.	100	100	10	11	Special	1	10
622	Psywave	Deals damage to the target equal to (user's level) * (X + 50) / 100, where X is a random number from 0 to 100, rounded down, but not less than 1 HP.	0	100	15	11	Special	1	10
623	Pulverizing Pancake	No additional effect.	210	1	1	1	Physical	1	10
624	Punishment	Power is equal to 60+(X*20), where X is the target's total stat stage changes that are greater than 0, but not more than 200 power.	0	100	5	17	Physical	1	10
625	Purify	The target is cured if it has a non-volatile status condition. If the target was cured, the user restores 1/2 of its maximum HP, rounded down.	0	1	20	8	Status	1	10
626	Pursuit	If an opposing Pokemon switches out this turn, this move hits that Pokemon before it leaves the field, even if it was not the original target. If the user moves after an opponent using Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch, but not Baton Pass, it will hit that opponent before it leaves the field. Power doubles and no accuracy check is done if the user hits an opponent switching out, and the user's turn is over; if an opponent faints from this, the replacement Pokemon does not become active until the end of the turn.	40	100	20	17	Physical	1	10
627	Pyro Ball	Has a 10% chance to burn the target.	120	90	5	2	Physical	1	10
628	Quash	Causes the target to take its turn after all other Pokemon this turn, no matter the priority of its selected move. Fails if the target already moved this turn.	0	100	15	17	Status	1	10
629	Quick Attack	No additional effect.	40	100	30	1	Physical	1	10
630	Quick Guard	The user and its party members are protected from attacks with original or altered priority greater than 0 made by other Pokemon, including allies, during this turn. This move modifies the same 1/X chance of being successful used by other protection moves, where X starts at 1 and triples each time this move is successfully used, but does not use the chance to check for failure. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn or if this move is already in effect for the user's side.	0	1	15	7	Status	1	10
631	Quiver Dance	Raises the user's Special Attack, Special Defense, and Speed by 1 stage.	0	1	20	12	Status	1	10
632	Rage	Once this move is successfully used, the user's Attack is raised by 1 stage every time it is hit by another Pokemon's attack as long as this move is chosen for use.	20	100	20	1	Physical	1	10
633	Rage Fist	Power is equal to 50+(X*50), where X is the total number of times the user has been hit by a damaging attack during the battle, even if the user did not lose HP from the attack. X cannot be greater than 6 and does not reset upon switching out or fainting. Each hit of a multi-hit attack is counted, but confusion damage is not counted.	50	100	10	14	Physical	1	10
634	Rage Powder	Until the end of the turn, all single-target attacks from the opposing side are redirected to the user. Such attacks are redirected to the user before they can be reflected by Magic Coat or the Magic Bounce Ability, or drawn in by the Lightning Rod or Storm Drain Abilities. Fails if it is not a Double Battle or Battle Royal. This effect is ignored while the user is under the effect of Sky Drop.	0	1	20	12	Status	1	10
635	Raging Bull	If this attack does not miss, the effects of Reflect, Light Screen, and Aurora Veil end for the target's side of the field before damage is calculated. If the user's current form is a Paldean Tauros, this move's type changes to match. Fighting type for Combat Breed, Fire type for Blaze Breed, and Water type for Aqua Breed.	90	100	10	1	Physical	1	10
636	Raging Fury	The user spends two or three turns locked into this move and becomes confused immediately after its move on the last turn of the effect if it is not already. This move targets an opposing Pokemon at random on each turn. If the user is prevented from moving, is asleep at the beginning of a turn, or the attack is not successful against the target on the first turn of the effect or the second turn of a three-turn effect, the effect ends without causing confusion. If this move is called by Sleep Talk and the user is asleep, the move is used for one turn and does not confuse the user.	120	100	10	2	Physical	1	10
637	Rain Dance	For 5 turns, the weather becomes Rain Dance. The damage of Water-type attacks is multiplied by 1.5 and the damage of Fire-type attacks is multiplied by 0.5 during the effect. Lasts for 8 turns if the user is holding Damp Rock. Fails if the current weather is Rain Dance.	0	1	5	3	Status	1	10
638	Rapid Spin	If this move is successful and the user has not fainted, the effects of Leech Seed and binding moves end for the user, and all hazards are removed from the user's side of the field. Has a 100% chance to raise the user's Speed by 1 stage.	50	100	40	1	Physical	1	10
639	Razor Leaf	Has a higher chance for a critical hit.	55	95	25	5	Physical	1	10
640	Razor Shell	Has a 50% chance to lower the target's Defense by 1 stage.	75	95	10	3	Physical	1	10
641	Razor Wind	Has a higher chance for a critical hit. This attack charges on the first turn and executes on the second. If the user is holding a Power Herb, the move completes in one turn.	80	100	10	1	Special	1	10
642	Recover	The user restores 1/2 of its maximum HP, rounded half up.	0	1	5	1	Status	1	10
643	Recycle	The user regains the item it last used. Fails if the user is holding an item, if the user has not held an item, if the item was a popped Air Balloon, if the item was picked up by a Pokemon with the Pickup Ability, or if the item was lost to Bug Bite, Corrosive Gas, Covet, Incinerate, Knock Off, Pluck, or Thief. Items thrown with Fling can be regained.	0	1	10	1	Status	1	10
644	Reflect	For 5 turns, the user and its party members take 0.5x damage from physical attacks, or 0.66x damage if in a Double Battle. Damage is not reduced further with Aurora Veil. Critical hits ignore this effect. It is removed from the user's side if the user or an ally is successfully hit by Brick Break, Psychic Fangs, or Defog. Lasts for 8 turns if the user is holding Light Clay. Fails if the effect is already active on the user's side.	0	1	20	11	Status	1	10
645	Reflect Type	Causes the user's types to become the same as the current types of the target. If the target's current types include typeless and a non-added type, typeless is ignored. If the target's current types include typeless and an added type from Forest's Curse or Trick-or-Treat, typeless is copied as the Normal type instead. Fails if the user is an Arceus or a Silvally, if the user is Terastallized, or if the target's current type is typeless alone.	0	1	15	1	Status	1	10
646	Refresh	The user cures its burn, poison, or paralysis. Fails if the user is not burned, poisoned, or paralyzed.	0	1	20	1	Status	1	10
647	Relic Song	Has a 10% chance to cause the target to fall asleep. If this move is successful on at least one target and the user is a Meloetta, it changes to Pirouette Forme if it is currently in Aria Forme, or changes to Aria Forme if it is currently in Pirouette Forme. This forme change does not happen if the Meloetta has the Sheer Force Ability. The Pirouette Forme reverts to Aria Forme when Meloetta is not active.	75	100	10	1	Special	1	10
648	Rest	The user falls asleep for the next two turns and restores all of its HP, curing itself of any non-volatile status condition in the process. Fails if the user has full HP, is already asleep, or if another effect is preventing sleep.	0	1	5	11	Status	1	10
649	Retaliate	Power doubles if one of the user's party members fainted last turn.	70	100	5	1	Physical	1	10
650	Return	Power is equal to the greater of (user's Happiness * 2/5), rounded down, or 1.	0	100	20	1	Physical	1	10
651	Revelation Dance	This move's type depends on the user's primary type. If the user's primary type is typeless, this move's type is the user's secondary type if it has one, otherwise the added type from Forest's Curse or Trick-or-Treat. This move is typeless if the user's type is typeless alone.	90	100	15	1	Special	1	10
652	Revenge	Power doubles if the user was hit by the target this turn.	60	100	10	7	Physical	1	10
653	Reversal	The power of this move is 20 if X is 33 to 48, 40 if X is 17 to 32, 80 if X is 10 to 16, 100 if X is 5 to 9, 150 if X is 2 to 4, and 200 if X is 0 or 1, where X is equal to (user's current HP * 48 / user's maximum HP), rounded down.	0	100	15	7	Physical	1	10
654	Revival Blessing	A fainted party member is selected and revived with 1/2 its max HP, rounded down. Fails if there are no fainted party members.	0	1	1	1	Status	1	10
655	Rising Voltage	If the current terrain is Electric Terrain and the target is grounded, this move's power is doubled.	70	100	20	4	Special	1	10
656	Roar	The target is forced to switch out and be replaced with a random unfainted ally. Fails if the target is the last unfainted Pokemon in its party, or if the target used Ingrain previously or has the Suction Cups Ability.	0	1	20	1	Status	1	10
657	Roar of Time	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	15	Special	1	10
658	Rock Blast	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	90	10	13	Physical	1	10
659	Rock Climb	Has a 20% chance to confuse the target.	90	85	20	1	Physical	1	10
660	Rock Polish	Raises the user's Speed by 2 stages.	0	1	20	13	Status	1	10
661	Rock Slide	Has a 30% chance to make the target flinch.	75	90	10	13	Physical	1	10
662	Rock Smash	Has a 50% chance to lower the target's Defense by 1 stage.	40	100	15	7	Physical	1	10
663	Rock Throw	No additional effect.	50	90	15	13	Physical	1	10
664	Rock Tomb	Has a 100% chance to lower the target's Speed by 1 stage.	60	95	15	13	Physical	1	10
665	Rock Wrecker	If this move is successful, the user must recharge on the following turn and cannot select a move.	150	90	5	13	Physical	1	10
666	Role Play	The user's Ability changes to match the target's Ability. Fails if the user's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Zen Mode, Zero to Hero, or already matches the target, or if the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Flower Gift, Forecast, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Imposter, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Power of Alchemy, Protosynthesis, Quark Drive, Receiver, RKS System, Schooling, Shields Down, Stance Change, Trace, Wonder Guard, Zen Mode, or Zero to Hero.	0	1	10	11	Status	1	10
667	Rolling Kick	Has a 30% chance to make the target flinch.	60	85	15	7	Physical	1	10
668	Rollout	If this move is successful, the user is locked into this move and cannot make another move until it misses, 5 turns have passed, or the attack cannot be used. Power doubles with each successful hit of this move and doubles again if Defense Curl was used previously by the user. If this move is called by Sleep Talk, the move is used for one turn.	30	90	20	13	Physical	1	10
669	Roost	The user restores 1/2 of its maximum HP, rounded half up. If the user is not Terastallized, until the end of the turn Flying-type users lose their Flying type and pure Flying-type users become Normal type. Does nothing if the user's HP is full.	0	1	5	10	Status	1	10
670	Rototiller	Raises the Attack and Special Attack of all grounded Grass-type Pokemon on the field by 1 stage.	0	1	10	9	Status	1	10
671	Round	If there are other active Pokemon that chose this move for use this turn, those Pokemon take their turn immediately after the user, in Speed order, and this move's power is 120 for each other user.	60	100	15	1	Special	1	10
672	Ruination	Deals damage to the target equal to half of its current HP, rounded down, but not less than 1 HP.	0	90	10	17	Special	1	10
673	Sacred Fire	Has a 50% chance to burn the target.	100	95	5	2	Physical	1	10
674	Sacred Sword	Ignores the target's stat stage changes, including evasiveness.	90	100	15	7	Physical	1	10
675	Safeguard	For 5 turns, the user and its party members cannot have non-volatile status conditions or confusion inflicted on them by other Pokemon. Pokemon on the user's side cannot become affected by Yawn but can fall asleep from its effect. It is removed from the user's side if the user or an ally is successfully hit by Defog. Fails if the effect is already active on the user's side.	0	1	25	1	Status	1	10
676	Salt Cure	Causes damage to the target equal to 1/8 of its maximum HP (1/4 if the target is Steel or Water type), rounded down, at the end of each turn during effect. This effect ends when the target is no longer active.	40	100	15	13	Physical	1	10
677	Sand Attack	Lowers the target's accuracy by 1 stage.	0	100	15	9	Status	1	10
678	Sandsear Storm	Has a 20% chance to burn the target. If the weather is Primordial Sea or Rain Dance, this move does not check accuracy. If this move is used against a Pokemon holding Utility Umbrella, this move's accuracy remains at 80%.	100	80	10	9	Special	1	10
679	Sandstorm	For 5 turns, the weather becomes Sandstorm. At the end of each turn except the last, all active Pokemon lose 1/16 of their maximum HP, rounded down, unless they are a Ground, Rock, or Steel type, or have the Magic Guard, Overcoat, Sand Force, Sand Rush, or Sand Veil Abilities. During the effect, the Special Defense of Rock-type Pokemon is multiplied by 1.5 when taking damage from a special attack. Lasts for 8 turns if the user is holding Smooth Rock. Fails if the current weather is Sandstorm.	0	1	10	13	Status	1	10
680	Sand Tomb	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	35	85	15	9	Physical	1	10
681	Sappy Seed	This move summons Leech Seed on the foe.	100	90	10	5	Physical	1	10
682	Savage Spin-Out	Power is equal to the base move's Z-Power.	1	1	1	12	Physical	1	10
683	Scald	Has a 30% chance to burn the target. The target thaws out if it is frozen.	80	100	15	3	Special	1	10
684	Scale Shot	Hits two to five times. Lowers the user's Defense by 1 stage and raises the user's Speed by 1 stage after the last hit. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	90	20	15	Physical	1	10
685	Scary Face	Lowers the target's Speed by 2 stages.	0	100	10	1	Status	1	10
686	Scorching Sands	Has a 30% chance to burn the target. The target thaws out if it is frozen.	70	100	10	9	Special	1	10
687	Scratch	No additional effect.	40	100	35	1	Physical	1	10
688	Screech	Lowers the target's Defense by 2 stages.	0	85	40	1	Status	1	10
689	Searing Shot	Has a 30% chance to burn the target.	100	100	5	2	Special	1	10
690	Searing Sunraze Smash	This move and its effects ignore the Abilities of other Pokemon.	200	1	1	16	Physical	1	10
691	Secret Power	Has a 30% chance to cause a secondary effect on the target based on the battle terrain. Causes paralysis on the regular Wi-Fi terrain, causes paralysis during Electric Terrain, lowers Special Attack by 1 stage during Misty Terrain, causes sleep during Grassy Terrain and lowers Speed by 1 stage during Psychic Terrain.	70	100	20	1	Physical	1	10
692	Secret Sword	Deals damage to the target based on its Defense instead of Special Defense.	85	100	10	7	Special	1	10
693	Seed Bomb	No additional effect.	80	100	15	5	Physical	1	10
694	Seed Flare	Has a 40% chance to lower the target's Special Defense by 2 stages.	120	85	5	5	Special	1	10
695	Seismic Toss	Deals damage to the target equal to the user's level.	0	100	20	7	Physical	1	10
696	Self-Destruct	The user faints after using this move, even if this move fails for having no target. This move is prevented from executing if any active Pokemon has the Damp Ability.	200	100	5	1	Physical	1	10
697	Shadow Ball	Has a 20% chance to lower the target's Special Defense by 1 stage.	80	100	15	14	Special	1	10
698	Shadow Bone	Has a 20% chance to lower the target's Defense by 1 stage.	85	100	10	14	Physical	1	10
699	Shadow Claw	Has a higher chance for a critical hit.	70	100	15	14	Physical	1	10
700	Shadow Force	If this move is successful, it breaks through the target's Baneful Bunker, Detect, King's Shield, Protect, or Spiky Shield for this turn, allowing other Pokemon to attack the target normally. If the target's side is protected by Crafty Shield, Mat Block, Quick Guard, or Wide Guard, that protection is also broken for this turn and other Pokemon may attack the target's side normally. This attack charges on the first turn and executes on the second. On the first turn, the user avoids all attacks. If the user is holding a Power Herb, the move completes in one turn.	120	100	5	14	Physical	1	10
701	Shadow Punch	This move does not check accuracy.	60	1	20	14	Physical	1	10
702	Shadow Sneak	No additional effect.	40	100	30	14	Physical	1	10
703	Shadow Strike	Has a 50% chance to lower the target's Defense by 1 stage.	80	95	10	14	Physical	1	10
704	Sharpen	Raises the user's Attack by 1 stage.	0	1	30	1	Status	1	10
705	Shattered Psyche	Power is equal to the base move's Z-Power.	1	1	1	11	Physical	1	10
706	Shed Tail	The user takes 1/2 of its maximum HP, rounded up, and creates a substitute that has 1/4 of the user's maximum HP, rounded down. The user is replaced with another Pokemon in its party and the selected Pokemon has the substitute transferred to it. Fails if the user would faint, or if there are no unfainted party members.	0	1	10	1	Status	1	10
707	Sheer Cold	Deals damage to the target equal to the target's maximum HP. Ignores accuracy and evasiveness modifiers. This attack's accuracy is equal to (user's level - target's level + X)%, where X is 30 if the user is an Ice type and 20 otherwise, and fails if the target is at a higher level. Ice-type Pokemon and Pokemon with the Sturdy Ability are immune.	0	30	5	6	Special	1	10
708	Shell Side Arm	Has a 20% chance to poison the target. This move becomes a physical attack that makes contact if the value of ((((2 * the user's level / 5 + 2) * 90 * X) / Y) / 50), where X is the user's Attack stat and Y is the target's Defense stat, is greater than the same value where X is the user's Special Attack stat and Y is the target's Special Defense stat. No stat modifiers other than stat stage changes are considered for this purpose. If the two values are equal, this move chooses a damage category at random.	90	100	10	8	Special	1	10
709	Shell Smash	Lowers the user's Defense and Special Defense by 1 stage. Raises the user's Attack, Special Attack, and Speed by 2 stages.	0	1	15	1	Status	1	10
710	Shell Trap	Fails unless the user is hit by a physical attack from an opponent this turn before it can execute the move. If the user was hit and has not fainted, it attacks immediately after being hit, and the effect ends. If the opponent's physical attack had a secondary effect removed by the Sheer Force Ability, it does not count for the purposes of this effect.	150	100	5	2	Special	1	10
711	Shelter	Raises the user's Defense by 2 stages.	0	1	10	16	Status	1	10
712	Shift Gear	Raises the user's Speed by 2 stages and its Attack by 1 stage.	0	1	10	16	Status	1	10
713	Shock Wave	This move does not check accuracy.	60	1	20	4	Special	1	10
714	Shore Up	The user restores 1/2 of its maximum HP, rounded half down. If the weather is Sandstorm, the user instead restores 2/3 of its maximum HP, rounded half down.	0	1	5	9	Status	1	10
715	Signal Beam	Has a 10% chance to confuse the target.	75	100	15	12	Special	1	10
716	Silk Trap	The user is protected from most attacks made by other Pokemon during this turn, and Pokemon trying to make contact with the user have their Speed lowered by 1 stage. Non-damaging moves go through this protection. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	12	Status	1	10
717	Silver Wind	Has a 10% chance to raise the user's Attack, Defense, Special Attack, Special Defense, and Speed by 1 stage.	60	100	5	12	Special	1	10
718	Simple Beam	Causes the target's Ability to become Simple. Fails if the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Simple, Stance Change, Truant, Zen Mode, or Zero to Hero.	0	100	15	1	Status	1	10
719	Sing	Causes the target to fall asleep.	0	55	15	1	Status	1	10
720	Sinister Arrow Raid	No additional effect.	180	1	1	14	Physical	1	10
721	Sizzly Slide	Has a 100% chance to burn the foe.	60	100	20	2	Physical	1	10
722	Sketch	This move is permanently replaced by the last move used by the target. The copied move has the maximum PP for that move. Fails if the target has not made a move, if the user has Transformed, or if the move is Chatter, Sketch, Struggle, or any move the user knows.	0	1	1	1	Status	1	10
723	Skill Swap	The user swaps its Ability with the target's Ability. Fails if either the user or the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Hunger Switch, Ice Face, Illusion, Multitype, Neutralizing Gas, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Wonder Guard, Zen Mode, or Zero to Hero.	0	1	10	11	Status	1	10
724	Skitter Smack	Has a 100% chance to lower the target's Special Attack by 1 stage.	70	90	10	12	Physical	1	10
725	Skull Bash	This attack charges on the first turn and executes on the second. Raises the user's Defense by 1 stage on the first turn. If the user is holding a Power Herb, the move completes in one turn.	130	100	10	1	Physical	1	10
726	Sky Attack	Has a 30% chance to make the target flinch and a higher chance for a critical hit. This attack charges on the first turn and executes on the second. If the user is holding a Power Herb, the move completes in one turn.	140	90	5	10	Physical	1	10
727	Sky Drop	This attack takes the target into the air with the user on the first turn and executes on the second. Pokemon weighing 200 kg or more cannot be lifted. On the first turn, the user and the target avoid all attacks other than Gust, Hurricane, Sky Uppercut, Smack Down, Thousand Arrows, Thunder, and Twister. The user and the target cannot make a move between turns, but the target can select a move to use. This move cannot damage Flying-type Pokemon. Fails on the first turn if the target is an ally, if the target has a substitute, or if the target is using Bounce, Dig, Dive, Fly, Phantom Force, Shadow Force, or Sky Drop.	60	100	10	10	Physical	1	10
728	Sky Uppercut	This move can hit a target using Bounce, Fly, or Sky Drop, or is under the effect of Sky Drop.	85	90	15	7	Physical	1	10
729	Slack Off	The user restores 1/2 of its maximum HP, rounded half up.	0	1	5	1	Status	1	10
730	Slam	No additional effect.	80	75	20	1	Physical	1	10
731	Slash	Has a higher chance for a critical hit.	70	100	20	1	Physical	1	10
732	Sleep Powder	Causes the target to fall asleep.	0	75	15	5	Status	1	10
733	Sleep Talk	One of the user's known moves, besides this move, is selected for use at random. Fails if the user is not asleep. The selected move does not have PP deducted from it, and can currently have 0 PP. This move cannot select Assist, Beak Blast, Belch, Bide, Blazing Torque, Celebrate, Chatter, Combat Torque, Copycat, Dynamax Cannon, Focus Punch, Hold Hands, Magical Torque, Me First, Metronome, Mimic, Mirror Move, Nature Power, Noxious Torque, Shell Trap, Sketch, Sleep Talk, Struggle, Uproar, Wicked Torque, or any two-turn move.	0	1	10	1	Status	1	10
734	Sludge	Has a 30% chance to poison the target.	65	100	20	8	Special	1	10
735	Sludge Bomb	Has a 30% chance to poison the target.	90	100	10	8	Special	1	10
736	Sludge Wave	Has a 10% chance to poison the target.	95	100	10	8	Special	1	10
737	Smack Down	This move can hit a target using Bounce, Fly, or Sky Drop, or is under the effect of Sky Drop. If this move hits a target under the effect of Bounce, Fly, Magnet Rise, or Telekinesis, the effect ends. If the target is a Flying type that has not used Roost this turn or a Pokemon with the Levitate Ability, it loses its immunity to Ground-type attacks and the Arena Trap Ability as long as it remains active. During the effect, Magnet Rise fails for the target and Telekinesis fails against the target.	50	100	15	13	Physical	1	10
739	Smelling Salts	Power doubles if the target is paralyzed. If the user has not fainted, the target is cured of paralysis.	70	100	10	1	Physical	1	10
740	Smog	Has a 40% chance to poison the target.	30	70	20	8	Special	1	10
741	Smokescreen	Lowers the target's accuracy by 1 stage.	0	100	20	1	Status	1	10
742	Snap Trap	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	35	100	15	5	Physical	1	10
743	Snarl	Has a 100% chance to lower the target's Special Attack by 1 stage.	55	95	15	17	Special	1	10
744	Snatch	If another Pokemon uses certain non-damaging moves this turn, the user steals that move to use itself. If multiple Pokemon use one of those moves this turn, the applicable moves are all stolen by the first Pokemon in turn order that used this move this turn. This effect is ignored while the user is under the effect of Sky Drop.	0	1	10	17	Status	1	10
745	Snipe Shot	Has a higher chance for a critical hit. This move cannot be redirected to a different target by any effect.	80	100	15	3	Special	1	10
746	Snore	Has a 30% chance to make the target flinch. Fails if the user is not asleep.	50	100	15	1	Special	1	10
747	Snowscape	For 5 turns, the weather becomes Snow. During the effect, the Defense of Ice-type Pokemon is multiplied by 1.5 when taking damage from a physical attack. Lasts for 8 turns if the user is holding Icy Rock. Fails if the current weather is Snow.	0	1	10	6	Status	1	10
748	Soak	Causes the target to become a Water type. Fails if the target is an Arceus or a Silvally, if the target is already purely Water type, or if the target is Terastallized.	0	100	20	3	Status	1	10
749	Soft-Boiled	The user restores 1/2 of its maximum HP, rounded half up.	0	1	5	1	Status	1	10
750	Solar Beam	This attack charges on the first turn and executes on the second. Power is halved if the weather is Primordial Sea, Rain Dance, Sandstorm, or Snow and the user is not holding Utility Umbrella. If the user is holding a Power Herb or the weather is Desolate Land or Sunny Day, the move completes in one turn. If the user is holding Utility Umbrella and the weather is Desolate Land or Sunny Day, the move still requires a turn to charge.	120	100	10	5	Special	1	10
751	Solar Blade	This attack charges on the first turn and executes on the second. Power is halved if the weather is Hail, Primordial Sea, Rain Dance, or Sandstorm and the user is not holding Utility Umbrella. If the user is holding a Power Herb or the weather is Desolate Land or Sunny Day, the move completes in one turn. If the user is holding Utility Umbrella and the weather is Desolate Land or Sunny Day, the move still requires a turn to charge.	125	100	10	5	Physical	1	10
752	Sonic Boom	Deals 20 HP of damage to the target.	0	90	20	1	Special	1	10
753	Soul-Stealing 7-Star Strike	No additional effect.	195	1	1	14	Physical	1	10
754	Spacial Rend	Has a higher chance for a critical hit.	100	95	5	15	Special	1	10
755	Spark	Has a 30% chance to paralyze the target.	65	100	20	4	Physical	1	10
756	Sparkling Aria	If the user has not fainted, the target is cured of its burn.	90	100	10	3	Special	1	10
757	Sparkly Swirl	Every Pokemon in the user's party is cured of its non-volatile status condition.	120	85	5	18	Special	1	10
758	Spectral Thief	The target's stat stages greater than 0 are stolen from it and applied to the user before dealing damage.	90	100	10	14	Physical	1	10
759	Speed Swap	The user swaps its Speed stat with the target. Stat stage changes are unaffected.	0	1	10	11	Status	1	10
760	Spicy Extract	Raises the target's Attack by 2 stages and lowers its Defense by 2 stages.	0	1	15	5	Status	1	10
761	Spider Web	Prevents the target from switching out. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	0	1	10	12	Status	1	10
762	Spike Cannon	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	20	100	15	1	Physical	1	10
763	Spikes	Sets up a hazard on the opposing side of the field, damaging each opposing Pokemon that switches in, unless it is a Flying-type Pokemon or has the Levitate Ability. Can be used up to three times before failing. Opponents lose 1/8 of their maximum HP with one layer, 1/6 of their maximum HP with two layers, and 1/4 of their maximum HP with three layers, all rounded down. Can be removed from the opposing side if any opposing Pokemon uses Mortal Spin, Rapid Spin, or Defog successfully, or is hit by Defog.	0	1	20	9	Status	1	10
764	Spiky Shield	The user is protected from most attacks made by other Pokemon during this turn, and Pokemon making contact with the user lose 1/8 of their maximum HP, rounded down. This move has a 1/X chance of being successful, where X starts at 1 and triples each time this move is successfully used. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn.	0	1	10	5	Status	1	10
765	Spin Out	Lowers the user's Speed by 2 stages.	100	100	5	16	Physical	1	10
766	Spirit Break	Has a 100% chance to lower the target's Special Attack by 1 stage.	75	100	15	18	Physical	1	10
767	Spirit Shackle	Prevents the target from switching out. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	80	100	10	14	Physical	1	10
768	Spit Up	Power is equal to 100 times the user's Stockpile count. Fails if the user's Stockpile count is 0. Whether or not this move is successful, the user's Defense and Special Defense decrease by as many stages as Stockpile had increased them, and the user's Stockpile count resets to 0.	0	100	10	1	Special	1	10
769	Spite	Causes the target's last move used to lose 4 PP. Fails if the target has not made a move, if the move has 0 PP, or if it no longer knows the move.	0	100	10	14	Status	1	10
770	Splash	No competitive use.	0	1	40	1	Status	1	10
771	Splintered Stormshards	Ends the effects of Electric Terrain, Grassy Terrain, Misty Terrain, and Psychic Terrain.	190	1	1	13	Physical	1	10
772	Splishy Splash	Has a 30% chance to paralyze the target.	90	100	15	3	Special	1	10
773	Spore	Causes the target to fall asleep.	0	100	15	5	Status	1	10
774	Spotlight	Until the end of the turn, all single-target attacks from opponents of the target are redirected to the target. Such attacks are redirected to the target before they can be reflected by Magic Coat or the Magic Bounce Ability, or drawn in by the Lightning Rod or Storm Drain Abilities. Fails if it is not a Double Battle or Battle Royal.	0	1	15	1	Status	1	10
775	Springtide Storm	Has a 30% chance to lower the target's Attack by 1 stage.	100	80	5	18	Special	1	10
776	Stealth Rock	Sets up a hazard on the opposing side of the field, damaging each opposing Pokemon that switches in. Fails if the effect is already active on the opposing side. Foes lose 1/32, 1/16, 1/8, 1/4, or 1/2 of their maximum HP, rounded down, based on their weakness to the Rock type; 0.25x, 0.5x, neutral, 2x, or 4x, respectively. Can be removed from the opposing side if any opposing Pokemon uses Mortal Spin, Rapid Spin, or Defog successfully, or is hit by Defog.	0	1	20	13	Status	1	10
777	Steam Eruption	Has a 30% chance to burn the target. The target thaws out if it is frozen.	110	95	5	3	Special	1	10
778	Steamroller	Has a 30% chance to make the target flinch. Damage doubles and no accuracy check is done if the target has used Minimize while active.	65	100	20	12	Physical	1	10
779	Steel Beam	Whether or not this move is successful and even if it would cause fainting, the user loses 1/2 of its maximum HP, rounded up, unless the user has the Magic Guard Ability.	140	95	5	16	Special	1	10
780	Steel Roller	Fails if there is no terrain active. Ends the effects of Electric Terrain, Grassy Terrain, Misty Terrain, and Psychic Terrain.	130	100	5	16	Physical	1	10
781	Steel Wing	Has a 10% chance to raise the user's Defense by 1 stage.	70	90	25	16	Physical	1	10
782	Sticky Web	Sets up a hazard on the opposing side of the field, lowering the Speed by 1 stage of each opposing Pokemon that switches in, unless it is a Flying-type Pokemon or has the Levitate Ability. Fails if the effect is already active on the opposing side. Can be removed from the opposing side if any opposing Pokemon uses Mortal Spin, Rapid Spin, or Defog successfully, or is hit by Defog.	0	1	20	12	Status	1	10
783	Stockpile	Raises the user's Defense and Special Defense by 1 stage. The user's Stockpile count increases by 1. Fails if the user's Stockpile count is 3. The user's Stockpile count is reset to 0 when it is no longer active.	0	1	20	1	Status	1	10
784	Stoked Sparksurfer	Has a 100% chance to paralyze the target.	175	1	1	4	Special	1	10
785	Stomp	Has a 30% chance to make the target flinch. Damage doubles and no accuracy check is done if the target has used Minimize while active.	65	100	20	1	Physical	1	10
786	Stomping Tantrum	Power doubles if the user's last move on the previous turn, including moves called by other moves or those used through Instruct, Magic Coat, Snatch, or the Dancer or Magic Bounce Abilities, failed to do any of its normal effects, not including damage from an unsuccessful High Jump Kick, Jump Kick, or Mind Blown, or if the user was prevented from moving by any effect other than recharging or Sky Drop. A move that was blocked by Baneful Bunker, Detect, King's Shield, Protect, Spiky Shield, Crafty Shield, Mat Block, Quick Guard, or Wide Guard will not double this move's power, nor will Bounce or Fly ending early due to the effect of Gravity, Smack Down, or Thousand Arrows.	75	100	10	9	Physical	1	10
787	Stone Axe	If this move is successful, it sets up a hazard on the opposing side of the field, damaging each opposing Pokemon that switches in. Foes lose 1/32, 1/16, 1/8, 1/4, or 1/2 of their maximum HP, rounded down, based on their weakness to the Rock type; 0.25x, 0.5x, neutral, 2x, or 4x, respectively. Can be removed from the opposing side if any opposing Pokemon uses Mortal Spin, Rapid Spin, or Defog successfully, or is hit by Defog.	65	90	15	13	Physical	1	10
788	Stone Edge	Has a higher chance for a critical hit.	100	80	5	13	Physical	1	10
789	Stored Power	Power is equal to 20+(X*20), where X is the user's total stat stage changes that are greater than 0.	20	100	10	11	Special	1	10
790	Storm Throw	This move is always a critical hit unless the target is under the effect of Lucky Chant or has the Battle Armor or Shell Armor Abilities.	60	100	10	7	Physical	1	10
791	Strange Steam	Has a 20% chance to confuse the target.	90	95	10	18	Special	1	10
792	Strength	No additional effect.	80	100	15	1	Physical	1	10
793	Strength Sap	Lowers the target's Attack by 1 stage. The user restores its HP equal to the target's Attack stat calculated with its stat stage before this move was used. If Big Root is held by the user, the HP recovered is 1.3x normal, rounded half down. Fails if the target's Attack stat stage is -6.	0	100	10	5	Status	1	10
794	String Shot	Lowers the target's Speed by 2 stages.	0	95	40	12	Status	1	10
795	Struggle	Deals typeless damage to a random opposing Pokemon. If this move was successful, the user loses 1/4 of its maximum HP, rounded half up, and the Rock Head Ability does not prevent this. This move is automatically used if none of the user's known moves can be selected.	50	1	1	1	Physical	1	10
796	Struggle Bug	Has a 100% chance to lower the target's Special Attack by 1 stage.	50	100	20	12	Special	1	10
797	Stuff Cheeks	This move cannot be selected unless the user is holding a Berry. The user eats its Berry and raises its Defense by 2 stages. This effect is not prevented by the Klutz or Unnerve Abilities, or the effects of Embargo or Magic Room. Fails if the user is not holding a Berry.	0	1	10	1	Status	1	10
798	Stun Spore	Paralyzes the target.	0	75	30	5	Status	1	10
799	Submission	If the target lost HP, the user takes recoil damage equal to 1/4 the HP lost by the target, rounded half up, but not less than 1 HP.	80	80	20	7	Physical	1	10
800	Substitute	The user takes 1/4 of its maximum HP, rounded down, and puts it into a substitute to take its place in battle. The substitute is removed once enough damage is inflicted on it, or if the user switches out or faints. Baton Pass can be used to transfer the substitute to an ally, and the substitute will keep its remaining HP. Until the substitute is broken, it receives damage from all attacks made by other Pokemon and shields the user from status effects and stat stage changes caused by other Pokemon. Sound-based moves and Pokemon with the Infiltrator Ability ignore substitutes. The user still takes normal damage from weather and status effects while behind its substitute. If the substitute breaks during a multi-hit attack, the user will take damage from any remaining hits. If a substitute is created while the user is trapped by a binding move, the binding effect ends immediately. Fails if the user does not have enough HP remaining to create a substitute without fainting, or if it already has a substitute.	0	1	10	1	Status	1	10
801	Subzero Slammer	Power is equal to the base move's Z-Power.	1	1	1	6	Physical	1	10
802	Sucker Punch	Fails if the target did not select a physical attack, special attack, or Me First for use this turn, or if the target moves before the user.	70	100	5	17	Physical	1	10
803	Sunny Day	For 5 turns, the weather becomes Sunny Day. The damage of Fire-type attacks is multiplied by 1.5 and the damage of Water-type attacks is multiplied by 0.5 during the effect. Lasts for 8 turns if the user is holding Heat Rock. Fails if the current weather is Sunny Day.	0	1	5	2	Status	1	10
804	Sunsteel Strike	This move and its effects ignore the Abilities of other Pokemon.	100	100	5	16	Physical	1	10
805	Super Fang	Deals damage to the target equal to half of its current HP, rounded down, but not less than 1 HP.	0	90	10	1	Physical	1	10
806	Superpower	Lowers the user's Attack and Defense by 1 stage.	120	100	5	7	Physical	1	10
807	Supersonic	Causes the target to become confused.	0	55	20	1	Status	1	10
808	Supersonic Skystrike	Power is equal to the base move's Z-Power.	1	1	1	10	Physical	1	10
809	Surf	Damage doubles if the target is using Dive.	90	100	15	3	Special	1	10
810	Surging Strikes	Hits three times. This move is always a critical hit unless the target is under the effect of Lucky Chant or has the Battle Armor or Shell Armor Abilities.	25	100	5	3	Physical	1	10
811	Swagger	Raises the target's Attack by 2 stages and confuses it.	0	85	15	1	Status	1	10
812	Swallow	The user restores its HP based on its Stockpile count. Restores 1/4 of its maximum HP if it's 1, 1/2 of its maximum HP if it's 2, both rounded half down, and all of its HP if it's 3. Fails if the user's Stockpile count is 0. The user's Defense and Special Defense decrease by as many stages as Stockpile had increased them, and the user's Stockpile count resets to 0.	0	1	10	1	Status	1	10
813	Sweet Kiss	Causes the target to become confused.	0	75	10	18	Status	1	10
814	Sweet Scent	Lowers the target's evasiveness by 2 stages.	0	100	20	1	Status	1	10
815	Swift	This move does not check accuracy.	60	1	20	1	Special	1	10
816	Switcheroo	The user swaps its held item with the target's held item. Fails if either the user or the target is holding a Mail or Z-Crystal, if neither is holding an item, if the user is trying to give or take a Mega Stone to or from the species that can Mega Evolve with it, or if the user is trying to give or take a Blue Orb, a Red Orb, a Griseous Orb, a Plate, a Drive, or a Memory to or from a Kyogre, a Groudon, a Giratina, an Arceus, a Genesect, or a Silvally, respectively. The target is immune to this move if it has the Sticky Hold Ability.	0	100	10	17	Status	1	10
817	Swords Dance	Raises the user's Attack by 2 stages.	0	1	20	1	Status	1	10
818	Synchronoise	The target is immune if it does not share a type with the user.	120	100	10	11	Special	1	10
819	Synthesis	The user restores 1/2 of its maximum HP if Delta Stream or no weather conditions are in effect or if the user is holding Utility Umbrella, 2/3 of its maximum HP if the weather is Desolate Land or Sunny Day, and 1/4 of its maximum HP if the weather is Primordial Sea, Rain Dance, Sandstorm, or Snow, all rounded half down.	0	1	5	5	Status	1	10
820	Syrup Bomb	If this move is successful, it causes the target's Speed to be lowered by 1 stage at the end of each turn for 3 turns.	60	85	10	5	Special	1	10
821	Tackle	No additional effect.	40	100	35	1	Physical	1	10
822	Tail Glow	Raises the user's Special Attack by 3 stages.	0	1	20	12	Status	1	10
823	Tail Slap	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times.	25	85	10	1	Physical	1	10
824	Tail Whip	Lowers the target's Defense by 1 stage.	0	100	30	1	Status	1	10
825	Tailwind	For 4 turns, the user and its party members have their Speed doubled. Fails if this move is already in effect for the user's side.	0	1	15	10	Status	1	10
826	Take Down	If the target lost HP, the user takes recoil damage equal to 1/4 the HP lost by the target, rounded half up, but not less than 1 HP.	90	85	20	1	Physical	1	10
827	Take Heart	The user cures its non-volatile status condition. Raises the user's Special Attack and Special Defense by 1 stage.	0	1	15	11	Status	1	10
828	Tar Shot	Lowers the target's Speed by 1 stage. Until the target switches out, the effectiveness of Fire-type moves is doubled against it.	0	100	15	13	Status	1	10
829	Taunt	Prevents the target from using non-damaging moves for its next three turns. Pokemon with the Oblivious Ability or protected by the Aroma Veil Ability are immune.	0	100	20	17	Status	1	10
830	Tearful Look	Lowers the target's Attack and Special Attack by 1 stage.	0	1	20	1	Status	1	10
831	Teatime	All active Pokemon consume their held Berries. This effect is not prevented by substitutes, the Klutz or Unnerve Abilities, or the effects of Embargo or Magic Room. Fails if no active Pokemon is holding a Berry.	0	1	10	1	Status	1	10
832	Techno Blast	This move's type depends on the user's held Drive.	120	100	5	1	Special	1	10
833	Tectonic Rage	Power is equal to the base move's Z-Power.	1	1	1	9	Physical	1	10
834	Teeter Dance	Causes the target to become confused.	0	100	20	1	Status	1	10
835	Telekinesis	For 3 turns, the target cannot avoid any attacks made against it, other than OHKO moves, as long as it remains active. During the effect, the target is immune to Ground-type attacks and the effects of Spikes, Toxic Spikes, Sticky Web, and the Arena Trap Ability as long as it remains active. If the target uses Baton Pass, the replacement will gain the effect. Ingrain, Smack Down, Thousand Arrows, and Iron Ball override this move if the target is under any of their effects. Fails if the target is already under this effect or the effects of Ingrain, Smack Down, or Thousand Arrows. The target is immune to this move on use if its species is Diglett, Dugtrio, Alolan Diglett, Alolan Dugtrio, Sandygast, Palossand, or Gengar while Mega-Evolved. Mega Gengar cannot be under this effect by any means.	0	1	15	11	Status	1	10
836	Teleport	If this move is successful and the user has not fainted, the user switches out even if it is trapped and is replaced immediately by a selected party member. The user does not switch out if there are no unfainted party members.	0	1	20	11	Status	1	10
837	Tera Blast	If the user is Terastallized, this move becomes a physical attack if the user's Attack is greater than its Special Attack, including stat stage changes, and this move's type becomes the same as the user's Tera Type.	80	100	10	1	Special	1	10
838	Terrain Pulse	Power doubles if the user is grounded and a terrain is active, and this move's type changes to match. Electric type during Electric Terrain, Grass type during Grassy Terrain, Fairy type during Misty Terrain, and Psychic type during Psychic Terrain.	50	100	10	1	Special	1	10
839	Thief	If this attack was successful and the user has not fainted, it steals the target's held item if the user is not holding one. The target's item is not stolen if it is a Mail or Z-Crystal, or if the target is a Kyogre holding a Blue Orb, a Groudon holding a Red Orb, a Giratina holding a Griseous Orb, an Arceus holding a Plate, a Genesect holding a Drive, a Silvally holding a Memory, or a Pokemon that can Mega Evolve holding the Mega Stone for its species. Items lost to this move cannot be regained with Recycle or the Harvest Ability.	60	100	25	17	Physical	1	10
840	Thousand Arrows	This move can hit airborne Pokemon, which includes Flying-type Pokemon, Pokemon with the Levitate Ability, Pokemon holding an Air Balloon, and Pokemon under the effect of Magnet Rise or Telekinesis. If the target is a Flying type and is not already grounded, this move deals neutral damage regardless of its other type(s). This move can hit a target using Bounce, Fly, or Sky Drop. If this move hits a target under the effect of Bounce, Fly, Magnet Rise, or Telekinesis, the effect ends. If the target is a Flying type that has not used Roost this turn or a Pokemon with the Levitate Ability, it loses its immunity to Ground-type attacks and the Arena Trap Ability as long as it remains active. During the effect, Magnet Rise fails for the target and Telekinesis fails against the target.	90	100	10	9	Physical	1	10
841	Thousand Waves	Prevents the target from switching out. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Teleport, U-turn, or Volt Switch. If the target leaves the field using Baton Pass, the replacement will remain trapped. The effect ends if the user leaves the field.	90	100	10	9	Physical	1	10
842	Thrash	The user spends two or three turns locked into this move and becomes confused immediately after its move on the last turn of the effect if it is not already. This move targets an opposing Pokemon at random on each turn. If the user is prevented from moving, is asleep at the beginning of a turn, or the attack is not successful against the target on the first turn of the effect or the second turn of a three-turn effect, the effect ends without causing confusion. If this move is called by Sleep Talk and the user is asleep, the move is used for one turn and does not confuse the user.	120	100	10	1	Physical	1	10
843	Throat Chop	For 2 turns, the target cannot use sound-based moves.	80	100	15	17	Physical	1	10
844	Thunder	Has a 30% chance to paralyze the target. This move can hit a target using Bounce, Fly, or Sky Drop, or is under the effect of Sky Drop. If the weather is Primordial Sea or Rain Dance, this move does not check accuracy. If the weather is Desolate Land or Sunny Day, this move's accuracy is 50%. If this move is used against a Pokemon holding Utility Umbrella, this move's accuracy remains at 70%.	110	70	10	4	Special	1	10
845	Thunderbolt	Has a 10% chance to paralyze the target.	90	100	15	4	Special	1	10
846	Thunder Cage	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	80	90	15	4	Special	1	10
847	Thunder Fang	Has a 10% chance to paralyze the target and a 10% chance to make it flinch.	65	95	15	4	Physical	1	10
848	Thunderous Kick	Has a 100% chance to lower the target's Defense by 1 stage.	90	100	10	7	Physical	1	10
849	Thunder Punch	Has a 10% chance to paralyze the target.	75	100	15	4	Physical	1	10
850	Thunder Shock	Has a 10% chance to paralyze the target.	40	100	30	4	Special	1	10
851	Thunder Wave	Paralyzes the target. This move does not ignore type immunity.	0	90	20	4	Status	1	10
852	Tickle	Lowers the target's Attack and Defense by 1 stage.	0	100	20	1	Status	1	10
853	Tidy Up	Raises the user's Attack and Speed by 1 stage. Removes subtitutes from all active Pokemon and ends the effects of Spikes, Stealth Rock, Sticky Web, and Toxic Spikes for both sides.	0	1	10	1	Status	1	10
854	Topsy-Turvy	The target's positive stat stages become negative and vice versa. Fails if all of the target's stat stages are 0.	0	1	20	17	Status	1	10
855	Torch Song	Has a 100% chance to raise the user's Special Attack by 1 stage.	80	100	10	2	Special	1	10
856	Torment	Prevents the target from selecting the same move for use two turns in a row. This effect ends when the target is no longer active.	0	100	15	17	Status	1	10
857	Toxic	Badly poisons the target. If a Poison-type Pokemon uses this move, the target cannot avoid the attack, even if the target is in the middle of a two-turn move.	0	90	10	8	Status	1	10
858	Toxic Spikes	Sets up a hazard on the opposing side of the field, poisoning each opposing Pokemon that switches in, unless it is a Flying-type Pokemon or has the Levitate Ability. Can be used up to two times before failing. Opposing Pokemon become poisoned with one layer and badly poisoned with two layers. Can be removed from the opposing side if any opposing Pokemon uses Mortal Spin, Rapid Spin, or Defog successfully, is hit by Defog, or a grounded Poison-type Pokemon switches in. Safeguard prevents the opposing party from being poisoned on switch-in, but a substitute does not.	0	1	20	8	Status	1	10
859	Toxic Thread	Lowers the target's Speed by 1 stage and poisons it.	0	100	20	8	Status	1	10
860	Trailblaze	Has a 100% chance to raise the user's Speed by 1 stage.	50	100	20	5	Physical	1	10
861	Transform	The user transforms into the target. The target's current stats, stat stages, types, moves, Ability, weight, gender, and sprite are copied. The user's level and HP remain the same and each copied move receives only 5 PP, with a maximum of 5 PP each. The user can no longer change formes if it would have the ability to do so. This move fails if it hits a substitute, if either the user or the target is already transformed, or if either is behind an Illusion.	0	1	10	1	Status	1	10
862	Tri Attack	Has a 20% chance to either burn, freeze, or paralyze the target.	80	100	10	1	Special	1	10
863	Trick	The user swaps its held item with the target's held item. Fails if either the user or the target is holding a Mail or Z-Crystal, if neither is holding an item, if the user is trying to give or take a Mega Stone to or from the species that can Mega Evolve with it, or if the user is trying to give or take a Blue Orb, a Red Orb, a Griseous Orb, a Plate, a Drive, or a Memory to or from a Kyogre, a Groudon, a Giratina, an Arceus, a Genesect, or a Silvally, respectively. The target is immune to this move if it has the Sticky Hold Ability.	0	100	10	11	Status	1	10
864	Trick-or-Treat	Causes the Ghost type to be added to the target, effectively making it have two or three types. Fails if the target is already a Ghost type. If Forest's Curse adds a type to the target, it replaces the type added by this move and vice versa.	0	100	20	14	Status	1	10
865	Trick Room	For 5 turns, the Speed of every Pokemon is recalculated for the purposes of determining turn order. During the effect, each Pokemon's Speed is considered to be (10000 - its normal Speed), and if this value is greater than 8191, 8192 is subtracted from it. If this move is used during the effect, the effect ends.	0	1	5	11	Status	1	10
866	Triple Arrows	Has a 50% chance to lower the target's Defense by 1 stage, a 30% chance to make it flinch, and a higher chance for a critical hit.	90	100	10	7	Physical	1	10
867	Triple Axel	Hits three times. Power increases to 40 for the second hit and 60 for the third. This move checks accuracy for each hit, and the attack ends if the target avoids a hit. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit three times.	20	90	10	6	Physical	1	10
868	Triple Dive	Hits three times.	30	95	10	3	Physical	1	10
869	Triple Kick	Hits three times. Power increases to 20 for the second hit and 30 for the third. This move checks accuracy for each hit, and the attack ends if the target avoids a hit. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit three times.	10	90	10	7	Physical	1	10
870	Trop Kick	Has a 100% chance to lower the target's Attack by 1 stage.	70	100	15	5	Physical	1	10
871	Trump Card	The power of this move is based on the amount of PP remaining after normal PP reduction and the Pressure Ability resolve. 200 power for 0 PP, 80 power for 1 PP, 60 power for 2 PP, 50 power for 3 PP, and 40 power for 4 or more PP.	0	1	5	1	Special	1	10
872	Twin Beam	Hits twice. If the first hit breaks the target's substitute, it will take damage for the second hit.	40	100	10	11	Special	1	10
873	Twineedle	Hits twice, with each hit having a 20% chance to poison the target. If the first hit breaks the target's substitute, it will take damage for the second hit.	25	100	20	12	Physical	1	10
874	Twinkle Tackle	Power is equal to the base move's Z-Power.	1	1	1	18	Physical	1	10
875	Twister	Has a 20% chance to make the target flinch. Power doubles if the target is using Bounce, Fly, or Sky Drop, or is under the effect of Sky Drop.	40	100	20	15	Special	1	10
876	U-turn	If this move is successful and the user has not fainted, the user switches out even if it is trapped and is replaced immediately by a selected party member. The user does not switch out if there are no unfainted party members, or if the target switched out using an Eject Button or through the effect of the Emergency Exit or Wimp Out Abilities.	70	100	20	12	Physical	1	10
877	Uproar	The user spends three turns locked into this move. This move targets an opponent at random on each turn. On the first of the three turns, all sleeping active Pokemon wake up. During the three turns, no active Pokemon can fall asleep by any means, and Pokemon switched in during the effect do not wake up. If the user is prevented from moving or the attack is not successful against the target during one of the turns, the effect ends.	90	100	10	1	Special	1	10
878	Vacuum Wave	No additional effect.	40	100	30	7	Special	1	10
879	V-create	Lowers the user's Speed, Defense, and Special Defense by 1 stage.	180	95	5	2	Physical	1	10
880	Veevee Volley	Power is equal to the greater of (user's Happiness * 2/5), rounded down, or 1.	0	1	20	1	Physical	1	10
881	Venom Drench	Lowers the target's Attack, Special Attack, and Speed by 1 stage if the target is poisoned. Fails if the target is not poisoned.	0	100	20	8	Status	1	10
882	Venoshock	Power doubles if the target is poisoned.	65	100	10	8	Special	1	10
883	Victory Dance	Raises the user's Attack, Defense, and Speed by 1 stage.	0	1	10	7	Status	1	10
884	Vine Whip	No additional effect.	45	100	25	5	Physical	1	10
885	Vise Grip	No additional effect.	55	100	30	1	Physical	1	10
886	Vital Throw	This move does not check accuracy.	70	1	10	7	Physical	1	10
887	Volt Switch	If this move is successful and the user has not fainted, the user switches out even if it is trapped and is replaced immediately by a selected party member. The user does not switch out if there are no unfainted party members, or if the target switched out using an Eject Button or through the effect of the Emergency Exit or Wimp Out Abilities.	70	100	20	4	Special	1	10
888	Volt Tackle	Has a 10% chance to paralyze the target. If the target lost HP, the user takes recoil damage equal to 33% the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	15	4	Physical	1	10
889	Wake-Up Slap	Power doubles if the target is asleep. If the user has not fainted, the target wakes up.	70	100	10	7	Physical	1	10
890	Waterfall	Has a 20% chance to make the target flinch.	80	100	15	3	Physical	1	10
891	Water Gun	No additional effect.	40	100	25	3	Special	1	10
892	Water Pledge	If one of the user's allies chose to use Fire Pledge or Grass Pledge this turn and has not moved yet, it takes its turn immediately after the user and the user's move does nothing. If combined with Fire Pledge, the ally uses Water Pledge with 150 power and a rainbow appears on the user's side for 4 turns, which doubles secondary effect chances and stacks with the Serene Grace Ability, except effects that cause flinching can only have their chance doubled once. If combined with Grass Pledge, the ally uses Grass Pledge with 150 power and a swamp appears on the target's side for 4 turns, which quarters the Speed of each Pokemon on that side. When used as a combined move, this move gains STAB no matter what the user's type is. This move does not consume the user's Water Gem, and cannot be redirected by the Storm Drain Ability.	80	100	10	3	Special	1	10
893	Water Pulse	Has a 20% chance to confuse the target.	60	100	20	3	Special	1	10
894	Water Shuriken	Hits two to five times. Has a 35% chance to hit two or three times and a 15% chance to hit four or five times. If one of the hits breaks the target's substitute, it will take damage for the remaining hits. If the user has the Skill Link Ability, this move will always hit five times. If the user is an Ash-Greninja with the Battle Bond Ability, this move has a power of 20 and always hits three times.	15	100	20	3	Special	1	10
895	Water Sport	For 5 turns, all Fire-type attacks used by any active Pokemon have their power multiplied by 0.33. Fails if this effect is already active.	0	1	15	3	Status	1	10
896	Water Spout	Power is equal to (user's current HP * 150 / user's maximum HP), rounded down, but not less than 1.	150	100	5	3	Special	1	10
897	Wave Crash	If the target lost HP, the user takes recoil damage equal to 33% the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	10	3	Physical	1	10
898	Weather Ball	Power doubles if a weather condition other than Delta Stream is active, and this move's type changes to match. Ice type during Snow, Water type during Primordial Sea or Rain Dance, Rock type during Sandstorm, and Fire type during Desolate Land or Sunny Day. If the user is holding Utility Umbrella and uses Weather Ball during Primordial Sea, Rain Dance, Desolate Land, or Sunny Day, this move remains Normal type and does not double in power.	50	100	10	1	Special	1	10
899	Whirlpool	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	35	85	15	3	Special	1	10
900	Whirlwind	The target is forced to switch out and be replaced with a random unfainted ally. Fails if the target is the last unfainted Pokemon in its party, or if the target used Ingrain previously or has the Suction Cups Ability.	0	1	20	1	Status	1	10
901	Wicked Blow	This move is always a critical hit unless the target is under the effect of Lucky Chant or has the Battle Armor or Shell Armor Abilities.	75	100	5	17	Physical	1	10
902	Wicked Torque	Has a 10% chance to cause the target to fall asleep.	80	100	10	17	Physical	1	10
903	Wide Guard	The user and its party members are protected from moves made by other Pokemon, including allies, during this turn that target all adjacent foes or all adjacent Pokemon. This move modifies the same 1/X chance of being successful used by other protection moves, where X starts at 1 and triples each time this move is successfully used, but does not use the chance to check for failure. X resets to 1 if this move fails, if the user's last move used is not Baneful Bunker, Detect, Endure, King's Shield, Max Guard, Obstruct, Protect, Quick Guard, Silk Trap, Spiky Shield, or Wide Guard, or if it was one of those moves and the user's protection was broken. Fails if the user moves last this turn or if this move is already in effect for the user's side.	0	1	10	13	Status	1	10
904	Wildbolt Storm	Has a 20% chance to paralyze the target. If the weather is Primordial Sea or Rain Dance, this move does not check accuracy. If this move is used against a Pokemon holding Utility Umbrella, this move's accuracy remains at 80%.	100	80	10	4	Special	1	10
905	Wild Charge	If the target lost HP, the user takes recoil damage equal to 1/4 the HP lost by the target, rounded half up, but not less than 1 HP.	90	100	15	4	Physical	1	10
906	Will-O-Wisp	Burns the target.	0	85	15	2	Status	1	10
907	Wing Attack	No additional effect.	60	100	35	10	Physical	1	10
908	Wish	At the end of the next turn, the Pokemon at the user's position has 1/2 of the user's maximum HP restored to it, rounded down. Fails if this move is already in effect for the user's position.	0	1	10	1	Status	1	10
909	Withdraw	Raises the user's Defense by 1 stage.	0	1	40	3	Status	1	10
910	Wonder Room	For 5 turns, all active Pokemon have their Defense and Special Defense stats swapped. Stat stage changes are unaffected. If this move is used during the effect, the effect ends.	0	1	10	11	Status	1	10
911	Wood Hammer	If the target lost HP, the user takes recoil damage equal to 33% the HP lost by the target, rounded half up, but not less than 1 HP.	120	100	15	5	Physical	1	10
912	Work Up	Raises the user's Attack and Special Attack by 1 stage.	0	1	30	1	Status	1	10
913	Worry Seed	Causes the target's Ability to become Insomnia. Fails if the target's Ability is As One, Battle Bond, Comatose, Commander, Disguise, Gulp Missile, Hadron Engine, Ice Face, Insomnia, Multitype, Orichalcum Pulse, Power Construct, Protosynthesis, Quark Drive, RKS System, Schooling, Shields Down, Stance Change, Truant, Zen Mode, or Zero to Hero.	0	100	10	5	Status	1	10
914	Wrap	Prevents the target from switching for four or five turns (seven turns if the user is holding Grip Claw). Causes damage to the target equal to 1/8 of its maximum HP (1/6 if the user is holding Binding Band), rounded down, at the end of each turn during effect. The target can still switch out if it is holding Shed Shell or uses Baton Pass, Flip Turn, Parting Shot, Shed Tail, Teleport, U-turn, or Volt Switch. The effect ends if either the user or the target leaves the field, or if the target uses Mortal Spin, Rapid Spin, or Substitute successfully. This effect is not stackable or reset by using this or another binding move.	15	90	20	1	Physical	1	10
915	Wring Out	Power is equal to 120 * (target's current HP / target's maximum HP), rounded half down, but not less than 1.	0	100	5	1	Special	1	10
916	X-Scissor	No additional effect.	80	100	15	12	Physical	1	10
917	Yawn	Causes the target to fall asleep at the end of the next turn. Fails when used if the target cannot fall asleep or if it already has a non-volatile status condition. At the end of the next turn, if the target is still active, does not have a non-volatile status condition, and can fall asleep, it falls asleep. If the target becomes affected, this effect cannot be prevented by Safeguard or a substitute, or by falling asleep and waking up during the effect.	0	1	10	1	Status	1	10
918	Zap Cannon	Has a 100% chance to paralyze the target.	120	50	5	4	Special	1	10
919	Zen Headbutt	Has a 20% chance to make the target flinch.	80	90	15	11	Physical	1	10
920	Zing Zap	Has a 30% chance to make the target flinch.	80	100	10	4	Physical	1	10
921	Zippy Zap	Has a 100% chance to raise the user's evasion by 1 stage.	80	100	10	4	Physical	1	10
\.


--
-- Data for Name: natures; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.natures (id, name, stat_up, stat_down) FROM stdin;
1	hardy	atk	atk
2	lonely	atk	def
3	brave	atk	spe
4	adamant	atk	spa
5	naughty	atk	spd
6	bold	def	atk
7	docile	def	def
8	relaxed	def	spe
9	impish	def	spa
10	lax	def	spd
11	timid	spe	atk
12	hasty	spe	def
13	serious	spe	spe
14	jolly	spe	spa
15	naive	spe	spd
16	modest	spa	atk
17	mild	spa	def
18	quiet	spa	spe
19	bashful	spa	spa
20	rash	spa	spd
21	calm	spd	atk
22	gentle	spd	def
23	sassy	spd	spe
24	careful	spd	spa
25	quirky	spd	spd
\.


--
-- Data for Name: pokemon; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.pokemon (id, name, base_stats, id_type_1, id_type_2, id_ability_1, id_ability_2, id_hidden_ability, generation) FROM stdin;
1	Bulbasaur	{"hp": 45, "atk": 49, "def": 49, "spa": 65, "spd": 65, "spe": 45}	5	8	1	\N	1	1
2	Ivysaur	{"hp": 60, "atk": 62, "def": 63, "spa": 80, "spd": 80, "spe": 60}	5	8	1	\N	1	1
3	Venusaur	{"hp": 80, "atk": 82, "def": 83, "spa": 100, "spd": 100, "spe": 80}	5	8	1	\N	1	1
4	Venusaur-Mega	{"hp": 80, "atk": 100, "def": 123, "spa": 122, "spd": 120, "spe": 80}	5	8	1	\N	\N	1
5	Venusaur-Gmax	{"hp": 80, "atk": 82, "def": 83, "spa": 100, "spd": 100, "spe": 80}	5	8	1	\N	1	1
6	Charmander	{"hp": 39, "atk": 52, "def": 43, "spa": 60, "spd": 50, "spe": 65}	2	\N	1	\N	1	1
7	Charmeleon	{"hp": 58, "atk": 64, "def": 58, "spa": 80, "spd": 65, "spe": 80}	2	\N	1	\N	1	1
8	Charizard	{"hp": 78, "atk": 84, "def": 78, "spa": 109, "spd": 85, "spe": 100}	2	10	1	\N	1	1
9	Charizard-Mega-X	{"hp": 78, "atk": 130, "def": 111, "spa": 130, "spd": 85, "spe": 100}	2	15	1	\N	\N	1
10	Charizard-Mega-Y	{"hp": 78, "atk": 104, "def": 78, "spa": 159, "spd": 115, "spe": 100}	2	10	1	\N	\N	1
11	Charizard-Gmax	{"hp": 78, "atk": 84, "def": 78, "spa": 109, "spd": 85, "spe": 100}	2	10	1	\N	1	1
12	Squirtle	{"hp": 44, "atk": 48, "def": 65, "spa": 50, "spd": 64, "spe": 43}	3	\N	1	\N	1	1
13	Wartortle	{"hp": 59, "atk": 63, "def": 80, "spa": 65, "spd": 80, "spe": 58}	3	\N	1	\N	1	1
14	Blastoise	{"hp": 79, "atk": 83, "def": 100, "spa": 85, "spd": 105, "spe": 78}	3	\N	1	\N	1	1
15	Blastoise-Mega	{"hp": 79, "atk": 103, "def": 120, "spa": 135, "spd": 115, "spe": 78}	3	\N	1	\N	\N	1
16	Blastoise-Gmax	{"hp": 79, "atk": 83, "def": 100, "spa": 85, "spd": 105, "spe": 78}	3	\N	1	\N	1	1
17	Caterpie	{"hp": 45, "atk": 30, "def": 35, "spa": 20, "spd": 20, "spe": 45}	12	\N	1	\N	1	1
18	Metapod	{"hp": 50, "atk": 20, "def": 55, "spa": 25, "spd": 25, "spe": 30}	12	\N	1	\N	\N	1
19	Butterfree	{"hp": 60, "atk": 45, "def": 50, "spa": 90, "spd": 80, "spe": 70}	12	10	1	\N	1	1
20	Butterfree-Gmax	{"hp": 60, "atk": 45, "def": 50, "spa": 90, "spd": 80, "spe": 70}	12	10	1	\N	1	1
21	Weedle	{"hp": 40, "atk": 35, "def": 30, "spa": 20, "spd": 20, "spe": 50}	12	8	1	\N	1	1
22	Kakuna	{"hp": 45, "atk": 25, "def": 50, "spa": 25, "spd": 25, "spe": 35}	12	8	1	\N	\N	1
23	Beedrill	{"hp": 65, "atk": 90, "def": 40, "spa": 45, "spd": 80, "spe": 75}	12	8	1	\N	1	1
24	Beedrill-Mega	{"hp": 65, "atk": 150, "def": 40, "spa": 15, "spd": 80, "spe": 145}	12	8	1	\N	\N	1
25	Pidgey	{"hp": 40, "atk": 45, "def": 40, "spa": 35, "spd": 35, "spe": 56}	1	10	1	1	1	1
26	Pidgeotto	{"hp": 63, "atk": 60, "def": 55, "spa": 50, "spd": 50, "spe": 71}	1	10	1	1	1	1
27	Pidgeot	{"hp": 83, "atk": 80, "def": 75, "spa": 70, "spd": 70, "spe": 101}	1	10	1	1	1	1
28	Pidgeot-Mega	{"hp": 83, "atk": 80, "def": 80, "spa": 135, "spd": 80, "spe": 121}	1	10	1	\N	\N	1
29	Rattata	{"hp": 30, "atk": 56, "def": 35, "spa": 25, "spd": 35, "spe": 72}	1	\N	1	1	1	1
30	Rattata-Alola	{"hp": 30, "atk": 56, "def": 35, "spa": 25, "spd": 35, "spe": 72}	17	1	1	1	1	1
31	Raticate	{"hp": 55, "atk": 81, "def": 60, "spa": 50, "spd": 70, "spe": 97}	1	\N	1	1	1	1
32	Raticate-Alola	{"hp": 75, "atk": 71, "def": 70, "spa": 40, "spd": 80, "spe": 77}	17	1	1	1	1	1
33	Raticate-Alola-Totem	{"hp": 75, "atk": 71, "def": 70, "spa": 40, "spd": 80, "spe": 77}	17	1	1	\N	\N	1
34	Spearow	{"hp": 40, "atk": 60, "def": 30, "spa": 31, "spd": 31, "spe": 70}	1	10	1	\N	1	1
35	Fearow	{"hp": 65, "atk": 90, "def": 65, "spa": 61, "spd": 61, "spe": 100}	1	10	1	\N	1	1
36	Ekans	{"hp": 35, "atk": 60, "def": 44, "spa": 40, "spd": 54, "spe": 55}	8	\N	1	1	1	1
37	Arbok	{"hp": 60, "atk": 95, "def": 69, "spa": 65, "spd": 79, "spe": 80}	8	\N	1	1	1	1
38	Pikachu	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
39	Pikachu-Cosplay	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	\N	1
40	Pikachu-Rock-Star	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	\N	1
41	Pikachu-Belle	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	\N	1
42	Pikachu-Pop-Star	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	\N	1
43	Pikachu-PhD	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	\N	1
44	Pikachu-Libre	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	\N	1
45	Pikachu-Original	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
46	Pikachu-Hoenn	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
47	Pikachu-Sinnoh	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
48	Pikachu-Unova	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
49	Pikachu-Kalos	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
50	Pikachu-Alola	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
51	Pikachu-Partner	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
52	Pikachu-Starter	{"hp": 45, "atk": 80, "def": 50, "spa": 75, "spd": 60, "spe": 120}	4	\N	1	\N	1	1
53	Pikachu-Gmax	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
54	Pikachu-World	{"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90}	4	\N	1	\N	1	1
55	Raichu	{"hp": 60, "atk": 90, "def": 55, "spa": 90, "spd": 80, "spe": 110}	4	\N	1	\N	1	1
56	Raichu-Alola	{"hp": 60, "atk": 85, "def": 50, "spa": 95, "spd": 85, "spe": 110}	4	11	1	\N	\N	1
57	Sandshrew	{"hp": 50, "atk": 75, "def": 85, "spa": 20, "spd": 30, "spe": 40}	9	\N	1	\N	1	1
58	Sandshrew-Alola	{"hp": 50, "atk": 75, "def": 90, "spa": 10, "spd": 35, "spe": 40}	6	16	1	\N	1	1
59	Sandslash	{"hp": 75, "atk": 100, "def": 110, "spa": 45, "spd": 55, "spe": 65}	9	\N	1	\N	1	1
60	Sandslash-Alola	{"hp": 75, "atk": 100, "def": 120, "spa": 25, "spd": 65, "spe": 65}	6	16	1	\N	1	1
61	Nidoran-F	{"hp": 55, "atk": 47, "def": 52, "spa": 40, "spd": 40, "spe": 41}	8	\N	1	1	1	1
62	Nidorina	{"hp": 70, "atk": 62, "def": 67, "spa": 55, "spd": 55, "spe": 56}	8	\N	1	1	1	1
63	Nidoqueen	{"hp": 90, "atk": 92, "def": 87, "spa": 75, "spd": 85, "spe": 76}	8	9	1	1	1	1
64	Nidoran-M	{"hp": 46, "atk": 57, "def": 40, "spa": 40, "spd": 40, "spe": 50}	8	\N	1	1	1	1
65	Nidorino	{"hp": 61, "atk": 72, "def": 57, "spa": 55, "spd": 55, "spe": 65}	8	\N	1	1	1	1
66	Nidoking	{"hp": 81, "atk": 102, "def": 77, "spa": 85, "spd": 75, "spe": 85}	8	9	1	1	1	1
67	Clefairy	{"hp": 70, "atk": 45, "def": 48, "spa": 60, "spd": 65, "spe": 35}	18	\N	1	1	1	1
68	Clefable	{"hp": 95, "atk": 70, "def": 73, "spa": 95, "spd": 90, "spe": 60}	18	\N	1	1	1	1
69	Vulpix	{"hp": 38, "atk": 41, "def": 40, "spa": 50, "spd": 65, "spe": 65}	2	\N	1	\N	1	1
70	Vulpix-Alola	{"hp": 38, "atk": 41, "def": 40, "spa": 50, "spd": 65, "spe": 65}	6	\N	1	\N	1	1
71	Ninetales	{"hp": 73, "atk": 76, "def": 75, "spa": 81, "spd": 100, "spe": 100}	2	\N	1	\N	1	1
72	Ninetales-Alola	{"hp": 73, "atk": 67, "def": 75, "spa": 81, "spd": 100, "spe": 109}	6	18	1	\N	1	1
73	Jigglypuff	{"hp": 115, "atk": 45, "def": 20, "spa": 45, "spd": 25, "spe": 20}	1	18	1	1	1	1
74	Wigglytuff	{"hp": 140, "atk": 70, "def": 45, "spa": 85, "spd": 50, "spe": 45}	1	18	1	1	1	1
75	Zubat	{"hp": 40, "atk": 45, "def": 35, "spa": 30, "spd": 40, "spe": 55}	8	10	1	\N	1	1
76	Golbat	{"hp": 75, "atk": 80, "def": 70, "spa": 65, "spd": 75, "spe": 90}	8	10	1	\N	1	1
77	Oddish	{"hp": 45, "atk": 50, "def": 55, "spa": 75, "spd": 65, "spe": 30}	5	8	1	\N	1	1
78	Gloom	{"hp": 60, "atk": 65, "def": 70, "spa": 85, "spd": 75, "spe": 40}	5	8	1	\N	1	1
79	Vileplume	{"hp": 75, "atk": 80, "def": 85, "spa": 110, "spd": 90, "spe": 50}	5	8	1	\N	1	1
80	Paras	{"hp": 35, "atk": 70, "def": 55, "spa": 45, "spd": 55, "spe": 25}	12	5	1	1	1	1
81	Parasect	{"hp": 60, "atk": 95, "def": 80, "spa": 60, "spd": 80, "spe": 30}	12	5	1	1	1	1
82	Venonat	{"hp": 60, "atk": 55, "def": 50, "spa": 40, "spd": 55, "spe": 45}	12	8	1	1	1	1
83	Venomoth	{"hp": 70, "atk": 65, "def": 60, "spa": 90, "spd": 75, "spe": 90}	12	8	1	1	1	1
84	Diglett	{"hp": 10, "atk": 55, "def": 25, "spa": 35, "spd": 45, "spe": 95}	9	\N	1	1	1	1
85	Diglett-Alola	{"hp": 10, "atk": 55, "def": 30, "spa": 35, "spd": 45, "spe": 90}	9	16	1	1	1	1
86	Dugtrio	{"hp": 35, "atk": 100, "def": 50, "spa": 50, "spd": 70, "spe": 120}	9	\N	1	1	1	1
87	Dugtrio-Alola	{"hp": 35, "atk": 100, "def": 60, "spa": 50, "spd": 70, "spe": 110}	9	16	1	1	1	1
88	Meowth	{"hp": 40, "atk": 45, "def": 35, "spa": 40, "spd": 40, "spe": 90}	1	\N	1	1	1	1
89	Meowth-Alola	{"hp": 40, "atk": 35, "def": 35, "spa": 50, "spd": 40, "spe": 90}	17	\N	1	1	1	1
90	Meowth-Galar	{"hp": 50, "atk": 65, "def": 55, "spa": 40, "spd": 40, "spe": 40}	16	\N	1	1	1	1
91	Meowth-Gmax	{"hp": 40, "atk": 45, "def": 35, "spa": 40, "spd": 40, "spe": 90}	1	\N	1	1	1	1
92	Persian	{"hp": 65, "atk": 70, "def": 60, "spa": 65, "spd": 65, "spe": 115}	1	\N	1	1	1	1
93	Persian-Alola	{"hp": 65, "atk": 60, "def": 60, "spa": 75, "spd": 65, "spe": 115}	17	\N	1	1	1	1
94	Psyduck	{"hp": 50, "atk": 52, "def": 48, "spa": 65, "spd": 50, "spe": 55}	3	\N	1	1	1	1
95	Golduck	{"hp": 80, "atk": 82, "def": 78, "spa": 95, "spd": 80, "spe": 85}	3	\N	1	1	1	1
96	Mankey	{"hp": 40, "atk": 80, "def": 35, "spa": 35, "spd": 45, "spe": 70}	7	\N	1	1	1	1
97	Primeape	{"hp": 65, "atk": 105, "def": 60, "spa": 60, "spd": 70, "spe": 95}	7	\N	1	1	1	1
98	Growlithe	{"hp": 55, "atk": 70, "def": 45, "spa": 70, "spd": 50, "spe": 60}	2	\N	1	1	1	1
99	Growlithe-Hisui	{"hp": 60, "atk": 75, "def": 45, "spa": 65, "spd": 50, "spe": 55}	2	13	1	1	1	1
100	Arcanine	{"hp": 90, "atk": 110, "def": 80, "spa": 100, "spd": 80, "spe": 95}	2	\N	1	1	1	1
101	Arcanine-Hisui	{"hp": 95, "atk": 115, "def": 80, "spa": 95, "spd": 80, "spe": 90}	2	13	1	1	1	1
102	Poliwag	{"hp": 40, "atk": 50, "def": 40, "spa": 40, "spd": 40, "spe": 90}	3	\N	1	1	1	1
103	Poliwhirl	{"hp": 65, "atk": 65, "def": 65, "spa": 50, "spd": 50, "spe": 90}	3	\N	1	1	1	1
104	Poliwrath	{"hp": 90, "atk": 95, "def": 95, "spa": 70, "spd": 90, "spe": 70}	3	7	1	1	1	1
105	Abra	{"hp": 25, "atk": 20, "def": 15, "spa": 105, "spd": 55, "spe": 90}	11	\N	1	1	1	1
106	Kadabra	{"hp": 40, "atk": 35, "def": 30, "spa": 120, "spd": 70, "spe": 105}	11	\N	1	1	1	1
107	Alakazam	{"hp": 55, "atk": 50, "def": 45, "spa": 135, "spd": 95, "spe": 120}	11	\N	1	1	1	1
108	Alakazam-Mega	{"hp": 55, "atk": 50, "def": 65, "spa": 175, "spd": 105, "spe": 150}	11	\N	1	\N	\N	1
109	Machop	{"hp": 70, "atk": 80, "def": 50, "spa": 35, "spd": 35, "spe": 35}	7	\N	1	1	1	1
110	Machoke	{"hp": 80, "atk": 100, "def": 70, "spa": 50, "spd": 60, "spe": 45}	7	\N	1	1	1	1
111	Machamp	{"hp": 90, "atk": 130, "def": 80, "spa": 65, "spd": 85, "spe": 55}	7	\N	1	1	1	1
112	Machamp-Gmax	{"hp": 90, "atk": 130, "def": 80, "spa": 65, "spd": 85, "spe": 55}	7	\N	1	1	1	1
113	Bellsprout	{"hp": 50, "atk": 75, "def": 35, "spa": 70, "spd": 30, "spe": 40}	5	8	1	\N	1	1
114	Weepinbell	{"hp": 65, "atk": 90, "def": 50, "spa": 85, "spd": 45, "spe": 55}	5	8	1	\N	1	1
115	Victreebel	{"hp": 80, "atk": 105, "def": 65, "spa": 100, "spd": 70, "spe": 70}	5	8	1	\N	1	1
116	Tentacool	{"hp": 40, "atk": 40, "def": 35, "spa": 50, "spd": 100, "spe": 70}	3	8	1	1	1	1
117	Tentacruel	{"hp": 80, "atk": 70, "def": 65, "spa": 80, "spd": 120, "spe": 100}	3	8	1	1	1	1
118	Geodude	{"hp": 40, "atk": 80, "def": 100, "spa": 30, "spd": 30, "spe": 20}	13	9	1	1	1	1
119	Geodude-Alola	{"hp": 40, "atk": 80, "def": 100, "spa": 30, "spd": 30, "spe": 20}	13	4	1	1	1	1
120	Graveler	{"hp": 55, "atk": 95, "def": 115, "spa": 45, "spd": 45, "spe": 35}	13	9	1	1	1	1
121	Graveler-Alola	{"hp": 55, "atk": 95, "def": 115, "spa": 45, "spd": 45, "spe": 35}	13	4	1	1	1	1
122	Golem	{"hp": 80, "atk": 120, "def": 130, "spa": 55, "spd": 65, "spe": 45}	13	9	1	1	1	1
123	Golem-Alola	{"hp": 80, "atk": 120, "def": 130, "spa": 55, "spd": 65, "spe": 45}	13	4	1	1	1	1
124	Ponyta	{"hp": 50, "atk": 85, "def": 55, "spa": 65, "spd": 65, "spe": 90}	2	\N	1	1	1	1
125	Ponyta-Galar	{"hp": 50, "atk": 85, "def": 55, "spa": 65, "spd": 65, "spe": 90}	11	\N	1	1	1	1
126	Rapidash	{"hp": 65, "atk": 100, "def": 70, "spa": 80, "spd": 80, "spe": 105}	2	\N	1	1	1	1
127	Rapidash-Galar	{"hp": 65, "atk": 100, "def": 70, "spa": 80, "spd": 80, "spe": 105}	11	18	1	1	1	1
128	Slowpoke	{"hp": 90, "atk": 65, "def": 65, "spa": 40, "spd": 40, "spe": 15}	3	11	1	1	1	1
129	Slowpoke-Galar	{"hp": 90, "atk": 65, "def": 65, "spa": 40, "spd": 40, "spe": 15}	11	\N	1	1	1	1
130	Slowbro	{"hp": 95, "atk": 75, "def": 110, "spa": 100, "spd": 80, "spe": 30}	3	11	1	1	1	1
131	Slowbro-Mega	{"hp": 95, "atk": 75, "def": 180, "spa": 130, "spd": 80, "spe": 30}	3	11	1	\N	\N	1
132	Slowbro-Galar	{"hp": 95, "atk": 100, "def": 95, "spa": 100, "spd": 70, "spe": 30}	8	11	1	1	1	1
133	Magnemite	{"hp": 25, "atk": 35, "def": 70, "spa": 95, "spd": 55, "spe": 45}	4	16	1	1	1	1
134	Magneton	{"hp": 50, "atk": 60, "def": 95, "spa": 120, "spd": 70, "spe": 70}	4	16	1	1	1	1
135	Farfetch’d	{"hp": 52, "atk": 90, "def": 55, "spa": 58, "spd": 62, "spe": 60}	1	10	1	1	1	1
136	Farfetch’d-Galar	{"hp": 52, "atk": 95, "def": 55, "spa": 58, "spd": 62, "spe": 55}	7	\N	1	\N	1	1
137	Doduo	{"hp": 35, "atk": 85, "def": 45, "spa": 35, "spd": 35, "spe": 75}	1	10	1	1	1	1
138	Dodrio	{"hp": 60, "atk": 110, "def": 70, "spa": 60, "spd": 60, "spe": 110}	1	10	1	1	1	1
139	Seel	{"hp": 65, "atk": 45, "def": 55, "spa": 45, "spd": 70, "spe": 45}	3	\N	1	1	1	1
140	Dewgong	{"hp": 90, "atk": 70, "def": 80, "spa": 70, "spd": 95, "spe": 70}	3	6	1	1	1	1
141	Grimer	{"hp": 80, "atk": 80, "def": 50, "spa": 40, "spd": 50, "spe": 25}	8	\N	1	1	1	1
142	Grimer-Alola	{"hp": 80, "atk": 80, "def": 50, "spa": 40, "spd": 50, "spe": 25}	8	17	1	1	1	1
143	Muk	{"hp": 105, "atk": 105, "def": 75, "spa": 65, "spd": 100, "spe": 50}	8	\N	1	1	1	1
144	Muk-Alola	{"hp": 105, "atk": 105, "def": 75, "spa": 65, "spd": 100, "spe": 50}	8	17	1	1	1	1
145	Shellder	{"hp": 30, "atk": 65, "def": 100, "spa": 45, "spd": 25, "spe": 40}	3	\N	1	1	1	1
146	Cloyster	{"hp": 50, "atk": 95, "def": 180, "spa": 85, "spd": 45, "spe": 70}	3	6	1	1	1	1
147	Gastly	{"hp": 30, "atk": 35, "def": 30, "spa": 100, "spd": 35, "spe": 80}	14	8	1	\N	\N	1
148	Haunter	{"hp": 45, "atk": 50, "def": 45, "spa": 115, "spd": 55, "spe": 95}	14	8	1	\N	\N	1
149	Gengar	{"hp": 60, "atk": 65, "def": 60, "spa": 130, "spd": 75, "spe": 110}	14	8	1	\N	\N	1
150	Gengar-Mega	{"hp": 60, "atk": 65, "def": 80, "spa": 170, "spd": 95, "spe": 130}	14	8	1	\N	\N	1
151	Gengar-Gmax	{"hp": 60, "atk": 65, "def": 60, "spa": 130, "spd": 75, "spe": 110}	14	8	1	\N	\N	1
152	Onix	{"hp": 35, "atk": 45, "def": 160, "spa": 30, "spd": 45, "spe": 70}	13	9	1	1	1	1
153	Drowzee	{"hp": 60, "atk": 48, "def": 45, "spa": 43, "spd": 90, "spe": 42}	11	\N	1	1	1	1
154	Hypno	{"hp": 85, "atk": 73, "def": 70, "spa": 73, "spd": 115, "spe": 67}	11	\N	1	1	1	1
155	Krabby	{"hp": 30, "atk": 105, "def": 90, "spa": 25, "spd": 25, "spe": 50}	3	\N	1	1	1	1
156	Kingler	{"hp": 55, "atk": 130, "def": 115, "spa": 50, "spd": 50, "spe": 75}	3	\N	1	1	1	1
157	Kingler-Gmax	{"hp": 55, "atk": 130, "def": 115, "spa": 50, "spd": 50, "spe": 75}	3	\N	1	1	1	1
158	Voltorb	{"hp": 40, "atk": 30, "def": 50, "spa": 55, "spd": 55, "spe": 100}	4	\N	1	1	1	1
159	Voltorb-Hisui	{"hp": 40, "atk": 30, "def": 50, "spa": 55, "spd": 55, "spe": 100}	4	5	1	1	1	1
160	Electrode	{"hp": 60, "atk": 50, "def": 70, "spa": 80, "spd": 80, "spe": 150}	4	\N	1	1	1	1
161	Electrode-Hisui	{"hp": 60, "atk": 50, "def": 70, "spa": 80, "spd": 80, "spe": 150}	4	5	1	1	1	1
162	Exeggcute	{"hp": 60, "atk": 40, "def": 80, "spa": 60, "spd": 45, "spe": 40}	5	11	1	\N	1	1
163	Exeggutor	{"hp": 95, "atk": 95, "def": 85, "spa": 125, "spd": 75, "spe": 55}	5	11	1	\N	1	1
164	Exeggutor-Alola	{"hp": 95, "atk": 105, "def": 85, "spa": 125, "spd": 75, "spe": 45}	5	15	1	\N	1	1
165	Cubone	{"hp": 50, "atk": 50, "def": 95, "spa": 40, "spd": 50, "spe": 35}	9	\N	1	1	1	1
166	Marowak	{"hp": 60, "atk": 80, "def": 110, "spa": 50, "spd": 80, "spe": 45}	9	\N	1	1	1	1
167	Marowak-Alola	{"hp": 60, "atk": 80, "def": 110, "spa": 50, "spd": 80, "spe": 45}	2	14	1	1	1	1
168	Marowak-Alola-Totem	{"hp": 60, "atk": 80, "def": 110, "spa": 50, "spd": 80, "spe": 45}	2	14	1	\N	\N	1
169	Hitmonlee	{"hp": 50, "atk": 120, "def": 53, "spa": 35, "spd": 110, "spe": 87}	7	\N	1	1	1	1
170	Hitmonchan	{"hp": 50, "atk": 105, "def": 79, "spa": 35, "spd": 110, "spe": 76}	7	\N	1	1	1	1
171	Lickitung	{"hp": 90, "atk": 55, "def": 75, "spa": 60, "spd": 75, "spe": 30}	1	\N	1	1	1	1
172	Koffing	{"hp": 40, "atk": 65, "def": 95, "spa": 60, "spd": 45, "spe": 35}	8	\N	1	1	1	1
173	Weezing	{"hp": 65, "atk": 90, "def": 120, "spa": 85, "spd": 70, "spe": 60}	8	\N	1	1	1	1
174	Weezing-Galar	{"hp": 65, "atk": 90, "def": 120, "spa": 85, "spd": 70, "spe": 60}	8	18	1	1	1	1
175	Rhyhorn	{"hp": 80, "atk": 85, "def": 95, "spa": 30, "spd": 30, "spe": 25}	9	13	1	1	1	1
176	Rhydon	{"hp": 105, "atk": 130, "def": 120, "spa": 45, "spd": 45, "spe": 40}	9	13	1	1	1	1
177	Chansey	{"hp": 250, "atk": 5, "def": 5, "spa": 35, "spd": 105, "spe": 50}	1	\N	1	1	1	1
178	Tangela	{"hp": 65, "atk": 55, "def": 115, "spa": 100, "spd": 40, "spe": 60}	5	\N	1	1	1	1
179	Kangaskhan	{"hp": 105, "atk": 95, "def": 80, "spa": 40, "spd": 80, "spe": 90}	1	\N	1	1	1	1
180	Kangaskhan-Mega	{"hp": 105, "atk": 125, "def": 100, "spa": 60, "spd": 100, "spe": 100}	1	\N	1	\N	\N	1
181	Horsea	{"hp": 30, "atk": 40, "def": 70, "spa": 70, "spd": 25, "spe": 60}	3	\N	1	1	1	1
182	Seadra	{"hp": 55, "atk": 65, "def": 95, "spa": 95, "spd": 45, "spe": 85}	3	\N	1	1	1	1
183	Goldeen	{"hp": 45, "atk": 67, "def": 60, "spa": 35, "spd": 50, "spe": 63}	3	\N	1	1	1	1
184	Seaking	{"hp": 80, "atk": 92, "def": 65, "spa": 65, "spd": 80, "spe": 68}	3	\N	1	1	1	1
185	Staryu	{"hp": 30, "atk": 45, "def": 55, "spa": 70, "spd": 55, "spe": 85}	3	\N	1	1	1	1
186	Starmie	{"hp": 60, "atk": 75, "def": 85, "spa": 100, "spd": 85, "spe": 115}	3	11	1	1	1	1
187	Mr. Mime	{"hp": 40, "atk": 45, "def": 65, "spa": 100, "spd": 120, "spe": 90}	11	18	1	1	1	1
188	Mr. Mime-Galar	{"hp": 50, "atk": 65, "def": 65, "spa": 90, "spd": 90, "spe": 100}	6	11	1	1	1	1
189	Scyther	{"hp": 70, "atk": 110, "def": 80, "spa": 55, "spd": 80, "spe": 105}	12	10	1	1	1	1
190	Jynx	{"hp": 65, "atk": 50, "def": 35, "spa": 115, "spd": 95, "spe": 95}	6	11	1	1	1	1
191	Electabuzz	{"hp": 65, "atk": 83, "def": 57, "spa": 95, "spd": 85, "spe": 105}	4	\N	1	\N	1	1
192	Magmar	{"hp": 65, "atk": 95, "def": 57, "spa": 100, "spd": 85, "spe": 93}	2	\N	1	\N	1	1
193	Pinsir	{"hp": 65, "atk": 125, "def": 100, "spa": 55, "spd": 70, "spe": 85}	12	\N	1	1	1	1
194	Pinsir-Mega	{"hp": 65, "atk": 155, "def": 120, "spa": 65, "spd": 90, "spe": 105}	12	10	1	\N	\N	1
195	Tauros	{"hp": 75, "atk": 100, "def": 95, "spa": 40, "spd": 70, "spe": 110}	1	\N	1	1	1	1
196	Tauros-Paldea-Combat	{"hp": 75, "atk": 110, "def": 105, "spa": 30, "spd": 70, "spe": 100}	7	\N	1	1	1	1
197	Tauros-Paldea-Blaze	{"hp": 75, "atk": 110, "def": 105, "spa": 30, "spd": 70, "spe": 100}	7	2	1	1	1	1
198	Tauros-Paldea-Aqua	{"hp": 75, "atk": 110, "def": 105, "spa": 30, "spd": 70, "spe": 100}	7	3	1	1	1	1
199	Magikarp	{"hp": 20, "atk": 10, "def": 55, "spa": 15, "spd": 20, "spe": 80}	3	\N	1	\N	1	1
200	Gyarados	{"hp": 95, "atk": 125, "def": 79, "spa": 60, "spd": 100, "spe": 81}	3	10	1	\N	1	1
201	Gyarados-Mega	{"hp": 95, "atk": 155, "def": 109, "spa": 70, "spd": 130, "spe": 81}	3	17	1	\N	\N	1
202	Lapras	{"hp": 130, "atk": 85, "def": 80, "spa": 85, "spd": 95, "spe": 60}	3	6	1	1	1	1
203	Lapras-Gmax	{"hp": 130, "atk": 85, "def": 80, "spa": 85, "spd": 95, "spe": 60}	3	6	1	1	1	1
204	Ditto	{"hp": 48, "atk": 48, "def": 48, "spa": 48, "spd": 48, "spe": 48}	1	\N	1	\N	1	1
205	Eevee	{"hp": 55, "atk": 55, "def": 50, "spa": 45, "spd": 65, "spe": 55}	1	\N	1	1	1	1
206	Eevee-Starter	{"hp": 65, "atk": 75, "def": 70, "spa": 65, "spd": 85, "spe": 75}	1	\N	1	1	1	1
207	Eevee-Gmax	{"hp": 55, "atk": 55, "def": 50, "spa": 45, "spd": 65, "spe": 55}	1	\N	1	1	1	1
208	Vaporeon	{"hp": 130, "atk": 65, "def": 60, "spa": 110, "spd": 95, "spe": 65}	3	\N	1	\N	1	1
209	Jolteon	{"hp": 65, "atk": 65, "def": 60, "spa": 110, "spd": 95, "spe": 130}	4	\N	1	\N	1	1
210	Flareon	{"hp": 65, "atk": 130, "def": 60, "spa": 95, "spd": 110, "spe": 65}	2	\N	1	\N	1	1
211	Porygon	{"hp": 65, "atk": 60, "def": 70, "spa": 85, "spd": 75, "spe": 40}	1	\N	1	1	1	1
212	Omanyte	{"hp": 35, "atk": 40, "def": 100, "spa": 90, "spd": 55, "spe": 35}	13	3	1	1	1	1
213	Omastar	{"hp": 70, "atk": 60, "def": 125, "spa": 115, "spd": 70, "spe": 55}	13	3	1	1	1	1
214	Kabuto	{"hp": 30, "atk": 80, "def": 90, "spa": 55, "spd": 45, "spe": 55}	13	3	1	1	1	1
215	Kabutops	{"hp": 60, "atk": 115, "def": 105, "spa": 65, "spd": 70, "spe": 80}	13	3	1	1	1	1
216	Aerodactyl	{"hp": 80, "atk": 105, "def": 65, "spa": 60, "spd": 75, "spe": 130}	13	10	1	1	1	1
217	Aerodactyl-Mega	{"hp": 80, "atk": 135, "def": 85, "spa": 70, "spd": 95, "spe": 150}	13	10	1	\N	\N	1
218	Snorlax	{"hp": 160, "atk": 110, "def": 65, "spa": 65, "spd": 110, "spe": 30}	1	\N	1	1	1	1
219	Snorlax-Gmax	{"hp": 160, "atk": 110, "def": 65, "spa": 65, "spd": 110, "spe": 30}	1	\N	1	1	1	1
220	Articuno	{"hp": 90, "atk": 85, "def": 100, "spa": 95, "spd": 125, "spe": 85}	6	10	1	\N	1	1
221	Articuno-Galar	{"hp": 90, "atk": 85, "def": 85, "spa": 125, "spd": 100, "spe": 95}	11	10	1	\N	\N	1
222	Zapdos	{"hp": 90, "atk": 90, "def": 85, "spa": 125, "spd": 90, "spe": 100}	4	10	1	\N	1	1
223	Zapdos-Galar	{"hp": 90, "atk": 125, "def": 90, "spa": 85, "spd": 90, "spe": 100}	7	10	1	\N	\N	1
224	Moltres	{"hp": 90, "atk": 100, "def": 90, "spa": 125, "spd": 85, "spe": 90}	2	10	1	\N	1	1
225	Moltres-Galar	{"hp": 90, "atk": 85, "def": 90, "spa": 100, "spd": 125, "spe": 90}	17	10	1	\N	\N	1
226	Dratini	{"hp": 41, "atk": 64, "def": 45, "spa": 50, "spd": 50, "spe": 50}	15	\N	1	\N	1	1
227	Dragonair	{"hp": 61, "atk": 84, "def": 65, "spa": 70, "spd": 70, "spe": 70}	15	\N	1	\N	1	1
228	Dragonite	{"hp": 91, "atk": 134, "def": 95, "spa": 100, "spd": 100, "spe": 80}	15	10	1	\N	1	1
229	Mewtwo	{"hp": 106, "atk": 110, "def": 90, "spa": 154, "spd": 90, "spe": 130}	11	\N	1	\N	1	1
230	Mewtwo-Mega-X	{"hp": 106, "atk": 190, "def": 100, "spa": 154, "spd": 100, "spe": 130}	11	7	1	\N	\N	1
231	Mewtwo-Mega-Y	{"hp": 106, "atk": 150, "def": 70, "spa": 194, "spd": 120, "spe": 140}	11	\N	1	\N	\N	1
232	Mew	{"hp": 100, "atk": 100, "def": 100, "spa": 100, "spd": 100, "spe": 100}	11	\N	1	\N	\N	1
233	Chikorita	{"hp": 45, "atk": 49, "def": 65, "spa": 49, "spd": 65, "spe": 45}	5	\N	1	\N	1	2
234	Bayleef	{"hp": 60, "atk": 62, "def": 80, "spa": 63, "spd": 80, "spe": 60}	5	\N	1	\N	1	2
235	Meganium	{"hp": 80, "atk": 82, "def": 100, "spa": 83, "spd": 100, "spe": 80}	5	\N	1	\N	1	2
236	Cyndaquil	{"hp": 39, "atk": 52, "def": 43, "spa": 60, "spd": 50, "spe": 65}	2	\N	1	\N	1	2
237	Quilava	{"hp": 58, "atk": 64, "def": 58, "spa": 80, "spd": 65, "spe": 80}	2	\N	1	\N	1	2
238	Typhlosion	{"hp": 78, "atk": 84, "def": 78, "spa": 109, "spd": 85, "spe": 100}	2	\N	1	\N	1	2
239	Typhlosion-Hisui	{"hp": 73, "atk": 84, "def": 78, "spa": 119, "spd": 85, "spe": 95}	2	14	1	\N	1	2
240	Totodile	{"hp": 50, "atk": 65, "def": 64, "spa": 44, "spd": 48, "spe": 43}	3	\N	1	\N	1	2
241	Croconaw	{"hp": 65, "atk": 80, "def": 80, "spa": 59, "spd": 63, "spe": 58}	3	\N	1	\N	1	2
242	Feraligatr	{"hp": 85, "atk": 105, "def": 100, "spa": 79, "spd": 83, "spe": 78}	3	\N	1	\N	1	2
243	Sentret	{"hp": 35, "atk": 46, "def": 34, "spa": 35, "spd": 45, "spe": 20}	1	\N	1	1	1	2
244	Furret	{"hp": 85, "atk": 76, "def": 64, "spa": 45, "spd": 55, "spe": 90}	1	\N	1	1	1	2
245	Hoothoot	{"hp": 60, "atk": 30, "def": 30, "spa": 36, "spd": 56, "spe": 50}	1	10	1	1	1	2
246	Noctowl	{"hp": 100, "atk": 50, "def": 50, "spa": 86, "spd": 96, "spe": 70}	1	10	1	1	1	2
247	Ledyba	{"hp": 40, "atk": 20, "def": 30, "spa": 40, "spd": 80, "spe": 55}	12	10	1	1	1	2
248	Ledian	{"hp": 55, "atk": 35, "def": 50, "spa": 55, "spd": 110, "spe": 85}	12	10	1	1	1	2
249	Spinarak	{"hp": 40, "atk": 60, "def": 40, "spa": 40, "spd": 40, "spe": 30}	12	8	1	1	1	2
250	Ariados	{"hp": 70, "atk": 90, "def": 70, "spa": 60, "spd": 70, "spe": 40}	12	8	1	1	1	2
251	Crobat	{"hp": 85, "atk": 90, "def": 80, "spa": 70, "spd": 80, "spe": 130}	8	10	1	\N	1	2
252	Chinchou	{"hp": 75, "atk": 38, "def": 38, "spa": 56, "spd": 56, "spe": 67}	3	4	1	1	1	2
253	Lanturn	{"hp": 125, "atk": 58, "def": 58, "spa": 76, "spd": 76, "spe": 67}	3	4	1	1	1	2
254	Pichu	{"hp": 20, "atk": 40, "def": 15, "spa": 35, "spd": 35, "spe": 60}	4	\N	1	\N	1	2
255	Pichu-Spiky-eared	{"hp": 20, "atk": 40, "def": 15, "spa": 35, "spd": 35, "spe": 60}	4	\N	1	\N	\N	2
256	Cleffa	{"hp": 50, "atk": 25, "def": 28, "spa": 45, "spd": 55, "spe": 15}	18	\N	1	1	1	2
257	Igglybuff	{"hp": 90, "atk": 30, "def": 15, "spa": 40, "spd": 20, "spe": 15}	1	18	1	1	1	2
258	Togepi	{"hp": 35, "atk": 20, "def": 65, "spa": 40, "spd": 65, "spe": 20}	18	\N	1	1	1	2
259	Togetic	{"hp": 55, "atk": 40, "def": 85, "spa": 80, "spd": 105, "spe": 40}	18	10	1	1	1	2
260	Natu	{"hp": 40, "atk": 50, "def": 45, "spa": 70, "spd": 45, "spe": 70}	11	10	1	1	1	2
261	Xatu	{"hp": 65, "atk": 75, "def": 70, "spa": 95, "spd": 70, "spe": 95}	11	10	1	1	1	2
262	Mareep	{"hp": 55, "atk": 40, "def": 40, "spa": 65, "spd": 45, "spe": 35}	4	\N	1	\N	1	2
263	Flaaffy	{"hp": 70, "atk": 55, "def": 55, "spa": 80, "spd": 60, "spe": 45}	4	\N	1	\N	1	2
264	Ampharos	{"hp": 90, "atk": 75, "def": 85, "spa": 115, "spd": 90, "spe": 55}	4	\N	1	\N	1	2
265	Ampharos-Mega	{"hp": 90, "atk": 95, "def": 105, "spa": 165, "spd": 110, "spe": 45}	4	15	1	\N	\N	2
266	Bellossom	{"hp": 75, "atk": 80, "def": 95, "spa": 90, "spd": 100, "spe": 50}	5	\N	1	\N	1	2
267	Marill	{"hp": 70, "atk": 20, "def": 50, "spa": 20, "spd": 50, "spe": 40}	3	18	1	1	1	2
268	Azumarill	{"hp": 100, "atk": 50, "def": 80, "spa": 60, "spd": 80, "spe": 50}	3	18	1	1	1	2
269	Sudowoodo	{"hp": 70, "atk": 100, "def": 115, "spa": 30, "spd": 65, "spe": 30}	13	\N	1	1	1	2
270	Politoed	{"hp": 90, "atk": 75, "def": 75, "spa": 90, "spd": 100, "spe": 70}	3	\N	1	1	1	2
271	Hoppip	{"hp": 35, "atk": 35, "def": 40, "spa": 35, "spd": 55, "spe": 50}	5	10	1	1	1	2
272	Skiploom	{"hp": 55, "atk": 45, "def": 50, "spa": 45, "spd": 65, "spe": 80}	5	10	1	1	1	2
273	Jumpluff	{"hp": 75, "atk": 55, "def": 70, "spa": 55, "spd": 95, "spe": 110}	5	10	1	1	1	2
274	Aipom	{"hp": 55, "atk": 70, "def": 55, "spa": 40, "spd": 55, "spe": 85}	1	\N	1	1	1	2
275	Sunkern	{"hp": 30, "atk": 30, "def": 30, "spa": 30, "spd": 30, "spe": 30}	5	\N	1	1	1	2
276	Sunflora	{"hp": 75, "atk": 75, "def": 55, "spa": 105, "spd": 85, "spe": 30}	5	\N	1	1	1	2
277	Yanma	{"hp": 65, "atk": 65, "def": 45, "spa": 75, "spd": 45, "spe": 95}	12	10	1	1	1	2
278	Wooper	{"hp": 55, "atk": 45, "def": 45, "spa": 25, "spd": 25, "spe": 15}	3	9	1	1	1	2
279	Wooper-Paldea	{"hp": 55, "atk": 45, "def": 45, "spa": 25, "spd": 25, "spe": 15}	8	9	1	1	1	2
280	Quagsire	{"hp": 95, "atk": 85, "def": 85, "spa": 65, "spd": 65, "spe": 35}	3	9	1	1	1	2
281	Espeon	{"hp": 65, "atk": 65, "def": 60, "spa": 130, "spd": 95, "spe": 110}	11	\N	1	\N	1	2
282	Umbreon	{"hp": 95, "atk": 65, "def": 110, "spa": 60, "spd": 130, "spe": 65}	17	\N	1	\N	1	2
283	Murkrow	{"hp": 60, "atk": 85, "def": 42, "spa": 85, "spd": 42, "spe": 91}	17	10	1	1	1	2
284	Slowking	{"hp": 95, "atk": 75, "def": 80, "spa": 100, "spd": 110, "spe": 30}	3	11	1	1	1	2
285	Slowking-Galar	{"hp": 95, "atk": 65, "def": 80, "spa": 110, "spd": 110, "spe": 30}	8	11	1	1	1	2
286	Misdreavus	{"hp": 60, "atk": 60, "def": 60, "spa": 85, "spd": 85, "spe": 85}	14	\N	1	\N	\N	2
287	Unown	{"hp": 48, "atk": 72, "def": 48, "spa": 72, "spd": 48, "spe": 48}	11	\N	1	\N	\N	2
288	Wobbuffet	{"hp": 190, "atk": 33, "def": 58, "spa": 33, "spd": 58, "spe": 33}	11	\N	1	\N	1	2
289	Girafarig	{"hp": 70, "atk": 80, "def": 65, "spa": 90, "spd": 65, "spe": 85}	1	11	1	1	1	2
290	Pineco	{"hp": 50, "atk": 65, "def": 90, "spa": 35, "spd": 35, "spe": 15}	12	\N	1	\N	1	2
291	Forretress	{"hp": 75, "atk": 90, "def": 140, "spa": 60, "spd": 60, "spe": 40}	12	16	1	\N	1	2
292	Dunsparce	{"hp": 100, "atk": 70, "def": 70, "spa": 65, "spd": 65, "spe": 45}	1	\N	1	1	1	2
293	Gligar	{"hp": 65, "atk": 75, "def": 105, "spa": 35, "spd": 65, "spe": 85}	9	10	1	1	1	2
294	Steelix	{"hp": 75, "atk": 85, "def": 200, "spa": 55, "spd": 65, "spe": 30}	16	9	1	1	1	2
295	Steelix-Mega	{"hp": 75, "atk": 125, "def": 230, "spa": 55, "spd": 95, "spe": 30}	16	9	1	\N	\N	2
296	Snubbull	{"hp": 60, "atk": 80, "def": 50, "spa": 40, "spd": 40, "spe": 30}	18	\N	1	1	1	2
297	Granbull	{"hp": 90, "atk": 120, "def": 75, "spa": 60, "spd": 60, "spe": 45}	18	\N	1	1	1	2
298	Qwilfish	{"hp": 65, "atk": 95, "def": 85, "spa": 55, "spd": 55, "spe": 85}	3	8	1	1	1	2
299	Qwilfish-Hisui	{"hp": 65, "atk": 95, "def": 85, "spa": 55, "spd": 55, "spe": 85}	17	8	1	1	1	2
300	Scizor	{"hp": 70, "atk": 130, "def": 100, "spa": 55, "spd": 80, "spe": 65}	12	16	1	1	1	2
301	Scizor-Mega	{"hp": 70, "atk": 150, "def": 140, "spa": 65, "spd": 100, "spe": 75}	12	16	1	\N	\N	2
302	Shuckle	{"hp": 20, "atk": 10, "def": 230, "spa": 10, "spd": 230, "spe": 5}	12	13	1	1	1	2
303	Heracross	{"hp": 80, "atk": 125, "def": 75, "spa": 40, "spd": 95, "spe": 85}	12	7	1	1	1	2
304	Heracross-Mega	{"hp": 80, "atk": 185, "def": 115, "spa": 40, "spd": 105, "spe": 75}	12	7	1	\N	\N	2
305	Sneasel	{"hp": 55, "atk": 95, "def": 55, "spa": 35, "spd": 75, "spe": 115}	17	6	1	1	1	2
306	Sneasel-Hisui	{"hp": 55, "atk": 95, "def": 55, "spa": 35, "spd": 75, "spe": 115}	7	8	1	1	1	2
307	Teddiursa	{"hp": 60, "atk": 80, "def": 50, "spa": 50, "spd": 50, "spe": 40}	1	\N	1	1	1	2
308	Ursaring	{"hp": 90, "atk": 130, "def": 75, "spa": 75, "spd": 75, "spe": 55}	1	\N	1	1	1	2
309	Slugma	{"hp": 40, "atk": 40, "def": 40, "spa": 70, "spd": 40, "spe": 20}	2	\N	1	1	1	2
310	Magcargo	{"hp": 60, "atk": 50, "def": 120, "spa": 90, "spd": 80, "spe": 30}	2	13	1	1	1	2
311	Swinub	{"hp": 50, "atk": 50, "def": 40, "spa": 30, "spd": 30, "spe": 50}	6	9	1	1	1	2
312	Piloswine	{"hp": 100, "atk": 100, "def": 80, "spa": 60, "spd": 60, "spe": 50}	6	9	1	1	1	2
313	Corsola	{"hp": 65, "atk": 55, "def": 95, "spa": 65, "spd": 95, "spe": 35}	3	13	1	1	1	2
314	Corsola-Galar	{"hp": 60, "atk": 55, "def": 100, "spa": 65, "spd": 100, "spe": 30}	14	\N	1	\N	1	2
315	Remoraid	{"hp": 35, "atk": 65, "def": 35, "spa": 65, "spd": 35, "spe": 65}	3	\N	1	1	1	2
316	Octillery	{"hp": 75, "atk": 105, "def": 75, "spa": 105, "spd": 75, "spe": 45}	3	\N	1	1	1	2
317	Delibird	{"hp": 45, "atk": 55, "def": 45, "spa": 65, "spd": 45, "spe": 75}	6	10	1	1	1	2
318	Mantine	{"hp": 85, "atk": 40, "def": 70, "spa": 80, "spd": 140, "spe": 70}	3	10	1	1	1	2
319	Skarmory	{"hp": 65, "atk": 80, "def": 140, "spa": 40, "spd": 70, "spe": 70}	16	10	1	1	1	2
320	Houndour	{"hp": 45, "atk": 60, "def": 30, "spa": 80, "spd": 50, "spe": 65}	17	2	1	1	1	2
321	Houndoom	{"hp": 75, "atk": 90, "def": 50, "spa": 110, "spd": 80, "spe": 95}	17	2	1	1	1	2
322	Houndoom-Mega	{"hp": 75, "atk": 90, "def": 90, "spa": 140, "spd": 90, "spe": 115}	17	2	1	\N	\N	2
323	Kingdra	{"hp": 75, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 85}	3	15	1	1	1	2
324	Phanpy	{"hp": 90, "atk": 60, "def": 60, "spa": 40, "spd": 40, "spe": 40}	9	\N	1	\N	1	2
325	Donphan	{"hp": 90, "atk": 120, "def": 120, "spa": 60, "spd": 60, "spe": 50}	9	\N	1	\N	1	2
326	Porygon2	{"hp": 85, "atk": 80, "def": 90, "spa": 105, "spd": 95, "spe": 60}	1	\N	1	1	1	2
327	Stantler	{"hp": 73, "atk": 95, "def": 62, "spa": 85, "spd": 65, "spe": 85}	1	\N	1	1	1	2
328	Smeargle	{"hp": 55, "atk": 20, "def": 35, "spa": 20, "spd": 45, "spe": 75}	1	\N	1	1	1	2
329	Tyrogue	{"hp": 35, "atk": 35, "def": 35, "spa": 35, "spd": 35, "spe": 35}	7	\N	1	1	1	2
330	Hitmontop	{"hp": 50, "atk": 95, "def": 95, "spa": 35, "spd": 110, "spe": 70}	7	\N	1	1	1	2
331	Smoochum	{"hp": 45, "atk": 30, "def": 15, "spa": 85, "spd": 65, "spe": 65}	6	11	1	1	1	2
332	Elekid	{"hp": 45, "atk": 63, "def": 37, "spa": 65, "spd": 55, "spe": 95}	4	\N	1	\N	1	2
333	Magby	{"hp": 45, "atk": 75, "def": 37, "spa": 70, "spd": 55, "spe": 83}	2	\N	1	\N	1	2
334	Miltank	{"hp": 95, "atk": 80, "def": 105, "spa": 40, "spd": 70, "spe": 100}	1	\N	1	1	1	2
335	Blissey	{"hp": 255, "atk": 10, "def": 10, "spa": 75, "spd": 135, "spe": 55}	1	\N	1	1	1	2
336	Raikou	{"hp": 90, "atk": 85, "def": 75, "spa": 115, "spd": 100, "spe": 115}	4	\N	1	\N	1	2
337	Entei	{"hp": 115, "atk": 115, "def": 85, "spa": 90, "spd": 75, "spe": 100}	2	\N	1	\N	1	2
338	Suicune	{"hp": 100, "atk": 75, "def": 115, "spa": 90, "spd": 115, "spe": 85}	3	\N	1	\N	1	2
339	Larvitar	{"hp": 50, "atk": 64, "def": 50, "spa": 45, "spd": 50, "spe": 41}	13	9	1	\N	1	2
340	Pupitar	{"hp": 70, "atk": 84, "def": 70, "spa": 65, "spd": 70, "spe": 51}	13	9	1	\N	\N	2
341	Tyranitar	{"hp": 100, "atk": 134, "def": 110, "spa": 95, "spd": 100, "spe": 61}	13	17	1	\N	1	2
342	Tyranitar-Mega	{"hp": 100, "atk": 164, "def": 150, "spa": 95, "spd": 120, "spe": 71}	13	17	1	\N	\N	2
343	Lugia	{"hp": 106, "atk": 90, "def": 130, "spa": 90, "spd": 154, "spe": 110}	11	10	1	\N	1	2
344	Ho-Oh	{"hp": 106, "atk": 130, "def": 90, "spa": 110, "spd": 154, "spe": 90}	2	10	1	\N	1	2
345	Celebi	{"hp": 100, "atk": 100, "def": 100, "spa": 100, "spd": 100, "spe": 100}	11	5	1	\N	\N	2
346	Treecko	{"hp": 40, "atk": 45, "def": 35, "spa": 65, "spd": 55, "spe": 70}	5	\N	1	\N	1	3
347	Grovyle	{"hp": 50, "atk": 65, "def": 45, "spa": 85, "spd": 65, "spe": 95}	5	\N	1	\N	1	3
348	Sceptile	{"hp": 70, "atk": 85, "def": 65, "spa": 105, "spd": 85, "spe": 120}	5	\N	1	\N	1	3
349	Sceptile-Mega	{"hp": 70, "atk": 110, "def": 75, "spa": 145, "spd": 85, "spe": 145}	5	15	1	\N	\N	3
350	Torchic	{"hp": 45, "atk": 60, "def": 40, "spa": 70, "spd": 50, "spe": 45}	2	\N	1	\N	1	3
351	Combusken	{"hp": 60, "atk": 85, "def": 60, "spa": 85, "spd": 60, "spe": 55}	2	7	1	\N	1	3
352	Blaziken	{"hp": 80, "atk": 120, "def": 70, "spa": 110, "spd": 70, "spe": 80}	2	7	1	\N	1	3
353	Blaziken-Mega	{"hp": 80, "atk": 160, "def": 80, "spa": 130, "spd": 80, "spe": 100}	2	7	1	\N	\N	3
354	Mudkip	{"hp": 50, "atk": 70, "def": 50, "spa": 50, "spd": 50, "spe": 40}	3	\N	1	\N	1	3
355	Marshtomp	{"hp": 70, "atk": 85, "def": 70, "spa": 60, "spd": 70, "spe": 50}	3	9	1	\N	1	3
356	Swampert	{"hp": 100, "atk": 110, "def": 90, "spa": 85, "spd": 90, "spe": 60}	3	9	1	\N	1	3
357	Swampert-Mega	{"hp": 100, "atk": 150, "def": 110, "spa": 95, "spd": 110, "spe": 70}	3	9	1	\N	\N	3
358	Poochyena	{"hp": 35, "atk": 55, "def": 35, "spa": 30, "spd": 30, "spe": 35}	17	\N	1	1	1	3
359	Mightyena	{"hp": 70, "atk": 90, "def": 70, "spa": 60, "spd": 60, "spe": 70}	17	\N	1	1	1	3
360	Zigzagoon	{"hp": 38, "atk": 30, "def": 41, "spa": 30, "spd": 41, "spe": 60}	1	\N	1	1	1	3
361	Zigzagoon-Galar	{"hp": 38, "atk": 30, "def": 41, "spa": 30, "spd": 41, "spe": 60}	17	1	1	1	1	3
362	Linoone	{"hp": 78, "atk": 70, "def": 61, "spa": 50, "spd": 61, "spe": 100}	1	\N	1	1	1	3
363	Linoone-Galar	{"hp": 78, "atk": 70, "def": 61, "spa": 50, "spd": 61, "spe": 100}	17	1	1	1	1	3
364	Wurmple	{"hp": 45, "atk": 45, "def": 35, "spa": 20, "spd": 30, "spe": 20}	12	\N	1	\N	1	3
365	Silcoon	{"hp": 50, "atk": 35, "def": 55, "spa": 25, "spd": 25, "spe": 15}	12	\N	1	\N	\N	3
366	Beautifly	{"hp": 60, "atk": 70, "def": 50, "spa": 100, "spd": 50, "spe": 65}	12	10	1	\N	1	3
367	Cascoon	{"hp": 50, "atk": 35, "def": 55, "spa": 25, "spd": 25, "spe": 15}	12	\N	1	\N	\N	3
368	Dustox	{"hp": 60, "atk": 50, "def": 70, "spa": 50, "spd": 90, "spe": 65}	12	8	1	\N	1	3
369	Lotad	{"hp": 40, "atk": 30, "def": 30, "spa": 40, "spd": 50, "spe": 30}	3	5	1	1	1	3
370	Lombre	{"hp": 60, "atk": 50, "def": 50, "spa": 60, "spd": 70, "spe": 50}	3	5	1	1	1	3
371	Ludicolo	{"hp": 80, "atk": 70, "def": 70, "spa": 90, "spd": 100, "spe": 70}	3	5	1	1	1	3
372	Seedot	{"hp": 40, "atk": 40, "def": 50, "spa": 30, "spd": 30, "spe": 30}	5	\N	1	1	1	3
373	Nuzleaf	{"hp": 70, "atk": 70, "def": 40, "spa": 60, "spd": 40, "spe": 60}	5	17	1	1	1	3
374	Shiftry	{"hp": 90, "atk": 100, "def": 60, "spa": 90, "spd": 60, "spe": 80}	5	17	1	1	1	3
375	Taillow	{"hp": 40, "atk": 55, "def": 30, "spa": 30, "spd": 30, "spe": 85}	1	10	1	\N	1	3
376	Swellow	{"hp": 60, "atk": 85, "def": 60, "spa": 75, "spd": 50, "spe": 125}	1	10	1	\N	1	3
377	Wingull	{"hp": 40, "atk": 30, "def": 30, "spa": 55, "spd": 30, "spe": 85}	3	10	1	1	1	3
378	Pelipper	{"hp": 60, "atk": 50, "def": 100, "spa": 95, "spd": 70, "spe": 65}	3	10	1	1	1	3
379	Ralts	{"hp": 28, "atk": 25, "def": 25, "spa": 45, "spd": 35, "spe": 40}	11	18	1	1	1	3
380	Kirlia	{"hp": 38, "atk": 35, "def": 35, "spa": 65, "spd": 55, "spe": 50}	11	18	1	1	1	3
381	Gardevoir	{"hp": 68, "atk": 65, "def": 65, "spa": 125, "spd": 115, "spe": 80}	11	18	1	1	1	3
382	Gardevoir-Mega	{"hp": 68, "atk": 85, "def": 65, "spa": 165, "spd": 135, "spe": 100}	11	18	1	\N	\N	3
383	Surskit	{"hp": 40, "atk": 30, "def": 32, "spa": 50, "spd": 52, "spe": 65}	12	3	1	\N	1	3
384	Masquerain	{"hp": 70, "atk": 60, "def": 62, "spa": 100, "spd": 82, "spe": 80}	12	10	1	\N	1	3
385	Shroomish	{"hp": 60, "atk": 40, "def": 60, "spa": 40, "spd": 60, "spe": 35}	5	\N	1	1	1	3
386	Breloom	{"hp": 60, "atk": 130, "def": 80, "spa": 60, "spd": 60, "spe": 70}	5	7	1	1	1	3
387	Slakoth	{"hp": 60, "atk": 60, "def": 60, "spa": 35, "spd": 35, "spe": 30}	1	\N	1	\N	\N	3
388	Vigoroth	{"hp": 80, "atk": 80, "def": 80, "spa": 55, "spd": 55, "spe": 90}	1	\N	1	\N	\N	3
389	Slaking	{"hp": 150, "atk": 160, "def": 100, "spa": 95, "spd": 65, "spe": 100}	1	\N	1	\N	\N	3
390	Nincada	{"hp": 31, "atk": 45, "def": 90, "spa": 30, "spd": 30, "spe": 40}	12	9	1	\N	1	3
391	Ninjask	{"hp": 61, "atk": 90, "def": 45, "spa": 50, "spd": 50, "spe": 160}	12	10	1	\N	1	3
392	Shedinja	{"hp": 1, "atk": 90, "def": 45, "spa": 30, "spd": 30, "spe": 40}	12	14	1	\N	\N	3
393	Whismur	{"hp": 64, "atk": 51, "def": 23, "spa": 51, "spd": 23, "spe": 28}	1	\N	1	\N	1	3
394	Loudred	{"hp": 84, "atk": 71, "def": 43, "spa": 71, "spd": 43, "spe": 48}	1	\N	1	\N	1	3
395	Exploud	{"hp": 104, "atk": 91, "def": 63, "spa": 91, "spd": 73, "spe": 68}	1	\N	1	\N	1	3
396	Makuhita	{"hp": 72, "atk": 60, "def": 30, "spa": 20, "spd": 30, "spe": 25}	7	\N	1	1	1	3
397	Hariyama	{"hp": 144, "atk": 120, "def": 60, "spa": 40, "spd": 60, "spe": 50}	7	\N	1	1	1	3
398	Azurill	{"hp": 50, "atk": 20, "def": 40, "spa": 20, "spd": 40, "spe": 20}	1	18	1	1	1	3
399	Nosepass	{"hp": 30, "atk": 45, "def": 135, "spa": 45, "spd": 90, "spe": 30}	13	\N	1	1	1	3
400	Skitty	{"hp": 50, "atk": 45, "def": 45, "spa": 35, "spd": 35, "spe": 50}	1	\N	1	1	1	3
401	Delcatty	{"hp": 70, "atk": 65, "def": 65, "spa": 55, "spd": 55, "spe": 90}	1	\N	1	1	1	3
402	Sableye	{"hp": 50, "atk": 75, "def": 75, "spa": 65, "spd": 65, "spe": 50}	17	14	1	1	1	3
403	Sableye-Mega	{"hp": 50, "atk": 85, "def": 125, "spa": 85, "spd": 115, "spe": 20}	17	14	1	\N	\N	3
404	Mawile	{"hp": 50, "atk": 85, "def": 85, "spa": 55, "spd": 55, "spe": 50}	16	18	1	1	1	3
405	Mawile-Mega	{"hp": 50, "atk": 105, "def": 125, "spa": 55, "spd": 95, "spe": 50}	16	18	1	\N	\N	3
406	Aron	{"hp": 50, "atk": 70, "def": 100, "spa": 40, "spd": 40, "spe": 30}	16	13	1	1	1	3
407	Lairon	{"hp": 60, "atk": 90, "def": 140, "spa": 50, "spd": 50, "spe": 40}	16	13	1	1	1	3
408	Aggron	{"hp": 70, "atk": 110, "def": 180, "spa": 60, "spd": 60, "spe": 50}	16	13	1	1	1	3
409	Aggron-Mega	{"hp": 70, "atk": 140, "def": 230, "spa": 60, "spd": 80, "spe": 50}	16	\N	1	\N	\N	3
410	Meditite	{"hp": 30, "atk": 40, "def": 55, "spa": 40, "spd": 55, "spe": 60}	7	11	1	\N	1	3
411	Medicham	{"hp": 60, "atk": 60, "def": 75, "spa": 60, "spd": 75, "spe": 80}	7	11	1	\N	1	3
412	Medicham-Mega	{"hp": 60, "atk": 100, "def": 85, "spa": 80, "spd": 85, "spe": 100}	7	11	1	\N	\N	3
413	Electrike	{"hp": 40, "atk": 45, "def": 40, "spa": 65, "spd": 40, "spe": 65}	4	\N	1	1	1	3
414	Manectric	{"hp": 70, "atk": 75, "def": 60, "spa": 105, "spd": 60, "spe": 105}	4	\N	1	1	1	3
415	Manectric-Mega	{"hp": 70, "atk": 75, "def": 80, "spa": 135, "spd": 80, "spe": 135}	4	\N	1	\N	\N	3
416	Plusle	{"hp": 60, "atk": 50, "def": 40, "spa": 85, "spd": 75, "spe": 95}	4	\N	1	\N	1	3
417	Minun	{"hp": 60, "atk": 40, "def": 50, "spa": 75, "spd": 85, "spe": 95}	4	\N	1	\N	1	3
418	Volbeat	{"hp": 65, "atk": 73, "def": 75, "spa": 47, "spd": 85, "spe": 85}	12	\N	1	1	1	3
419	Illumise	{"hp": 65, "atk": 47, "def": 75, "spa": 73, "spd": 85, "spe": 85}	12	\N	1	1	1	3
420	Roselia	{"hp": 50, "atk": 60, "def": 45, "spa": 100, "spd": 80, "spe": 65}	5	8	1	1	1	3
421	Gulpin	{"hp": 70, "atk": 43, "def": 53, "spa": 43, "spd": 53, "spe": 40}	8	\N	1	1	1	3
422	Swalot	{"hp": 100, "atk": 73, "def": 83, "spa": 73, "spd": 83, "spe": 55}	8	\N	1	1	1	3
423	Carvanha	{"hp": 45, "atk": 90, "def": 20, "spa": 65, "spd": 20, "spe": 65}	3	17	1	\N	1	3
424	Sharpedo	{"hp": 70, "atk": 120, "def": 40, "spa": 95, "spd": 40, "spe": 95}	3	17	1	\N	1	3
425	Sharpedo-Mega	{"hp": 70, "atk": 140, "def": 70, "spa": 110, "spd": 65, "spe": 105}	3	17	1	\N	\N	3
426	Wailmer	{"hp": 130, "atk": 70, "def": 35, "spa": 70, "spd": 35, "spe": 60}	3	\N	1	1	1	3
427	Wailord	{"hp": 170, "atk": 90, "def": 45, "spa": 90, "spd": 45, "spe": 60}	3	\N	1	1	1	3
428	Numel	{"hp": 60, "atk": 60, "def": 40, "spa": 65, "spd": 45, "spe": 35}	2	9	1	1	1	3
429	Camerupt	{"hp": 70, "atk": 100, "def": 70, "spa": 105, "spd": 75, "spe": 40}	2	9	1	1	1	3
430	Camerupt-Mega	{"hp": 70, "atk": 120, "def": 100, "spa": 145, "spd": 105, "spe": 20}	2	9	1	\N	\N	3
431	Torkoal	{"hp": 70, "atk": 85, "def": 140, "spa": 85, "spd": 70, "spe": 20}	2	\N	1	1	1	3
432	Spoink	{"hp": 60, "atk": 25, "def": 35, "spa": 70, "spd": 80, "spe": 60}	11	\N	1	1	1	3
433	Grumpig	{"hp": 80, "atk": 45, "def": 65, "spa": 90, "spd": 110, "spe": 80}	11	\N	1	1	1	3
434	Spinda	{"hp": 60, "atk": 60, "def": 60, "spa": 60, "spd": 60, "spe": 60}	1	\N	1	1	1	3
435	Trapinch	{"hp": 45, "atk": 100, "def": 45, "spa": 45, "spd": 45, "spe": 10}	9	\N	1	1	1	3
436	Vibrava	{"hp": 50, "atk": 70, "def": 50, "spa": 50, "spd": 50, "spe": 70}	9	15	1	\N	\N	3
437	Flygon	{"hp": 80, "atk": 100, "def": 80, "spa": 80, "spd": 80, "spe": 100}	9	15	1	\N	\N	3
438	Cacnea	{"hp": 50, "atk": 85, "def": 40, "spa": 85, "spd": 40, "spe": 35}	5	\N	1	\N	1	3
439	Cacturne	{"hp": 70, "atk": 115, "def": 60, "spa": 115, "spd": 60, "spe": 55}	5	17	1	\N	1	3
440	Swablu	{"hp": 45, "atk": 40, "def": 60, "spa": 40, "spd": 75, "spe": 50}	1	10	1	\N	1	3
441	Altaria	{"hp": 75, "atk": 70, "def": 90, "spa": 70, "spd": 105, "spe": 80}	15	10	1	\N	1	3
442	Altaria-Mega	{"hp": 75, "atk": 110, "def": 110, "spa": 110, "spd": 105, "spe": 80}	15	18	1	\N	\N	3
443	Zangoose	{"hp": 73, "atk": 115, "def": 60, "spa": 60, "spd": 60, "spe": 90}	1	\N	1	\N	1	3
444	Seviper	{"hp": 73, "atk": 100, "def": 60, "spa": 100, "spd": 60, "spe": 65}	8	\N	1	\N	1	3
445	Lunatone	{"hp": 90, "atk": 55, "def": 65, "spa": 95, "spd": 85, "spe": 70}	13	11	1	\N	\N	3
446	Solrock	{"hp": 90, "atk": 95, "def": 85, "spa": 55, "spd": 65, "spe": 70}	13	11	1	\N	\N	3
447	Barboach	{"hp": 50, "atk": 48, "def": 43, "spa": 46, "spd": 41, "spe": 60}	3	9	1	1	1	3
448	Whiscash	{"hp": 110, "atk": 78, "def": 73, "spa": 76, "spd": 71, "spe": 60}	3	9	1	1	1	3
449	Corphish	{"hp": 43, "atk": 80, "def": 65, "spa": 50, "spd": 35, "spe": 35}	3	\N	1	1	1	3
450	Crawdaunt	{"hp": 63, "atk": 120, "def": 85, "spa": 90, "spd": 55, "spe": 55}	3	17	1	1	1	3
451	Baltoy	{"hp": 40, "atk": 40, "def": 55, "spa": 40, "spd": 70, "spe": 55}	9	11	1	\N	\N	3
452	Claydol	{"hp": 60, "atk": 70, "def": 105, "spa": 70, "spd": 120, "spe": 75}	9	11	1	\N	\N	3
453	Lileep	{"hp": 66, "atk": 41, "def": 77, "spa": 61, "spd": 87, "spe": 23}	13	5	1	\N	1	3
454	Cradily	{"hp": 86, "atk": 81, "def": 97, "spa": 81, "spd": 107, "spe": 43}	13	5	1	\N	1	3
455	Anorith	{"hp": 45, "atk": 95, "def": 50, "spa": 40, "spd": 50, "spe": 75}	13	12	1	\N	1	3
456	Armaldo	{"hp": 75, "atk": 125, "def": 100, "spa": 70, "spd": 80, "spe": 45}	13	12	1	\N	1	3
457	Feebas	{"hp": 20, "atk": 15, "def": 20, "spa": 10, "spd": 55, "spe": 80}	3	\N	1	1	1	3
458	Milotic	{"hp": 95, "atk": 60, "def": 79, "spa": 100, "spd": 125, "spe": 81}	3	\N	1	1	1	3
459	Castform	{"hp": 70, "atk": 70, "def": 70, "spa": 70, "spd": 70, "spe": 70}	1	\N	1	\N	\N	3
460	Castform-Sunny	{"hp": 70, "atk": 70, "def": 70, "spa": 70, "spd": 70, "spe": 70}	2	\N	1	\N	\N	3
461	Castform-Rainy	{"hp": 70, "atk": 70, "def": 70, "spa": 70, "spd": 70, "spe": 70}	3	\N	1	\N	\N	3
462	Castform-Snowy	{"hp": 70, "atk": 70, "def": 70, "spa": 70, "spd": 70, "spe": 70}	6	\N	1	\N	\N	3
463	Kecleon	{"hp": 60, "atk": 90, "def": 70, "spa": 60, "spd": 120, "spe": 40}	1	\N	1	\N	1	3
464	Shuppet	{"hp": 44, "atk": 75, "def": 35, "spa": 63, "spd": 33, "spe": 45}	14	\N	1	1	1	3
465	Banette	{"hp": 64, "atk": 115, "def": 65, "spa": 83, "spd": 63, "spe": 65}	14	\N	1	1	1	3
466	Banette-Mega	{"hp": 64, "atk": 165, "def": 75, "spa": 93, "spd": 83, "spe": 75}	14	\N	1	\N	\N	3
467	Duskull	{"hp": 20, "atk": 40, "def": 90, "spa": 30, "spd": 90, "spe": 25}	14	\N	1	\N	1	3
468	Dusclops	{"hp": 40, "atk": 70, "def": 130, "spa": 60, "spd": 130, "spe": 25}	14	\N	1	\N	1	3
469	Tropius	{"hp": 99, "atk": 68, "def": 83, "spa": 72, "spd": 87, "spe": 51}	5	10	1	1	1	3
470	Chimecho	{"hp": 75, "atk": 50, "def": 80, "spa": 95, "spd": 90, "spe": 65}	11	\N	1	\N	\N	3
471	Absol	{"hp": 65, "atk": 130, "def": 60, "spa": 75, "spd": 60, "spe": 75}	17	\N	1	1	1	3
472	Absol-Mega	{"hp": 65, "atk": 150, "def": 60, "spa": 115, "spd": 60, "spe": 115}	17	\N	1	\N	\N	3
473	Wynaut	{"hp": 95, "atk": 23, "def": 48, "spa": 23, "spd": 48, "spe": 23}	11	\N	1	\N	1	3
474	Snorunt	{"hp": 50, "atk": 50, "def": 50, "spa": 50, "spd": 50, "spe": 50}	6	\N	1	1	1	3
475	Glalie	{"hp": 80, "atk": 80, "def": 80, "spa": 80, "spd": 80, "spe": 80}	6	\N	1	1	1	3
476	Glalie-Mega	{"hp": 80, "atk": 120, "def": 80, "spa": 120, "spd": 80, "spe": 100}	6	\N	1	\N	\N	3
477	Spheal	{"hp": 70, "atk": 40, "def": 50, "spa": 55, "spd": 50, "spe": 25}	6	3	1	1	1	3
478	Sealeo	{"hp": 90, "atk": 60, "def": 70, "spa": 75, "spd": 70, "spe": 45}	6	3	1	1	1	3
479	Walrein	{"hp": 110, "atk": 80, "def": 90, "spa": 95, "spd": 90, "spe": 65}	6	3	1	1	1	3
480	Clamperl	{"hp": 35, "atk": 64, "def": 85, "spa": 74, "spd": 55, "spe": 32}	3	\N	1	\N	1	3
481	Huntail	{"hp": 55, "atk": 104, "def": 105, "spa": 94, "spd": 75, "spe": 52}	3	\N	1	\N	1	3
482	Gorebyss	{"hp": 55, "atk": 84, "def": 105, "spa": 114, "spd": 75, "spe": 52}	3	\N	1	\N	1	3
483	Relicanth	{"hp": 100, "atk": 90, "def": 130, "spa": 45, "spd": 65, "spe": 55}	3	13	1	1	1	3
484	Luvdisc	{"hp": 43, "atk": 30, "def": 55, "spa": 40, "spd": 65, "spe": 97}	3	\N	1	\N	1	3
485	Bagon	{"hp": 45, "atk": 75, "def": 60, "spa": 40, "spd": 30, "spe": 50}	15	\N	1	\N	1	3
486	Shelgon	{"hp": 65, "atk": 95, "def": 100, "spa": 60, "spd": 50, "spe": 50}	15	\N	1	\N	1	3
487	Salamence	{"hp": 95, "atk": 135, "def": 80, "spa": 110, "spd": 80, "spe": 100}	15	10	1	\N	1	3
488	Salamence-Mega	{"hp": 95, "atk": 145, "def": 130, "spa": 120, "spd": 90, "spe": 120}	15	10	1	\N	\N	3
489	Beldum	{"hp": 40, "atk": 55, "def": 80, "spa": 35, "spd": 60, "spe": 30}	16	11	1	\N	1	3
490	Metang	{"hp": 60, "atk": 75, "def": 100, "spa": 55, "spd": 80, "spe": 50}	16	11	1	\N	1	3
491	Metagross	{"hp": 80, "atk": 135, "def": 130, "spa": 95, "spd": 90, "spe": 70}	16	11	1	\N	1	3
492	Metagross-Mega	{"hp": 80, "atk": 145, "def": 150, "spa": 105, "spd": 110, "spe": 110}	16	11	1	\N	\N	3
493	Regirock	{"hp": 80, "atk": 100, "def": 200, "spa": 50, "spd": 100, "spe": 50}	13	\N	1	\N	1	3
494	Regice	{"hp": 80, "atk": 50, "def": 100, "spa": 100, "spd": 200, "spe": 50}	6	\N	1	\N	1	3
495	Registeel	{"hp": 80, "atk": 75, "def": 150, "spa": 75, "spd": 150, "spe": 50}	16	\N	1	\N	1	3
496	Latias	{"hp": 80, "atk": 80, "def": 90, "spa": 110, "spd": 130, "spe": 110}	15	11	1	\N	\N	3
497	Latias-Mega	{"hp": 80, "atk": 100, "def": 120, "spa": 140, "spd": 150, "spe": 110}	15	11	1	\N	\N	3
498	Latios	{"hp": 80, "atk": 90, "def": 80, "spa": 130, "spd": 110, "spe": 110}	15	11	1	\N	\N	3
499	Latios-Mega	{"hp": 80, "atk": 130, "def": 100, "spa": 160, "spd": 120, "spe": 110}	15	11	1	\N	\N	3
500	Kyogre	{"hp": 100, "atk": 100, "def": 90, "spa": 150, "spd": 140, "spe": 90}	3	\N	1	\N	\N	3
501	Kyogre-Primal	{"hp": 100, "atk": 150, "def": 90, "spa": 180, "spd": 160, "spe": 90}	3	\N	1	\N	\N	3
502	Groudon	{"hp": 100, "atk": 150, "def": 140, "spa": 100, "spd": 90, "spe": 90}	9	\N	1	\N	\N	3
503	Groudon-Primal	{"hp": 100, "atk": 180, "def": 160, "spa": 150, "spd": 90, "spe": 90}	9	2	1	\N	\N	3
504	Rayquaza	{"hp": 105, "atk": 150, "def": 90, "spa": 150, "spd": 90, "spe": 95}	15	10	1	\N	\N	3
505	Rayquaza-Mega	{"hp": 105, "atk": 180, "def": 100, "spa": 180, "spd": 100, "spe": 115}	15	10	1	\N	\N	3
506	Jirachi	{"hp": 100, "atk": 100, "def": 100, "spa": 100, "spd": 100, "spe": 100}	16	11	1	\N	\N	3
507	Deoxys	{"hp": 50, "atk": 150, "def": 50, "spa": 150, "spd": 50, "spe": 150}	11	\N	1	\N	\N	3
508	Deoxys-Attack	{"hp": 50, "atk": 180, "def": 20, "spa": 180, "spd": 20, "spe": 150}	11	\N	1	\N	\N	3
509	Deoxys-Defense	{"hp": 50, "atk": 70, "def": 160, "spa": 70, "spd": 160, "spe": 90}	11	\N	1	\N	\N	3
510	Deoxys-Speed	{"hp": 50, "atk": 95, "def": 90, "spa": 95, "spd": 90, "spe": 180}	11	\N	1	\N	\N	3
511	Turtwig	{"hp": 55, "atk": 68, "def": 64, "spa": 45, "spd": 55, "spe": 31}	5	\N	1	\N	1	4
512	Grotle	{"hp": 75, "atk": 89, "def": 85, "spa": 55, "spd": 65, "spe": 36}	5	\N	1	\N	1	4
513	Torterra	{"hp": 95, "atk": 109, "def": 105, "spa": 75, "spd": 85, "spe": 56}	5	9	1	\N	1	4
514	Chimchar	{"hp": 44, "atk": 58, "def": 44, "spa": 58, "spd": 44, "spe": 61}	2	\N	1	\N	1	4
515	Monferno	{"hp": 64, "atk": 78, "def": 52, "spa": 78, "spd": 52, "spe": 81}	2	7	1	\N	1	4
516	Infernape	{"hp": 76, "atk": 104, "def": 71, "spa": 104, "spd": 71, "spe": 108}	2	7	1	\N	1	4
517	Piplup	{"hp": 53, "atk": 51, "def": 53, "spa": 61, "spd": 56, "spe": 40}	3	\N	1	\N	1	4
518	Prinplup	{"hp": 64, "atk": 66, "def": 68, "spa": 81, "spd": 76, "spe": 50}	3	\N	1	\N	1	4
519	Empoleon	{"hp": 84, "atk": 86, "def": 88, "spa": 111, "spd": 101, "spe": 60}	3	16	1	\N	1	4
520	Starly	{"hp": 40, "atk": 55, "def": 30, "spa": 30, "spd": 30, "spe": 60}	1	10	1	\N	1	4
521	Staravia	{"hp": 55, "atk": 75, "def": 50, "spa": 40, "spd": 40, "spe": 80}	1	10	1	\N	1	4
522	Staraptor	{"hp": 85, "atk": 120, "def": 70, "spa": 50, "spd": 60, "spe": 100}	1	10	1	\N	1	4
523	Bidoof	{"hp": 59, "atk": 45, "def": 40, "spa": 35, "spd": 40, "spe": 31}	1	\N	1	1	1	4
524	Bibarel	{"hp": 79, "atk": 85, "def": 60, "spa": 55, "spd": 60, "spe": 71}	1	3	1	1	1	4
525	Kricketot	{"hp": 37, "atk": 25, "def": 41, "spa": 25, "spd": 41, "spe": 25}	12	\N	1	\N	1	4
526	Kricketune	{"hp": 77, "atk": 85, "def": 51, "spa": 55, "spd": 51, "spe": 65}	12	\N	1	\N	1	4
527	Shinx	{"hp": 45, "atk": 65, "def": 34, "spa": 40, "spd": 34, "spe": 45}	4	\N	1	1	1	4
528	Luxio	{"hp": 60, "atk": 85, "def": 49, "spa": 60, "spd": 49, "spe": 60}	4	\N	1	1	1	4
529	Luxray	{"hp": 80, "atk": 120, "def": 79, "spa": 95, "spd": 79, "spe": 70}	4	\N	1	1	1	4
530	Budew	{"hp": 40, "atk": 30, "def": 35, "spa": 50, "spd": 70, "spe": 55}	5	8	1	1	1	4
531	Roserade	{"hp": 60, "atk": 70, "def": 65, "spa": 125, "spd": 105, "spe": 90}	5	8	1	1	1	4
532	Cranidos	{"hp": 67, "atk": 125, "def": 40, "spa": 30, "spd": 30, "spe": 58}	13	\N	1	\N	1	4
533	Rampardos	{"hp": 97, "atk": 165, "def": 60, "spa": 65, "spd": 50, "spe": 58}	13	\N	1	\N	1	4
534	Shieldon	{"hp": 30, "atk": 42, "def": 118, "spa": 42, "spd": 88, "spe": 30}	13	16	1	\N	1	4
535	Bastiodon	{"hp": 60, "atk": 52, "def": 168, "spa": 47, "spd": 138, "spe": 30}	13	16	1	\N	1	4
536	Burmy	{"hp": 40, "atk": 29, "def": 45, "spa": 29, "spd": 45, "spe": 36}	12	\N	1	\N	1	4
537	Wormadam	{"hp": 60, "atk": 59, "def": 85, "spa": 79, "spd": 105, "spe": 36}	12	5	1	\N	1	4
538	Wormadam-Sandy	{"hp": 60, "atk": 79, "def": 105, "spa": 59, "spd": 85, "spe": 36}	12	9	1	\N	1	4
539	Wormadam-Trash	{"hp": 60, "atk": 69, "def": 95, "spa": 69, "spd": 95, "spe": 36}	12	16	1	\N	1	4
540	Mothim	{"hp": 70, "atk": 94, "def": 50, "spa": 94, "spd": 50, "spe": 66}	12	10	1	\N	1	4
541	Combee	{"hp": 30, "atk": 30, "def": 42, "spa": 30, "spd": 42, "spe": 70}	12	10	1	\N	1	4
542	Vespiquen	{"hp": 70, "atk": 80, "def": 102, "spa": 80, "spd": 102, "spe": 40}	12	10	1	\N	1	4
543	Pachirisu	{"hp": 60, "atk": 45, "def": 70, "spa": 45, "spd": 90, "spe": 95}	4	\N	1	1	1	4
544	Buizel	{"hp": 55, "atk": 65, "def": 35, "spa": 60, "spd": 30, "spe": 85}	3	\N	1	\N	1	4
545	Floatzel	{"hp": 85, "atk": 105, "def": 55, "spa": 85, "spd": 50, "spe": 115}	3	\N	1	\N	1	4
546	Cherubi	{"hp": 45, "atk": 35, "def": 45, "spa": 62, "spd": 53, "spe": 35}	5	\N	1	\N	\N	4
547	Cherrim	{"hp": 70, "atk": 60, "def": 70, "spa": 87, "spd": 78, "spe": 85}	5	\N	1	\N	\N	4
548	Cherrim-Sunshine	{"hp": 70, "atk": 60, "def": 70, "spa": 87, "spd": 78, "spe": 85}	5	\N	1	\N	\N	4
549	Shellos	{"hp": 76, "atk": 48, "def": 48, "spa": 57, "spd": 62, "spe": 34}	3	\N	1	1	1	4
550	Gastrodon	{"hp": 111, "atk": 83, "def": 68, "spa": 92, "spd": 82, "spe": 39}	3	9	1	1	1	4
551	Ambipom	{"hp": 75, "atk": 100, "def": 66, "spa": 60, "spd": 66, "spe": 115}	1	\N	1	1	1	4
552	Drifloon	{"hp": 90, "atk": 50, "def": 34, "spa": 60, "spd": 44, "spe": 70}	14	10	1	1	1	4
553	Drifblim	{"hp": 150, "atk": 80, "def": 44, "spa": 90, "spd": 54, "spe": 80}	14	10	1	1	1	4
554	Buneary	{"hp": 55, "atk": 66, "def": 44, "spa": 44, "spd": 56, "spe": 85}	1	\N	1	1	1	4
555	Lopunny	{"hp": 65, "atk": 76, "def": 84, "spa": 54, "spd": 96, "spe": 105}	1	\N	1	1	1	4
556	Lopunny-Mega	{"hp": 65, "atk": 136, "def": 94, "spa": 54, "spd": 96, "spe": 135}	1	7	1	\N	\N	4
557	Mismagius	{"hp": 60, "atk": 60, "def": 60, "spa": 105, "spd": 105, "spe": 105}	14	\N	1	\N	\N	4
558	Honchkrow	{"hp": 100, "atk": 125, "def": 52, "spa": 105, "spd": 52, "spe": 71}	17	10	1	1	1	4
559	Glameow	{"hp": 49, "atk": 55, "def": 42, "spa": 42, "spd": 37, "spe": 85}	1	\N	1	1	1	4
560	Purugly	{"hp": 71, "atk": 82, "def": 64, "spa": 64, "spd": 59, "spe": 112}	1	\N	1	1	1	4
561	Chingling	{"hp": 45, "atk": 30, "def": 50, "spa": 65, "spd": 50, "spe": 45}	11	\N	1	\N	\N	4
562	Stunky	{"hp": 63, "atk": 63, "def": 47, "spa": 41, "spd": 41, "spe": 74}	8	17	1	1	1	4
563	Skuntank	{"hp": 103, "atk": 93, "def": 67, "spa": 71, "spd": 61, "spe": 84}	8	17	1	1	1	4
564	Bronzor	{"hp": 57, "atk": 24, "def": 86, "spa": 24, "spd": 86, "spe": 23}	16	11	1	1	1	4
565	Bronzong	{"hp": 67, "atk": 89, "def": 116, "spa": 79, "spd": 116, "spe": 33}	16	11	1	1	1	4
566	Bonsly	{"hp": 50, "atk": 80, "def": 95, "spa": 10, "spd": 45, "spe": 10}	13	\N	1	1	1	4
567	Mime Jr.	{"hp": 20, "atk": 25, "def": 45, "spa": 70, "spd": 90, "spe": 60}	11	18	1	1	1	4
568	Happiny	{"hp": 100, "atk": 5, "def": 5, "spa": 15, "spd": 65, "spe": 30}	1	\N	1	1	1	4
569	Chatot	{"hp": 76, "atk": 65, "def": 45, "spa": 92, "spd": 42, "spe": 91}	1	10	1	1	1	4
570	Spiritomb	{"hp": 50, "atk": 92, "def": 108, "spa": 92, "spd": 108, "spe": 35}	14	17	1	\N	1	4
571	Gible	{"hp": 58, "atk": 70, "def": 45, "spa": 40, "spd": 45, "spe": 42}	15	9	1	\N	1	4
572	Gabite	{"hp": 68, "atk": 90, "def": 65, "spa": 50, "spd": 55, "spe": 82}	15	9	1	\N	1	4
573	Garchomp	{"hp": 108, "atk": 130, "def": 95, "spa": 80, "spd": 85, "spe": 102}	15	9	1	\N	1	4
574	Garchomp-Mega	{"hp": 108, "atk": 170, "def": 115, "spa": 120, "spd": 95, "spe": 92}	15	9	1	\N	\N	4
575	Munchlax	{"hp": 135, "atk": 85, "def": 40, "spa": 40, "spd": 85, "spe": 5}	1	\N	1	1	1	4
576	Riolu	{"hp": 40, "atk": 70, "def": 40, "spa": 35, "spd": 40, "spe": 60}	7	\N	1	1	1	4
577	Lucario	{"hp": 70, "atk": 110, "def": 70, "spa": 115, "spd": 70, "spe": 90}	7	16	1	1	1	4
578	Lucario-Mega	{"hp": 70, "atk": 145, "def": 88, "spa": 140, "spd": 70, "spe": 112}	7	16	1	\N	\N	4
579	Hippopotas	{"hp": 68, "atk": 72, "def": 78, "spa": 38, "spd": 42, "spe": 32}	9	\N	1	\N	1	4
580	Hippowdon	{"hp": 108, "atk": 112, "def": 118, "spa": 68, "spd": 72, "spe": 47}	9	\N	1	\N	1	4
581	Skorupi	{"hp": 40, "atk": 50, "def": 90, "spa": 30, "spd": 55, "spe": 65}	8	12	1	1	1	4
582	Drapion	{"hp": 70, "atk": 90, "def": 110, "spa": 60, "spd": 75, "spe": 95}	8	17	1	1	1	4
583	Croagunk	{"hp": 48, "atk": 61, "def": 40, "spa": 61, "spd": 40, "spe": 50}	8	7	1	1	1	4
584	Toxicroak	{"hp": 83, "atk": 106, "def": 65, "spa": 86, "spd": 65, "spe": 85}	8	7	1	1	1	4
585	Carnivine	{"hp": 74, "atk": 100, "def": 72, "spa": 90, "spd": 72, "spe": 46}	5	\N	1	\N	\N	4
586	Finneon	{"hp": 49, "atk": 49, "def": 56, "spa": 49, "spd": 61, "spe": 66}	3	\N	1	1	1	4
587	Lumineon	{"hp": 69, "atk": 69, "def": 76, "spa": 69, "spd": 86, "spe": 91}	3	\N	1	1	1	4
588	Mantyke	{"hp": 45, "atk": 20, "def": 50, "spa": 60, "spd": 120, "spe": 50}	3	10	1	1	1	4
589	Snover	{"hp": 60, "atk": 62, "def": 50, "spa": 62, "spd": 60, "spe": 40}	5	6	1	\N	1	4
590	Abomasnow	{"hp": 90, "atk": 92, "def": 75, "spa": 92, "spd": 85, "spe": 60}	5	6	1	\N	1	4
591	Abomasnow-Mega	{"hp": 90, "atk": 132, "def": 105, "spa": 132, "spd": 105, "spe": 30}	5	6	1	\N	\N	4
592	Weavile	{"hp": 70, "atk": 120, "def": 65, "spa": 45, "spd": 85, "spe": 125}	17	6	1	\N	1	4
593	Magnezone	{"hp": 70, "atk": 70, "def": 115, "spa": 130, "spd": 90, "spe": 60}	4	16	1	1	1	4
594	Lickilicky	{"hp": 110, "atk": 85, "def": 95, "spa": 80, "spd": 95, "spe": 50}	1	\N	1	1	1	4
595	Rhyperior	{"hp": 115, "atk": 140, "def": 130, "spa": 55, "spd": 55, "spe": 40}	9	13	1	1	1	4
596	Tangrowth	{"hp": 100, "atk": 100, "def": 125, "spa": 110, "spd": 50, "spe": 50}	5	\N	1	1	1	4
597	Electivire	{"hp": 75, "atk": 123, "def": 67, "spa": 95, "spd": 85, "spe": 95}	4	\N	1	\N	1	4
598	Magmortar	{"hp": 75, "atk": 95, "def": 67, "spa": 125, "spd": 95, "spe": 83}	2	\N	1	\N	1	4
599	Togekiss	{"hp": 85, "atk": 50, "def": 95, "spa": 120, "spd": 115, "spe": 80}	18	10	1	1	1	4
600	Yanmega	{"hp": 86, "atk": 76, "def": 86, "spa": 116, "spd": 56, "spe": 95}	12	10	1	1	1	4
601	Leafeon	{"hp": 65, "atk": 110, "def": 130, "spa": 60, "spd": 65, "spe": 95}	5	\N	1	\N	1	4
602	Glaceon	{"hp": 65, "atk": 60, "def": 110, "spa": 130, "spd": 95, "spe": 65}	6	\N	1	\N	1	4
603	Gliscor	{"hp": 75, "atk": 95, "def": 125, "spa": 45, "spd": 75, "spe": 95}	9	10	1	1	1	4
604	Mamoswine	{"hp": 110, "atk": 130, "def": 80, "spa": 70, "spd": 60, "spe": 80}	6	9	1	1	1	4
605	Porygon-Z	{"hp": 85, "atk": 80, "def": 70, "spa": 135, "spd": 75, "spe": 90}	1	\N	1	1	1	4
606	Gallade	{"hp": 68, "atk": 125, "def": 65, "spa": 65, "spd": 115, "spe": 80}	11	7	1	1	1	4
607	Gallade-Mega	{"hp": 68, "atk": 165, "def": 95, "spa": 65, "spd": 115, "spe": 110}	11	7	1	\N	\N	4
608	Probopass	{"hp": 60, "atk": 55, "def": 145, "spa": 75, "spd": 150, "spe": 40}	13	16	1	1	1	4
609	Dusknoir	{"hp": 45, "atk": 100, "def": 135, "spa": 65, "spd": 135, "spe": 45}	14	\N	1	\N	1	4
610	Froslass	{"hp": 70, "atk": 80, "def": 70, "spa": 80, "spd": 70, "spe": 110}	6	14	1	\N	1	4
611	Rotom	{"hp": 50, "atk": 50, "def": 77, "spa": 95, "spd": 77, "spe": 91}	4	14	1	\N	\N	4
612	Rotom-Heat	{"hp": 50, "atk": 65, "def": 107, "spa": 105, "spd": 107, "spe": 86}	4	2	1	\N	\N	4
613	Rotom-Wash	{"hp": 50, "atk": 65, "def": 107, "spa": 105, "spd": 107, "spe": 86}	4	3	1	\N	\N	4
614	Rotom-Frost	{"hp": 50, "atk": 65, "def": 107, "spa": 105, "spd": 107, "spe": 86}	4	6	1	\N	\N	4
615	Rotom-Fan	{"hp": 50, "atk": 65, "def": 107, "spa": 105, "spd": 107, "spe": 86}	4	10	1	\N	\N	4
616	Rotom-Mow	{"hp": 50, "atk": 65, "def": 107, "spa": 105, "spd": 107, "spe": 86}	4	5	1	\N	\N	4
617	Uxie	{"hp": 75, "atk": 75, "def": 130, "spa": 75, "spd": 130, "spe": 95}	11	\N	1	\N	\N	4
618	Mesprit	{"hp": 80, "atk": 105, "def": 105, "spa": 105, "spd": 105, "spe": 80}	11	\N	1	\N	\N	4
619	Azelf	{"hp": 75, "atk": 125, "def": 70, "spa": 125, "spd": 70, "spe": 115}	11	\N	1	\N	\N	4
620	Dialga	{"hp": 100, "atk": 120, "def": 120, "spa": 150, "spd": 100, "spe": 90}	16	15	1	\N	1	4
621	Dialga-Origin	{"hp": 100, "atk": 100, "def": 120, "spa": 150, "spd": 120, "spe": 90}	16	15	1	\N	1	4
622	Palkia	{"hp": 90, "atk": 120, "def": 100, "spa": 150, "spd": 120, "spe": 100}	3	15	1	\N	1	4
623	Palkia-Origin	{"hp": 90, "atk": 100, "def": 100, "spa": 150, "spd": 120, "spe": 120}	3	15	1	\N	1	4
624	Heatran	{"hp": 91, "atk": 90, "def": 106, "spa": 130, "spd": 106, "spe": 77}	2	16	1	\N	1	4
625	Regigigas	{"hp": 110, "atk": 160, "def": 110, "spa": 80, "spd": 110, "spe": 100}	1	\N	1	\N	\N	4
626	Giratina	{"hp": 150, "atk": 100, "def": 120, "spa": 100, "spd": 120, "spe": 90}	14	15	1	\N	1	4
627	Giratina-Origin	{"hp": 150, "atk": 120, "def": 100, "spa": 120, "spd": 100, "spe": 90}	14	15	1	\N	\N	4
628	Cresselia	{"hp": 120, "atk": 70, "def": 110, "spa": 75, "spd": 120, "spe": 85}	11	\N	1	\N	\N	4
629	Phione	{"hp": 80, "atk": 80, "def": 80, "spa": 80, "spd": 80, "spe": 80}	3	\N	1	\N	\N	4
630	Manaphy	{"hp": 100, "atk": 100, "def": 100, "spa": 100, "spd": 100, "spe": 100}	3	\N	1	\N	\N	4
631	Darkrai	{"hp": 70, "atk": 90, "def": 90, "spa": 135, "spd": 90, "spe": 125}	17	\N	1	\N	\N	4
632	Shaymin	{"hp": 100, "atk": 100, "def": 100, "spa": 100, "spd": 100, "spe": 100}	5	\N	1	\N	\N	4
633	Shaymin-Sky	{"hp": 100, "atk": 103, "def": 75, "spa": 120, "spd": 75, "spe": 127}	5	10	1	\N	\N	4
634	Arceus	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	1	\N	1	\N	\N	4
635	Arceus-Bug	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	12	\N	1	\N	\N	4
636	Arceus-Dark	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	17	\N	1	\N	\N	4
637	Arceus-Dragon	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	15	\N	1	\N	\N	4
638	Arceus-Electric	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	4	\N	1	\N	\N	4
639	Arceus-Fairy	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	18	\N	1	\N	\N	4
640	Arceus-Fighting	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	7	\N	1	\N	\N	4
641	Arceus-Fire	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	2	\N	1	\N	\N	4
642	Arceus-Flying	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	10	\N	1	\N	\N	4
643	Arceus-Ghost	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	14	\N	1	\N	\N	4
644	Arceus-Grass	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	5	\N	1	\N	\N	4
645	Arceus-Ground	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	9	\N	1	\N	\N	4
646	Arceus-Ice	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	6	\N	1	\N	\N	4
647	Arceus-Poison	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	8	\N	1	\N	\N	4
648	Arceus-Psychic	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	11	\N	1	\N	\N	4
649	Arceus-Rock	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	13	\N	1	\N	\N	4
650	Arceus-Steel	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	16	\N	1	\N	\N	4
651	Arceus-Water	{"hp": 120, "atk": 120, "def": 120, "spa": 120, "spd": 120, "spe": 120}	3	\N	1	\N	\N	4
652	Victini	{"hp": 100, "atk": 100, "def": 100, "spa": 100, "spd": 100, "spe": 100}	11	2	1	\N	\N	5
653	Snivy	{"hp": 45, "atk": 45, "def": 55, "spa": 45, "spd": 55, "spe": 63}	5	\N	1	\N	1	5
654	Servine	{"hp": 60, "atk": 60, "def": 75, "spa": 60, "spd": 75, "spe": 83}	5	\N	1	\N	1	5
655	Serperior	{"hp": 75, "atk": 75, "def": 95, "spa": 75, "spd": 95, "spe": 113}	5	\N	1	\N	1	5
656	Tepig	{"hp": 65, "atk": 63, "def": 45, "spa": 45, "spd": 45, "spe": 45}	2	\N	1	\N	1	5
657	Pignite	{"hp": 90, "atk": 93, "def": 55, "spa": 70, "spd": 55, "spe": 55}	2	7	1	\N	1	5
658	Emboar	{"hp": 110, "atk": 123, "def": 65, "spa": 100, "spd": 65, "spe": 65}	2	7	1	\N	1	5
659	Oshawott	{"hp": 55, "atk": 55, "def": 45, "spa": 63, "spd": 45, "spe": 45}	3	\N	1	\N	1	5
660	Dewott	{"hp": 75, "atk": 75, "def": 60, "spa": 83, "spd": 60, "spe": 60}	3	\N	1	\N	1	5
661	Samurott	{"hp": 95, "atk": 100, "def": 85, "spa": 108, "spd": 70, "spe": 70}	3	\N	1	\N	1	5
662	Samurott-Hisui	{"hp": 90, "atk": 108, "def": 80, "spa": 100, "spd": 65, "spe": 85}	3	17	1	\N	1	5
663	Patrat	{"hp": 45, "atk": 55, "def": 39, "spa": 35, "spd": 39, "spe": 42}	1	\N	1	1	1	5
664	Watchog	{"hp": 60, "atk": 85, "def": 69, "spa": 60, "spd": 69, "spe": 77}	1	\N	1	1	1	5
665	Lillipup	{"hp": 45, "atk": 60, "def": 45, "spa": 25, "spd": 45, "spe": 55}	1	\N	1	1	1	5
666	Herdier	{"hp": 65, "atk": 80, "def": 65, "spa": 35, "spd": 65, "spe": 60}	1	\N	1	1	1	5
667	Stoutland	{"hp": 85, "atk": 110, "def": 90, "spa": 45, "spd": 90, "spe": 80}	1	\N	1	1	1	5
668	Purrloin	{"hp": 41, "atk": 50, "def": 37, "spa": 50, "spd": 37, "spe": 66}	17	\N	1	1	1	5
669	Liepard	{"hp": 64, "atk": 88, "def": 50, "spa": 88, "spd": 50, "spe": 106}	17	\N	1	1	1	5
670	Pansage	{"hp": 50, "atk": 53, "def": 48, "spa": 53, "spd": 48, "spe": 64}	5	\N	1	\N	1	5
671	Simisage	{"hp": 75, "atk": 98, "def": 63, "spa": 98, "spd": 63, "spe": 101}	5	\N	1	\N	1	5
672	Pansear	{"hp": 50, "atk": 53, "def": 48, "spa": 53, "spd": 48, "spe": 64}	2	\N	1	\N	1	5
673	Simisear	{"hp": 75, "atk": 98, "def": 63, "spa": 98, "spd": 63, "spe": 101}	2	\N	1	\N	1	5
674	Panpour	{"hp": 50, "atk": 53, "def": 48, "spa": 53, "spd": 48, "spe": 64}	3	\N	1	\N	1	5
675	Simipour	{"hp": 75, "atk": 98, "def": 63, "spa": 98, "spd": 63, "spe": 101}	3	\N	1	\N	1	5
676	Munna	{"hp": 76, "atk": 25, "def": 45, "spa": 67, "spd": 55, "spe": 24}	11	\N	1	1	1	5
677	Musharna	{"hp": 116, "atk": 55, "def": 85, "spa": 107, "spd": 95, "spe": 29}	11	\N	1	1	1	5
678	Pidove	{"hp": 50, "atk": 55, "def": 50, "spa": 36, "spd": 30, "spe": 43}	1	10	1	1	1	5
679	Tranquill	{"hp": 62, "atk": 77, "def": 62, "spa": 50, "spd": 42, "spe": 65}	1	10	1	1	1	5
680	Unfezant	{"hp": 80, "atk": 115, "def": 80, "spa": 65, "spd": 55, "spe": 93}	1	10	1	1	1	5
681	Blitzle	{"hp": 45, "atk": 60, "def": 32, "spa": 50, "spd": 32, "spe": 76}	4	\N	1	1	1	5
682	Zebstrika	{"hp": 75, "atk": 100, "def": 63, "spa": 80, "spd": 63, "spe": 116}	4	\N	1	1	1	5
683	Roggenrola	{"hp": 55, "atk": 75, "def": 85, "spa": 25, "spd": 25, "spe": 15}	13	\N	1	1	1	5
684	Boldore	{"hp": 70, "atk": 105, "def": 105, "spa": 50, "spd": 40, "spe": 20}	13	\N	1	1	1	5
685	Gigalith	{"hp": 85, "atk": 135, "def": 130, "spa": 60, "spd": 80, "spe": 25}	13	\N	1	1	1	5
686	Woobat	{"hp": 65, "atk": 45, "def": 43, "spa": 55, "spd": 43, "spe": 72}	11	10	1	1	1	5
687	Swoobat	{"hp": 67, "atk": 57, "def": 55, "spa": 77, "spd": 55, "spe": 114}	11	10	1	1	1	5
688	Drilbur	{"hp": 60, "atk": 85, "def": 40, "spa": 30, "spd": 45, "spe": 68}	9	\N	1	1	1	5
689	Excadrill	{"hp": 110, "atk": 135, "def": 60, "spa": 50, "spd": 65, "spe": 88}	9	16	1	1	1	5
690	Audino	{"hp": 103, "atk": 60, "def": 86, "spa": 60, "spd": 86, "spe": 50}	1	\N	1	1	1	5
691	Audino-Mega	{"hp": 103, "atk": 60, "def": 126, "spa": 80, "spd": 126, "spe": 50}	1	18	1	\N	\N	5
692	Timburr	{"hp": 75, "atk": 80, "def": 55, "spa": 25, "spd": 35, "spe": 35}	7	\N	1	1	1	5
693	Gurdurr	{"hp": 85, "atk": 105, "def": 85, "spa": 40, "spd": 50, "spe": 40}	7	\N	1	1	1	5
694	Conkeldurr	{"hp": 105, "atk": 140, "def": 95, "spa": 55, "spd": 65, "spe": 45}	7	\N	1	1	1	5
695	Tympole	{"hp": 50, "atk": 50, "def": 40, "spa": 50, "spd": 40, "spe": 64}	3	\N	1	1	1	5
696	Palpitoad	{"hp": 75, "atk": 65, "def": 55, "spa": 65, "spd": 55, "spe": 69}	3	9	1	1	1	5
697	Seismitoad	{"hp": 105, "atk": 95, "def": 75, "spa": 85, "spd": 75, "spe": 74}	3	9	1	1	1	5
698	Throh	{"hp": 120, "atk": 100, "def": 85, "spa": 30, "spd": 85, "spe": 45}	7	\N	1	1	1	5
699	Sawk	{"hp": 75, "atk": 125, "def": 75, "spa": 30, "spd": 75, "spe": 85}	7	\N	1	1	1	5
700	Sewaddle	{"hp": 45, "atk": 53, "def": 70, "spa": 40, "spd": 60, "spe": 42}	12	5	1	1	1	5
701	Swadloon	{"hp": 55, "atk": 63, "def": 90, "spa": 50, "spd": 80, "spe": 42}	12	5	1	1	1	5
702	Leavanny	{"hp": 75, "atk": 103, "def": 80, "spa": 70, "spd": 80, "spe": 92}	12	5	1	1	1	5
703	Venipede	{"hp": 30, "atk": 45, "def": 59, "spa": 30, "spd": 39, "spe": 57}	12	8	1	1	1	5
704	Whirlipede	{"hp": 40, "atk": 55, "def": 99, "spa": 40, "spd": 79, "spe": 47}	12	8	1	1	1	5
705	Scolipede	{"hp": 60, "atk": 100, "def": 89, "spa": 55, "spd": 69, "spe": 112}	12	8	1	1	1	5
706	Cottonee	{"hp": 40, "atk": 27, "def": 60, "spa": 37, "spd": 50, "spe": 66}	5	18	1	1	1	5
707	Whimsicott	{"hp": 60, "atk": 67, "def": 85, "spa": 77, "spd": 75, "spe": 116}	5	18	1	1	1	5
708	Petilil	{"hp": 45, "atk": 35, "def": 50, "spa": 70, "spd": 50, "spe": 30}	5	\N	1	1	1	5
709	Lilligant	{"hp": 70, "atk": 60, "def": 75, "spa": 110, "spd": 75, "spe": 90}	5	\N	1	1	1	5
710	Lilligant-Hisui	{"hp": 70, "atk": 105, "def": 75, "spa": 50, "spd": 75, "spe": 105}	5	7	1	1	1	5
711	Basculin	{"hp": 70, "atk": 92, "def": 65, "spa": 80, "spd": 55, "spe": 98}	3	\N	1	1	1	5
712	Basculin-Blue-Striped	{"hp": 70, "atk": 92, "def": 65, "spa": 80, "spd": 55, "spe": 98}	3	\N	1	1	1	5
713	Basculin-White-Striped	{"hp": 70, "atk": 92, "def": 65, "spa": 80, "spd": 55, "spe": 98}	3	\N	1	1	1	5
714	Sandile	{"hp": 50, "atk": 72, "def": 35, "spa": 35, "spd": 35, "spe": 65}	9	17	1	1	1	5
715	Krokorok	{"hp": 60, "atk": 82, "def": 45, "spa": 45, "spd": 45, "spe": 74}	9	17	1	1	1	5
716	Krookodile	{"hp": 95, "atk": 117, "def": 80, "spa": 65, "spd": 70, "spe": 92}	9	17	1	1	1	5
717	Darumaka	{"hp": 70, "atk": 90, "def": 45, "spa": 15, "spd": 45, "spe": 50}	2	\N	1	\N	1	5
718	Darumaka-Galar	{"hp": 70, "atk": 90, "def": 45, "spa": 15, "spd": 45, "spe": 50}	6	\N	1	\N	1	5
719	Darmanitan	{"hp": 105, "atk": 140, "def": 55, "spa": 30, "spd": 55, "spe": 95}	2	\N	1	\N	1	5
720	Darmanitan-Zen	{"hp": 105, "atk": 30, "def": 105, "spa": 140, "spd": 105, "spe": 55}	2	11	1	\N	\N	5
721	Darmanitan-Galar	{"hp": 105, "atk": 140, "def": 55, "spa": 30, "spd": 55, "spe": 95}	6	\N	1	\N	1	5
722	Darmanitan-Galar-Zen	{"hp": 105, "atk": 160, "def": 55, "spa": 30, "spd": 55, "spe": 135}	6	2	1	\N	\N	5
723	Maractus	{"hp": 75, "atk": 86, "def": 67, "spa": 106, "spd": 67, "spe": 60}	5	\N	1	1	1	5
724	Dwebble	{"hp": 50, "atk": 65, "def": 85, "spa": 35, "spd": 35, "spe": 55}	12	13	1	1	1	5
725	Crustle	{"hp": 70, "atk": 105, "def": 125, "spa": 65, "spd": 75, "spe": 45}	12	13	1	1	1	5
726	Scraggy	{"hp": 50, "atk": 75, "def": 70, "spa": 35, "spd": 70, "spe": 48}	17	7	1	1	1	5
727	Scrafty	{"hp": 65, "atk": 90, "def": 115, "spa": 45, "spd": 115, "spe": 58}	17	7	1	1	1	5
728	Sigilyph	{"hp": 72, "atk": 58, "def": 80, "spa": 103, "spd": 80, "spe": 97}	11	10	1	1	1	5
729	Yamask	{"hp": 38, "atk": 30, "def": 85, "spa": 55, "spd": 65, "spe": 30}	14	\N	1	\N	\N	5
730	Yamask-Galar	{"hp": 38, "atk": 55, "def": 85, "spa": 30, "spd": 65, "spe": 30}	9	14	1	\N	\N	5
731	Cofagrigus	{"hp": 58, "atk": 50, "def": 145, "spa": 95, "spd": 105, "spe": 30}	14	\N	1	\N	\N	5
732	Tirtouga	{"hp": 54, "atk": 78, "def": 103, "spa": 53, "spd": 45, "spe": 22}	3	13	1	1	1	5
733	Carracosta	{"hp": 74, "atk": 108, "def": 133, "spa": 83, "spd": 65, "spe": 32}	3	13	1	1	1	5
734	Archen	{"hp": 55, "atk": 112, "def": 45, "spa": 74, "spd": 45, "spe": 70}	13	10	1	\N	\N	5
735	Archeops	{"hp": 75, "atk": 140, "def": 65, "spa": 112, "spd": 65, "spe": 110}	13	10	1	\N	\N	5
736	Trubbish	{"hp": 50, "atk": 50, "def": 62, "spa": 40, "spd": 62, "spe": 65}	8	\N	1	1	1	5
737	Garbodor	{"hp": 80, "atk": 95, "def": 82, "spa": 60, "spd": 82, "spe": 75}	8	\N	1	1	1	5
738	Garbodor-Gmax	{"hp": 80, "atk": 95, "def": 82, "spa": 60, "spd": 82, "spe": 75}	8	\N	1	1	1	5
739	Zorua	{"hp": 40, "atk": 65, "def": 40, "spa": 80, "spd": 40, "spe": 65}	17	\N	1	\N	\N	5
740	Zorua-Hisui	{"hp": 35, "atk": 60, "def": 40, "spa": 85, "spd": 40, "spe": 70}	1	14	1	\N	\N	5
741	Zoroark	{"hp": 60, "atk": 105, "def": 60, "spa": 120, "spd": 60, "spe": 105}	17	\N	1	\N	\N	5
742	Zoroark-Hisui	{"hp": 55, "atk": 100, "def": 60, "spa": 125, "spd": 60, "spe": 110}	1	14	1	\N	\N	5
743	Minccino	{"hp": 55, "atk": 50, "def": 40, "spa": 40, "spd": 40, "spe": 75}	1	\N	1	1	1	5
744	Cinccino	{"hp": 75, "atk": 95, "def": 60, "spa": 65, "spd": 60, "spe": 115}	1	\N	1	1	1	5
745	Gothita	{"hp": 45, "atk": 30, "def": 50, "spa": 55, "spd": 65, "spe": 45}	11	\N	1	1	1	5
746	Gothorita	{"hp": 60, "atk": 45, "def": 70, "spa": 75, "spd": 85, "spe": 55}	11	\N	1	1	1	5
747	Gothitelle	{"hp": 70, "atk": 55, "def": 95, "spa": 95, "spd": 110, "spe": 65}	11	\N	1	1	1	5
748	Solosis	{"hp": 45, "atk": 30, "def": 40, "spa": 105, "spd": 50, "spe": 20}	11	\N	1	1	1	5
749	Duosion	{"hp": 65, "atk": 40, "def": 50, "spa": 125, "spd": 60, "spe": 30}	11	\N	1	1	1	5
750	Reuniclus	{"hp": 110, "atk": 65, "def": 75, "spa": 125, "spd": 85, "spe": 30}	11	\N	1	1	1	5
751	Ducklett	{"hp": 62, "atk": 44, "def": 50, "spa": 44, "spd": 50, "spe": 55}	3	10	1	1	1	5
752	Swanna	{"hp": 75, "atk": 87, "def": 63, "spa": 87, "spd": 63, "spe": 98}	3	10	1	1	1	5
753	Vanillite	{"hp": 36, "atk": 50, "def": 50, "spa": 65, "spd": 60, "spe": 44}	6	\N	1	1	1	5
754	Vanillish	{"hp": 51, "atk": 65, "def": 65, "spa": 80, "spd": 75, "spe": 59}	6	\N	1	1	1	5
755	Vanilluxe	{"hp": 71, "atk": 95, "def": 85, "spa": 110, "spd": 95, "spe": 79}	6	\N	1	1	1	5
756	Deerling	{"hp": 60, "atk": 60, "def": 50, "spa": 40, "spd": 50, "spe": 75}	1	5	1	1	1	5
757	Sawsbuck	{"hp": 80, "atk": 100, "def": 70, "spa": 60, "spd": 70, "spe": 95}	1	5	1	1	1	5
758	Emolga	{"hp": 55, "atk": 75, "def": 60, "spa": 75, "spd": 60, "spe": 103}	4	10	1	\N	1	5
759	Karrablast	{"hp": 50, "atk": 75, "def": 45, "spa": 40, "spd": 45, "spe": 60}	12	\N	1	1	1	5
760	Escavalier	{"hp": 70, "atk": 135, "def": 105, "spa": 60, "spd": 105, "spe": 20}	12	16	1	1	1	5
761	Foongus	{"hp": 69, "atk": 55, "def": 45, "spa": 55, "spd": 55, "spe": 15}	5	8	1	\N	1	5
762	Amoonguss	{"hp": 114, "atk": 85, "def": 70, "spa": 85, "spd": 80, "spe": 30}	5	8	1	\N	1	5
763	Frillish	{"hp": 55, "atk": 40, "def": 50, "spa": 65, "spd": 85, "spe": 40}	3	14	1	1	1	5
764	Jellicent	{"hp": 100, "atk": 60, "def": 70, "spa": 85, "spd": 105, "spe": 60}	3	14	1	1	1	5
765	Alomomola	{"hp": 165, "atk": 75, "def": 80, "spa": 40, "spd": 45, "spe": 65}	3	\N	1	1	1	5
766	Joltik	{"hp": 50, "atk": 47, "def": 50, "spa": 57, "spd": 50, "spe": 65}	12	4	1	1	1	5
767	Galvantula	{"hp": 70, "atk": 77, "def": 60, "spa": 97, "spd": 60, "spe": 108}	12	4	1	1	1	5
768	Ferroseed	{"hp": 44, "atk": 50, "def": 91, "spa": 24, "spd": 86, "spe": 10}	5	16	1	\N	\N	5
769	Ferrothorn	{"hp": 74, "atk": 94, "def": 131, "spa": 54, "spd": 116, "spe": 20}	5	16	1	\N	1	5
770	Klink	{"hp": 40, "atk": 55, "def": 70, "spa": 45, "spd": 60, "spe": 30}	16	\N	1	1	1	5
771	Klang	{"hp": 60, "atk": 80, "def": 95, "spa": 70, "spd": 85, "spe": 50}	16	\N	1	1	1	5
772	Klinklang	{"hp": 60, "atk": 100, "def": 115, "spa": 70, "spd": 85, "spe": 90}	16	\N	1	1	1	5
773	Tynamo	{"hp": 35, "atk": 55, "def": 40, "spa": 45, "spd": 40, "spe": 60}	4	\N	1	\N	\N	5
774	Eelektrik	{"hp": 65, "atk": 85, "def": 70, "spa": 75, "spd": 70, "spe": 40}	4	\N	1	\N	\N	5
775	Eelektross	{"hp": 85, "atk": 115, "def": 80, "spa": 105, "spd": 80, "spe": 50}	4	\N	1	\N	\N	5
776	Elgyem	{"hp": 55, "atk": 55, "def": 55, "spa": 85, "spd": 55, "spe": 30}	11	\N	1	1	1	5
777	Beheeyem	{"hp": 75, "atk": 75, "def": 75, "spa": 125, "spd": 95, "spe": 40}	11	\N	1	1	1	5
778	Litwick	{"hp": 50, "atk": 30, "def": 55, "spa": 65, "spd": 55, "spe": 20}	14	2	1	1	1	5
779	Lampent	{"hp": 60, "atk": 40, "def": 60, "spa": 95, "spd": 60, "spe": 55}	14	2	1	1	1	5
780	Chandelure	{"hp": 60, "atk": 55, "def": 90, "spa": 145, "spd": 90, "spe": 80}	14	2	1	1	1	5
781	Axew	{"hp": 46, "atk": 87, "def": 60, "spa": 30, "spd": 40, "spe": 57}	15	\N	1	1	1	5
782	Fraxure	{"hp": 66, "atk": 117, "def": 70, "spa": 40, "spd": 50, "spe": 67}	15	\N	1	1	1	5
783	Haxorus	{"hp": 76, "atk": 147, "def": 90, "spa": 60, "spd": 70, "spe": 97}	15	\N	1	1	1	5
784	Cubchoo	{"hp": 55, "atk": 70, "def": 40, "spa": 60, "spd": 40, "spe": 40}	6	\N	1	1	1	5
785	Beartic	{"hp": 95, "atk": 130, "def": 80, "spa": 70, "spd": 80, "spe": 50}	6	\N	1	1	1	5
786	Cryogonal	{"hp": 80, "atk": 50, "def": 50, "spa": 95, "spd": 135, "spe": 105}	6	\N	1	\N	\N	5
787	Shelmet	{"hp": 50, "atk": 40, "def": 85, "spa": 40, "spd": 65, "spe": 25}	12	\N	1	1	1	5
788	Accelgor	{"hp": 80, "atk": 70, "def": 40, "spa": 100, "spd": 60, "spe": 145}	12	\N	1	1	1	5
789	Stunfisk	{"hp": 109, "atk": 66, "def": 84, "spa": 81, "spd": 99, "spe": 32}	9	4	1	1	1	5
790	Stunfisk-Galar	{"hp": 109, "atk": 81, "def": 99, "spa": 66, "spd": 84, "spe": 32}	9	16	1	\N	\N	5
791	Mienfoo	{"hp": 45, "atk": 85, "def": 50, "spa": 55, "spd": 50, "spe": 65}	7	\N	1	1	1	5
792	Mienshao	{"hp": 65, "atk": 125, "def": 60, "spa": 95, "spd": 60, "spe": 105}	7	\N	1	1	1	5
793	Druddigon	{"hp": 77, "atk": 120, "def": 90, "spa": 60, "spd": 90, "spe": 48}	15	\N	1	1	1	5
794	Golett	{"hp": 59, "atk": 74, "def": 50, "spa": 35, "spd": 50, "spe": 35}	9	14	1	1	1	5
795	Golurk	{"hp": 89, "atk": 124, "def": 80, "spa": 55, "spd": 80, "spe": 55}	9	14	1	1	1	5
796	Pawniard	{"hp": 45, "atk": 85, "def": 70, "spa": 40, "spd": 40, "spe": 60}	17	16	1	1	1	5
797	Bisharp	{"hp": 65, "atk": 125, "def": 100, "spa": 60, "spd": 70, "spe": 70}	17	16	1	1	1	5
798	Bouffalant	{"hp": 95, "atk": 110, "def": 95, "spa": 40, "spd": 95, "spe": 55}	1	\N	1	1	1	5
799	Rufflet	{"hp": 70, "atk": 83, "def": 50, "spa": 37, "spd": 50, "spe": 60}	1	10	1	1	1	5
800	Braviary	{"hp": 100, "atk": 123, "def": 75, "spa": 57, "spd": 75, "spe": 80}	1	10	1	1	1	5
801	Braviary-Hisui	{"hp": 110, "atk": 83, "def": 70, "spa": 112, "spd": 70, "spe": 65}	11	10	1	1	1	5
802	Vullaby	{"hp": 70, "atk": 55, "def": 75, "spa": 45, "spd": 65, "spe": 60}	17	10	1	1	1	5
803	Mandibuzz	{"hp": 110, "atk": 65, "def": 105, "spa": 55, "spd": 95, "spe": 80}	17	10	1	1	1	5
804	Heatmor	{"hp": 85, "atk": 97, "def": 66, "spa": 105, "spd": 66, "spe": 65}	2	\N	1	1	1	5
805	Durant	{"hp": 58, "atk": 109, "def": 112, "spa": 48, "spd": 48, "spe": 109}	12	16	1	1	1	5
806	Deino	{"hp": 52, "atk": 65, "def": 50, "spa": 45, "spd": 50, "spe": 38}	17	15	1	\N	\N	5
807	Zweilous	{"hp": 72, "atk": 85, "def": 70, "spa": 65, "spd": 70, "spe": 58}	17	15	1	\N	\N	5
808	Hydreigon	{"hp": 92, "atk": 105, "def": 90, "spa": 125, "spd": 90, "spe": 98}	17	15	1	\N	\N	5
809	Larvesta	{"hp": 55, "atk": 85, "def": 55, "spa": 50, "spd": 55, "spe": 60}	12	2	1	\N	1	5
810	Volcarona	{"hp": 85, "atk": 60, "def": 65, "spa": 135, "spd": 105, "spe": 100}	12	2	1	\N	1	5
811	Cobalion	{"hp": 91, "atk": 90, "def": 129, "spa": 90, "spd": 72, "spe": 108}	16	7	1	\N	\N	5
812	Terrakion	{"hp": 91, "atk": 129, "def": 90, "spa": 72, "spd": 90, "spe": 108}	13	7	1	\N	\N	5
813	Virizion	{"hp": 91, "atk": 90, "def": 72, "spa": 90, "spd": 129, "spe": 108}	5	7	1	\N	\N	5
814	Tornadus	{"hp": 79, "atk": 115, "def": 70, "spa": 125, "spd": 80, "spe": 111}	10	\N	1	\N	1	5
815	Tornadus-Therian	{"hp": 79, "atk": 100, "def": 80, "spa": 110, "spd": 90, "spe": 121}	10	\N	1	\N	\N	5
816	Thundurus	{"hp": 79, "atk": 115, "def": 70, "spa": 125, "spd": 80, "spe": 111}	4	10	1	\N	1	5
817	Thundurus-Therian	{"hp": 79, "atk": 105, "def": 70, "spa": 145, "spd": 80, "spe": 101}	4	10	1	\N	\N	5
818	Reshiram	{"hp": 100, "atk": 120, "def": 100, "spa": 150, "spd": 120, "spe": 90}	15	2	1	\N	\N	5
819	Zekrom	{"hp": 100, "atk": 150, "def": 120, "spa": 120, "spd": 100, "spe": 90}	15	4	1	\N	\N	5
820	Landorus	{"hp": 89, "atk": 125, "def": 90, "spa": 115, "spd": 80, "spe": 101}	9	10	1	\N	1	5
821	Landorus-Therian	{"hp": 89, "atk": 145, "def": 90, "spa": 105, "spd": 80, "spe": 91}	9	10	1	\N	\N	5
822	Kyurem	{"hp": 125, "atk": 130, "def": 90, "spa": 130, "spd": 90, "spe": 95}	15	6	1	\N	\N	5
823	Kyurem-Black	{"hp": 125, "atk": 170, "def": 100, "spa": 120, "spd": 90, "spe": 95}	15	6	1	\N	\N	5
824	Kyurem-White	{"hp": 125, "atk": 120, "def": 90, "spa": 170, "spd": 100, "spe": 95}	15	6	1	\N	\N	5
825	Keldeo	{"hp": 91, "atk": 72, "def": 90, "spa": 129, "spd": 90, "spe": 108}	3	7	1	\N	\N	5
826	Keldeo-Resolute	{"hp": 91, "atk": 72, "def": 90, "spa": 129, "spd": 90, "spe": 108}	3	7	1	\N	\N	5
827	Meloetta	{"hp": 100, "atk": 77, "def": 77, "spa": 128, "spd": 128, "spe": 90}	1	11	1	\N	\N	5
828	Meloetta-Pirouette	{"hp": 100, "atk": 128, "def": 90, "spa": 77, "spd": 77, "spe": 128}	1	7	1	\N	\N	5
829	Genesect	{"hp": 71, "atk": 120, "def": 95, "spa": 120, "spd": 95, "spe": 99}	12	16	1	\N	\N	5
830	Genesect-Douse	{"hp": 71, "atk": 120, "def": 95, "spa": 120, "spd": 95, "spe": 99}	12	16	1	\N	\N	5
831	Genesect-Shock	{"hp": 71, "atk": 120, "def": 95, "spa": 120, "spd": 95, "spe": 99}	12	16	1	\N	\N	5
832	Genesect-Burn	{"hp": 71, "atk": 120, "def": 95, "spa": 120, "spd": 95, "spe": 99}	12	16	1	\N	\N	5
833	Genesect-Chill	{"hp": 71, "atk": 120, "def": 95, "spa": 120, "spd": 95, "spe": 99}	12	16	1	\N	\N	5
834	Chespin	{"hp": 56, "atk": 61, "def": 65, "spa": 48, "spd": 45, "spe": 38}	5	\N	1	\N	1	6
835	Quilladin	{"hp": 61, "atk": 78, "def": 95, "spa": 56, "spd": 58, "spe": 57}	5	\N	1	\N	1	6
836	Chesnaught	{"hp": 88, "atk": 107, "def": 122, "spa": 74, "spd": 75, "spe": 64}	5	7	1	\N	1	6
837	Fennekin	{"hp": 40, "atk": 45, "def": 40, "spa": 62, "spd": 60, "spe": 60}	2	\N	1	\N	1	6
838	Braixen	{"hp": 59, "atk": 59, "def": 58, "spa": 90, "spd": 70, "spe": 73}	2	\N	1	\N	1	6
839	Delphox	{"hp": 75, "atk": 69, "def": 72, "spa": 114, "spd": 100, "spe": 104}	2	11	1	\N	1	6
840	Froakie	{"hp": 41, "atk": 56, "def": 40, "spa": 62, "spd": 44, "spe": 71}	3	\N	1	\N	1	6
841	Frogadier	{"hp": 54, "atk": 63, "def": 52, "spa": 83, "spd": 56, "spe": 97}	3	\N	1	\N	1	6
842	Greninja	{"hp": 72, "atk": 95, "def": 67, "spa": 103, "spd": 71, "spe": 122}	3	17	1	\N	1	6
843	Greninja-Bond	{"hp": 72, "atk": 95, "def": 67, "spa": 103, "spd": 71, "spe": 122}	3	17	1	\N	\N	6
844	Greninja-Ash	{"hp": 72, "atk": 145, "def": 67, "spa": 153, "spd": 71, "spe": 132}	3	17	1	\N	\N	6
845	Bunnelby	{"hp": 38, "atk": 36, "def": 38, "spa": 32, "spd": 36, "spe": 57}	1	\N	1	1	1	6
846	Diggersby	{"hp": 85, "atk": 56, "def": 77, "spa": 50, "spd": 77, "spe": 78}	1	9	1	1	1	6
847	Fletchling	{"hp": 45, "atk": 50, "def": 43, "spa": 40, "spd": 38, "spe": 62}	1	10	1	\N	1	6
848	Fletchinder	{"hp": 62, "atk": 73, "def": 55, "spa": 56, "spd": 52, "spe": 84}	2	10	1	\N	1	6
849	Talonflame	{"hp": 78, "atk": 81, "def": 71, "spa": 74, "spd": 69, "spe": 126}	2	10	1	\N	1	6
850	Scatterbug	{"hp": 38, "atk": 35, "def": 40, "spa": 27, "spd": 25, "spe": 35}	12	\N	1	1	1	6
851	Spewpa	{"hp": 45, "atk": 22, "def": 60, "spa": 27, "spd": 30, "spe": 29}	12	\N	1	\N	1	6
852	Vivillon	{"hp": 80, "atk": 52, "def": 50, "spa": 90, "spd": 50, "spe": 89}	12	10	1	1	1	6
853	Vivillon-Fancy	{"hp": 80, "atk": 52, "def": 50, "spa": 90, "spd": 50, "spe": 89}	12	10	1	1	1	6
854	Vivillon-Pokeball	{"hp": 80, "atk": 52, "def": 50, "spa": 90, "spd": 50, "spe": 89}	12	10	1	1	1	6
855	Litleo	{"hp": 62, "atk": 50, "def": 58, "spa": 73, "spd": 54, "spe": 72}	2	1	1	1	1	6
856	Pyroar	{"hp": 86, "atk": 68, "def": 72, "spa": 109, "spd": 66, "spe": 106}	2	1	1	1	1	6
857	Flabébé	{"hp": 44, "atk": 38, "def": 39, "spa": 61, "spd": 79, "spe": 42}	18	\N	1	\N	1	6
858	Floette	{"hp": 54, "atk": 45, "def": 47, "spa": 75, "spd": 98, "spe": 52}	18	\N	1	\N	1	6
859	Floette-Eternal	{"hp": 74, "atk": 65, "def": 67, "spa": 125, "spd": 128, "spe": 92}	18	\N	1	\N	\N	6
860	Florges	{"hp": 78, "atk": 65, "def": 68, "spa": 112, "spd": 154, "spe": 75}	18	\N	1	\N	1	6
861	Skiddo	{"hp": 66, "atk": 65, "def": 48, "spa": 62, "spd": 57, "spe": 52}	5	\N	1	\N	1	6
862	Gogoat	{"hp": 123, "atk": 100, "def": 62, "spa": 97, "spd": 81, "spe": 68}	5	\N	1	\N	1	6
863	Pancham	{"hp": 67, "atk": 82, "def": 62, "spa": 46, "spd": 48, "spe": 43}	7	\N	1	1	1	6
864	Pangoro	{"hp": 95, "atk": 124, "def": 78, "spa": 69, "spd": 71, "spe": 58}	7	17	1	1	1	6
865	Furfrou	{"hp": 75, "atk": 80, "def": 60, "spa": 65, "spd": 90, "spe": 102}	1	\N	1	\N	\N	6
866	Espurr	{"hp": 62, "atk": 48, "def": 54, "spa": 63, "spd": 60, "spe": 68}	11	\N	1	1	1	6
867	Meowstic	{"hp": 74, "atk": 48, "def": 76, "spa": 83, "spd": 81, "spe": 104}	11	\N	1	1	1	6
868	Meowstic-F	{"hp": 74, "atk": 48, "def": 76, "spa": 83, "spd": 81, "spe": 104}	11	\N	1	1	1	6
869	Honedge	{"hp": 45, "atk": 80, "def": 100, "spa": 35, "spd": 37, "spe": 28}	16	14	1	\N	\N	6
870	Doublade	{"hp": 59, "atk": 110, "def": 150, "spa": 45, "spd": 49, "spe": 35}	16	14	1	\N	\N	6
871	Aegislash	{"hp": 60, "atk": 50, "def": 140, "spa": 50, "spd": 140, "spe": 60}	16	14	1	\N	\N	6
872	Aegislash-Blade	{"hp": 60, "atk": 140, "def": 50, "spa": 140, "spd": 50, "spe": 60}	16	14	1	\N	\N	6
873	Spritzee	{"hp": 78, "atk": 52, "def": 60, "spa": 63, "spd": 65, "spe": 23}	18	\N	1	\N	1	6
874	Aromatisse	{"hp": 101, "atk": 72, "def": 72, "spa": 99, "spd": 89, "spe": 29}	18	\N	1	\N	1	6
875	Swirlix	{"hp": 62, "atk": 48, "def": 66, "spa": 59, "spd": 57, "spe": 49}	18	\N	1	\N	1	6
876	Slurpuff	{"hp": 82, "atk": 80, "def": 86, "spa": 85, "spd": 75, "spe": 72}	18	\N	1	\N	1	6
877	Inkay	{"hp": 53, "atk": 54, "def": 53, "spa": 37, "spd": 46, "spe": 45}	17	11	1	1	1	6
878	Malamar	{"hp": 86, "atk": 92, "def": 88, "spa": 68, "spd": 75, "spe": 73}	17	11	1	1	1	6
879	Binacle	{"hp": 42, "atk": 52, "def": 67, "spa": 39, "spd": 56, "spe": 50}	13	3	1	1	1	6
880	Barbaracle	{"hp": 72, "atk": 105, "def": 115, "spa": 54, "spd": 86, "spe": 68}	13	3	1	1	1	6
881	Skrelp	{"hp": 50, "atk": 60, "def": 60, "spa": 60, "spd": 60, "spe": 30}	8	3	1	1	1	6
882	Dragalge	{"hp": 65, "atk": 75, "def": 90, "spa": 97, "spd": 123, "spe": 44}	8	15	1	1	1	6
883	Clauncher	{"hp": 50, "atk": 53, "def": 62, "spa": 58, "spd": 63, "spe": 44}	3	\N	1	\N	\N	6
884	Clawitzer	{"hp": 71, "atk": 73, "def": 88, "spa": 120, "spd": 89, "spe": 59}	3	\N	1	\N	\N	6
885	Helioptile	{"hp": 44, "atk": 38, "def": 33, "spa": 61, "spd": 43, "spe": 70}	4	1	1	1	1	6
886	Heliolisk	{"hp": 62, "atk": 55, "def": 52, "spa": 109, "spd": 94, "spe": 109}	4	1	1	1	1	6
887	Tyrunt	{"hp": 58, "atk": 89, "def": 77, "spa": 45, "spd": 45, "spe": 48}	13	15	1	\N	1	6
888	Tyrantrum	{"hp": 82, "atk": 121, "def": 119, "spa": 69, "spd": 59, "spe": 71}	13	15	1	\N	1	6
889	Amaura	{"hp": 77, "atk": 59, "def": 50, "spa": 67, "spd": 63, "spe": 46}	13	6	1	\N	1	6
890	Aurorus	{"hp": 123, "atk": 77, "def": 72, "spa": 99, "spd": 92, "spe": 58}	13	6	1	\N	1	6
891	Sylveon	{"hp": 95, "atk": 65, "def": 65, "spa": 110, "spd": 130, "spe": 60}	18	\N	1	\N	1	6
892	Hawlucha	{"hp": 78, "atk": 92, "def": 75, "spa": 74, "spd": 63, "spe": 118}	7	10	1	1	1	6
893	Dedenne	{"hp": 67, "atk": 58, "def": 57, "spa": 81, "spd": 67, "spe": 101}	4	18	1	1	1	6
894	Carbink	{"hp": 50, "atk": 50, "def": 150, "spa": 50, "spd": 150, "spe": 50}	13	18	1	\N	1	6
895	Goomy	{"hp": 45, "atk": 50, "def": 35, "spa": 55, "spd": 75, "spe": 40}	15	\N	1	1	1	6
896	Sliggoo	{"hp": 68, "atk": 75, "def": 53, "spa": 83, "spd": 113, "spe": 60}	15	\N	1	1	1	6
897	Sliggoo-Hisui	{"hp": 58, "atk": 75, "def": 83, "spa": 83, "spd": 113, "spe": 40}	16	15	1	1	1	6
898	Goodra	{"hp": 90, "atk": 100, "def": 70, "spa": 110, "spd": 150, "spe": 80}	15	\N	1	1	1	6
899	Goodra-Hisui	{"hp": 80, "atk": 100, "def": 100, "spa": 110, "spd": 150, "spe": 60}	16	15	1	1	1	6
900	Klefki	{"hp": 57, "atk": 80, "def": 91, "spa": 80, "spd": 87, "spe": 75}	16	18	1	\N	1	6
901	Phantump	{"hp": 43, "atk": 70, "def": 48, "spa": 50, "spd": 60, "spe": 38}	14	5	1	1	1	6
902	Trevenant	{"hp": 85, "atk": 110, "def": 76, "spa": 65, "spd": 82, "spe": 56}	14	5	1	1	1	6
903	Pumpkaboo	{"hp": 49, "atk": 66, "def": 70, "spa": 44, "spd": 55, "spe": 51}	14	5	1	1	1	6
904	Pumpkaboo-Small	{"hp": 44, "atk": 66, "def": 70, "spa": 44, "spd": 55, "spe": 56}	14	5	1	1	1	6
905	Pumpkaboo-Large	{"hp": 54, "atk": 66, "def": 70, "spa": 44, "spd": 55, "spe": 46}	14	5	1	1	1	6
906	Pumpkaboo-Super	{"hp": 59, "atk": 66, "def": 70, "spa": 44, "spd": 55, "spe": 41}	14	5	1	1	1	6
907	Gourgeist	{"hp": 65, "atk": 90, "def": 122, "spa": 58, "spd": 75, "spe": 84}	14	5	1	1	1	6
908	Gourgeist-Small	{"hp": 55, "atk": 85, "def": 122, "spa": 58, "spd": 75, "spe": 99}	14	5	1	1	1	6
909	Gourgeist-Large	{"hp": 75, "atk": 95, "def": 122, "spa": 58, "spd": 75, "spe": 69}	14	5	1	1	1	6
910	Gourgeist-Super	{"hp": 85, "atk": 100, "def": 122, "spa": 58, "spd": 75, "spe": 54}	14	5	1	1	1	6
911	Bergmite	{"hp": 55, "atk": 69, "def": 85, "spa": 32, "spd": 35, "spe": 28}	6	\N	1	1	1	6
912	Avalugg	{"hp": 95, "atk": 117, "def": 184, "spa": 44, "spd": 46, "spe": 28}	6	\N	1	1	1	6
913	Avalugg-Hisui	{"hp": 95, "atk": 127, "def": 184, "spa": 34, "spd": 36, "spe": 38}	6	13	1	1	1	6
914	Noibat	{"hp": 40, "atk": 30, "def": 35, "spa": 45, "spd": 40, "spe": 55}	10	15	1	1	1	6
915	Noivern	{"hp": 85, "atk": 70, "def": 80, "spa": 97, "spd": 80, "spe": 123}	10	15	1	1	1	6
916	Xerneas	{"hp": 126, "atk": 131, "def": 95, "spa": 131, "spd": 98, "spe": 99}	18	\N	1	\N	\N	6
917	Xerneas-Neutral	{"hp": 126, "atk": 131, "def": 95, "spa": 131, "spd": 98, "spe": 99}	18	\N	1	\N	\N	6
918	Yveltal	{"hp": 126, "atk": 131, "def": 95, "spa": 131, "spd": 98, "spe": 99}	17	10	1	\N	\N	6
919	Zygarde	{"hp": 108, "atk": 100, "def": 121, "spa": 81, "spd": 95, "spe": 95}	15	9	1	\N	\N	6
920	Zygarde-10%	{"hp": 54, "atk": 100, "def": 71, "spa": 61, "spd": 85, "spe": 115}	15	9	1	\N	\N	6
921	Zygarde-Complete	{"hp": 216, "atk": 100, "def": 121, "spa": 91, "spd": 95, "spe": 85}	15	9	1	\N	\N	6
922	Diancie	{"hp": 50, "atk": 100, "def": 150, "spa": 100, "spd": 150, "spe": 50}	13	18	1	\N	\N	6
923	Diancie-Mega	{"hp": 50, "atk": 160, "def": 110, "spa": 160, "spd": 110, "spe": 110}	13	18	1	\N	\N	6
924	Hoopa	{"hp": 80, "atk": 110, "def": 60, "spa": 150, "spd": 130, "spe": 70}	11	14	1	\N	\N	6
925	Hoopa-Unbound	{"hp": 80, "atk": 160, "def": 60, "spa": 170, "spd": 130, "spe": 80}	11	17	1	\N	\N	6
926	Volcanion	{"hp": 80, "atk": 110, "def": 120, "spa": 130, "spd": 90, "spe": 70}	2	3	1	\N	\N	6
927	Rowlet	{"hp": 68, "atk": 55, "def": 55, "spa": 50, "spd": 50, "spe": 42}	5	10	1	\N	1	7
928	Dartrix	{"hp": 78, "atk": 75, "def": 75, "spa": 70, "spd": 70, "spe": 52}	5	10	1	\N	1	7
929	Decidueye	{"hp": 78, "atk": 107, "def": 75, "spa": 100, "spd": 100, "spe": 70}	5	14	1	\N	1	7
930	Decidueye-Hisui	{"hp": 88, "atk": 112, "def": 80, "spa": 95, "spd": 95, "spe": 60}	5	7	1	\N	1	7
931	Litten	{"hp": 45, "atk": 65, "def": 40, "spa": 60, "spd": 40, "spe": 70}	2	\N	1	\N	1	7
932	Torracat	{"hp": 65, "atk": 85, "def": 50, "spa": 80, "spd": 50, "spe": 90}	2	\N	1	\N	1	7
933	Incineroar	{"hp": 95, "atk": 115, "def": 90, "spa": 80, "spd": 90, "spe": 60}	2	17	1	\N	1	7
934	Popplio	{"hp": 50, "atk": 54, "def": 54, "spa": 66, "spd": 56, "spe": 40}	3	\N	1	\N	1	7
935	Brionne	{"hp": 60, "atk": 69, "def": 69, "spa": 91, "spd": 81, "spe": 50}	3	\N	1	\N	1	7
936	Primarina	{"hp": 80, "atk": 74, "def": 74, "spa": 126, "spd": 116, "spe": 60}	3	18	1	\N	1	7
937	Pikipek	{"hp": 35, "atk": 75, "def": 30, "spa": 30, "spd": 30, "spe": 65}	1	10	1	1	1	7
938	Trumbeak	{"hp": 55, "atk": 85, "def": 50, "spa": 40, "spd": 50, "spe": 75}	1	10	1	1	1	7
939	Toucannon	{"hp": 80, "atk": 120, "def": 75, "spa": 75, "spd": 75, "spe": 60}	1	10	1	1	1	7
940	Yungoos	{"hp": 48, "atk": 70, "def": 30, "spa": 30, "spd": 30, "spe": 45}	1	\N	1	1	1	7
941	Gumshoos	{"hp": 88, "atk": 110, "def": 60, "spa": 55, "spd": 60, "spe": 45}	1	\N	1	1	1	7
942	Gumshoos-Totem	{"hp": 88, "atk": 110, "def": 60, "spa": 55, "spd": 60, "spe": 45}	1	\N	1	\N	\N	7
943	Grubbin	{"hp": 47, "atk": 62, "def": 45, "spa": 55, "spd": 45, "spe": 46}	12	\N	1	\N	\N	7
944	Charjabug	{"hp": 57, "atk": 82, "def": 95, "spa": 55, "spd": 75, "spe": 36}	12	4	1	\N	\N	7
945	Vikavolt	{"hp": 77, "atk": 70, "def": 90, "spa": 145, "spd": 75, "spe": 43}	12	4	1	\N	\N	7
946	Vikavolt-Totem	{"hp": 77, "atk": 70, "def": 90, "spa": 145, "spd": 75, "spe": 43}	12	4	1	\N	\N	7
947	Crabrawler	{"hp": 47, "atk": 82, "def": 57, "spa": 42, "spd": 47, "spe": 63}	7	\N	1	1	1	7
948	Crabominable	{"hp": 97, "atk": 132, "def": 77, "spa": 62, "spd": 67, "spe": 43}	7	6	1	1	1	7
949	Oricorio	{"hp": 75, "atk": 70, "def": 70, "spa": 98, "spd": 70, "spe": 93}	2	10	1	\N	\N	7
950	Oricorio-Pom-Pom	{"hp": 75, "atk": 70, "def": 70, "spa": 98, "spd": 70, "spe": 93}	4	10	1	\N	\N	7
951	Oricorio-Pa'u	{"hp": 75, "atk": 70, "def": 70, "spa": 98, "spd": 70, "spe": 93}	11	10	1	\N	\N	7
952	Oricorio-Sensu	{"hp": 75, "atk": 70, "def": 70, "spa": 98, "spd": 70, "spe": 93}	14	10	1	\N	\N	7
953	Cutiefly	{"hp": 40, "atk": 45, "def": 40, "spa": 55, "spd": 40, "spe": 84}	12	18	1	1	1	7
954	Ribombee	{"hp": 60, "atk": 55, "def": 60, "spa": 95, "spd": 70, "spe": 124}	12	18	1	1	1	7
955	Ribombee-Totem	{"hp": 60, "atk": 55, "def": 60, "spa": 95, "spd": 70, "spe": 124}	12	18	1	\N	\N	7
956	Rockruff	{"hp": 45, "atk": 65, "def": 40, "spa": 30, "spd": 40, "spe": 60}	13	\N	1	1	1	7
957	Lycanroc	{"hp": 75, "atk": 115, "def": 65, "spa": 55, "spd": 65, "spe": 112}	13	\N	1	1	1	7
958	Lycanroc-Midnight	{"hp": 85, "atk": 115, "def": 75, "spa": 55, "spd": 75, "spe": 82}	13	\N	1	1	1	7
959	Lycanroc-Dusk	{"hp": 75, "atk": 117, "def": 65, "spa": 55, "spd": 65, "spe": 110}	13	\N	1	\N	\N	7
960	Wishiwashi	{"hp": 45, "atk": 20, "def": 20, "spa": 25, "spd": 25, "spe": 40}	3	\N	1	\N	\N	7
961	Wishiwashi-School	{"hp": 45, "atk": 140, "def": 130, "spa": 140, "spd": 135, "spe": 30}	3	\N	1	\N	\N	7
962	Mareanie	{"hp": 50, "atk": 53, "def": 62, "spa": 43, "spd": 52, "spe": 45}	8	3	1	1	1	7
963	Toxapex	{"hp": 50, "atk": 63, "def": 152, "spa": 53, "spd": 142, "spe": 35}	8	3	1	1	1	7
964	Mudbray	{"hp": 70, "atk": 100, "def": 70, "spa": 45, "spd": 55, "spe": 45}	9	\N	1	1	1	7
965	Mudsdale	{"hp": 100, "atk": 125, "def": 100, "spa": 55, "spd": 85, "spe": 35}	9	\N	1	1	1	7
966	Dewpider	{"hp": 38, "atk": 40, "def": 52, "spa": 40, "spd": 72, "spe": 27}	3	12	1	\N	1	7
967	Araquanid	{"hp": 68, "atk": 70, "def": 92, "spa": 50, "spd": 132, "spe": 42}	3	12	1	\N	1	7
968	Araquanid-Totem	{"hp": 68, "atk": 70, "def": 92, "spa": 50, "spd": 132, "spe": 42}	3	12	1	\N	\N	7
969	Fomantis	{"hp": 40, "atk": 55, "def": 35, "spa": 50, "spd": 35, "spe": 35}	5	\N	1	\N	1	7
970	Lurantis	{"hp": 70, "atk": 105, "def": 90, "spa": 80, "spd": 90, "spe": 45}	5	\N	1	\N	1	7
971	Lurantis-Totem	{"hp": 70, "atk": 105, "def": 90, "spa": 80, "spd": 90, "spe": 45}	5	\N	1	\N	\N	7
972	Morelull	{"hp": 40, "atk": 35, "def": 55, "spa": 65, "spd": 75, "spe": 15}	5	18	1	1	1	7
973	Shiinotic	{"hp": 60, "atk": 45, "def": 80, "spa": 90, "spd": 100, "spe": 30}	5	18	1	1	1	7
974	Salandit	{"hp": 48, "atk": 44, "def": 40, "spa": 71, "spd": 40, "spe": 77}	8	2	1	\N	1	7
975	Salazzle	{"hp": 68, "atk": 64, "def": 60, "spa": 111, "spd": 60, "spe": 117}	8	2	1	\N	1	7
976	Salazzle-Totem	{"hp": 68, "atk": 64, "def": 60, "spa": 111, "spd": 60, "spe": 117}	8	2	1	\N	\N	7
977	Stufful	{"hp": 70, "atk": 75, "def": 50, "spa": 45, "spd": 50, "spe": 50}	1	7	1	1	1	7
978	Bewear	{"hp": 120, "atk": 125, "def": 80, "spa": 55, "spd": 60, "spe": 60}	1	7	1	1	1	7
979	Bounsweet	{"hp": 42, "atk": 30, "def": 38, "spa": 30, "spd": 38, "spe": 32}	5	\N	1	1	1	7
980	Steenee	{"hp": 52, "atk": 40, "def": 48, "spa": 40, "spd": 48, "spe": 62}	5	\N	1	1	1	7
981	Tsareena	{"hp": 72, "atk": 120, "def": 98, "spa": 50, "spd": 98, "spe": 72}	5	\N	1	1	1	7
982	Comfey	{"hp": 51, "atk": 52, "def": 90, "spa": 82, "spd": 110, "spe": 100}	18	\N	1	1	1	7
983	Oranguru	{"hp": 90, "atk": 60, "def": 80, "spa": 90, "spd": 110, "spe": 60}	1	11	1	1	1	7
984	Passimian	{"hp": 100, "atk": 120, "def": 90, "spa": 40, "spd": 60, "spe": 80}	7	\N	1	\N	1	7
985	Wimpod	{"hp": 25, "atk": 35, "def": 40, "spa": 20, "spd": 30, "spe": 80}	12	3	1	\N	\N	7
986	Golisopod	{"hp": 75, "atk": 125, "def": 140, "spa": 60, "spd": 90, "spe": 40}	12	3	1	\N	\N	7
987	Sandygast	{"hp": 55, "atk": 55, "def": 80, "spa": 70, "spd": 45, "spe": 15}	14	9	1	\N	1	7
988	Palossand	{"hp": 85, "atk": 75, "def": 110, "spa": 100, "spd": 75, "spe": 35}	14	9	1	\N	1	7
989	Pyukumuku	{"hp": 55, "atk": 60, "def": 130, "spa": 30, "spd": 130, "spe": 5}	3	\N	1	\N	1	7
990	Type: Null	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 59}	1	\N	1	\N	\N	7
991	Silvally	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	1	\N	1	\N	\N	7
992	Silvally-Bug	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	12	\N	1	\N	\N	7
993	Silvally-Dark	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	17	\N	1	\N	\N	7
994	Silvally-Dragon	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	15	\N	1	\N	\N	7
995	Silvally-Electric	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	4	\N	1	\N	\N	7
996	Silvally-Fairy	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	18	\N	1	\N	\N	7
997	Silvally-Fighting	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	7	\N	1	\N	\N	7
998	Silvally-Fire	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	2	\N	1	\N	\N	7
999	Silvally-Flying	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	10	\N	1	\N	\N	7
1000	Silvally-Ghost	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	14	\N	1	\N	\N	7
1001	Silvally-Grass	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	5	\N	1	\N	\N	7
1002	Silvally-Ground	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	9	\N	1	\N	\N	7
1003	Silvally-Ice	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	6	\N	1	\N	\N	7
1004	Silvally-Poison	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	8	\N	1	\N	\N	7
1005	Silvally-Psychic	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	11	\N	1	\N	\N	7
1006	Silvally-Rock	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	13	\N	1	\N	\N	7
1007	Silvally-Steel	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	16	\N	1	\N	\N	7
1008	Silvally-Water	{"hp": 95, "atk": 95, "def": 95, "spa": 95, "spd": 95, "spe": 95}	3	\N	1	\N	\N	7
1009	Minior	{"hp": 60, "atk": 100, "def": 60, "spa": 100, "spd": 60, "spe": 120}	13	10	1	\N	\N	7
1010	Minior-Meteor	{"hp": 60, "atk": 60, "def": 100, "spa": 60, "spd": 100, "spe": 60}	13	10	1	\N	\N	7
1011	Komala	{"hp": 65, "atk": 115, "def": 65, "spa": 75, "spd": 95, "spe": 65}	1	\N	1	\N	\N	7
1012	Turtonator	{"hp": 60, "atk": 78, "def": 135, "spa": 91, "spd": 85, "spe": 36}	2	15	1	\N	\N	7
1013	Togedemaru	{"hp": 65, "atk": 98, "def": 63, "spa": 40, "spd": 73, "spe": 96}	4	16	1	1	1	7
1014	Togedemaru-Totem	{"hp": 65, "atk": 98, "def": 63, "spa": 40, "spd": 73, "spe": 96}	4	16	1	\N	\N	7
1015	Mimikyu	{"hp": 55, "atk": 90, "def": 80, "spa": 50, "spd": 105, "spe": 96}	14	18	1	\N	\N	7
1016	Mimikyu-Busted	{"hp": 55, "atk": 90, "def": 80, "spa": 50, "spd": 105, "spe": 96}	14	18	1	\N	\N	7
1017	Mimikyu-Totem	{"hp": 55, "atk": 90, "def": 80, "spa": 50, "spd": 105, "spe": 96}	14	18	1	\N	\N	7
1018	Mimikyu-Busted-Totem	{"hp": 55, "atk": 90, "def": 80, "spa": 50, "spd": 105, "spe": 96}	14	18	1	\N	\N	7
1019	Bruxish	{"hp": 68, "atk": 105, "def": 70, "spa": 70, "spd": 70, "spe": 92}	3	11	1	1	1	7
1020	Drampa	{"hp": 78, "atk": 60, "def": 85, "spa": 135, "spd": 91, "spe": 36}	1	15	1	1	1	7
1021	Dhelmise	{"hp": 70, "atk": 131, "def": 100, "spa": 86, "spd": 90, "spe": 40}	14	5	1	\N	\N	7
1022	Jangmo-o	{"hp": 45, "atk": 55, "def": 65, "spa": 45, "spd": 45, "spe": 45}	15	\N	1	1	1	7
1023	Hakamo-o	{"hp": 55, "atk": 75, "def": 90, "spa": 65, "spd": 70, "spe": 65}	15	7	1	1	1	7
1024	Kommo-o	{"hp": 75, "atk": 110, "def": 125, "spa": 100, "spd": 105, "spe": 85}	15	7	1	1	1	7
1025	Kommo-o-Totem	{"hp": 75, "atk": 110, "def": 125, "spa": 100, "spd": 105, "spe": 85}	15	7	1	\N	\N	7
1026	Tapu Koko	{"hp": 70, "atk": 115, "def": 85, "spa": 95, "spd": 75, "spe": 130}	4	18	1	\N	1	7
1027	Tapu Lele	{"hp": 70, "atk": 85, "def": 75, "spa": 130, "spd": 115, "spe": 95}	11	18	1	\N	1	7
1028	Tapu Bulu	{"hp": 70, "atk": 130, "def": 115, "spa": 85, "spd": 95, "spe": 75}	5	18	1	\N	1	7
1029	Tapu Fini	{"hp": 70, "atk": 75, "def": 115, "spa": 95, "spd": 130, "spe": 85}	3	18	1	\N	1	7
1030	Cosmog	{"hp": 43, "atk": 29, "def": 31, "spa": 29, "spd": 31, "spe": 37}	11	\N	1	\N	\N	7
1031	Cosmoem	{"hp": 43, "atk": 29, "def": 131, "spa": 29, "spd": 131, "spe": 37}	11	\N	1	\N	\N	7
1032	Solgaleo	{"hp": 137, "atk": 137, "def": 107, "spa": 113, "spd": 89, "spe": 97}	11	16	1	\N	\N	7
1033	Lunala	{"hp": 137, "atk": 113, "def": 89, "spa": 137, "spd": 107, "spe": 97}	11	14	1	\N	\N	7
1034	Nihilego	{"hp": 109, "atk": 53, "def": 47, "spa": 127, "spd": 131, "spe": 103}	13	8	1	\N	\N	7
1035	Buzzwole	{"hp": 107, "atk": 139, "def": 139, "spa": 53, "spd": 53, "spe": 79}	12	7	1	\N	\N	7
1036	Pheromosa	{"hp": 71, "atk": 137, "def": 37, "spa": 137, "spd": 37, "spe": 151}	12	7	1	\N	\N	7
1037	Xurkitree	{"hp": 83, "atk": 89, "def": 71, "spa": 173, "spd": 71, "spe": 83}	4	\N	1	\N	\N	7
1038	Celesteela	{"hp": 97, "atk": 101, "def": 103, "spa": 107, "spd": 101, "spe": 61}	16	10	1	\N	\N	7
1039	Kartana	{"hp": 59, "atk": 181, "def": 131, "spa": 59, "spd": 31, "spe": 109}	5	16	1	\N	\N	7
1040	Guzzlord	{"hp": 223, "atk": 101, "def": 53, "spa": 97, "spd": 53, "spe": 43}	17	15	1	\N	\N	7
1041	Necrozma	{"hp": 97, "atk": 107, "def": 101, "spa": 127, "spd": 89, "spe": 79}	11	\N	1	\N	\N	7
1042	Necrozma-Dusk-Mane	{"hp": 97, "atk": 157, "def": 127, "spa": 113, "spd": 109, "spe": 77}	11	16	1	\N	\N	7
1043	Necrozma-Dawn-Wings	{"hp": 97, "atk": 113, "def": 109, "spa": 157, "spd": 127, "spe": 77}	11	14	1	\N	\N	7
1044	Necrozma-Ultra	{"hp": 97, "atk": 167, "def": 97, "spa": 167, "spd": 97, "spe": 129}	11	15	1	\N	\N	7
1045	Magearna	{"hp": 80, "atk": 95, "def": 115, "spa": 130, "spd": 115, "spe": 65}	16	18	1	\N	\N	7
1046	Magearna-Original	{"hp": 80, "atk": 95, "def": 115, "spa": 130, "spd": 115, "spe": 65}	16	18	1	\N	\N	7
1047	Marshadow	{"hp": 90, "atk": 125, "def": 80, "spa": 90, "spd": 90, "spe": 125}	7	14	1	\N	\N	7
1048	Poipole	{"hp": 67, "atk": 73, "def": 67, "spa": 73, "spd": 67, "spe": 73}	8	\N	1	\N	\N	7
1049	Naganadel	{"hp": 73, "atk": 73, "def": 73, "spa": 127, "spd": 73, "spe": 121}	8	15	1	\N	\N	7
1050	Stakataka	{"hp": 61, "atk": 131, "def": 211, "spa": 53, "spd": 101, "spe": 13}	13	16	1	\N	\N	7
1051	Blacephalon	{"hp": 53, "atk": 127, "def": 53, "spa": 151, "spd": 79, "spe": 107}	2	14	1	\N	\N	7
1052	Zeraora	{"hp": 88, "atk": 112, "def": 75, "spa": 102, "spd": 80, "spe": 143}	4	\N	1	\N	\N	7
1053	Meltan	{"hp": 46, "atk": 65, "def": 65, "spa": 55, "spd": 35, "spe": 34}	16	\N	1	\N	\N	7
1054	Melmetal	{"hp": 135, "atk": 143, "def": 143, "spa": 80, "spd": 65, "spe": 34}	16	\N	1	\N	\N	7
1055	Melmetal-Gmax	{"hp": 135, "atk": 143, "def": 143, "spa": 80, "spd": 65, "spe": 34}	16	\N	1	\N	\N	7
1056	Grookey	{"hp": 50, "atk": 65, "def": 50, "spa": 40, "spd": 40, "spe": 65}	5	\N	1	\N	1	8
1057	Thwackey	{"hp": 70, "atk": 85, "def": 70, "spa": 55, "spd": 60, "spe": 80}	5	\N	1	\N	1	8
1058	Rillaboom	{"hp": 100, "atk": 125, "def": 90, "spa": 60, "spd": 70, "spe": 85}	5	\N	1	\N	1	8
1059	Rillaboom-Gmax	{"hp": 100, "atk": 125, "def": 90, "spa": 60, "spd": 70, "spe": 85}	5	\N	1	\N	1	8
1060	Scorbunny	{"hp": 50, "atk": 71, "def": 40, "spa": 40, "spd": 40, "spe": 69}	2	\N	1	\N	1	8
1061	Raboot	{"hp": 65, "atk": 86, "def": 60, "spa": 55, "spd": 60, "spe": 94}	2	\N	1	\N	1	8
1062	Cinderace	{"hp": 80, "atk": 116, "def": 75, "spa": 65, "spd": 75, "spe": 119}	2	\N	1	\N	1	8
1063	Cinderace-Gmax	{"hp": 80, "atk": 116, "def": 75, "spa": 65, "spd": 75, "spe": 119}	2	\N	1	\N	1	8
1064	Sobble	{"hp": 50, "atk": 40, "def": 40, "spa": 70, "spd": 40, "spe": 70}	3	\N	1	\N	1	8
1065	Drizzile	{"hp": 65, "atk": 60, "def": 55, "spa": 95, "spd": 55, "spe": 90}	3	\N	1	\N	1	8
1066	Inteleon	{"hp": 70, "atk": 85, "def": 65, "spa": 125, "spd": 65, "spe": 120}	3	\N	1	\N	1	8
1067	Inteleon-Gmax	{"hp": 70, "atk": 85, "def": 65, "spa": 125, "spd": 65, "spe": 120}	3	\N	1	\N	1	8
1068	Skwovet	{"hp": 70, "atk": 55, "def": 55, "spa": 35, "spd": 35, "spe": 25}	1	\N	1	\N	1	8
1069	Greedent	{"hp": 120, "atk": 95, "def": 95, "spa": 55, "spd": 75, "spe": 20}	1	\N	1	\N	1	8
1070	Rookidee	{"hp": 38, "atk": 47, "def": 35, "spa": 33, "spd": 35, "spe": 57}	10	\N	1	1	1	8
1071	Corvisquire	{"hp": 68, "atk": 67, "def": 55, "spa": 43, "spd": 55, "spe": 77}	10	\N	1	1	1	8
1072	Corviknight	{"hp": 98, "atk": 87, "def": 105, "spa": 53, "spd": 85, "spe": 67}	10	16	1	1	1	8
1073	Corviknight-Gmax	{"hp": 98, "atk": 87, "def": 105, "spa": 53, "spd": 85, "spe": 67}	10	16	1	1	1	8
1074	Blipbug	{"hp": 25, "atk": 20, "def": 20, "spa": 25, "spd": 45, "spe": 45}	12	\N	1	1	1	8
1075	Dottler	{"hp": 50, "atk": 35, "def": 80, "spa": 50, "spd": 90, "spe": 30}	12	11	1	1	1	8
1076	Orbeetle	{"hp": 60, "atk": 45, "def": 110, "spa": 80, "spd": 120, "spe": 90}	12	11	1	1	1	8
1077	Orbeetle-Gmax	{"hp": 60, "atk": 45, "def": 110, "spa": 80, "spd": 120, "spe": 90}	12	11	1	1	1	8
1078	Nickit	{"hp": 40, "atk": 28, "def": 28, "spa": 47, "spd": 52, "spe": 50}	17	\N	1	1	1	8
1079	Thievul	{"hp": 70, "atk": 58, "def": 58, "spa": 87, "spd": 92, "spe": 90}	17	\N	1	1	1	8
1080	Gossifleur	{"hp": 40, "atk": 40, "def": 60, "spa": 40, "spd": 60, "spe": 10}	5	\N	1	1	1	8
1081	Eldegoss	{"hp": 60, "atk": 50, "def": 90, "spa": 80, "spd": 120, "spe": 60}	5	\N	1	1	1	8
1082	Wooloo	{"hp": 42, "atk": 40, "def": 55, "spa": 40, "spd": 45, "spe": 48}	1	\N	1	1	1	8
1083	Dubwool	{"hp": 72, "atk": 80, "def": 100, "spa": 60, "spd": 90, "spe": 88}	1	\N	1	1	1	8
1084	Chewtle	{"hp": 50, "atk": 64, "def": 50, "spa": 38, "spd": 38, "spe": 44}	3	\N	1	1	1	8
1085	Drednaw	{"hp": 90, "atk": 115, "def": 90, "spa": 48, "spd": 68, "spe": 74}	3	13	1	1	1	8
1086	Drednaw-Gmax	{"hp": 90, "atk": 115, "def": 90, "spa": 48, "spd": 68, "spe": 74}	3	13	1	1	1	8
1087	Yamper	{"hp": 59, "atk": 45, "def": 50, "spa": 40, "spd": 50, "spe": 26}	4	\N	1	\N	1	8
1088	Boltund	{"hp": 69, "atk": 90, "def": 60, "spa": 90, "spd": 60, "spe": 121}	4	\N	1	\N	1	8
1089	Rolycoly	{"hp": 30, "atk": 40, "def": 50, "spa": 40, "spd": 50, "spe": 30}	13	\N	1	1	1	8
1090	Carkol	{"hp": 80, "atk": 60, "def": 90, "spa": 60, "spd": 70, "spe": 50}	13	2	1	1	1	8
1091	Coalossal	{"hp": 110, "atk": 80, "def": 120, "spa": 80, "spd": 90, "spe": 30}	13	2	1	1	1	8
1092	Coalossal-Gmax	{"hp": 110, "atk": 80, "def": 120, "spa": 80, "spd": 90, "spe": 30}	13	2	1	1	1	8
1093	Applin	{"hp": 40, "atk": 40, "def": 80, "spa": 40, "spd": 40, "spe": 20}	5	15	1	1	1	8
1094	Flapple	{"hp": 70, "atk": 110, "def": 80, "spa": 95, "spd": 60, "spe": 70}	5	15	1	1	1	8
1095	Flapple-Gmax	{"hp": 70, "atk": 110, "def": 80, "spa": 95, "spd": 60, "spe": 70}	5	15	1	1	1	8
1096	Appletun	{"hp": 110, "atk": 85, "def": 80, "spa": 100, "spd": 80, "spe": 30}	5	15	1	1	1	8
1097	Appletun-Gmax	{"hp": 110, "atk": 85, "def": 80, "spa": 100, "spd": 80, "spe": 30}	5	15	1	1	1	8
1098	Silicobra	{"hp": 52, "atk": 57, "def": 75, "spa": 35, "spd": 50, "spe": 46}	9	\N	1	1	1	8
1099	Sandaconda	{"hp": 72, "atk": 107, "def": 125, "spa": 65, "spd": 70, "spe": 71}	9	\N	1	1	1	8
1100	Sandaconda-Gmax	{"hp": 72, "atk": 107, "def": 125, "spa": 65, "spd": 70, "spe": 71}	9	\N	1	1	1	8
1101	Cramorant	{"hp": 70, "atk": 85, "def": 55, "spa": 85, "spd": 95, "spe": 85}	10	3	1	\N	\N	8
1102	Cramorant-Gulping	{"hp": 70, "atk": 85, "def": 55, "spa": 85, "spd": 95, "spe": 85}	10	3	1	\N	\N	8
1103	Cramorant-Gorging	{"hp": 70, "atk": 85, "def": 55, "spa": 85, "spd": 95, "spe": 85}	10	3	1	\N	\N	8
1104	Arrokuda	{"hp": 41, "atk": 63, "def": 40, "spa": 40, "spd": 30, "spe": 66}	3	\N	1	\N	1	8
1105	Barraskewda	{"hp": 61, "atk": 123, "def": 60, "spa": 60, "spd": 50, "spe": 136}	3	\N	1	\N	1	8
1106	Toxel	{"hp": 40, "atk": 38, "def": 35, "spa": 54, "spd": 35, "spe": 40}	4	8	1	1	1	8
1107	Toxtricity	{"hp": 75, "atk": 98, "def": 70, "spa": 114, "spd": 70, "spe": 75}	4	8	1	1	1	8
1108	Toxtricity-Low-Key	{"hp": 75, "atk": 98, "def": 70, "spa": 114, "spd": 70, "spe": 75}	4	8	1	1	1	8
1109	Toxtricity-Gmax	{"hp": 75, "atk": 98, "def": 70, "spa": 114, "spd": 70, "spe": 75}	4	8	1	1	1	8
1110	Toxtricity-Low-Key-Gmax	{"hp": 75, "atk": 98, "def": 70, "spa": 114, "spd": 70, "spe": 75}	4	8	1	1	1	8
1111	Sizzlipede	{"hp": 50, "atk": 65, "def": 45, "spa": 50, "spd": 50, "spe": 45}	2	12	1	1	1	8
1112	Centiskorch	{"hp": 100, "atk": 115, "def": 65, "spa": 90, "spd": 90, "spe": 65}	2	12	1	1	1	8
1113	Centiskorch-Gmax	{"hp": 100, "atk": 115, "def": 65, "spa": 90, "spd": 90, "spe": 65}	2	12	1	1	1	8
1114	Clobbopus	{"hp": 50, "atk": 68, "def": 60, "spa": 50, "spd": 50, "spe": 32}	7	\N	1	\N	1	8
1115	Grapploct	{"hp": 80, "atk": 118, "def": 90, "spa": 70, "spd": 80, "spe": 42}	7	\N	1	\N	1	8
1116	Sinistea	{"hp": 40, "atk": 45, "def": 45, "spa": 74, "spd": 54, "spe": 50}	14	\N	1	\N	1	8
1117	Sinistea-Antique	{"hp": 40, "atk": 45, "def": 45, "spa": 74, "spd": 54, "spe": 50}	14	\N	1	\N	1	8
1118	Polteageist	{"hp": 60, "atk": 65, "def": 65, "spa": 134, "spd": 114, "spe": 70}	14	\N	1	\N	1	8
1119	Polteageist-Antique	{"hp": 60, "atk": 65, "def": 65, "spa": 134, "spd": 114, "spe": 70}	14	\N	1	\N	1	8
1120	Hatenna	{"hp": 42, "atk": 30, "def": 45, "spa": 56, "spd": 53, "spe": 39}	11	\N	1	1	1	8
1121	Hattrem	{"hp": 57, "atk": 40, "def": 65, "spa": 86, "spd": 73, "spe": 49}	11	\N	1	1	1	8
1122	Hatterene	{"hp": 57, "atk": 90, "def": 95, "spa": 136, "spd": 103, "spe": 29}	11	18	1	1	1	8
1123	Hatterene-Gmax	{"hp": 57, "atk": 90, "def": 95, "spa": 136, "spd": 103, "spe": 29}	11	18	1	1	1	8
1124	Impidimp	{"hp": 45, "atk": 45, "def": 30, "spa": 55, "spd": 40, "spe": 50}	17	18	1	1	1	8
1125	Morgrem	{"hp": 65, "atk": 60, "def": 45, "spa": 75, "spd": 55, "spe": 70}	17	18	1	1	1	8
1126	Grimmsnarl	{"hp": 95, "atk": 120, "def": 65, "spa": 95, "spd": 75, "spe": 60}	17	18	1	1	1	8
1127	Grimmsnarl-Gmax	{"hp": 95, "atk": 120, "def": 65, "spa": 95, "spd": 75, "spe": 60}	17	18	1	1	1	8
1128	Obstagoon	{"hp": 93, "atk": 90, "def": 101, "spa": 60, "spd": 81, "spe": 95}	17	1	1	1	1	8
1129	Perrserker	{"hp": 70, "atk": 110, "def": 100, "spa": 50, "spd": 60, "spe": 50}	16	\N	1	1	1	8
1130	Cursola	{"hp": 60, "atk": 95, "def": 50, "spa": 145, "spd": 130, "spe": 30}	14	\N	1	\N	1	8
1131	Sirfetch’d	{"hp": 62, "atk": 135, "def": 95, "spa": 68, "spd": 82, "spe": 65}	7	\N	1	\N	1	8
1132	Mr. Rime	{"hp": 80, "atk": 85, "def": 75, "spa": 110, "spd": 100, "spe": 70}	6	11	1	1	1	8
1133	Runerigus	{"hp": 58, "atk": 95, "def": 145, "spa": 50, "spd": 105, "spe": 30}	9	14	1	\N	\N	8
1134	Milcery	{"hp": 45, "atk": 40, "def": 40, "spa": 50, "spd": 61, "spe": 34}	18	\N	1	\N	1	8
1135	Alcremie	{"hp": 65, "atk": 60, "def": 75, "spa": 110, "spd": 121, "spe": 64}	18	\N	1	\N	1	8
1136	Alcremie-Gmax	{"hp": 65, "atk": 60, "def": 75, "spa": 110, "spd": 121, "spe": 64}	18	\N	1	\N	1	8
1137	Falinks	{"hp": 65, "atk": 100, "def": 100, "spa": 70, "spd": 60, "spe": 75}	7	\N	1	\N	1	8
1138	Pincurchin	{"hp": 48, "atk": 101, "def": 95, "spa": 91, "spd": 85, "spe": 15}	4	\N	1	\N	1	8
1139	Snom	{"hp": 30, "atk": 25, "def": 35, "spa": 45, "spd": 30, "spe": 20}	6	12	1	\N	1	8
1140	Frosmoth	{"hp": 70, "atk": 65, "def": 60, "spa": 125, "spd": 90, "spe": 65}	6	12	1	\N	1	8
1141	Stonjourner	{"hp": 100, "atk": 125, "def": 135, "spa": 20, "spd": 20, "spe": 70}	13	\N	1	\N	\N	8
1142	Eiscue	{"hp": 75, "atk": 80, "def": 110, "spa": 65, "spd": 90, "spe": 50}	6	\N	1	\N	\N	8
1143	Eiscue-Noice	{"hp": 75, "atk": 80, "def": 70, "spa": 65, "spd": 50, "spe": 130}	6	\N	1	\N	\N	8
1144	Indeedee	{"hp": 60, "atk": 65, "def": 55, "spa": 105, "spd": 95, "spe": 95}	11	1	1	1	1	8
1145	Indeedee-F	{"hp": 70, "atk": 55, "def": 65, "spa": 95, "spd": 105, "spe": 85}	11	1	1	1	1	8
1146	Morpeko	{"hp": 58, "atk": 95, "def": 58, "spa": 70, "spd": 58, "spe": 97}	4	17	1	\N	\N	8
1147	Morpeko-Hangry	{"hp": 58, "atk": 95, "def": 58, "spa": 70, "spd": 58, "spe": 97}	4	17	1	\N	\N	8
1148	Cufant	{"hp": 72, "atk": 80, "def": 49, "spa": 40, "spd": 49, "spe": 40}	16	\N	1	\N	1	8
1149	Copperajah	{"hp": 122, "atk": 130, "def": 69, "spa": 80, "spd": 69, "spe": 30}	16	\N	1	\N	1	8
1150	Copperajah-Gmax	{"hp": 122, "atk": 130, "def": 69, "spa": 80, "spd": 69, "spe": 30}	16	\N	1	\N	1	8
1151	Dracozolt	{"hp": 90, "atk": 100, "def": 90, "spa": 80, "spd": 70, "spe": 75}	4	15	1	1	1	8
1152	Arctozolt	{"hp": 90, "atk": 100, "def": 90, "spa": 90, "spd": 80, "spe": 55}	4	6	1	1	1	8
1153	Dracovish	{"hp": 90, "atk": 90, "def": 100, "spa": 70, "spd": 80, "spe": 75}	3	15	1	1	1	8
1154	Arctovish	{"hp": 90, "atk": 90, "def": 100, "spa": 80, "spd": 90, "spe": 55}	3	6	1	1	1	8
1155	Duraludon	{"hp": 70, "atk": 95, "def": 115, "spa": 120, "spd": 50, "spe": 85}	16	15	1	1	1	8
1156	Duraludon-Gmax	{"hp": 70, "atk": 95, "def": 115, "spa": 120, "spd": 50, "spe": 85}	16	15	1	1	1	8
1157	Dreepy	{"hp": 28, "atk": 60, "def": 30, "spa": 40, "spd": 30, "spe": 82}	15	14	1	1	1	8
1158	Drakloak	{"hp": 68, "atk": 80, "def": 50, "spa": 60, "spd": 50, "spe": 102}	15	14	1	1	1	8
1159	Dragapult	{"hp": 88, "atk": 120, "def": 75, "spa": 100, "spd": 75, "spe": 142}	15	14	1	1	1	8
1160	Zacian	{"hp": 92, "atk": 120, "def": 115, "spa": 80, "spd": 115, "spe": 138}	18	\N	1	\N	\N	8
1161	Zacian-Crowned	{"hp": 92, "atk": 150, "def": 115, "spa": 80, "spd": 115, "spe": 148}	18	16	1	\N	\N	8
1162	Zamazenta	{"hp": 92, "atk": 120, "def": 115, "spa": 80, "spd": 115, "spe": 138}	7	\N	1	\N	\N	8
1163	Zamazenta-Crowned	{"hp": 92, "atk": 120, "def": 140, "spa": 80, "spd": 140, "spe": 128}	7	16	1	\N	\N	8
1164	Eternatus	{"hp": 140, "atk": 85, "def": 95, "spa": 145, "spd": 95, "spe": 130}	8	15	1	\N	\N	8
1165	Eternatus-Eternamax	{"hp": 255, "atk": 115, "def": 250, "spa": 125, "spd": 250, "spe": 130}	8	15	1	\N	\N	8
1166	Kubfu	{"hp": 60, "atk": 90, "def": 60, "spa": 53, "spd": 50, "spe": 72}	7	\N	1	\N	\N	8
1167	Urshifu	{"hp": 100, "atk": 130, "def": 100, "spa": 63, "spd": 60, "spe": 97}	7	17	1	\N	\N	8
1168	Urshifu-Rapid-Strike	{"hp": 100, "atk": 130, "def": 100, "spa": 63, "spd": 60, "spe": 97}	7	3	1	\N	\N	8
1169	Urshifu-Gmax	{"hp": 100, "atk": 130, "def": 100, "spa": 63, "spd": 60, "spe": 97}	7	17	1	\N	\N	8
1170	Urshifu-Rapid-Strike-Gmax	{"hp": 100, "atk": 130, "def": 100, "spa": 63, "spd": 60, "spe": 97}	7	3	1	\N	\N	8
1171	Zarude	{"hp": 105, "atk": 120, "def": 105, "spa": 70, "spd": 95, "spe": 105}	17	5	1	\N	\N	8
1172	Zarude-Dada	{"hp": 105, "atk": 120, "def": 105, "spa": 70, "spd": 95, "spe": 105}	17	5	1	\N	\N	8
1173	Regieleki	{"hp": 80, "atk": 100, "def": 50, "spa": 100, "spd": 50, "spe": 200}	4	\N	1	\N	\N	8
1174	Regidrago	{"hp": 200, "atk": 100, "def": 50, "spa": 100, "spd": 50, "spe": 80}	15	\N	1	\N	\N	8
1175	Glastrier	{"hp": 100, "atk": 145, "def": 130, "spa": 65, "spd": 110, "spe": 30}	6	\N	1	\N	\N	8
1176	Spectrier	{"hp": 100, "atk": 65, "def": 60, "spa": 145, "spd": 80, "spe": 130}	14	\N	1	\N	\N	8
1177	Calyrex	{"hp": 100, "atk": 80, "def": 80, "spa": 80, "spd": 80, "spe": 80}	11	5	1	\N	\N	8
1178	Calyrex-Ice	{"hp": 100, "atk": 165, "def": 150, "spa": 85, "spd": 130, "spe": 50}	11	6	1	\N	\N	8
1179	Calyrex-Shadow	{"hp": 100, "atk": 85, "def": 80, "spa": 165, "spd": 100, "spe": 150}	11	14	1	\N	\N	8
1180	Wyrdeer	{"hp": 103, "atk": 105, "def": 72, "spa": 105, "spd": 75, "spe": 65}	1	11	1	1	1	8
1181	Kleavor	{"hp": 70, "atk": 135, "def": 95, "spa": 45, "spd": 70, "spe": 85}	12	13	1	1	1	8
1182	Ursaluna	{"hp": 130, "atk": 140, "def": 105, "spa": 45, "spd": 80, "spe": 50}	9	1	1	1	1	8
1183	Ursaluna-Bloodmoon	{"hp": 113, "atk": 70, "def": 120, "spa": 135, "spd": 65, "spe": 52}	9	1	1	\N	\N	8
1184	Basculegion	{"hp": 120, "atk": 112, "def": 65, "spa": 80, "spd": 75, "spe": 78}	3	14	1	1	1	8
1185	Basculegion-F	{"hp": 120, "atk": 92, "def": 65, "spa": 100, "spd": 75, "spe": 78}	3	14	1	1	1	8
1186	Sneasler	{"hp": 80, "atk": 130, "def": 60, "spa": 40, "spd": 80, "spe": 120}	7	8	1	1	1	8
1187	Overqwil	{"hp": 85, "atk": 115, "def": 95, "spa": 65, "spd": 65, "spe": 85}	17	8	1	1	1	8
1188	Enamorus	{"hp": 74, "atk": 115, "def": 70, "spa": 135, "spd": 80, "spe": 106}	18	10	1	\N	1	8
1189	Enamorus-Therian	{"hp": 74, "atk": 115, "def": 110, "spa": 135, "spd": 100, "spe": 46}	18	10	1	\N	\N	8
1190	Sprigatito	{"hp": 40, "atk": 61, "def": 54, "spa": 45, "spd": 45, "spe": 65}	5	\N	1	\N	1	9
1191	Floragato	{"hp": 61, "atk": 80, "def": 63, "spa": 60, "spd": 63, "spe": 83}	5	\N	1	\N	1	9
1192	Meowscarada	{"hp": 76, "atk": 110, "def": 70, "spa": 81, "spd": 70, "spe": 123}	5	17	1	\N	1	9
1193	Fuecoco	{"hp": 67, "atk": 45, "def": 59, "spa": 63, "spd": 40, "spe": 36}	2	\N	1	\N	1	9
1194	Crocalor	{"hp": 81, "atk": 55, "def": 78, "spa": 90, "spd": 58, "spe": 49}	2	\N	1	\N	1	9
1195	Skeledirge	{"hp": 104, "atk": 75, "def": 100, "spa": 110, "spd": 75, "spe": 66}	2	14	1	\N	1	9
1196	Quaxly	{"hp": 55, "atk": 65, "def": 45, "spa": 50, "spd": 45, "spe": 50}	3	\N	1	\N	1	9
1197	Quaxwell	{"hp": 70, "atk": 85, "def": 65, "spa": 65, "spd": 60, "spe": 65}	3	\N	1	\N	1	9
1198	Quaquaval	{"hp": 85, "atk": 120, "def": 80, "spa": 85, "spd": 75, "spe": 85}	3	7	1	\N	1	9
1199	Lechonk	{"hp": 54, "atk": 45, "def": 40, "spa": 35, "spd": 45, "spe": 35}	1	\N	1	1	1	9
1200	Oinkologne	{"hp": 110, "atk": 100, "def": 75, "spa": 59, "spd": 80, "spe": 65}	1	\N	1	1	1	9
1201	Oinkologne-F	{"hp": 115, "atk": 90, "def": 70, "spa": 59, "spd": 90, "spe": 65}	1	\N	1	1	1	9
1202	Tarountula	{"hp": 35, "atk": 41, "def": 45, "spa": 29, "spd": 40, "spe": 20}	12	\N	1	\N	1	9
1203	Spidops	{"hp": 60, "atk": 79, "def": 92, "spa": 52, "spd": 86, "spe": 35}	12	\N	1	\N	1	9
1204	Nymble	{"hp": 33, "atk": 46, "def": 40, "spa": 21, "spd": 25, "spe": 45}	12	\N	1	\N	1	9
1205	Lokix	{"hp": 71, "atk": 102, "def": 78, "spa": 52, "spd": 55, "spe": 92}	12	17	1	\N	1	9
1206	Pawmi	{"hp": 45, "atk": 50, "def": 20, "spa": 40, "spd": 25, "spe": 60}	4	\N	1	1	1	9
1207	Pawmo	{"hp": 60, "atk": 75, "def": 40, "spa": 50, "spd": 40, "spe": 85}	4	7	1	1	1	9
1208	Pawmot	{"hp": 70, "atk": 115, "def": 70, "spa": 70, "spd": 60, "spe": 105}	4	7	1	1	1	9
1209	Tandemaus	{"hp": 50, "atk": 50, "def": 45, "spa": 40, "spd": 45, "spe": 75}	1	\N	1	1	1	9
1210	Maushold	{"hp": 74, "atk": 75, "def": 70, "spa": 65, "spd": 75, "spe": 111}	1	\N	1	1	1	9
1211	Maushold-Four	{"hp": 74, "atk": 75, "def": 70, "spa": 65, "spd": 75, "spe": 111}	1	\N	1	1	1	9
1212	Fidough	{"hp": 37, "atk": 55, "def": 70, "spa": 30, "spd": 55, "spe": 65}	18	\N	1	\N	1	9
1213	Dachsbun	{"hp": 57, "atk": 80, "def": 115, "spa": 50, "spd": 80, "spe": 95}	18	\N	1	\N	1	9
1214	Smoliv	{"hp": 41, "atk": 35, "def": 45, "spa": 58, "spd": 51, "spe": 30}	5	1	1	\N	1	9
1215	Dolliv	{"hp": 52, "atk": 53, "def": 60, "spa": 78, "spd": 78, "spe": 33}	5	1	1	\N	1	9
1216	Arboliva	{"hp": 78, "atk": 69, "def": 90, "spa": 125, "spd": 109, "spe": 39}	5	1	1	\N	1	9
1217	Squawkabilly	{"hp": 82, "atk": 96, "def": 51, "spa": 45, "spd": 51, "spe": 92}	1	10	1	1	1	9
1218	Squawkabilly-Blue	{"hp": 82, "atk": 96, "def": 51, "spa": 45, "spd": 51, "spe": 92}	1	10	1	1	1	9
1219	Squawkabilly-Yellow	{"hp": 82, "atk": 96, "def": 51, "spa": 45, "spd": 51, "spe": 92}	1	10	1	1	1	9
1220	Squawkabilly-White	{"hp": 82, "atk": 96, "def": 51, "spa": 45, "spd": 51, "spe": 92}	1	10	1	1	1	9
1221	Nacli	{"hp": 55, "atk": 55, "def": 75, "spa": 35, "spd": 35, "spe": 25}	13	\N	1	1	1	9
1222	Naclstack	{"hp": 60, "atk": 60, "def": 100, "spa": 35, "spd": 65, "spe": 35}	13	\N	1	1	1	9
1223	Garganacl	{"hp": 100, "atk": 100, "def": 130, "spa": 45, "spd": 90, "spe": 35}	13	\N	1	1	1	9
1224	Charcadet	{"hp": 40, "atk": 50, "def": 40, "spa": 50, "spd": 40, "spe": 35}	2	\N	1	\N	1	9
1225	Armarouge	{"hp": 85, "atk": 60, "def": 100, "spa": 125, "spd": 80, "spe": 75}	2	11	1	\N	1	9
1226	Ceruledge	{"hp": 75, "atk": 125, "def": 80, "spa": 60, "spd": 100, "spe": 85}	2	14	1	\N	1	9
1227	Tadbulb	{"hp": 61, "atk": 31, "def": 41, "spa": 59, "spd": 35, "spe": 45}	4	\N	1	1	1	9
1228	Bellibolt	{"hp": 109, "atk": 64, "def": 91, "spa": 103, "spd": 83, "spe": 45}	4	\N	1	1	1	9
1229	Wattrel	{"hp": 40, "atk": 40, "def": 35, "spa": 55, "spd": 40, "spe": 70}	4	10	1	1	1	9
1230	Kilowattrel	{"hp": 70, "atk": 70, "def": 60, "spa": 105, "spd": 60, "spe": 125}	4	10	1	1	1	9
1231	Maschiff	{"hp": 60, "atk": 78, "def": 60, "spa": 40, "spd": 51, "spe": 51}	17	\N	1	1	1	9
1232	Mabosstiff	{"hp": 80, "atk": 120, "def": 90, "spa": 60, "spd": 70, "spe": 85}	17	\N	1	1	1	9
1233	Shroodle	{"hp": 40, "atk": 65, "def": 35, "spa": 40, "spd": 35, "spe": 75}	8	1	1	1	1	9
1234	Grafaiai	{"hp": 63, "atk": 95, "def": 65, "spa": 80, "spd": 72, "spe": 110}	8	1	1	1	1	9
1235	Bramblin	{"hp": 40, "atk": 65, "def": 30, "spa": 45, "spd": 35, "spe": 60}	5	14	1	\N	1	9
1236	Brambleghast	{"hp": 55, "atk": 115, "def": 70, "spa": 80, "spd": 70, "spe": 90}	5	14	1	\N	1	9
1237	Toedscool	{"hp": 40, "atk": 40, "def": 35, "spa": 50, "spd": 100, "spe": 70}	9	5	1	\N	\N	9
1238	Toedscruel	{"hp": 80, "atk": 70, "def": 65, "spa": 80, "spd": 120, "spe": 100}	9	5	1	\N	\N	9
1239	Klawf	{"hp": 70, "atk": 100, "def": 115, "spa": 35, "spd": 55, "spe": 75}	13	\N	1	1	1	9
1240	Capsakid	{"hp": 50, "atk": 62, "def": 40, "spa": 62, "spd": 40, "spe": 50}	5	\N	1	1	1	9
1241	Scovillain	{"hp": 65, "atk": 108, "def": 65, "spa": 108, "spd": 65, "spe": 75}	5	2	1	1	1	9
1242	Rellor	{"hp": 41, "atk": 50, "def": 60, "spa": 31, "spd": 58, "spe": 30}	12	\N	1	\N	1	9
1243	Rabsca	{"hp": 75, "atk": 50, "def": 85, "spa": 115, "spd": 100, "spe": 45}	12	11	1	\N	1	9
1244	Flittle	{"hp": 30, "atk": 35, "def": 30, "spa": 55, "spd": 30, "spe": 75}	11	\N	1	1	1	9
1245	Espathra	{"hp": 95, "atk": 60, "def": 60, "spa": 101, "spd": 60, "spe": 105}	11	\N	1	1	1	9
1246	Tinkatink	{"hp": 50, "atk": 45, "def": 45, "spa": 35, "spd": 64, "spe": 58}	18	16	1	1	1	9
1247	Tinkatuff	{"hp": 65, "atk": 55, "def": 55, "spa": 45, "spd": 82, "spe": 78}	18	16	1	1	1	9
1248	Tinkaton	{"hp": 85, "atk": 75, "def": 77, "spa": 70, "spd": 105, "spe": 94}	18	16	1	1	1	9
1249	Wiglett	{"hp": 10, "atk": 55, "def": 25, "spa": 35, "spd": 25, "spe": 95}	3	\N	1	1	1	9
1250	Wugtrio	{"hp": 35, "atk": 100, "def": 50, "spa": 50, "spd": 70, "spe": 120}	3	\N	1	1	1	9
1251	Bombirdier	{"hp": 70, "atk": 103, "def": 85, "spa": 60, "spd": 85, "spe": 82}	10	17	1	1	1	9
1252	Finizen	{"hp": 70, "atk": 45, "def": 40, "spa": 45, "spd": 40, "spe": 75}	3	\N	1	\N	\N	9
1253	Palafin	{"hp": 100, "atk": 70, "def": 72, "spa": 53, "spd": 62, "spe": 100}	3	\N	1	\N	\N	9
1254	Palafin-Hero	{"hp": 100, "atk": 160, "def": 97, "spa": 106, "spd": 87, "spe": 100}	3	\N	1	\N	\N	9
1255	Varoom	{"hp": 45, "atk": 70, "def": 63, "spa": 30, "spd": 45, "spe": 47}	16	8	1	\N	1	9
1256	Revavroom	{"hp": 80, "atk": 119, "def": 90, "spa": 54, "spd": 67, "spe": 90}	16	8	1	\N	1	9
1257	Cyclizar	{"hp": 70, "atk": 95, "def": 65, "spa": 85, "spd": 65, "spe": 121}	15	1	1	\N	1	9
1258	Orthworm	{"hp": 70, "atk": 85, "def": 145, "spa": 60, "spd": 55, "spe": 65}	16	\N	1	\N	1	9
1259	Glimmet	{"hp": 48, "atk": 35, "def": 42, "spa": 105, "spd": 60, "spe": 60}	13	8	1	\N	1	9
1260	Glimmora	{"hp": 83, "atk": 55, "def": 90, "spa": 130, "spd": 81, "spe": 86}	13	8	1	\N	1	9
1261	Greavard	{"hp": 50, "atk": 61, "def": 60, "spa": 30, "spd": 55, "spe": 34}	14	\N	1	\N	1	9
1262	Houndstone	{"hp": 72, "atk": 101, "def": 100, "spa": 50, "spd": 97, "spe": 68}	14	\N	1	\N	1	9
1263	Flamigo	{"hp": 82, "atk": 115, "def": 74, "spa": 75, "spd": 64, "spe": 90}	10	7	1	1	1	9
1264	Cetoddle	{"hp": 108, "atk": 68, "def": 45, "spa": 30, "spd": 40, "spe": 43}	6	\N	1	1	1	9
1265	Cetitan	{"hp": 170, "atk": 113, "def": 65, "spa": 45, "spd": 55, "spe": 73}	6	\N	1	1	1	9
1266	Veluza	{"hp": 90, "atk": 102, "def": 73, "spa": 78, "spd": 65, "spe": 70}	3	11	1	\N	1	9
1267	Dondozo	{"hp": 150, "atk": 100, "def": 115, "spa": 65, "spd": 65, "spe": 35}	3	\N	1	1	1	9
1268	Tatsugiri	{"hp": 68, "atk": 50, "def": 60, "spa": 120, "spd": 95, "spe": 82}	15	3	1	\N	1	9
1269	Annihilape	{"hp": 110, "atk": 115, "def": 80, "spa": 50, "spd": 90, "spe": 90}	7	14	1	1	1	9
1270	Clodsire	{"hp": 130, "atk": 75, "def": 60, "spa": 45, "spd": 100, "spe": 20}	8	9	1	1	1	9
1271	Farigiraf	{"hp": 120, "atk": 90, "def": 70, "spa": 110, "spd": 70, "spe": 60}	1	11	1	1	1	9
1272	Dudunsparce	{"hp": 125, "atk": 100, "def": 80, "spa": 85, "spd": 75, "spe": 55}	1	\N	1	1	1	9
1273	Dudunsparce-Three-Segment	{"hp": 125, "atk": 100, "def": 80, "spa": 85, "spd": 75, "spe": 55}	1	\N	1	1	1	9
1274	Kingambit	{"hp": 100, "atk": 135, "def": 120, "spa": 60, "spd": 85, "spe": 50}	17	16	1	1	1	9
1275	Great Tusk	{"hp": 115, "atk": 131, "def": 131, "spa": 53, "spd": 53, "spe": 87}	9	7	1	\N	\N	9
1276	Scream Tail	{"hp": 115, "atk": 65, "def": 99, "spa": 65, "spd": 115, "spe": 111}	18	11	1	\N	\N	9
1277	Brute Bonnet	{"hp": 111, "atk": 127, "def": 99, "spa": 79, "spd": 99, "spe": 55}	5	17	1	\N	\N	9
1278	Flutter Mane	{"hp": 55, "atk": 55, "def": 55, "spa": 135, "spd": 135, "spe": 135}	14	18	1	\N	\N	9
1279	Slither Wing	{"hp": 85, "atk": 135, "def": 79, "spa": 85, "spd": 105, "spe": 81}	12	7	1	\N	\N	9
1280	Sandy Shocks	{"hp": 85, "atk": 81, "def": 97, "spa": 121, "spd": 85, "spe": 101}	4	9	1	\N	\N	9
1281	Iron Treads	{"hp": 90, "atk": 112, "def": 120, "spa": 72, "spd": 70, "spe": 106}	9	16	1	\N	\N	9
1282	Iron Bundle	{"hp": 56, "atk": 80, "def": 114, "spa": 124, "spd": 60, "spe": 136}	6	3	1	\N	\N	9
1283	Iron Hands	{"hp": 154, "atk": 140, "def": 108, "spa": 50, "spd": 68, "spe": 50}	7	4	1	\N	\N	9
1284	Iron Jugulis	{"hp": 94, "atk": 80, "def": 86, "spa": 122, "spd": 80, "spe": 108}	17	10	1	\N	\N	9
1285	Iron Moth	{"hp": 80, "atk": 70, "def": 60, "spa": 140, "spd": 110, "spe": 110}	2	8	1	\N	\N	9
1286	Iron Thorns	{"hp": 100, "atk": 134, "def": 110, "spa": 70, "spd": 84, "spe": 72}	13	4	1	\N	\N	9
1287	Frigibax	{"hp": 65, "atk": 75, "def": 45, "spa": 35, "spd": 45, "spe": 55}	15	6	1	\N	1	9
1288	Arctibax	{"hp": 90, "atk": 95, "def": 66, "spa": 45, "spd": 65, "spe": 62}	15	6	1	\N	1	9
1289	Baxcalibur	{"hp": 115, "atk": 145, "def": 92, "spa": 75, "spd": 86, "spe": 87}	15	6	1	\N	1	9
1290	Gimmighoul	{"hp": 45, "atk": 30, "def": 70, "spa": 75, "spd": 70, "spe": 10}	14	\N	1	\N	\N	9
1291	Gimmighoul-Roaming	{"hp": 45, "atk": 30, "def": 25, "spa": 75, "spd": 45, "spe": 80}	14	\N	1	\N	\N	9
1292	Gholdengo	{"hp": 87, "atk": 60, "def": 95, "spa": 133, "spd": 91, "spe": 84}	16	14	1	\N	\N	9
1293	Wo-Chien	{"hp": 85, "atk": 85, "def": 100, "spa": 95, "spd": 135, "spe": 70}	17	5	1	\N	\N	9
1294	Chien-Pao	{"hp": 80, "atk": 120, "def": 80, "spa": 90, "spd": 65, "spe": 135}	17	6	1	\N	\N	9
1295	Ting-Lu	{"hp": 155, "atk": 110, "def": 125, "spa": 55, "spd": 80, "spe": 45}	17	9	1	\N	\N	9
1296	Chi-Yu	{"hp": 55, "atk": 80, "def": 80, "spa": 135, "spd": 120, "spe": 100}	17	2	1	\N	\N	9
1297	Roaring Moon	{"hp": 105, "atk": 139, "def": 71, "spa": 55, "spd": 101, "spe": 119}	15	17	1	\N	\N	9
1298	Iron Valiant	{"hp": 74, "atk": 130, "def": 90, "spa": 120, "spd": 60, "spe": 116}	18	7	1	\N	\N	9
1299	Koraidon	{"hp": 100, "atk": 135, "def": 115, "spa": 85, "spd": 100, "spe": 135}	7	15	1	\N	\N	9
1300	Miraidon	{"hp": 100, "atk": 85, "def": 100, "spa": 135, "spd": 115, "spe": 135}	4	15	1	\N	\N	9
1301	Walking Wake	{"hp": 99, "atk": 83, "def": 91, "spa": 125, "spd": 83, "spe": 109}	3	15	1	\N	\N	9
1302	Iron Leaves	{"hp": 90, "atk": 130, "def": 88, "spa": 70, "spd": 108, "spe": 104}	5	11	1	\N	\N	9
1303	Dipplin	{"hp": 80, "atk": 80, "def": 110, "spa": 95, "spd": 80, "spe": 40}	5	15	1	1	1	9
1304	Poltchageist	{"hp": 40, "atk": 45, "def": 45, "spa": 74, "spd": 54, "spe": 50}	5	14	1	\N	1	9
1305	Poltchageist-Artisan	{"hp": 40, "atk": 45, "def": 45, "spa": 74, "spd": 54, "spe": 50}	5	14	1	\N	1	9
1306	Sinistcha	{"hp": 71, "atk": 60, "def": 106, "spa": 121, "spd": 80, "spe": 70}	5	14	1	\N	1	9
1307	Sinistcha-Masterpiece	{"hp": 71, "atk": 60, "def": 106, "spa": 121, "spd": 80, "spe": 70}	5	14	1	\N	1	9
1308	Okidogi	{"hp": 88, "atk": 128, "def": 115, "spa": 58, "spd": 86, "spe": 80}	8	7	1	\N	1	9
1309	Munkidori	{"hp": 88, "atk": 75, "def": 66, "spa": 130, "spd": 90, "spe": 106}	8	11	1	\N	1	9
1310	Fezandipiti	{"hp": 88, "atk": 91, "def": 82, "spa": 70, "spd": 125, "spe": 99}	8	18	1	\N	1	9
1311	Ogerpon	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	\N	1	\N	\N	9
1312	Ogerpon-Wellspring	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	3	1	\N	\N	9
1313	Ogerpon-Hearthflame	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	2	1	\N	\N	9
1314	Ogerpon-Cornerstone	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	13	1	\N	\N	9
1315	Ogerpon-Teal-Tera	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	\N	1	\N	\N	9
1316	Ogerpon-Wellspring-Tera	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	3	1	\N	\N	9
1317	Ogerpon-Hearthflame-Tera	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	2	1	\N	\N	9
1318	Ogerpon-Cornerstone-Tera	{"hp": 80, "atk": 120, "def": 84, "spa": 60, "spd": 96, "spe": 110}	5	13	1	\N	\N	9
\.


--
-- Data for Name: pokemon_movements; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.pokemon_movements (id_pokemon, id_movement) FROM stdin;
1	1
1	5
1	7
2	5
2	6
3	8
3	9
6	6
7	3
7	8
8	9
\.


--
-- Data for Name: pokemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokemons (id, name, "baseStats", "idType1", "idType2", "idAbility1", "idAbility2", "idHiddenAbility", generation) FROM stdin;
\.


--
-- Data for Name: selected_pokemon; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.selected_pokemon (id, id_pokemon, id_team, ability, id_nature, id_item, moveset, ivs, evs, shiny, nickname) FROM stdin;
1	100	1	0	1	8	{}	{}	{}	f	\N
2	608	1	0	14	20	{}	{}	{}	f	\N
3	306	1	0	10	16	{}	{}	{}	f	\N
4	208	1	0	4	2	{}	{}	{}	f	\N
5	137	1	0	11	5	{}	{}	{}	f	\N
6	504	1	0	13	7	{}	{}	{}	f	\N
7	406	2	0	2	16	{}	{}	{}	f	\N
8	208	2	0	11	12	{}	{}	{}	f	\N
9	104	2	0	6	19	{}	{}	{}	f	\N
10	76	2	0	8	17	{}	{}	{}	f	\N
11	809	2	0	5	2	{}	{}	{}	f	\N
12	246	2	0	8	6	{}	{}	{}	f	\N
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.teams (id, id_trainer, id_format, name, private) FROM stdin;
1	1	1	Raining team	f
2	1	2	Trick room team	t
3	2	1	All offensive team	t
4	2	2	Water type team	f
5	3	1	Champion's team	f
6	3	2	Stall team	f
7	1	2	testTeam2	f
\.


--
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.tournaments (id, name, id_format) FROM stdin;
1	Regional tournament	1
2	San Diego's tournament	2
3	Allin tournament	1
\.


--
-- Data for Name: trainers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trainers (id, username, email, password, "createdAt", "updatedAt") FROM stdin;
1	test1	test1@mail.com	$2b$10$4Gw0qGrT19rm0Pk9XZHiculy3eNWhQ3MrpnIX9HxjFcIfLxF55JrK	2024-03-26 17:46:32.995+03	2024-03-26 17:46:32.995+03
\.


--
-- Data for Name: trainers_tournaments; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.trainers_tournaments (id_trainer, id_tournament) FROM stdin;
1	1
2	1
1	2
2	2
3	2
\.


--
-- Data for Name: types; Type: TABLE DATA; Schema: public; Owner: jorge
--

COPY public.types (id, name, generation) FROM stdin;
1	normal	1
2	fire	1
3	water	1
4	electric	1
5	grass	1
6	ice	1
7	fighting	1
8	poison	1
9	ground	1
10	flying	1
11	psychic	1
12	bug	1
13	rock	1
14	ghost	1
15	dragon	1
16	steel	2
17	dark	2
18	fairy	6
\.


--
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.abilities_id_seq', 310, true);


--
-- Name: formats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.formats_id_seq', 2, true);


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.items_id_seq', 535, true);


--
-- Name: movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.movements_id_seq', 921, true);


--
-- Name: natures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.natures_id_seq', 25, true);


--
-- Name: pokemon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.pokemon_id_seq', 1318, true);


--
-- Name: pokemons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pokemons_id_seq', 1, false);


--
-- Name: selected_pokemon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.selected_pokemon_id_seq', 12, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.teams_id_seq', 8, true);


--
-- Name: tournaments_id_format_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.tournaments_id_format_seq', 1, false);


--
-- Name: tournaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.tournaments_id_seq', 3, true);


--
-- Name: trainers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trainers_id_seq', 1, true);


--
-- Name: types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: jorge
--

SELECT pg_catalog.setval('public.types_id_seq', 18, true);


--
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- Name: formats formats_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.formats
    ADD CONSTRAINT formats_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id_tournament, id_team_1, id_team_2);


--
-- Name: movements movements_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_pkey PRIMARY KEY (id);


--
-- Name: natures natures_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.natures
    ADD CONSTRAINT natures_pkey PRIMARY KEY (id);


--
-- Name: pokemon_movements pokemon_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon_movements
    ADD CONSTRAINT pokemon_movements_pkey PRIMARY KEY (id_pokemon, id_movement);


--
-- Name: pokemon pokemon_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_pkey PRIMARY KEY (id);


--
-- Name: pokemons pokemons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokemons
    ADD CONSTRAINT pokemons_pkey PRIMARY KEY (id);


--
-- Name: selected_pokemon selected_pokemon_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.selected_pokemon
    ADD CONSTRAINT selected_pokemon_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tournaments tournaments_name_key; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_name_key UNIQUE (name);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (id);


--
-- Name: trainers trainers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainers
    ADD CONSTRAINT trainers_email_key UNIQUE (email);


--
-- Name: trainers trainers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainers
    ADD CONSTRAINT trainers_pkey PRIMARY KEY (id);


--
-- Name: trainers_tournaments trainers_tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.trainers_tournaments
    ADD CONSTRAINT trainers_tournaments_pkey PRIMARY KEY (id_trainer, id_tournament);


--
-- Name: trainers trainers_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainers
    ADD CONSTRAINT trainers_username_key UNIQUE (username);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: movement_power; Type: INDEX; Schema: public; Owner: jorge
--

CREATE INDEX movement_power ON public.movements USING btree (power);


--
-- Name: nature_idx; Type: INDEX; Schema: public; Owner: jorge
--

CREATE INDEX nature_idx ON public.natures USING hash (stat_up);


--
-- Name: pokemon_type; Type: INDEX; Schema: public; Owner: jorge
--

CREATE INDEX pokemon_type ON public.pokemon USING hash (id_type_1);


--
-- Name: selected_pokemon_idx; Type: INDEX; Schema: public; Owner: jorge
--

CREATE INDEX selected_pokemon_idx ON public.selected_pokemon USING hash (id_team);


--
-- Name: team_idx; Type: INDEX; Schema: public; Owner: jorge
--

CREATE INDEX team_idx ON public.teams USING hash (id_trainer);


--
-- Name: trainers_tournaments verifyteamavailable; Type: TRIGGER; Schema: public; Owner: jorge
--

CREATE TRIGGER verifyteamavailable AFTER INSERT ON public.trainers_tournaments FOR EACH ROW EXECUTE FUNCTION public.verifytournamentformat();


--
-- Name: selected_pokemon verifyteammembers; Type: TRIGGER; Schema: public; Owner: jorge
--

CREATE TRIGGER verifyteammembers BEFORE INSERT ON public.selected_pokemon FOR EACH ROW EXECUTE FUNCTION public.verifyteammembers();


--
-- Name: matches matches_id_team_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_id_team_1_fkey FOREIGN KEY (id_team_1) REFERENCES public.teams(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: matches matches_id_team_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_id_team_2_fkey FOREIGN KEY (id_team_2) REFERENCES public.teams(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: matches matches_id_tournament_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_id_tournament_fkey FOREIGN KEY (id_tournament) REFERENCES public.tournaments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: movements movements_id_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_id_type_fkey FOREIGN KEY (id_type) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon pokemon_id_ability_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_id_ability_1_fkey FOREIGN KEY (id_ability_1) REFERENCES public.abilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon pokemon_id_ability_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_id_ability_2_fkey FOREIGN KEY (id_ability_2) REFERENCES public.abilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon pokemon_id_hidden_ability_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_id_hidden_ability_fkey FOREIGN KEY (id_hidden_ability) REFERENCES public.abilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon pokemon_id_type_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_id_type_1_fkey FOREIGN KEY (id_type_1) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon pokemon_id_type_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon
    ADD CONSTRAINT pokemon_id_type_2_fkey FOREIGN KEY (id_type_2) REFERENCES public.types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon_movements pokemon_movements_id_movement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon_movements
    ADD CONSTRAINT pokemon_movements_id_movement_fkey FOREIGN KEY (id_movement) REFERENCES public.movements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pokemon_movements pokemon_movements_id_pokemon_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.pokemon_movements
    ADD CONSTRAINT pokemon_movements_id_pokemon_fkey FOREIGN KEY (id_pokemon) REFERENCES public.pokemon(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: selected_pokemon selected_pokemon_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.selected_pokemon
    ADD CONSTRAINT selected_pokemon_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: selected_pokemon selected_pokemon_id_nature_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.selected_pokemon
    ADD CONSTRAINT selected_pokemon_id_nature_fkey FOREIGN KEY (id_nature) REFERENCES public.natures(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: selected_pokemon selected_pokemon_id_pokemon_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.selected_pokemon
    ADD CONSTRAINT selected_pokemon_id_pokemon_fkey FOREIGN KEY (id_pokemon) REFERENCES public.pokemon(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: selected_pokemon selected_pokemon_id_team_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.selected_pokemon
    ADD CONSTRAINT selected_pokemon_id_team_fkey FOREIGN KEY (id_team) REFERENCES public.teams(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: teams teams_id_format_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_id_format_fkey FOREIGN KEY (id_format) REFERENCES public.formats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tournaments tournaments_id_format_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_id_format_fkey FOREIGN KEY (id_format) REFERENCES public.formats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: trainers_tournaments trainers_tournaments_id_tournament_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jorge
--

ALTER TABLE ONLY public.trainers_tournaments
    ADD CONSTRAINT trainers_tournaments_id_tournament_fkey FOREIGN KEY (id_tournament) REFERENCES public.tournaments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

