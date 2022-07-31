--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 14.1

-- Started on 2022-07-31 22:38:15 CEST

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
-- TOC entry 1 (class 3079 OID 1997817)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 207 (class 1255 OID 1997826)
-- Name: Headshots(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."Headshots"() RETURNS TABLE(name text, "Headshot(%)" double precision, "TotalKills" bigint, "TotalHeadshot" bigint)
    LANGUAGE plpgsql
    AS $$ begin
return query

select hs.name, (cast(hs.headshots as float)/total.kills)*100 as "Headshot(%)", total.kills, hs."headshots" from
(
select count(*) as kills, Lower("Kills"."KillerName") as name from public."Kills"
group by Lower("KillerName")
) as total
join
(
select count(*) as headshots, Lower("Kills"."KillerName") as name, "Kills"."Headshot" from public."Kills"
where "Headshot" = 'Yes'
group by Lower("KillerName"), "Headshot"
) as hs
on total.name = hs.name
order by "Headshot(%)" desc;

end$$;


ALTER FUNCTION public."Headshots"() OWNER TO postgres;

--
-- TOC entry 200 (class 1255 OID 1997827)
-- Name: Nemesis(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."Nemesis"() RETURNS TABLE(cnt bigint, killer character varying, victim character varying)
    LANGUAGE plpgsql
    AS $$ begin
return query

select count(*), "Kills"."KillerName", "Kills"."VictimName" from public."Kills"
group by "KillerName", "VictimName"
order by count desc;

end$$;


ALTER FUNCTION public."Nemesis"() OWNER TO postgres;

--
-- TOC entry 208 (class 1255 OID 1997828)
-- Name: kd(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kd() RETURNS TABLE(name text, kills bigint, deaths bigint, kd double precision)
    LANGUAGE plpgsql
    AS $$ begin
return query

select k.killerName, k.kills, v.deaths, Cast(k.kills as float)/v.deaths as "k/d" from(

select count(*) as kills, Lower("Kills"."KillerName") as killerName from public."Kills"
group by Lower("KillerName")
) as k
join
(
select count(*) as deaths, Lower("Kills"."VictimName") as victimName from public."Kills"
group by Lower("VictimName")
	) as v
	on k.KillerName = v.victimName
	
order by "k/d" desc, k.kills desc;
end$$;


ALTER FUNCTION public.kd() OWNER TO postgres;

--
-- TOC entry 211 (class 1255 OID 1997829)
-- Name: kpr1(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kpr1(pname character varying) RETURNS TABLE(txt character varying, totalrounds bigint, kpr double precision)
    LANGUAGE plpgsql
    AS $$begin
	return query
	select pname as Name, mr."totalrounds" as totalRounds, cast(k."kills" as float)/mr."totalrounds" as kpr from
	(
		-- First get all the round played by the player
		select 1 as test, count(*) as TotalRounds from
			(
			select * from public."PlayerMatches" where Lower("Player1") like '%'||pname||'%' or Lower("Player2") like '%'||pname||'%'  or Lower("Player3") like '%'||pname||'%'  or Lower("Player4") like '%'||pname||'%' or Lower("Player5") like '%'||pname||'%' or Lower("Player6") like '%'||pname||'%' or Lower("Player7") like '%'||pname||'%'  or Lower("Player8") like '%'||pname||'%' or Lower("Player9") like '%'||pname||'%' or lower("Player10") like '%'||pname||'%'
			) as m
			inner join
			(
			select * from public."Rounds"
			) as r
			on m."MatchID" = r."MatchID"
		where r."Atck/Def" = 'Attacker'
	) as mr
		inner join
		-- Join the above with all the kills the player got
		(select 1 as test, count(*) as kills from public."Kills" where Lower("KillerName") like '%'||pName||'%') as k
	on k."test" = mr."test";
	
end
$$;


ALTER FUNCTION public.kpr1(pname character varying) OWNER TO postgres;

SET default_tablespace = '';

--
-- TOC entry 197 (class 1259 OID 1997832)
-- Name: kills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kills (
    kill_id integer NOT NULL,
    killer_name character varying,
    victim_name character varying NOT NULL,
    round_id integer NOT NULL,
    headshot character varying NOT NULL,
    "time" integer NOT NULL
);


ALTER TABLE public.kills OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 1997838)
-- Name: matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches (
    season integer,
    match_id integer NOT NULL,
    map text,
    home_team text NOT NULL,
    away_team text NOT NULL,
    winner text,
    loser text,
    h1 character varying(100),
    h2 character varying(100),
    h3 character varying(100),
    h4 character varying(100),
    h5 character varying(100),
    a1 character varying(100),
    a2 character varying(100),
    a3 character varying(100),
    a4 character varying(100),
    a5 character varying(100),
    map2 character varying(100)
);


ALTER TABLE public.matches OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 1997850)
-- Name: rounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rounds (
    round_id integer NOT NULL,
    winner character varying NOT NULL,
    match_id integer NOT NULL,
    planted_by character varying,
    defused_by character varying
);


ALTER TABLE public.rounds OWNER TO postgres;

--
-- TOC entry 3142 (class 0 OID 1997832)
-- Dependencies: 197
-- Data for Name: kills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kills (kill_id, killer_name, victim_name, round_id, headshot, "time") FROM stdin;
1010101	Stan	Street	10101	No	64
1010102	Stan	SaiyanbornQueen	10101	No	86
1010103	Stan	HotKebab	10101	Yes	87
1010104	Next	Stan	10101	No	128
1010105	Next	Wes	10101	Yes	132
1010106	Next	Jimmy	10101	No	136
1010107	Next	FrenchFrie	10101	Yes	140
1010108	Next	Omega	10101	Yes	156
1010201	Street	FrenchFrie	10102	No	43
1010202	Wes	Street	10102	Yes	45
1010203	Wes	SaiyanbornQueen	10102	No	55
1010204	Next	Jimmy	10102	Yes	55
1010205	Wes	Next	10102	No	58
1010206	HotKebab	Wes	10102	Yes	139
1010207	Stan	NastyHobbit	10102	No	152
1010208	Stan	HotKebab	10102	Yes	160
1010301	Stan	Next	10103	No	38
1010302	Street	Stan	10103	Yes	45
1010303	Jimmy	Street	10103	No	54
1010304	HotKebab	Jimmy	10103	No	71
1010305	NastyHobbit	Wes	10103	No	109
1010306	NastyHobbit	Omega	10103	Yes	119
1010307	FrenchFrie	NastyHobbit	10103	No	137
1010308	HotKebab	FrenchFrie	10103	No	137
1010401	Stan	Next	10104	No	79
1010402	Wes	Street	10104	Yes	110
1010403	Stan	NastyHobbit	10104	Yes	120
1010404	SaiyanbornQueen	Stan	10104	No	125
1010405	Omega	HotKebab	10104	Yes	132
1010406	Omega	SaiyanbornQueen	10104	No	153
1010501	Wes	Next	10105	Yes	99
1010502	Stan	Street	10105	No	117
1010503	Wes	NastyHobbit	10105	No	159
1010504	HotKebab	FrenchFrie	10105	Yes	169
1010505	HotKebab	Wes	10105	No	169
1010506	HotKebab	Jimmy	10105	No	170
1010507	Stan	HotKebab	10105	Yes	179
1010601	Next	Omega	10106	Yes	51
1010602	Next	Wes	10106	Yes	95
1010603	Jimmy	HotKebab	10106	Yes	103
1010604	Stan	Next	10106	Yes	113
1010605	SaiyanbornQueen	Stan	10106	Yes	114
1010606	Jimmy	Street	10106	No	151
1010607	FrenchFrie	SaiyanbornQueen	10106	No	158
1010608	NastyHobbit	Jimmy	10106	No	161
1010609	NastyHobbit	FrenchFrie	10106	Yes	164
1010701	HotKebab	Stan	10107	Yes	62
1010702	Next	FrenchFrie	10107	Yes	90
1010703	Omega	HotKebab	10107	Yes	102
1010704	Wes	Next	10107	No	111
1010705	Wes	SaiyanbornQueen	10107	No	171
1010706	Wes	NastyHobbit	10107	No	173
1010707	Street	Jimmy	10107	No	177
1010708	Street	Omega	10107	Yes	148
1010709	Street	Wes	10107	No	154
1010801	HotKebab	Jimmy	10108	No	129
1010802	FrenchFrie	Next	10108	Yes	161
1010803	Stan	SaiyanbornQueen	10108	No	164
1010804	Street	Wes	10108	No	174
1010805	Stan	HotKebab	10108	No	176
1010806	Street	Stan	10108	Yes	179
1010901	Next	Wes	10109	No	75
1010902	Next	FrenchFrie	10109	Yes	79
1010903	Omega	Next	10109	No	94
1010904	Jimmy	HotKebab	10109	Yes	103
1010905	Omega	Street	10109	Yes	129
1010906	Stan	SaiyanbornQueen	10109	No	136
1010907	HotKebab	Jimmy	10109	No	139
1010908	HotKebab	Omega	10109	No	140
1010909	HotKebab	Stan	10109	No	160
1050101	MoodyCereal	Stan	10501	No	116
1050102	OnThinIce	Jimmy	10501	No	132
1050103	ameenHere	Nex_Ingeniarius	10501	Yes	137
1050104	Bauer	FrenchFrie	10501	No	157
1050201	Bauer	Nex_Ingeniarius	10502	Yes	50
1050202	Wes	Bauer	10502	No	56
1050203	ameenHere	Wes	10502	No	56
1050204	Stan	OnThinIce	10502	Yes	87
1050205	MoodyCereal	Stan	10502	Yes	173
1050206	MoodyCereal	FrenchFrie	10502	Yes	138
1050207	speedymax	Jimmy	10502	Yes	141
1050301	Jimmy	ameenHere	10503	No	71
1050302	Stan	MoodyCereal	10503	Yes	89
1050303	Nex_Ingeniarius	OnThinIce	10503	Yes	98
1050304	Stan	speedymax	10503	Yes	114
1050305	Bauer	FrenchFrie	10503	No	136
1050306	Bauer	Nex_Ingeniarius	10503	Yes	139
1050307	Wes	Bauer	10503	No	140
1050401	Stan	OnThinIce	10504	No	83
1050402	Wes	Bauer	10504	No	87
1050403	Wes	ameenHere	10504	Yes	89
1050404	speedymax	FrenchFrie	10504	No	94
1050405	MoodyCereal	Nex_Ingeniarius	10504	Yes	94
1050406	Wes	MoodyCereal	10504	No	97
1050407	speedymax	Wes	10504	No	102
1050408	speedymax	Stan	10504	No	138
1050409	speedymax	Jimmy	10504	No	142
1050501	Bauer	Stan	10505	Yes	6
1050502	MoodyCereal	Nex_Ingeniarius	10505	Yes	124
1050503	ameenHere	Wes	10505	No	138
1050504	FrenchFrie	ameenHere	10505	Yes	159
1050505	MoodyCereal	Jimmy	10505	Yes	170
1050506	MoodyCereal	FrenchFrie	10505	No	173
1050601	ameenHere	Jimmy	10506	No	133
1050602	ameenHere	Stan	10506	No	139
1050603	Nex_Ingeniarius	ameenHere	10506	No	141
1050604	Nex_Ingeniarius	MoodyCereal	10506	Yes	144
1050605	Wes	speedymax	10506	No	147
1050606	FrenchFrie	Bauer	10506	Yes	153
1050607	OnThinIce	Wes	10506	Yes	155
1050608	Nex_Ingeniarius	OnThinIce	10506	Yes	170
1050701	Stan	Bauer	10507	Yes	119
1050702	Wes	OnThinIce	10507	Yes	134
1050703	ameenHere	Nex_Ingeniarius	10507	No	147
1050704	Stan	MoodyCereal	10507	Yes	160
1050705	Jimmy	ameenHere	10507	Yes	162
1050706	Stan	speedymax	10507	Yes	166
1050801	Stan	MoodyCereal	10508	No	110
1050802	speedymax	Stan	10508	No	111
1050803	Bauer	Wes	10508	No	116
1050804	ameenHere	Nex_Ingeniarius	10508	Yes	120
1050805	FrenchFrie	Bauer	10508	No	127
1050806	Jimmy	speedymax	10508	Yes	128
1050807	Jimmy	ameenHere	10508	Yes	134
1050808	FrenchFrie	OnThinIce	10508	No	159
1050901	Bauer	FrenchFrie	10509	No	87
1050902	OnThinIce	Nex_Ingeniarius	10509	No	92
1050903	Wes	Bauer	10509	No	100
1050904	OnThinIce	Jimmy	10509	Yes	103
1050905	Wes	OnThinIce	10509	Yes	111
1050906	Stan	ameenHere	10509	No	115
1050907	speedymax	Stan	10509	No	139
1050908	Wes	speedymax	10509	No	143
1050909	MoodyCereal	Wes	10509	No	168
1051001	Stan	ameenHere	10510	Yes	41
1051002	Nex_Ingeniarius	OnThinIce	10510	Yes	82
1051003	MoodyCereal	Nex_Ingeniarius	10510	No	132
1051004	Wes	speedymax	10510	No	133
1051005	Bauer	Wes	10510	No	140
1051006	FrenchFrie	Bauer	10510	Yes	140
1051007	Stan	MoodyCereal	10510	No	166
1051101	Wes	Bauer	10511	Yes	137
1051102	MoodyCereal	Wes	10511	No	139
1051103	Stan	MoodyCereal	10511	No	143
1051104	Stan	OnThinIce	10511	Yes	150
1051105	ameenHere	FrenchFrie	10511	Yes	152
1051106	Jimmy	ameenHere	10511	No	154
1051107	speedymax	Nex_Ingeniarius	10511	No	158
1051108	Jimmy	speedymax	10511	No	162
1051201	ameenHere	Wes	10512	No	68
1051202	Stan	Bauer	10512	No	69
1051203	Stan	speedymax	10512	Yes	97
1051204	Nex_Ingeniarius	OnThinIce	10512	Yes	141
1051205	ameenHere	Jimmy	10512	Yes	145
1051206	ameenHere	FrenchFrie	10512	No	147
1051207	OnThinIce	Stan	10512	No	169
1051301	Stan	MoodyCereal	10513	Yes	54
1051302	Stan	OnThinIce	10513	No	59
1051303	Stan	ameenHere	10513	No	75
1051304	speedymax	Stan	10513	Yes	76
1051305	Nex_Ingeniarius	speedymax	10513	No	108
1051306	Nex_Ingeniarius	Bauer	10513	No	122
1030101	MoodyCereal	HotKebab	10301	Yes	99
1030102	MrLiam	OnThinIce	10301	No	112
1030103	Bauer	Next	10301	Yes	143
1030104	Bauer	Street	10301	Yes	143
1030105	MrLiam	MoodyCereal	10301	No	145
1030106	MrLiam	ameenHere	10301	Yes	150
1030107	Bauer	MrLiam	10301	No	152
1030108	NastyHobbit	lxrde	10301	No	180
1030109	Bauer	NastyHobbit	10301	Yes	180
1030201	HotKebab	MoodyCereal	10302	Yes	88
1030202	OnThinIce	MrLiam	10302	Yes	95
1030203	ameenHere	NastyHobbit	10302	Yes	103
1030204	HotKebab	ameenHere	10302	No	142
1030205	Next	OnThinIce	10302	No	146
1030206	Next	lxrde	10302	No	152
1030207	HotKebab	Bauer	10302	Yes	153
1030301	Street	ameenHere	10303	No	66
1030302	MrLiam	Bauer	10303	No	119
1030303	lxrde	MrLiam	10303	Yes	119
1030304	HotKebab	MoodyCereal	10303	No	136
1030305	HotKebab	OnThinIce	10303	Yes	172
1030306	Street	lxrde	10303	No	173
1030401	MrLiam	lxrde	10304	No	112
1030402	HotKebab	MoodyCereal	10304	No	116
1030403	ameenHere	MrLiam	10304	Yes	116
1030404	OnThinIce	HotKebab	10304	Yes	122
1030405	NastyHobbit	ameenHere	10304	Yes	148
1030406	Street	OnThinIce	10304	No	177
1030407	Bauer	Next	10304	Yes	180
1030408	Street	Bauer	10304	Yes	180
1030501	OnThinIce	MrLiam	10305	Yes	96
1030502	lxrde	HotKebab	10305	Yes	99
1030503	Bauer	Street	10305	No	123
1030504	Bauer	NastyHobbit	10305	Yes	141
1030505	MoodyCereal	Next	10305	No	145
1030601	Street	lxrde	10306	No	57
1030602	ameenHere	Street	10306	No	58
1030603	HotKebab	Bauer	10306	Yes	74
1030604	MrLiam	OnThinIce	10306	No	83
1030605	MoodyCereal	HotKebab	10306	Yes	88
1030606	MoodyCereal	Next	10306	No	116
1030607	ameenHere	NastyHobbit	10306	Yes	121
1030608	OnThinIce	MrLiam	10306	No	122
1030701	OnThinIce	Next	10307	No	34
1030702	MoodyCereal	MrLiam	10307	No	125
1030703	Bauer	HotKebab	10307	No	131
1030704	ameenHere	Street	10307	Yes	164
1030705	NastyHobbit	lxrde	10307	No	164
1030706	ameenHere	NastyHobbit	10307	No	167
1030801	MrLiam	ameenHere	10308	Yes	34
1030802	lxrde	MrLiam	10308	No	37
1030803	Street	lxrde	10308	Yes	43
1030804	Street	Bauer	10308	No	45
1030805	Street	OnThinIce	10308	No	47
1030806	Street	MoodyCereal	10308	No	51
1030901	MrLiam	ameenHere	10309	Yes	53
1030902	HotKebab	lxrde	10309	Yes	100
1030903	MoodyCereal	MrLiam	10309	No	124
1030904	Bauer	Street	10309	No	133
1030905	MoodyCereal	Next	10309	No	160
1030906	Bauer	NastyHobbit	10309	Yes	161
1030907	HotKebab	Bauer	10309	No	165
1030908	MoodyCereal	HotKebab	10309	No	166
1031001	OnThinIce	MrLiam	10310	No	151
1031002	MoodyCereal	lxrde	10310	No	154
1031003	HotKebab	ameenHere	10310	No	155
1031004	OnThinIce	Next	10310	No	159
1031005	Bauer	HotKebab	10310	No	159
1031006	NastyHobbit	Bauer	10310	No	160
1031007	Street	OnThinIce	10310	No	161
1031008	Street	MoodyCereal	10310	Yes	165
1031101	ameenHere	MrLiam	10311	Yes	26
1031102	OnThinIce	HotKebab	10311	No	31
1031103	Next	lxrde	10311	Yes	93
1031104	MoodyCereal	Street	10311	No	107
1031105	MoodyCereal	Next	10311	Yes	122
1031106	ameenHere	NastyHobbit	10311	Yes	129
1031201	MrLiam	ameenHere	10312	Yes	127
1031202	MrLiam	MoodyCereal	10312	No	128
1031203	Next	Bauer	10312	No	131
1031204	MrLiam	lxrde	10312	No	135
1031205	NastyHobbit	OnThinIce	10312	Yes	163
1031301	MrLiam	MoodyCereal	10313	Yes	64
1031302	ameenHere	MrLiam	10313	No	70
1031303	OnThinIce	Street	10313	No	75
1031304	HotKebab	Bauer	10313	Yes	102
1031305	HotKebab	ameenHere	10313	Yes	119
1031306	Next	lxrde	10313	No	128
1031307	HotKebab	OnThinIce	10313	Yes	161
1070101	Jimmy	NastyHobbit	10701	Yes	70
1070102	HotKebab	Wes	10701	Yes	79
1070103	HotKebab	Jimmy	10701	Yes	106
1070104	HotKebab	Omega	10701	No	116
1070105	Stan	HotKebab	10701	No	119
1070106	Mastermagpie	egons.on	10701	Yes	180
1070107	Stan	ameenHere	10701	No	180
1070108	Stan	Mastermagpie	10701	Yes	180
1070109	Stan	SaiyanbornQueen	10701	Yes	180
1070201	Wes	ameenHere	10702	Yes	56
1070202	Omega	SaiyanbornQueen	10702	Yes	60
1070203	HotKebab	Wes	10702	Yes	80
1070204	Stan	HotKebab	10702	Yes	110
1070205	Stan	Mastermagpie	10702	Yes	114
1070206	NastyHobbit	Omega	10702	No	180
1070207	Stan	NastyHobbit	10702	No	180
1070301	Wes	HotKebab	10703	Yes	80
1070302	Mastermagpie	Stan	10703	Yes	82
1070303	Omega	Mastermagpie	10703	No	96
1070304	Omega	SaiyanbornQueen	10703	Yes	159
1070305	ameenHere	Omega	10703	Yes	171
1070401	Stan	ameenHere	10704	Yes	64
1070402	Mastermagpie	Stan	10704	No	67
1070403	Wes	SaiyanbornQueen	10704	No	73
1070404	NastyHobbit	Jimmy	10704	No	118
1070405	Omega	HotKebab	10704	Yes	120
1070406	Wes	NastyHobbit	10704	No	124
1070407	Mastermagpie	Omega	10704	No	180
1070408	Wes	Mastermagpie	10704	No	180
1070501	ameenHere	Wes	10705	No	53
1070502	egons.on	ameenHere	10705	No	56
1070503	SaiyanbornQueen	Omega	10705	Yes	64
1070504	SaiyanbornQueen	egons.on	10705	Yes	85
1070505	HotKebab	Jimmy	10705	Yes	132
1070506	NastyHobbit	Stan	10705	No	170
1070601	Mastermagpie	Jimmy	10706	No	77
1070602	ameenHere	Wes	10706	Yes	180
1070603	Stan	ameenHere	10706	No	180
1070604	Stan	NastyHobbit	10706	Yes	180
1070605	HotKebab	egons.on	10706	Yes	180
1070606	Stan	HotKebab	10706	No	180
1070607	Mastermagpie	Stan	10706	Yes	180
1070608	Omega	Mastermagpie	10706	No	180
1070701	SaiyanbornQueen	egons.on	10707	No	62
1070702	Stan	SaiyanbornQueen	10707	Yes	72
1070703	HotKebab	Omega	10707	No	110
1070704	NastyHobbit	Stan	10707	No	117
1070705	Wes	ameenHere	10707	Yes	127
1070706	Jimmy	HotKebab	10707	Yes	140
1070707	Mastermagpie	Jimmy	10707	No	142
1070708	Wes	NastyHobbit	10707	No	143
1070709	Wes	Mastermagpie	10707	Yes	153
1070801	NastyHobbit	Wes	10708	Yes	58
1070802	egons.on	HotKebab	10708	Yes	61
1070803	Stan	ameenHere	10708	No	96
1070804	Stan	Mastermagpie	10708	No	110
1070805	NastyHobbit	Omega	10708	No	119
1070806	Stan	NastyHobbit	10708	No	143
1070807	Stan	SaiyanbornQueen	10708	No	143
1100101	FrenchFrie	Mastermagpie	11001	Yes	79
1100102	Marras	Stan	11001	No	118
1100103	Marras	FrenchFrie	11001	Yes	123
1100104	crimsonfever	Wes	11001	No	163
1100105	HaiDing	Nex_Ingeniarius	11001	Yes	168
1100106	crimsonfever	Omega	11001	No	180
1100201	Marras	Stan	11002	No	54
1100202	Mastermagpie	Nex_Ingeniarius	11002	No	103
1100203	HaiDing	Wes	11002	No	107
1100204	Omega	CalLycus	11002	No	112
1100205	crimsonfever	Omega	11002	No	115
1100206	FrenchFrie	HaiDing	11002	Yes	119
1100207	FrenchFrie	Mastermagpie	11002	No	132
1100208	Marras	FrenchFrie	11002	No	139
1100301	Stan	Mastermagpie	11003	Yes	41
1100302	HaiDing	FrenchFrie	11003	No	120
1100303	Stan	HaiDing	11003	No	134
1100304	Marras	Stan	11003	No	150
1100305	CalLycus	Wes	11003	No	162
1100306	Marras	Omega	11003	Yes	165
1100307	crimsonfever	Nex_Ingeniarius	11003	Yes	180
1100401	Nex_Ingeniarius	CalLycus	11004	Yes	41
1100402	HaiDing	Nex_Ingeniarius	11004	No	138
1100403	Stan	Mastermagpie	11004	No	142
1100404	FrenchFrie	crimsonfever	11004	No	146
1100405	Marras	Stan	11004	No	147
1100406	Wes	Marras	11004	No	149
1100407	FrenchFrie	HaiDing	11004	Yes	167
1100501	CalLycus	Nex_Ingeniarius	11005	Yes	121
1100502	Stan	Marras	11005	No	162
1100503	Stan	HaiDing	11005	Yes	170
1100504	FrenchFrie	crimsonfever	11005	No	175
1100505	Wes	CalLycus	11005	No	180
1100601	Marras	Omega	11006	Yes	49
1100602	Mastermagpie	Nex_Ingeniarius	11006	No	141
1100603	FrenchFrie	Mastermagpie	11006	No	150
1100604	Wes	CalLycus	11006	No	172
1100605	crimsonfever	Wes	11006	Yes	178
1100606	Stan	crimsonfever	11006	Yes	180
1100701	FrenchFrie	Marras	11007	No	43
1100702	Mastermagpie	Wes	11007	Yes	60
1100703	Omega	Mastermagpie	11007	Yes	67
1100704	Omega	crimsonfever	11007	No	148
1100705	CalLycus	Stan	11007	Yes	156
1100706	CalLycus	FrenchFrie	11007	No	171
1100707	Nex_Ingeniarius	HaiDing	11007	No	171
1100708	Omega	CalLycus	11007	Yes	178
1100801	Stan	HaiDing	11008	No	56
1100802	Marras	Stan	11008	Yes	57
1100803	Marras	Omega	11008	No	87
1100804	FrenchFrie	Marras	11008	No	92
1100805	Mastermagpie	FrenchFrie	11008	No	131
1100806	Nex_Ingeniarius	Mastermagpie	11008	Yes	150
1100807	Wes	CalLycus	11008	No	159
1100808	Wes	crimsonfever	11008	Yes	163
1100901	FrenchFrie	HaiDing	11009	No	66
1100902	Mastermagpie	Wes	11009	Yes	101
1100903	Marras	Stan	11009	No	104
1100904	FrenchFrie	Mastermagpie	11009	Yes	129
1100905	Omega	crimsonfever	11009	Yes	133
1100906	CalLycus	FrenchFrie	11009	Yes	136
1100907	Marras	Nex_Ingeniarius	11009	Yes	139
1100908	Marras	Omega	11009	No	168
1101001	Stan	HaiDing	11010	Yes	60
1101002	Marras	Wes	11010	No	68
1101003	Mastermagpie	Stan	11010	No	112
1101004	Omega	Marras	11010	Yes	161
1101005	crimsonfever	FrenchFrie	11010	No	170
1101006	CalLycus	Nex_Ingeniarius	11010	Yes	173
1101007	Omega	CalLycus	11010	Yes	174
1101008	Omega	Mastermagpie	11010	Yes	176
1101009	crimsonfever	Omega	11010	Yes	180
1120101	Marras	HotKebab	11201	Yes	106
1120102	NastyHobbit	Justice	11201	No	131
1120103	Bauer	Mastermagpie	11201	Yes	145
1120104	Bauer	CalLycus	11201	Yes	153
1120105	Marras	Bauer	11201	Yes	162
1120106	FadeToBlue	Marras	11201	Yes	164
1120107	HaiDing	SaiyanbornQueen	11201	No	176
1120108	FadeToBlue	HaiDing	11201	No	180
1120201	SaiyanbornQueen	NastyHobbit	11202	Yes	11
1120202	Marras	HotKebab	11202	Yes	43
1120203	Marras	FadeToBlue	11202	Yes	93
1120204	Marras	Bauer	11202	Yes	146
1120205	CalLycus	SaiyanbornQueen	11202	No	148
1120301	FadeToBlue	Marras	11203	Yes	57
1120302	HaiDing	SaiyanbornQueen	11203	No	69
1120303	Justice	FadeToBlue	11203	No	71
1120304	NastyHobbit	HaiDing	11203	No	73
1120305	Bauer	Mastermagpie	11203	Yes	154
1120306	Bauer	CalLycus	11203	Yes	168
1120307	Justice	Bauer	11203	No	169
1120308	Justice	NastyHobbit	11203	Yes	180
1120401	HaiDing	HotKebab	11204	Yes	108
1120402	FadeToBlue	Justice	11204	Yes	175
1120403	SaiyanbornQueen	Mastermagpie	11204	Yes	178
1120404	HaiDing	FadeToBlue	11204	No	180
1120405	NastyHobbit	HaiDing	11204	Yes	180
1120406	CalLycus	NastyHobbit	11204	Yes	180
1120407	SaiyanbornQueen	Marras	11204	Yes	180
1120408	SaiyanbornQueen	CalLycus	11204	No	180
1120501	FadeToBlue	Justice	11205	Yes	125
1120502	Marras	SaiyanbornQueen	11205	Yes	132
1120503	Marras	HotKebab	11205	Yes	136
1120504	CalLycus	FadeToBlue	11205	Yes	151
1120505	HaiDing	Bauer	11205	No	164
1120506	Marras	NastyHobbit	11205	Yes	173
1120601	Justice	Bauer	11206	Yes	11
1120602	HotKebab	HaiDing	11206	Yes	130
1120603	FadeToBlue	CalLycus	11206	Yes	165
1120604	Justice	HotKebab	11206	Yes	170
1120605	SaiyanbornQueen	Justice	11206	Yes	179
1120701	Bauer	Mastermagpie	11207	Yes	84
1120702	Justice	FadeToBlue	11207	Yes	96
1120703	Marras	Bauer	11207	Yes	132
1120704	HotKebab	Marras	11207	No	137
1120705	HotKebab	Justice	11207	No	173
1120706	HaiDing	HotKebab	11207	No	174
1120801	Bauer	Mastermagpie	11208	No	38
1120802	HaiDing	Bauer	11208	No	75
1120803	HaiDing	FadeToBlue	11208	Yes	98
1120804	Marras	HotKebab	11208	Yes	106
1120805	Justice	NastyHobbit	11208	Yes	121
1120806	Justice	SaiyanbornQueen	11208	Yes	130
1120901	CalLycus	FadeToBlue	11209	Yes	71
1120902	CalLycus	SaiyanbornQueen	11209	Yes	160
1120903	Bauer	Mastermagpie	11209	Yes	171
1120904	Justice	Bauer	11209	No	176
1120905	CalLycus	HotKebab	11209	Yes	180
1120906	Marras	NastyHobbit	11209	No	180
1121001	SaiyanbornQueen	Mastermagpie	11210	No	87
1121002	Justice	SaiyanbornQueen	11210	No	100
1121003	Marras	FadeToBlue	11210	Yes	150
1121004	Marras	HotKebab	11210	Yes	153
1121005	HaiDing	Bauer	11210	Yes	160
1121006	NastyHobbit	Justice	11210	No	164
1121007	Marras	NastyHobbit	11210	No	180
1040101	crimsonfever	Jimmy	10401	No	117
1040102	Wes	crimsonfever	10401	Yes	121
1040103	Marras	Wes	10401	Yes	128
1040104	Stan	Marras	10401	No	144
1040105	Mastermagpie	Nex_Ingeniarius	10401	No	149
1040106	FrenchFrie	Mastermagpie	10401	Yes	154
1040107	HaiDing	Stan	10401	No	160
1040108	Justice	FrenchFrie	10401	No	173
1040201	Stan	HaiDing	10402	Yes	106
1040202	Stan	crimsonfever	10402	Yes	133
1040203	Stan	Mastermagpie	10402	Yes	138
1040204	Justice	Stan	10402	No	141
1040205	Marras	Jimmy	10402	No	144
1040206	Nex_Ingeniarius	Marras	10402	No	145
1040207	Wes	Justice	10402	No	164
1040301	Marras	Wes	10403	No	65
1040302	Stan	Marras	10403	Yes	66
1040303	HaiDing	Nex_Ingeniarius	10403	Yes	160
1040304	Jimmy	Mastermagpie	10403	No	171
1040305	FrenchFrie	HaiDing	10403	Yes	173
1040306	crimsonfever	Jimmy	10403	No	175
1040307	Stan	crimsonfever	10403	No	176
1040308	Justice	FrenchFrie	10403	No	178
1040401	Jimmy	HaiDing	10404	No	54
1040402	crimsonfever	Jimmy	10404	No	87
1040403	crimsonfever	Wes	10404	Yes	123
1040404	FrenchFrie	crimsonfever	10404	No	124
1040405	Justice	Stan	10404	Yes	138
1040406	FrenchFrie	Marras	10404	No	144
1040407	Nex_Ingeniarius	Justice	10404	Yes	146
1040501	Marras	Wes	10405	Yes	83
1040502	Jimmy	crimsonfever	10405	Yes	87
1040503	Stan	Mastermagpie	10405	No	99
1040504	Justice	FrenchFrie	10405	Yes	134
1040505	FrenchFrie	Justice	10405	No	134
1040506	Marras	Jimmy	10405	Yes	135
1040507	Stan	Marras	10405	Yes	141
1040508	Stan	HaiDing	10405	No	145
1040601	Marras	FrenchFrie	10406	Yes	120
1040602	Stan	Marras	10406	Yes	122
1040603	Stan	Justice	10406	Yes	122
1040604	Jimmy	Mastermagpie	10406	Yes	134
1040605	Stan	crimsonfever	10406	Yes	154
1040606	Stan	HaiDing	10406	Yes	155
1040701	Justice	Stan	10407	No	75
1040702	Wes	crimsonfever	10407	No	161
1040703	Nex_Ingeniarius	Marras	10407	No	162
1040704	HaiDing	Jimmy	10407	No	175
1040705	Nex_Ingeniarius	HaiDing	10407	No	178
1040801	Nex_Ingeniarius	Mastermagpie	10408	Yes	48
1040802	Wes	Marras	10408	Yes	82
1040803	Justice	Stan	10408	Yes	84
1040804	HaiDing	Wes	10408	Yes	115
1040805	FrenchFrie	crimsonfever	10408	Yes	129
1040806	Jimmy	HaiDing	10408	Yes	136
1040807	FrenchFrie	Justice	10408	Yes	143
1110101	speedymax	Jimmy	11101	Yes	79
1110102	Nex_Ingeniarius	Bauer	11101	Yes	83
1110103	speedymax	Stan	11101	Yes	124
1110104	speedymax	Wes	11101	Yes	135
1110105	Nex_Ingeniarius	Justice	11101	No	137
1110106	MoodyCereal	Nex_Ingeniarius	11101	No	139
1110107	speedymax	egons.on	11101	No	140
1110201	speedymax	Stan	11102	Yes	78
1110202	Justice	egons.on	11102	No	80
1110203	Jimmy	MoodyCereal	11102	No	85
1110204	Justice	Jimmy	11102	No	87
1110205	Justice	Wes	11102	No	96
1110206	Bauer	Nex_Ingeniarius	11102	No	146
1110301	MoodyCereal	Wes	11103	Yes	61
1110302	Jimmy	Jimmy	11103	No	102
1110303	ameenHere	Nex_Ingeniarius	11103	Yes	104
1110304	Stan	speedymax	11103	Yes	110
1110305	Stan	Bauer	11103	Yes	116
1110306	MoodyCereal	Stan	11103	No	118
1110307	MoodyCereal	egons.on	11103	No	136
1110401	Justice	Stan	11104	No	50
1110402	Nex_Ingeniarius	Bauer	11104	Yes	78
1110403	Wes	speedymax	11104	Yes	142
1110404	Wes	ameenHere	11104	No	152
1110405	egons.on	MoodyCereal	11104	Yes	154
1110406	Nex_Ingeniarius	Justice	11104	No	154
1110501	ameenHere	Jimmy	11105	No	114
1110502	Wes	speedymax	11105	Yes	149
1110503	Nex_Ingeniarius	ameenHere	11105	No	140
1110504	Wes	Bauer	11105	Yes	140
1110505	MoodyCereal	Wes	11105	No	147
1110506	MoodyCereal	Nex_Ingeniarius	11105	No	149
1110507	Justice	egons.on	11105	Yes	154
1110508	Stan	Justice	11105	Yes	165
1110601	speedymax	Wes	11106	No	66
1110602	Nex_Ingeniarius	speedymax	11106	Yes	68
1110603	Bauer	egons.on	11106	Yes	105
1110604	Nex_Ingeniarius	Bauer	11106	Yes	117
1110605	Jimmy	Justice	11106	No	153
1110606	ameenHere	Jimmy	11106	Yes	163
1110607	ameenHere	Nex_Ingeniarius	11106	No	173
1110608	MoodyCereal	Stan	11106	No	177
1110701	speedymax	Nex_Ingeniarius	11107	Yes	94
1110702	Stan	MoodyCereal	11107	Yes	96
1110703	Justice	Stan	11107	No	132
1110704	ameenHere	egons.on	11107	No	145
1110705	ameenHere	Jimmy	11107	No	171
1110706	speedymax	Wes	11107	No	173
1020101	OnThinIce	Marras	10201	Yes	81
1020102	Scarecrow	ameenHere	10201	No	86
1020103	speedymax	Scarecrow	10201	Yes	112
1020104	Justice	OnThinIce	10201	No	126
1020105	speedymax	CalLycus	10201	Yes	171
1020106	crimsonfever	lxrde	10201	Yes	176
1020201	Marras	OnThinIce	10202	No	41
1020202	Scarecrow	ameenHere	10202	No	81
1020301	OnThinIce	Scarecrow	10203	Yes	66
1020302	crimsonfever	Bauer	10203	Yes	98
1020303	OnThinIce	CalLycus	10203	No	159
1020304	crimsonfever	OnThinIce	10203	No	160
1020305	ameenHere	crimsonfever	10203	No	163
1020306	ameenHere	Justice	10203	No	164
1020307	Marras	lxrde	10203	No	166
1020308	Marras	ameenHere	10203	No	167
1020309	speedymax	Marras	10203	No	180
1020401	lxrde	Scarecrow	10204	Yes	89
1020402	lxrde	Marras	10204	Yes	90
1020403	Bauer	crimsonfever	10204	Yes	124
1020404	Bauer	CalLycus	10204	Yes	126
1020405	OnThinIce	Justice	10204	No	128
1020502	Scarecrow	lxrde	10205	No	115
1020503	OnThinIce	Scarecrow	10205	No	117
1020504	Justice	OnThinIce	10205	Yes	132
1020505	Bauer	CalLycus	10205	Yes	140
1020506	Bauer	Justice	10205	No	142
1020601	crimsonfever	OnThinIce	10206	Yes	132
1020603	Bauer	crimsonfever	10206	Yes	175
1020701	Justice	Bauer	10207	Yes	51
1020702	Marras	ameenHere	10207	No	90
1020703	crimsonfever	OnThinIce	10207	Yes	120
1020704	lxrde	CalLycus	10207	No	125
1020705	speedymax	Marras	10207	Yes	154
1020706	speedymax	Scarecrow	10207	Yes	155
1020707	Justice	lxrde	10207	No	157
1020708	Justice	speedymax	10207	No	160
1020801	lxrde	Justice	10208	Yes	104
1020802	OnThinIce	Scarecrow	10208	No	124
1020803	CalLycus	lxrde	10208	No	134
1020804	CalLycus	ameenHere	10208	No	146
1020805	Bauer	crimsonfever	10208	Yes	148
1020806	Bauer	CalLycus	10208	No	155
1020807	Marras	OnThinIce	10208	No	176
1020808	Marras	speedymax	10208	Yes	177
1020901	Marras	OnThinIce	10209	Yes	85
1020902	lxrde	CalLycus	10209	Yes	122
1020903	ameenHere	Marras	10209	No	127
1020904	Bauer	Justice	10209	Yes	161
1020905	lxrde	crimsonfever	10209	Yes	167
1020906	Bauer	Scarecrow	10209	No	174
1090101	speedymax	HotKebab	10901	No	69
1090102	ameenHere	NastyHobbit	10901	No	75
1090103	MrLiam	OnThinIce	10901	No	91
1090104	MoodyCereal	SaiyanbornQueen	10901	Yes	94
1090105	Bauer	MrLiam	10901	No	100
1090106	MoodyCereal	FadeToBlue	10901	No	100
1090201	speedymax	MrLiam	10902	No	34
1090202	SaiyanbornQueen	ameenHere	10902	Yes	94
1090203	MoodyCereal	NastyHobbit	10902	Yes	142
1090204	HotKebab	OnThinIce	10902	No	159
1090205	speedymax	FadeToBlue	10902	No	160
1090206	speedymax	HotKebab	10902	No	164
1090207	Bauer	SaiyanbornQueen	10902	Yes	166
1090301	MoodyCereal	MrLiam	10903	No	20
1090302	Bauer	HotKebab	10903	Yes	20
1090303	OnThinIce	NastyHobbit	10903	No	34
1090304	MoodyCereal	FadeToBlue	10903	No	115
1090305	ameenHere	SaiyanbornQueen	10903	No	162
1090401	MrLiam	OnThinIce	10904	No	88
1090402	ameenHere	HotKebab	10904	No	128
1090403	ameenHere	FadeToBlue	10904	No	149
1090404	MoodyCereal	MrLiam	10904	No	151
1090405	ameenHere	NastyHobbit	10904	Yes	166
1090501	ameenHere	SaiyanbornQueen	10905	Yes	47
1090502	NastyHobbit	speedymax	10905	Yes	47
1090503	ameenHere	NastyHobbit	10905	No	54
1090504	OnThinIce	HotKebab	10905	Yes	67
1090505	Bauer	MrLiam	10905	No	103
1090506	Bauer	FadeToBlue	10905	Yes	108
1080101	Marras	lxrde	10801	No	126
1080102	Bauer	Justice	10801	No	150
1080103	ameenHere	Mastermagpie	10801	No	159
1080104	CalLycus	speedymax	10801	No	160
1080105	ameenHere	CalLycus	10801	Yes	160
1080106	Marras	ameenHere	10801	No	163
1080107	OnThinIce	Marras	10801	Yes	176
1080108	Scarecrow	Bauer	10801	No	180
1080109	Scarecrow	OnThinIce	10801	No	180
1080201	Marras	OnThinIce	10802	Yes	81
1080202	CalLycus	Bauer	10802	Yes	153
1080203	speedymax	Scarecrow	10802	No	154
1080204	ameenHere	Justice	10802	No	155
1080205	Marras	lxrde	10802	Yes	163
1080206	CalLycus	speedymax	10802	No	164
1080207	ameenHere	Marras	10802	Yes	170
1080208	ameenHere	CalLycus	10802	No	180
1080301	Bauer	CalLycus	10803	Yes	97
1080302	ameenHere	Justice	10803	No	157
1080303	Bauer	Mastermagpie	10803	No	162
1080304	lxrde	Marras	10803	Yes	168
1080305	Scarecrow	Bauer	10803	No	179
1080401	Mastermagpie	Bauer	10804	No	111
1080402	Justice	OnThinIce	10804	Yes	114
1080403	ameenHere	Justice	10804	No	145
1080404	ameenHere	Marras	10804	No	145
1080405	CalLycus	speedymax	10804	Yes	146
1080406	lxrde	CalLycus	10804	No	155
1080407	ameenHere	Mastermagpie	10804	Yes	167
1080408	Scarecrow	lxrde	10804	No	168
1080409	Scarecrow	ameenHere	10804	Yes	180
1080501	ameenHere	Mastermagpie	10805	No	97
1080502	OnThinIce	CalLycus	10805	Yes	107
1080503	ameenHere	Scarecrow	10805	No	119
1080504	Marras	ameenHere	10805	Yes	126
1080505	Marras	OnThinIce	10805	Yes	132
1080506	Marras	lxrde	10805	Yes	148
1080507	Bauer	Justice	10805	Yes	168
1080508	Marras	Bauer	10805	No	174
1080509	speedymax	Marras	10805	No	178
1080601	Marras	speedymax	10806	Yes	55
1080602	Mastermagpie	OnThinIce	10806	No	120
1080603	ameenHere	CalLycus	10806	Yes	127
1080604	Mastermagpie	Bauer	10806	Yes	149
1080605	lxrde	Mastermagpie	10806	No	152
1080606	Marras	ameenHere	10806	Yes	161
1080607	lxrde	Scarecrow	10806	No	167
1080608	Marras	lxrde	10806	No	179
1080701	Justice	OnThinIce	10807	No	146
1080702	lxrde	Mastermagpie	10807	No	149
1080703	Scarecrow	Bauer	10807	No	150
1080704	Marras	ameenHere	10807	No	158
1080705	Scarecrow	lxrde	10807	No	162
1080706	CalLycus	speedymax	10807	Yes	167
1080801	ameenHere	Scarecrow	10808	No	105
1080802	Scarecrow	ameenHere	10808	Yes	106
1080803	speedymax	CalLycus	10808	No	156
1080804	Mastermagpie	lxrde	10808	Yes	159
1080805	Justice	Bauer	10808	No	160
1080806	speedymax	Marras	10808	No	168
1080807	speedymax	Mastermagpie	10808	Yes	180
1080808	OnThinIce	Justice	10808	Yes	180
1080901	Scarecrow	speedymax	10809	No	77
1080902	Scarecrow	ameenHere	10809	Yes	128
1080903	Mastermagpie	OnThinIce	10809	No	128
1080904	Justice	lxrde	10809	No	133
1080905	Bauer	Marras	10809	No	147
1080906	Justice	Bauer	10809	No	160
1081001	Marras	speedymax	10810	Yes	79
1081002	Scarecrow	OnThinIce	10810	No	101
1081003	Bauer	Scarecrow	10810	No	103
1081004	lxrde	CalLycus	10810	No	108
1081005	ameenHere	Mastermagpie	10810	No	109
1081006	Justice	ameenHere	10810	No	116
1081007	Justice	Bauer	10810	No	117
1081008	lxrde	Marras	10810	Yes	122
1081009	Justice	lxrde	10810	No	142
1020501	ameenHere	Marras	10205	Yes	114
1020602	ameenHere	Scarecrow	10206	No	165
1020604	ameenHere	CalLycus	10206	No	176
1060101	Marras	Street	10601	Yes	84
1060102	NastyHobbit	Marras	10601	No	108
1060103	FadeToBlue	Mastermagpie	10601	Yes	126
1060104	FadeToBlue	Justice	10601	Yes	130
1060105	crimsonfever	FadeToBlue	10601	No	131
1060106	NastyHobbit	crimsonfever	10601	Yes	165
1060201	HotKebab	Mastermagpie	10602	Yes	47
1060202	HotKebab	Justice	10602	Yes	61
1060203	Marras	FadeToBlue	10602	No	152
1060204	Street	Marras	10602	No	173
1060205	Next	CalLycus	10602	No	179
1060206	NastyHobbit	crimsonfever	10602	No	179
1060301	Marras	HotKebab	10603	No	68
1060302	Street	Marras	10603	Yes	79
1060303	Mastermagpie	Street	10603	No	86
1060304	NastyHobbit	crimsonfever	10603	No	124
1060305	FadeToBlue	CalLycus	10603	Yes	178
1060306	Justice	FadeToBlue	10603	No	179
1060307	Next	Mastermagpie	10603	No	179
1060401	HotKebab	Marras	10604	Yes	73
1060402	FadeToBlue	crimsonfever	10604	No	123
1060403	Justice	FadeToBlue	10604	No	128
1060404	HotKebab	Justice	10604	Yes	130
1060405	Next	CalLycus	10604	No	175
1060406	HotKebab	Mastermagpie	10604	No	176
1060501	Street	Mastermagpie	10605	No	45
1060502	HotKebab	Justice	10605	No	66
1060503	Street	CalLycus	10605	No	97
1060504	HotKebab	crimsonfever	10605	No	119
1060505	Marras	HotKebab	10605	Yes	137
1060506	Marras	Next	10605	No	162
1060507	NastyHobbit	Marras	10605	Yes	164
1060601	HotKebab	Marras	10606	Yes	67
1060602	crimsonfever	Next	10606	No	85
1060603	Justice	Street	10606	Yes	89
1060604	Justice	FadeToBlue	10606	Yes	107
1060605	Mastermagpie	NastyHobbit	10606	Yes	108
1060606	Justice	HotKebab	10606	No	168
1060701	Next	crimsonfever	10607	Yes	91
1060702	Marras	Next	10607	Yes	110
1060703	Marras	NastyHobbit	10607	Yes	111
1060704	HotKebab	Marras	10607	No	118
1060705	FadeToBlue	Mastermagpie	10607	No	142
1060706	Justice	Street	10607	No	148
1060707	HotKebab	CalLycus	10607	Yes	150
1060708	Justice	FadeToBlue	10607	Yes	139
1060709	Justice	HotKebab	10607	No	147
1060801	Street	Mastermagpie	10608	No	61
1060802	Street	CalLycus	10608	No	157
1060803	Next	Justice	10608	Yes	173
1060804	crimsonfever	FadeToBlue	10608	Yes	179
1060805	Marras	Next	10608	Yes	180
1060806	Street	crimsonfever	10608	Yes	180
1060807	Street	Marras	10608	Yes	180
2020101	Pacmyn	TwinkPeach	20201	Yes	56
2020102	Justice	Balf	20201	No	101
2020104	Pacmyn	NastyHobbit	20201	Yes	166
2020105	OnThinIce	Justice	20201	No	171
2020106	OnThinIce	Pacmyn	20201	No	184
2020107	FadeToBlue	OnThinIce	20201	Yes	196
2020202	ameenHere	Balf	20202	Yes	138
2020203	TwinkPeach	Justice	20202	No	156
2020204	ameenHere	TwinkPeach	20202	Yes	164
2020205	OnThinIce	ameenHere	20202	No	168
2020206	Pacmyn	OnThinIce	20202	Yes	178
2020301	Justice	TwinkPeach	20203	Yes	50
2020302	OnThinIce	Pacmyn	20203	Yes	77
2020303	ameenHere	OnThinIce	20203	No	95
2020304	ameenHere	Balf	20203	No	152
2020306	NastyHobbit	FadeToBlue	20203	Yes	183
2020307	NastyHobbit	polarctic	20203	No	195
2020308	ameenHere	NastyHobbit	20203	No	206
2020401	Justice	TwinkPeach	20204	Yes	97
2020402	FadeToBlue	Balf	20204	Yes	131
2020403	Justice	NastyHobbit	20204	No	160
2020404	OnThinIce	FadeToBlue	20204	Yes	163
2020405	Justice	OnThinIce	20204	No	176
2020501	Justice	TwinkPeach	20205	No	65
2020502	ameenHere	NastyHobbit	20205	No	144
2020504	OnThinIce	ameenHere	20205	No	152
2020505	Pacmyn	OnThinIce	20205	Yes	156
2020508	Pacmyn	Balf	20205	No	200
2020602	polarctic	NastyHobbit	20206	Yes	146
2020603	OnThinIce	FadeToBlue	20206	No	165
2020604	Pacmyn	OnThinIce	20206	Yes	178
2020605	ameenHere	TwinkPeach	20206	No	180
2020606	Pacmyn	Balf	20206	No	180
2020701	ameenHere	TwinkPeach	20207	No	80
2020702	ameenHere	NastyHobbit	20207	No	99
2020704	Justice	Balf	20207	No	126
2020705	Balf	Justice	20207	Yes	126
2020706	Pacmyn	OnThinIce	20207	No	140
2020801	Justice	NastyHobbit	20208	Yes	20
2020804	Justice	TwinkPeach	20208	No	99
2020805	Pacmyn	Balf	20208	No	122
2020806	polarctic	OnThinIce	20208	Yes	122
2130101	Jimmy	Justice	21301	No	124
2130102	Pacmyn	Jimmy	21301	No	138
2130103	WishMaster	FrenchFrie	21301	Yes	140
2130104	fury	polarctic	21301	No	143
2130105	TheRandomGuy	Pacmyn	21301	No	163
2130106	fury	ameenHere	21301	No	166
2130107	TheRandomGuy	WishMaster	21301	No	174
2130201	Justice	Bauer	21302	No	61
2130202	Justice	Jimmy	21302	Yes	101
2130203	FrenchFrie	ameenHere	21302	No	162
2130204	polarctic	fury	21302	Yes	173
2130205	Pacmyn	FrenchFrie	21302	No	190
2130206	Pacmyn	TheRandomGuy	21302	No	190
2130301	ameenHere	fury	21303	No	58
2130302	Bauer	polarctic	21303	Yes	87
2130303	Justice	Bauer	21303	No	97
2130304	Justice	Jimmy	21303	No	133
2130305	FrenchFrie	Justice	21303	Yes	155
2130306	Pacmyn	TheRandomGuy	21303	Yes	167
2130307	ameenHere	FrenchFrie	21303	No	175
2130401	Jimmy	Justice	21304	Yes	69
2130402	FrenchFrie	polarctic	21304	Yes	77
2130403	Pacmyn	Jimmy	21304	Yes	103
2130404	FrenchFrie	ameenHere	21304	Yes	136
2130405	Pacmyn	FrenchFrie	21304	Yes	151
2130406	Bauer	Pacmyn	21304	Yes	163
2130407	WishMaster	TheRandomGuy	21304	No	168
2130408	Bauer	WishMaster	21304	No	175
2130501	Pacmyn	Jimmy	21305	Yes	76
2130502	WishMaster	Bauer	21305	Yes	176
2130503	polarctic	FrenchFrie	21305	No	182
2130504	fury	polarctic	21305	Yes	188
2130505	Pacmyn	TheRandomGuy	21305	Yes	191
2130506	fury	WishMaster	21305	Yes	194
2130507	Pacmyn	fury	21305	No	202
2130601	FrenchFrie	ameenHere	21306	Yes	98
2130602	Bauer	Justice	21306	Yes	100
2130603	Bauer	WishMaster	21306	Yes	110
2130604	Bauer	polarctic	21306	No	120
2130605	Jimmy	Pacmyn	21306	No	126
2130701	WishMaster	fury	21307	Yes	15
2130702	Jimmy	Justice	21307	No	69
2130703	WishMaster	Jimmy	21307	No	117
2130704	Bauer	polarctic	21307	No	136
2130705	ameenHere	Bauer	21307	No	151
2130706	Pacmyn	FrenchFrie	21307	No	160
2130707	Pacmyn	TheRandomGuy	21307	Yes	168
2130801	Jimmy	Justice	21308	Yes	70
2130802	fury	ameenHere	21308	No	93
2130803	fury	WishMaster	21308	No	161
2130804	Pacmyn	fury	21308	No	164
2130805	Jimmy	Pacmyn	21308	No	172
2130806	TheRandomGuy	polarctic	21308	Yes	179
2130901	WishMaster	Jimmy	21309	Yes	141
2130902	WishMaster	Bauer	21309	Yes	173
2131001	WishMaster	fury	21310	Yes	121
2131002	WishMaster	FrenchFrie	21310	Yes	131
2131003	Pacmyn	Bauer	21310	No	154
2131004	ameenHere	TheRandomGuy	21310	No	162
2131005	Pacmyn	Jimmy	21310	No	163
2131101	Pacmyn	fury	21311	No	105
2131102	Justice	FrenchFrie	21311	No	117
2131103	Bauer	Pacmyn	21311	No	124
2131104	WishMaster	Bauer	21311	Yes	127
2131105	Jimmy	WishMaster	21311	Yes	134
2131106	TheRandomGuy	Justice	21311	No	148
2131107	ameenHere	TheRandomGuy	21311	No	170
2131108	ameenHere	Jimmy	21311	No	170
2120101	WishMaster	Balf	21201	Yes	44
2120102	Justice	OnThinIce	21201	Yes	45
2120103	Pacmyn	Nathan492	21201	No	106
2120104	WishMaster	crimsonfever	21201	Yes	119
2120105	NastyHobbit	Pacmyn	21201	No	135
2120106	ameenHere	NastyHobbit	21201	Yes	135
2120201	crimsonfever	Pacmyn	21202	Yes	75
2120202	polarctic	OnThinIce	21202	Yes	142
2120203	WishMaster	NastyHobbit	21202	Yes	148
2120204	Balf	WishMaster	21202	Yes	167
2120205	Balf	ameenHere	21202	Yes	176
2120206	ameenHere	crimsonfever	21202	No	180
2120207	Justice	Balf	21202	No	186
2120208	Justice	Nathan492	21202	No	194
2120301	crimsonfever	Pacmyn	21203	Yes	17
2120302	Justice	crimsonfever	21203	Yes	62
2120303	OnThinIce	Justice	21203	Yes	115
2120304	polarctic	Balf	21203	Yes	125
2120305	WishMaster	Nathan492	21203	Yes	144
2120306	WishMaster	NastyHobbit	21203	Yes	186
2120307	WishMaster	OnThinIce	21203	No	197
2120401	Pacmyn	crimsonfever	21204	Yes	55
2120402	Nathan492	ameenHere	21204	No	72
2120403	WishMaster	Nathan492	21204	No	111
2120404	OnThinIce	Pacmyn	21204	No	142
2120405	Justice	OnThinIce	21204	Yes	145
2120406	Balf	WishMaster	21204	Yes	161
2120407	Justice	NastyHobbit	21204	Yes	183
2120408	polarctic	Balf	21204	No	213
2120501	crimsonfever	Justice	21205	Yes	58
2120502	crimsonfever	polarctic	21205	No	65
2020507	Pacmyn	HotKebab	20205	Yes	164
2020601	Pacmyn	HotKebab	20206	No	73
2020703	ameenHere	HotKebab	20207	Yes	115
2020803	ameenHere	HotKebab	20208	No	89
2120503	Nathan492	ameenHere	21205	No	65
2120504	Pacmyn	Nathan492	21205	Yes	120
2120505	crimsonfever	Pacmyn	21205	No	120
2120506	WishMaster	crimsonfever	21205	Yes	127
2120507	NastyHobbit	WishMaster	21205	Yes	127
2120601	WishMaster	Nathan492	21206	No	113
2120602	Pacmyn	Balf	21206	No	147
2120603	OnThinIce	ameenHere	21206	Yes	157
2120604	WishMaster	OnThinIce	21206	No	162
2120605	crimsonfever	Pacmyn	21206	No	166
2120606	NastyHobbit	Justice	21206	Yes	180
2120701	OnThinIce	polarctic	21207	No	113
2120702	Balf	Justice	21207	Yes	166
2120703	Balf	Pacmyn	21207	Yes	174
2120704	WishMaster	OnThinIce	21207	No	175
2120705	WishMaster	NastyHobbit	21207	Yes	177
2120801	OnThinIce	ameenHere	21208	No	67
2120802	Justice	Balf	21208	No	83
2120803	Pacmyn	NastyHobbit	21208	Yes	116
2120804	WishMaster	crimsonfever	21208	No	119
2120805	OnThinIce	WishMaster	21208	No	120
2120806	Pacmyn	Nathan492	21208	No	130
2120901	ameenHere	crimsonfever	21209	No	45
2120902	ameenHere	NastyHobbit	21209	No	45
2120903	ameenHere	Balf	21209	Yes	61
2120904	Pacmyn	OnThinIce	21209	Yes	131
2120905	Nathan492	Pacmyn	21209	Yes	142
2120906	WishMaster	Nathan492	21209	Yes	158
2150101	GetMoisty	Justice	21501	No	95
2150102	ameenHere	Barboryx	21501	No	97
2150103	speedymax	ameenHere	21501	Yes	122
2150104	GetMoisty	FadeToBlue	21501	No	161
2150105	GetMoisty	Pacmyn	21501	Yes	161
2150106	GetMoisty	WishMaster	21501	Yes	168
2150201	Barboryx	Justice	21502	No	102
2150202	Spade	FadeToBlue	21502	Yes	108
2150203	WishMaster	Barboryx	21502	No	110
2150204	Spade	Pacmyn	21502	Yes	111
2150205	WishMaster	GetMoisty	21502	Yes	119
2150206	WishMaster	Spade	21502	Yes	127
2150207	WishMaster	MoodyCereal	21502	No	131
2150208	ameenHere	speedymax	21502	Yes	139
2150301	ameenHere	Spade	21503	Yes	37
2150302	FadeToBlue	GetMoisty	21503	Yes	55
2150303	ameenHere	speedymax	21503	No	146
2150305	FadeToBlue	MoodyCereal	21503	Yes	165
2150306	FadeToBlue	Barboryx	21503	No	167
2150401	GetMoisty	FadeToBlue	21504	Yes	34
2150402	Spade	WishMaster	21504	Yes	57
2150403	Pacmyn	Spade	21504	No	78
2150404	Pacmyn	GetMoisty	21504	No	129
2150405	Pacmyn	speedymax	21504	No	133
2150406	MoodyCereal	Justice	21504	Yes	138
2150407	ameenHere	Barboryx	21504	Yes	147
2150408	MoodyCereal	Pacmyn	21504	No	157
2150409	ameenHere	MoodyCereal	21504	Yes	167
2150501	FadeToBlue	Spade	21505	Yes	75
2150502	ameenHere	GetMoisty	21505	No	152
2150503	ameenHere	speedymax	21505	No	154
2150504	Barboryx	Justice	21505	Yes	163
2150505	MoodyCereal	ameenHere	21505	No	169
2150506	FadeToBlue	MoodyCereal	21505	Yes	173
2150507	Pacmyn	Barboryx	21505	No	173
2150601	WishMaster	speedymax	21506	Yes	136
2150602	ameenHere	GetMoisty	21506	No	150
2150603	Barboryx	Pacmyn	21506	No	156
2150604	Justice	MoodyCereal	21506	No	156
2150605	FadeToBlue	Spade	21506	Yes	161
2150606	FadeToBlue	Barboryx	21506	No	163
2150701	FadeToBlue	Spade	21507	Yes	56
2150702	FadeToBlue	speedymax	21507	No	74
2150703	WishMaster	Barboryx	21507	No	79
2150704	Pacmyn	GetMoisty	21507	No	125
2150705	MoodyCereal	FadeToBlue	21507	No	132
2150706	Justice	MoodyCereal	21507	No	135
2150801	Spade	WishMaster	21508	Yes	120
2150802	Spade	FadeToBlue	21508	No	146
2150803	Justice	Spade	21508	Yes	165
2150804	ameenHere	Barboryx	21508	No	165
2150805	MoodyCereal	ameenHere	21508	Yes	167
2150806	GetMoisty	Justice	21508	No	171
2150807	Pacmyn	GetMoisty	21508	No	174
2150901	WishMaster	Barboryx	21509	Yes	50
2150902	GetMoisty	WishMaster	21509	Yes	102
2150903	FadeToBlue	Spade	21509	No	104
2150904	FadeToBlue	MoodyCereal	21509	Yes	117
2150905	Pacmyn	GetMoisty	21509	No	122
2150906	ameenHere	speedymax	21509	Yes	139
2070101	Justice	Stan	20701	No	63
2070102	ameenHere	Nex_Ingeniarius	20701	Yes	64
2070103	ameenHere	Poseidon	20701	No	92
2070104	WishMaster	CalLycus	20701	No	112
2070105	Marras	ameenHere	20701	Yes	114
2070106	Justice	Marras	20701	Yes	127
2070107	Marras	Justice	20701	No	127
2070201	Marras	FadeToBlue	20702	Yes	106
2070202	Marras	WishMaster	20702	No	117
2070203	Pacmyn	Poseidon	20702	Yes	162
2070204	ameenHere	Stan	20702	Yes	174
2070205	Nex_Ingeniarius	Pacmyn	20702	No	175
2070206	Justice	Nex_Ingeniarius	20702	No	177
2070207	ameenHere	CalLycus	20702	Yes	177
2070208	Marras	Justice	20702	No	179
2070209	Marras	ameenHere	20702	No	182
2070301	Stan	ameenHere	20703	No	56
2070302	Nex_Ingeniarius	Justice	20703	Yes	87
2070303	FadeToBlue	Nex_Ingeniarius	20703	No	95
2070304	FadeToBlue	Poseidon	20703	No	99
2070305	Stan	FadeToBlue	20703	No	100
2070306	Stan	Pacmyn	20703	Yes	113
2070307	Marras	WishMaster	20703	Yes	141
2070401	Marras	ameenHere	20704	Yes	85
2070402	Nex_Ingeniarius	FadeToBlue	20704	Yes	90
2070403	Pacmyn	Marras	20704	Yes	90
2070404	Nex_Ingeniarius	WishMaster	20704	Yes	95
2070405	\N	Pacmyn	20704	No	91
2070406	Justice	Nex_Ingeniarius	20704	No	100
2070407	Stan	Justice	20704	Yes	119
2070501	Pacmyn	Stan	20705	Yes	67
2070502	Nex_Ingeniarius	Pacmyn	20705	Yes	70
2070503	Poseidon	FadeToBlue	20705	Yes	91
2070504	ameenHere	Nex_Ingeniarius	20705	No	150
2070505	ameenHere	Marras	20705	Yes	162
2070506	Poseidon	Justice	20705	Yes	164
2070507	ameenHere	CalLycus	20705	No	174
2070508	WishMaster	Poseidon	20705	No	174
2070601	ameenHere	CalLycus	20706	Yes	14
2070602	ameenHere	Nex_Ingeniarius	20706	No	74
2070603	WishMaster	Poseidon	20706	Yes	87
2070604	Stan	ameenHere	20706	No	96
2070605	Pacmyn	Stan	20706	No	99
2070606	Pacmyn	Marras	20706	Yes	148
2070701	Stan	Pacmyn	20707	Yes	70
2070702	Nex_Ingeniarius	ameenHere	20707	Yes	95
2070703	Justice	Stan	20707	No	97
2070704	Marras	Justice	20707	Yes	83
2070705	WishMaster	Marras	20707	No	83
2070706	WishMaster	Poseidon	20707	Yes	163
2070707	CalLycus	FadeToBlue	20707	Yes	173
2070708	WishMaster	CalLycus	20707	Yes	173
2070709	Nex_Ingeniarius	WishMaster	20707	No	178
2070801	Poseidon	FadeToBlue	20708	Yes	151
2070802	Marras	Pacmyn	20708	No	160
2070803	ameenHere	Nex_Ingeniarius	20708	Yes	164
2070804	CalLycus	Justice	20708	Yes	171
2070805	ameenHere	Poseidon	20708	No	172
2070806	WishMaster	Marras	20708	No	174
2070807	WishMaster	CalLycus	20708	Yes	178
2070808	Stan	ameenHere	20708	No	179
2070901	ameenHere	Marras	20709	No	65
2070902	ameenHere	Stan	20709	No	67
2070903	Nex_Ingeniarius	Pacmyn	20709	No	68
2070904	Nex_Ingeniarius	FadeToBlue	20709	Yes	74
2070905	Nex_Ingeniarius	WishMaster	20709	No	155
2070906	CalLycus	Justice	20709	Yes	159
2070907	Poseidon	ameenHere	20709	No	167
2071001	FadeToBlue	Poseidon	20710	No	68
2071002	ameenHere	Nex_Ingeniarius	20710	No	160
2071003	Stan	WishMaster	20710	Yes	170
2071004	Stan	Justice	20710	Yes	172
2071005	Pacmyn	CalLycus	20710	No	172
2071006	Stan	FadeToBlue	20710	Yes	176
2071007	Marras	ameenHere	20710	Yes	179
2200101	speedymax	Dante	22001	No	92
2200102	Balf	GetMoisty	22001	No	100
2200104	OnThinIce	Mastermagpie	22001	No	136
2200105	egons.on	Tommy	22001	Yes	141
2200106	speedymax	OnThinIce	22001	Yes	141
2200107	speedymax	Nathan492	22001	Yes	147
2200108	egons.on	speedymax	22001	Yes	151
2200201	speedymax	egons.on	22002	No	112
2200202	GetMoisty	OnThinIce	22002	No	118
2200203	speedymax	Balf	22002	No	160
2200204	Dante	speedymax	22002	Yes	164
2200301	Mastermagpie	Balf	22003	No	102
2200303	speedymax	Nathan492	22003	No	127
2200304	OnThinIce	Mastermagpie	22003	No	133
2200305	speedymax	egons.on	22003	No	134
2200306	GetMoisty	OnThinIce	22003	No	136
2200307	Dante	speedymax	22003	No	145
2200308	Tommy	Dante	22003	No	162
2200401	speedymax	Nathan492	22004	No	78
2200402	Dante	GetMoisty	22004	No	82
2200404	Tommy	Balf	22004	Yes	119
2200405	Dante	Tommy	22004	Yes	134
2200406	Dante	Mastermagpie	22004	No	142
2200407	Dante	speedymax	22004	No	151
2200501	egons.on	GetMoisty	22005	Yes	93
2200502	speedymax	egons.on	22005	Yes	116
2200503	Dante	speedymax	22005	Yes	161
2200504	Mastermagpie	Balf	22005	Yes	178
2200505	Mastermagpie	Dante	22005	No	186
2200507	OnThinIce	Tommy	22005	Yes	190
2200508	OnThinIce	Mastermagpie	22005	No	198
2200601	Tommy	Dante	22006	Yes	142
2200603	OnThinIce	Mastermagpie	22006	No	160
2200604	speedymax	OnThinIce	22006	Yes	163
2200605	Balf	GetMoisty	22006	No	174
2200606	Balf	speedymax	22006	No	176
2200701	speedymax	OnThinIce	22007	Yes	64
2200702	Nathan492	Tommy	22007	No	75
2200703	egons.on	speedymax	22007	No	80
2200704	egons.on	GetMoisty	22007	No	80
2200705	egons.on	Mastermagpie	22007	No	129
2200802	Dante	speedymax	22008	Yes	91
2200803	Mastermagpie	Nathan492	22008	No	151
2200804	Balf	Tommy	22008	Yes	165
2200805	Balf	Mastermagpie	22008	Yes	165
2200902	GetMoisty	egons.on	22009	No	71
2200904	Tommy	Nathan492	22009	No	112
2200905	speedymax	Balf	22009	No	115
2201001	Mastermagpie	egons.on	22010	Yes	44
2201002	Nathan492	Tommy	22010	No	105
2201005	Mastermagpie	Dante	22010	No	142
2201006	GetMoisty	Nathan492	22010	No	148
2201007	GetMoisty	Balf	22010	No	162
2201101	speedymax	OnThinIce	22011	Yes	85
2201102	egons.on	GetMoisty	22011	Yes	94
2201103	egons.on	Tommy	22011	No	111
2201106	Balf	speedymax	22011	No	169
2201107	egons.on	Mastermagpie	22011	Yes	179
2201202	GetMoisty	Dante	22012	No	103
2201203	speedymax	Nathan492	22012	No	144
2201204	egons.on	Mastermagpie	22012	No	165
2201205	speedymax	Balf	22012	No	166
2201206	egons.on	GetMoisty	22012	Yes	175
2200103	OnThinIce	SaiyanbornQueen	22001	No	129
2200302	OnThinIce	SaiyanbornQueen	22003	Yes	118
2200408	egons.on	SaiyanbornQueen	22004	No	157
2200506	OnThinIce	SaiyanbornQueen	22005	No	188
2200602	Balf	SaiyanbornQueen	22006	Yes	160
2200706	Dante	SaiyanbornQueen	22007	No	157
2200806	egons.on	SaiyanbornQueen	22008	No	172
2201004	Dante	SaiyanbornQueen	22010	No	133
2201105	Balf	SaiyanbornQueen	22011	Yes	150
2201208	speedymax	egons.on	22012	Yes	215
2201301	speedymax	egons.on	22013	No	97
2201302	Balf	GetMoisty	22013	Yes	157
2201303	Mastermagpie	Nathan492	22013	No	161
2201305	OnThinIce	Mastermagpie	22013	No	166
2201306	speedymax	OnThinIce	22013	Yes	168
2201307	Tommy	Balf	22013	No	176
2201308	speedymax	Dante	22013	Yes	217
2201402	\N	Mastermagpie	22014	No	130
2201404	OnThinIce	GetMoisty	22014	Yes	155
2201405	Tommy	egons.on	22014	No	159
2201406	OnThinIce	speedymax	22014	No	160
2201407	Tommy	OnThinIce	22014	No	168
2201408	Tommy	Nathan492	22014	No	176
2201409	Dante	Tommy	22014	No	177
2201501	OnThinIce	Tommy	22015	No	71
2201502	OnThinIce	Mastermagpie	22015	Yes	79
2201504	egons.on	speedymax	22015	No	167
2201505	Dante	GetMoisty	22015	Yes	172
2080101	Balf	Mastermagpie	20801	No	96
2080102	GetMoisty	TwinkPeach	20801	No	122
2080103	MoodyCereal	Balf	20801	No	146
2080105	MoodyCereal	OnThinIce	20801	No	161
2080106	NastyHobbit	Barboryx	20801	No	140
2080107	MoodyCereal	NastyHobbit	20801	Yes	144
2080202	speedymax	NastyHobbit	20802	Yes	72
2080203	MoodyCereal	Balf	20802	No	146
2080204	GetMoisty	TwinkPeach	20802	No	166
2080205	MoodyCereal	OnThinIce	20802	No	169
2080302	Balf	Mastermagpie	20803	Yes	45
2080303	Barboryx	OnThinIce	20803	No	92
2080304	speedymax	Balf	20803	Yes	93
2080305	NastyHobbit	Barboryx	20803	No	104
2080306	GetMoisty	NastyHobbit	20803	Yes	126
2080307	TwinkPeach	MoodyCereal	20803	Yes	130
2080308	speedymax	TwinkPeach	20803	No	132
2080401	OnThinIce	speedymax	20804	No	71
2080402	GetMoisty	OnThinIce	20804	Yes	88
2080403	Mastermagpie	Balf	20804	No	105
2080404	MoodyCereal	NastyHobbit	20804	No	112
2080406	MoodyCereal	TwinkPeach	20804	No	137
2080501	Mastermagpie	TwinkPeach	20805	Yes	108
2080502	MoodyCereal	Balf	20805	Yes	111
2080503	NastyHobbit	GetMoisty	20805	Yes	127
2080504	Barboryx	OnThinIce	20805	No	138
2080506	Barboryx	NastyHobbit	20805	No	156
2080601	MoodyCereal	OnThinIce	20806	Yes	36
2080602	Mastermagpie	Balf	20806	Yes	73
2080603	GetMoisty	TwinkPeach	20806	No	79
2080605	GetMoisty	NastyHobbit	20806	Yes	142
2080702	NastyHobbit	Barboryx	20807	No	62
2080703	GetMoisty	Balf	20807	Yes	64
2080704	TwinkPeach	GetMoisty	20807	Yes	66
2080705	TwinkPeach	MoodyCereal	20807	Yes	68
2080706	Mastermagpie	TwinkPeach	20807	No	71
2080707	Mastermagpie	NastyHobbit	20807	No	138
2080708	speedymax	OnThinIce	20807	No	152
2090101	Scarecrow	Spade	20901	No	33
2090102	GetMoisty	Scarecrow	20901	Yes	49
2090103	GetMoisty	Street	20901	No	123
2090106	Bauer	GetMoisty	20901	Yes	147
2090107	Mastermagpie	Bauer	20901	No	151
2090201	Jimmy	Spade	20902	No	107
2090202	GetMoisty	Jimmy	20902	No	122
2090203	speedymax	Street	20902	Yes	131
2090206	Bauer	GetMoisty	20902	No	157
2090207	speedymax	Mastermagpie	20902	No	163
2090208	speedymax	Bauer	20902	Yes	166
2090209	speedymax	Scarecrow	20902	Yes	157
2090301	Spade	FrenchFrie	20903	No	65
2090302	Spade	Jimmy	20903	No	106
2090304	Scarecrow	GetMoisty	20903	No	137
2090305	Spade	Street	20903	Yes	138
2090306	Scarecrow	Spade	20903	No	139
2090307	speedymax	Scarecrow	20903	No	149
2090401	speedymax	Scarecrow	20904	Yes	74
2090402	Jimmy	Mastermagpie	20904	No	75
2090403	Spade	Jimmy	20904	No	77
2090404	speedymax	Street	20904	No	79
2090405	Spade	Bauer	20904	No	97
2090406	Spade	FrenchFrie	20904	Yes	124
2090502	Street	Mastermagpie	20905	No	119
2090503	Street	GetMoisty	20905	Yes	122
2090504	Spade	FrenchFrie	20905	Yes	131
2090505	Spade	Scarecrow	20905	Yes	140
2090506	Spade	Bauer	20905	Yes	150
2090507	Street	Spade	20905	No	167
2090508	speedymax	Jimmy	20905	No	167
2090509	Street	speedymax	20905	No	169
2090601	Jimmy	speedymax	20906	No	114
2090602	Jimmy	GetMoisty	20906	No	114
2090603	FrenchFrie	Mastermagpie	20906	No	131
2090604	FrenchFrie	Spade	20906	Yes	153
2090701	Bauer	speedymax	20907	Yes	80
2090702	Street	Spade	20907	No	89
2090705	Bauer	Mastermagpie	20907	Yes	133
2090707	Bauer	GetMoisty	20907	No	151
2090801	Spade	Scarecrow	20908	No	139
2090802	Spade	Street	20908	Yes	150
2201207	egons.on	SaiyanbornQueen	22012	Yes	210
2201304	Dante	SaiyanbornQueen	22013	Yes	163
2090104	Tommy	Jimmy	20901	Yes	132
2090105	Tommy	FrenchFrie	20901	Yes	139
2090204	Tommy	FrenchFrie	20902	No	147
2090205	Bauer	Tommy	20902	No	148
2080104	MoodyCereal	HotKebab	20801	No	146
2090605	Scarecrow	Tommy	20906	Yes	153
2090708	Bauer	Tommy	20907	No	160
2090501	Bauer	Tommy	20905	Yes	15
2080201	Mastermagpie	HotKebab	20802	Yes	45
2080301	GetMoisty	HotKebab	20803	Yes	22
2080405	Mastermagpie	HotKebab	20804	Yes	129
2080505	speedymax	HotKebab	20805	Yes	146
2080604	Barboryx	HotKebab	20806	No	140
2080701	Barboryx	HotKebab	20807	Yes	56
2090804	FrenchFrie	GetMoisty	20908	Yes	156
2090805	Spade	FrenchFrie	20908	No	165
2090806	Bauer	Spade	20908	Yes	178
2090807	Mastermagpie	Bauer	20908	No	179
2090901	FrenchFrie	Mastermagpie	20909	No	78
2090903	Spade	Scarecrow	20909	No	99
2090904	GetMoisty	FrenchFrie	20909	Yes	108
2090905	Street	Spade	20909	Yes	120
2090906	Street	GetMoisty	20909	No	158
2090907	Street	speedymax	20909	No	170
2091001	FrenchFrie	Mastermagpie	20910	Yes	43
2091003	FrenchFrie	GetMoisty	20910	Yes	90
2091004	Spade	Scarecrow	20910	Yes	94
2091005	speedymax	FrenchFrie	20910	No	112
2091006	Jimmy	Spade	20910	Yes	114
2091007	Bauer	speedymax	20910	No	125
2091101	speedymax	Scarecrow	20911	Yes	61
2091103	Bauer	Spade	20911	Yes	91
2091105	Bauer	GetMoisty	20911	No	147
2091106	FrenchFrie	Mastermagpie	20911	Yes	140
2091109	FrenchFrie	speedymax	20911	No	154
2091201	Mastermagpie	Street	20912	Yes	39
2091202	Spade	Bauer	20912	Yes	66
2091203	Spade	Scarecrow	20912	No	85
2091204	Jimmy	Spade	20912	No	111
2091205	Jimmy	speedymax	20912	No	135
2091206	Mastermagpie	Jimmy	20912	No	138
2091207	Mastermagpie	FrenchFrie	20912	No	145
2091301	Street	Mastermagpie	20913	No	42
2091302	Spade	Street	20913	Yes	56
2091303	speedymax	Bauer	20913	No	143
2091304	FrenchFrie	Spade	20913	No	145
2091305	GetMoisty	FrenchFrie	20913	Yes	168
2091306	GetMoisty	Scarecrow	20913	No	141
2091401	Spade	Jimmy	20914	No	95
2091402	Spade	Bauer	20914	No	97
2091403	speedymax	Street	20914	No	102
2091405	FrenchFrie	GetMoisty	20914	Yes	106
2091406	Spade	FrenchFrie	20914	No	114
2091407	Scarecrow	Mastermagpie	20914	No	153
2091408	Scarecrow	Spade	20914	No	164
2091409	speedymax	Scarecrow	20914	No	165
2170101	Bauer	GetMoisty	21701	Yes	61
2170102	MoodyCereal	Bauer	21701	No	73
2170103	Barboryx	TheRandomGuy	21701	Yes	74
2170104	Street	MoodyCereal	21701	Yes	136
2170105	Street	speedymax	21701	No	136
2170106	Spade	fury	21701	No	153
2170107	Barboryx	Street	21701	No	166
2170108	Jimmy	Spade	21701	No	171
2170109	Barboryx	Jimmy	21701	No	174
2170201	Bauer	GetMoisty	21702	Yes	79
2170202	Street	speedymax	21702	No	101
2170203	Spade	fury	21702	Yes	105
2170204	Jimmy	Spade	21702	Yes	138
2170205	Street	Barboryx	21702	No	142
2170206	Street	MoodyCereal	21702	Yes	144
2170301	Street	Spade	21703	No	55
2170302	Street	speedymax	21703	Yes	66
2170303	MoodyCereal	Jimmy	21703	Yes	109
2170304	Bauer	Barboryx	21703	No	123
2170305	fury	MoodyCereal	21703	Yes	123
2170306	Bauer	GetMoisty	21703	Yes	124
2170401	Street	GetMoisty	21704	Yes	107
2170402	Street	speedymax	21704	Yes	121
2170403	MoodyCereal	Street	21704	Yes	125
2170404	Jimmy	MoodyCereal	21704	No	126
2170405	Barboryx	Jimmy	21704	Yes	134
2170406	Bauer	Spade	21704	No	134
2170407	Bauer	Barboryx	21704	Yes	138
2170501	Street	GetMoisty	21705	Yes	148
2170502	TheRandomGuy	Spade	21705	No	156
2170503	Street	speedymax	21705	No	165
2170504	TheRandomGuy	Barboryx	21705	No	149
2170505	MoodyCereal	Street	21705	Yes	151
2170506	MoodyCereal	fury	21705	Yes	157
2170507	Jimmy	MoodyCereal	21705	No	167
2170601	TheRandomGuy	GetMoisty	21706	No	135
2170602	TheRandomGuy	MoodyCereal	21706	No	146
2170603	Barboryx	TheRandomGuy	21706	Yes	149
2170604	Spade	fury	21706	Yes	163
2170605	Street	Barboryx	21706	No	168
2170606	Jimmy	Spade	21706	No	169
2170607	Bauer	speedymax	21706	No	180
2170701	TheRandomGuy	MoodyCereal	21707	Yes	147
2170702	GetMoisty	TheRandomGuy	21707	Yes	150
2170703	Spade	Jimmy	21707	Yes	155
2170704	Street	Barboryx	21707	Yes	160
2170705	Bauer	GetMoisty	21707	No	164
2170706	speedymax	fury	21707	No	136
2170707	speedymax	Street	21707	Yes	138
2170708	Spade	Bauer	21707	Yes	169
2170801	Street	Barboryx	21708	No	128
2170802	Spade	TheRandomGuy	21708	No	156
2170803	Bauer	Spade	21708	No	163
2170804	Bauer	GetMoisty	21708	No	166
2170805	speedymax	Bauer	21708	No	168
2170806	Street	MoodyCereal	21708	Yes	172
2170807	Jimmy	speedymax	21708	No	173
2160105	NastyHobbit	FrenchFrie	21601	No	155
2160106	OnThinIce	TheRandomGuy	21601	Yes	156
2160201	OnThinIce	Bauer	21602	No	81
2160202	Scarecrow	Balf	21602	No	108
2160204	TheRandomGuy	NastyHobbit	21602	No	123
2160206	Jimmy	OnThinIce	21602	No	158
2160302	Scarecrow	OnThinIce	21603	No	132
2160303	Scarecrow	Balf	21603	No	139
2160304	FrenchFrie	NastyHobbit	21603	Yes	139
2090902	Street	Tommy	20909	No	95
2091002	FrenchFrie	Tommy	20910	No	82
2091108	FrenchFrie	Tommy	20911	Yes	153
2160101	HotKebab	Scarecrow	21601	No	58
2160103	HotKebab	Bauer	21601	No	107
2160104	HotKebab	Jimmy	21601	Yes	135
2160205	TheRandomGuy	HotKebab	21602	No	123
2160305	FrenchFrie	HotKebab	21603	Yes	150
2160203	egons.on	Jimmy	21602	Yes	117
2160301	egons.on	Bauer	21603	Yes	52
2160102	Bauer	egons.on	21601	Yes	63
2160207	Scarecrow	egons.on	21602	No	174
2160306	FrenchFrie	egons.on	21603	No	155
2160402	Scarecrow	Balf	21604	No	69
2160403	Scarecrow	NastyHobbit	21604	No	73
2160404	OnThinIce	FrenchFrie	21604	Yes	103
2160405	OnThinIce	Jimmy	21604	Yes	106
2160406	Scarecrow	OnThinIce	21604	No	108
2160501	Balf	FrenchFrie	21605	Yes	112
2160503	Scarecrow	OnThinIce	21605	No	160
2160505	Bauer	Balf	21605	No	173
2160506	Bauer	NastyHobbit	21605	No	177
2160603	Jimmy	OnThinIce	21606	No	146
2160605	NastyHobbit	Scarecrow	21606	No	168
2160606	Bauer	NastyHobbit	21606	No	172
2160607	TheRandomGuy	Balf	21606	No	174
2160702	Scarecrow	Balf	21607	No	97
2160703	FrenchFrie	OnThinIce	21607	Yes	105
2160704	NastyHobbit	Jimmy	21607	No	110
2160706	Bauer	NastyHobbit	21607	No	136
2160801	NastyHobbit	Scarecrow	21608	Yes	64
2160802	NastyHobbit	TheRandomGuy	21608	Yes	77
2160803	FrenchFrie	OnThinIce	21608	No	91
2160805	NastyHobbit	Jimmy	21608	No	151
2160807	Balf	FrenchFrie	21608	No	174
2160902	FrenchFrie	Balf	21609	Yes	111
2160904	NastyHobbit	Scarecrow	21609	Yes	116
2160905	Jimmy	NastyHobbit	21609	Yes	117
2160906	OnThinIce	FrenchFrie	21609	Yes	118
2160907	OnThinIce	Jimmy	21609	Yes	128
2160908	OnThinIce	TheRandomGuy	21609	Yes	153
2160909	Bauer	OnThinIce	21609	No	156
2161002	Scarecrow	OnThinIce	21610	Yes	138
2161004	Balf	Jimmy	21610	No	151
2161101	NastyHobbit	Jimmy	21611	No	81
2161102	Bauer	OnThinIce	21611	Yes	81
2161103	Scarecrow	Balf	21611	Yes	116
2161105	Scarecrow	Balf	21611	No	121
2161106	FrenchFrie	NastyHobbit	21611	No	130
2030101	Street	Pacmyn	20301	No	46
2030102	Street	ameenHere	20301	Yes	53
2030103	Street	WishMaster	20301	No	63
2030104	polarctic	Street	20301	No	67
2030105	Justice	TheRandomGuy	20301	No	76
2030106	Justice	FrenchFrie	20301	No	128
2030107	Jimmy	Justice	20301	Yes	140
2030108	Jimmy	polarctic	20301	No	159
2030201	Scarecrow	WishMaster	20302	No	55
2030202	Street	Pacmyn	20302	No	70
2030203	Street	ameenHere	20302	No	125
2030204	Justice	Scarecrow	20302	No	127
2030205	Street	Justice	20302	No	129
2030206	Street	polarctic	20302	Yes	140
2030301	Justice	TheRandomGuy	20303	No	63
2030302	FrenchFrie	Justice	20303	Yes	78
2030303	Jimmy	ameenHere	20303	Yes	91
2030304	Street	Pacmyn	20303	Yes	124
2030305	WishMaster	Scarecrow	20303	Yes	128
2030306	polarctic	Street	20303	Yes	132
2030307	FrenchFrie	polarctic	20303	Yes	162
2030308	FrenchFrie	WishMaster	20303	No	166
2030402	WishMaster	FrenchFrie	20304	Yes	134
2030403	WishMaster	TheRandomGuy	20304	No	173
2030404	Jimmy	Pacmyn	20304	No	177
2030405	Scarecrow	WishMaster	20304	No	180
2030406	Scarecrow	polarctic	20304	Yes	180
2030407	Justice	Street	20304	No	180
2030501	TheRandomGuy	Justice	20305	Yes	107
2030502	TheRandomGuy	ameenHere	20305	Yes	108
2030503	polarctic	Street	20305	Yes	110
2030504	Pacmyn	Scarecrow	20305	Yes	156
2030505	Pacmyn	TheRandomGuy	20305	No	162
2030506	polarctic	Jimmy	20305	Yes	171
2030601	FrenchFrie	WishMaster	20306	Yes	90
2030602	Justice	Scarecrow	20306	Yes	122
2030603	Justice	Street	20306	Yes	131
2030604	WishMaster	TheRandomGuy	20306	Yes	132
2030605	WishMaster	FrenchFrie	20306	No	161
2030606	Jimmy	Justice	20306	Yes	166
2030607	ameenHere	Jimmy	20306	No	167
2030701	Justice	Scarecrow	20307	No	105
2030702	Street	Justice	20307	Yes	106
2030703	Street	ameenHere	20307	No	170
2030704	WishMaster	Street	20307	Yes	174
2030705	FrenchFrie	WishMaster	20307	No	179
2030706	FrenchFrie	polarctic	20307	Yes	179
2030801	Scarecrow	ameenHere	20308	No	77
2030802	Jimmy	Justice	20308	No	90
2030803	WishMaster	Jimmy	20308	Yes	115
2030804	FrenchFrie	Pacmyn	20308	No	117
2030805	WishMaster	Scarecrow	20308	No	122
2030806	Street	polarctic	20308	Yes	128
2030807	Street	WishMaster	20308	Yes	128
2030901	Pacmyn	Street	20309	No	92
2030902	TheRandomGuy	Pacmyn	20309	No	144
2030903	FrenchFrie	WishMaster	20309	Yes	149
2030904	polarctic	TheRandomGuy	20309	Yes	152
2030905	FrenchFrie	polarctic	20309	Yes	155
2030906	FrenchFrie	Justice	20309	Yes	137
2031001	WishMaster	Scarecrow	20310	Yes	103
2031002	Street	Pacmyn	20310	No	154
2031003	Street	ameenHere	20310	Yes	171
2031004	Justice	FrenchFrie	20310	Yes	174
2031005	WishMaster	TheRandomGuy	20310	Yes	175
2031006	Justice	Street	20310	Yes	179
2031007	Justice	Jimmy	20310	No	180
2031101	Justice	Jimmy	20311	Yes	85
2160401	Jimmy	HotKebab	21604	No	68
2160602	Jimmy	HotKebab	21606	Yes	136
2160705	FrenchFrie	HotKebab	21607	No	115
2160804	Bauer	HotKebab	21608	Yes	138
2030401	Street	ameenHere	20304	Yes	93
2160502	egons.on	TheRandomGuy	21605	Yes	128
2160504	egons.on	Scarecrow	21605	Yes	172
2160601	egons.on	FrenchFrie	21606	No	134
2160604	egons.on	Jimmy	21606	Yes	150
2160806	egons.on	Bauer	21608	No	169
2160608	Jimmy	egons.on	21606	No	174
2160701	FrenchFrie	egons.on	21607	Yes	75
2160901	TheRandomGuy	egons.on	21609	Yes	86
2031102	Pacmyn	Street	20311	Yes	90
2031103	Pacmyn	TheRandomGuy	20311	Yes	144
2031104	Pacmyn	FrenchFrie	20311	No	148
2031105	Scarecrow	Justice	20311	No	157
2031106	Scarecrow	WishMaster	20311	Yes	148
2031107	ameenHere	Scarecrow	20311	No	163
2031201	FrenchFrie	Justice	20312	Yes	116
2031202	WishMaster	Scarecrow	20312	No	138
2031203	Pacmyn	TheRandomGuy	20312	Yes	139
2031204	ameenHere	FrenchFrie	20312	Yes	141
2031205	Street	Pacmyn	20312	Yes	148
2031206	polarctic	Street	20312	Yes	141
2031207	ameenHere	Jimmy	20312	No	142
2031301	Pacmyn	TheRandomGuy	20313	Yes	63
2031302	WishMaster	Scarecrow	20313	Yes	140
2031303	Street	Pacmyn	20313	Yes	143
2031304	polarctic	FrenchFrie	20313	Yes	145
2031305	Street	ameenHere	20313	Yes	155
2031306	Street	Justice	20313	Yes	174
2031307	Street	polarctic	20313	Yes	179
2031308	Street	WishMaster	20313	No	179
2031401	WishMaster	Street	20314	No	94
2031402	polarctic	FrenchFrie	20314	Yes	127
2031403	polarctic	Scarecrow	20314	No	135
2031404	TheRandomGuy	Justice	20314	Yes	142
2031405	WishMaster	TheRandomGuy	20314	No	147
2031501	ameenHere	Scarecrow	20315	Yes	47
2031502	Pacmyn	Street	20315	Yes	82
2031503	Jimmy	polarctic	20315	No	107
2031504	Justice	TheRandomGuy	20315	No	125
2031505	WishMaster	FrenchFrie	20315	No	139
2031506	Pacmyn	Jimmy	20315	Yes	141
2050101	FadeToBlue	MoodyCereal	20501	Yes	155
2050102	Pacmyn	SaiyanbornQueen	20501	Yes	155
2050103	Pacmyn	Mastermagpie	20501	Yes	158
2050104	GetMoisty	Pacmyn	20501	No	161
2050105	FadeToBlue	speedymax	20501	Yes	169
2050106	Justice	GetMoisty	20501	No	170
2050201	WishMaster	Mastermagpie	20502	No	72
2050202	Pacmyn	GetMoisty	20502	Yes	100
2050203	MoodyCereal	Pacmyn	20502	Yes	102
2050204	FadeToBlue	speedymax	20502	Yes	130
2050205	MoodyCereal	ameenHere	20502	No	142
2050206	SaiyanbornQueen	FadeToBlue	20502	No	158
2050207	MoodyCereal	Justice	20502	No	163
2050208	MoodyCereal	WishMaster	20502	Yes	176
2050301	MoodyCereal	FadeToBlue	20503	Yes	47
2050302	ameenHere	Mastermagpie	20503	Yes	51
2050303	MoodyCereal	WishMaster	20503	Yes	103
2050304	ameenHere	GetMoisty	20503	Yes	141
2050305	MoodyCereal	Pacmyn	20503	No	155
2050306	Pacmyn	MoodyCereal	20503	No	173
2050307	speedymax	ameenHere	20503	No	174
2050308	SaiyanbornQueen	Justice	20503	No	174
2050401	FadeToBlue	speedymax	20504	Yes	91
2050402	GetMoisty	FadeToBlue	20504	No	143
2050403	Justice	Mastermagpie	20504	No	146
2050404	GetMoisty	Justice	20504	Yes	163
2050405	SaiyanbornQueen	Pacmyn	20504	Yes	163
2050406	GetMoisty	ameenHere	20504	No	166
2050501	ameenHere	Mastermagpie	20505	Yes	91
2050502	speedymax	Pacmyn	20505	Yes	119
2050503	GetMoisty	FadeToBlue	20505	Yes	142
2050504	WishMaster	speedymax	20505	No	144
2050505	WishMaster	MoodyCereal	20505	No	149
2050506	Justice	GetMoisty	20505	No	159
2050507	WishMaster	SaiyanbornQueen	20505	No	164
2050601	Pacmyn	GetMoisty	20506	No	102
2050602	ameenHere	SaiyanbornQueen	20506	No	135
2050603	ameenHere	speedymax	20506	Yes	141
2050604	MoodyCereal	ameenHere	20506	No	145
2050605	Mastermagpie	Justice	20506	No	150
2050606	WishMaster	MoodyCereal	20506	No	152
2050607	FadeToBlue	Mastermagpie	20506	Yes	183
2050701	ameenHere	MoodyCereal	20507	Yes	101
2050702	speedymax	Justice	20507	No	109
2050703	\N	Mastermagpie	20507	No	144
2050704	Pacmyn	GetMoisty	20507	No	152
2050705	WishMaster	speedymax	20507	No	172
2050706	ameenHere	SaiyanbornQueen	20507	No	172
2050801	ameenHere	SaiyanbornQueen	20508	Yes	50
2050802	speedymax	ameenHere	20508	No	53
2050803	Mastermagpie	FadeToBlue	20508	Yes	98
2050804	WishMaster	speedymax	20508	Yes	144
2050805	Mastermagpie	WishMaster	20508	Yes	168
2050806	Pacmyn	Mastermagpie	20508	Yes	171
2050807	Justice	MoodyCereal	20508	Yes	178
2050901	Justice	MoodyCereal	20509	Yes	35
2050902	FadeToBlue	GetMoisty	20509	No	147
2050903	Mastermagpie	WishMaster	20509	No	157
2050904	Pacmyn	speedymax	20509	No	158
2050905	SaiyanbornQueen	Pacmyn	20509	No	161
2050906	ameenHere	Mastermagpie	20509	No	168
2050907	Justice	SaiyanbornQueen	20509	No	179
2051001	Pacmyn	MoodyCereal	20510	Yes	89
2051002	WishMaster	speedymax	20510	Yes	142
2051003	FadeToBlue	GetMoisty	20510	Yes	154
2051004	ameenHere	Mastermagpie	20510	Yes	160
2051005	ameenHere	SaiyanbornQueen	20510	No	176
2060101	FrenchFrie	crimsonfever	20601	No	64
2060102	Balf	Street	20601	Yes	88
2060103	egons.on	FrenchFrie	20601	No	89
2060104	Scarecrow	egons.on	20601	Yes	93
2060106	OnThinIce	Bauer	20601	Yes	128
2060108	Jimmy	Balf	20601	No	141
2060109	OnThinIce	Jimmy	20601	No	167
2060201	crimsonfever	Bauer	20602	Yes	64
2060202	FrenchFrie	egons.on	20602	Yes	88
2060204	Jimmy	crimsonfever	20602	Yes	157
2060206	Street	Balf	20602	Yes	164
2060207	Jimmy	OnThinIce	20602	Yes	166
2060301	OnThinIce	Bauer	20603	Yes	93
2060302	Street	OnThinIce	20603	No	94
2060303	Street	egons.on	20603	Yes	114
2140802	Street	Stan	21408	Yes	99
2060107	Jimmy	HotKebab	20601	No	128
2060208	Street	HotKebab	20602	Yes	167
2031406	ameenHere	Jimmy	20314	No	148
2060305	Jimmy	Balf	20603	Yes	136
2060401	Street	Balf	20604	Yes	83
2060403	OnThinIce	Jimmy	20604	No	106
2060404	FrenchFrie	OnThinIce	20604	Yes	115
2060405	crimsonfever	Scarecrow	20604	No	129
2060406	Street	egons.on	20604	No	135
2060407	Street	crimsonfever	20604	Yes	136
2060501	OnThinIce	FrenchFrie	20605	No	55
2060502	Scarecrow	egons.on	20605	Yes	111
2060503	Balf	Bauer	20605	Yes	122
2060506	Balf	Scarecrow	20605	No	143
2060601	Balf	Scarecrow	20606	Yes	83
2060602	OnThinIce	Street	20606	Yes	92
2060603	crimsonfever	FrenchFrie	20606	No	99
2060604	Bauer	OnThinIce	20606	No	138
2060605	Jimmy	egons.on	20606	Yes	152
2060607	crimsonfever	Jimmy	20606	No	163
2060608	Bauer	crimsonfever	20606	Yes	177
2060701	OnThinIce	Bauer	20607	Yes	95
2060703	crimsonfever	Street	20607	Yes	138
2060704	Scarecrow	OnThinIce	20607	No	147
2060705	egons.on	FrenchFrie	20607	No	187
2060706	Balf	Scarecrow	20607	Yes	202
2060801	FrenchFrie	Balf	20608	Yes	147
2060803	OnThinIce	Scarecrow	20608	No	173
2060804	Bauer	crimsonfever	20608	Yes	173
2060805	OnThinIce	FrenchFrie	20608	No	174
2060901	Balf	Street	20609	No	91
2060902	FrenchFrie	Balf	20609	No	95
2060904	OnThinIce	Bauer	20609	Yes	109
2060905	Jimmy	egons.on	20609	Yes	122
2060906	Scarecrow	crimsonfever	20609	No	155
2060908	Scarecrow	OnThinIce	20609	No	180
2061001	Jimmy	egons.on	20610	Yes	121
2061002	Scarecrow	crimsonfever	20610	Yes	125
2061003	Scarecrow	OnThinIce	20610	Yes	129
2061006	FrenchFrie	Balf	20610	No	176
2061102	Bauer	OnThinIce	20611	No	34
2061104	Balf	Bauer	20611	Yes	35
2061105	crimsonfever	FrenchFrie	20611	No	37
2061106	Balf	Street	20611	No	37
2061107	egons.on	Jimmy	20611	Yes	41
2061202	Scarecrow	OnThinIce	20612	Yes	103
2061204	Scarecrow	crimsonfever	20612	No	145
2061205	crimsonfever	Scarecrow	20612	No	153
2061206	egons.on	FrenchFrie	20612	Yes	160
2061208	egons.on	Bauer	20612	No	168
2061301	Balf	FrenchFrie	20613	Yes	69
2061302	Street	crimsonfever	20613	Yes	117
2061303	Bauer	OnThinIce	20613	No	118
2061304	Jimmy	egons.on	20613	No	122
2061306	Balf	Street	20613	Yes	126
2061307	Jimmy	Balf	20613	No	126
2061401	Balf	Bauer	20614	No	68
2061402	FrenchFrie	egons.on	20614	Yes	94
2061403	Street	crimsonfever	20614	Yes	103
2061404	Street	Balf	20614	No	121
2061406	Scarecrow	OnThinIce	20614	No	122
2140101	Scarecrow	Stan	21401	No	113
2140102	Bauer	Nex_Ingeniarius	21401	Yes	139
2140103	Marras	Jimmy	21401	Yes	140
2140104	Marras	Street	21401	Yes	145
2140105	Bauer	CalLycus	21401	No	170
2140106	Bauer	Marras	21401	No	170
2140107	Scarecrow	Omega	21401	No	176
2140201	Nex_Ingeniarius	Bauer	21402	Yes	61
2140202	Stan	Scarecrow	21402	Yes	82
2140203	Stan	fury	21402	Yes	102
2140204	Stan	Street	21402	No	103
2140205	Jimmy	CalLycus	21402	Yes	112
2140206	Stan	Jimmy	21402	Yes	118
2140301	Bauer	Nex_Ingeniarius	21403	Yes	93
2140302	Street	Stan	21403	Yes	119
2140303	Marras	Scarecrow	21403	No	135
2140304	Bauer	Omega	21403	No	161
2140305	Street	CalLycus	21403	No	172
2140306	Bauer	Marras	21403	No	172
2140401	Street	Omega	21404	Yes	40
2140402	CalLycus	Bauer	21404	Yes	72
2140403	Scarecrow	Marras	21404	No	84
2140404	Street	Stan	21404	No	145
2140405	Jimmy	CalLycus	21404	No	149
2140406	Street	Nex_Ingeniarius	21404	No	149
2140501	Nex_Ingeniarius	Jimmy	21405	Yes	79
2140502	Scarecrow	Nex_Ingeniarius	21405	Yes	117
2140503	Scarecrow	Omega	21405	No	138
2140504	Street	Stan	21405	Yes	155
2140505	Marras	Scarecrow	21405	Yes	162
2140506	fury	Marras	21405	Yes	178
2140507	Bauer	CalLycus	21405	No	179
2140601	Jimmy	Stan	21406	Yes	41
2140602	fury	Marras	21406	Yes	125
2140603	Omega	Scarecrow	21406	No	149
2140604	Jimmy	Nex_Ingeniarius	21406	Yes	150
2140605	Jimmy	CalLycus	21406	No	156
2140606	Omega	Bauer	21406	No	166
2140607	Jimmy	Omega	21406	Yes	177
2140701	Scarecrow	Marras	21407	Yes	33
2140702	Bauer	Nex_Ingeniarius	21407	No	140
2140703	Omega	fury	21407	Yes	154
2140704	Bauer	Stan	21407	Yes	155
2140705	Street	CalLycus	21407	Yes	164
2140706	Omega	Street	21407	No	173
2140707	Jimmy	Omega	21407	Yes	177
2140801	Stan	Jimmy	21408	No	71
2060308	Scarecrow	HotKebab	20603	No	156
2060402	Jimmy	HotKebab	20604	No	92
2060606	Bauer	HotKebab	20606	No	159
2060907	Jimmy	HotKebab	20609	No	172
2061005	Bauer	HotKebab	20610	No	173
2061103	Street	HotKebab	20611	No	34
2061207	Bauer	HotKebab	20612	No	168
2061305	Street	HotKebab	20613	Yes	126
2061405	FrenchFrie	HotKebab	20614	Yes	121
2140803	Omega	Scarecrow	21408	No	103
2140804	Nex_Ingeniarius	Street	21408	Yes	120
2140805	Nex_Ingeniarius	fury	21408	Yes	143
2140806	Bauer	Marras	21408	No	159
2140807	Omega	Bauer	21408	Yes	160
2140901	CalLycus	Scarecrow	21409	No	110
2140902	Stan	fury	21409	No	114
2140903	Nex_Ingeniarius	Street	21409	Yes	121
2140904	Stan	Jimmy	21409	No	127
2140905	Marras	Bauer	21409	No	127
2141001	fury	Nex_Ingeniarius	21410	Yes	15
2141002	Stan	Scarecrow	21410	No	137
2141003	Bauer	Marras	21410	No	142
2141004	Street	Stan	21410	No	145
2141005	Street	CalLycus	21410	No	158
2141006	Omega	Street	21410	No	165
2141007	Omega	fury	21410	No	198
2141008	Bauer	Omega	21410	No	199
2180101	Vance	Nex_Ingeniarius	21801	No	69
2180102	NastyHobbit	Poseidon	21801	Yes	79
2180103	Marras	Vance	21801	No	79
2180104	Marras	OnThinIce	21801	No	132
2180105	Marras	NastyHobbit	21801	Yes	146
2180106	egons.on	CalLycus	21801	Yes	147
2180107	Omega	egons.on	21801	Yes	150
2180108	Marras	Nathan492	21801	Yes	159
2180201	CalLycus	egons.on	21802	Yes	63
2180202	Marras	Vance	21802	No	92
2180203	Marras	Nathan492	21802	No	112
2180204	Marras	OnThinIce	21802	No	123
2180205	Nex_Ingeniarius	NastyHobbit	21802	Yes	124
2180301	egons.on	Poseidon	21803	Yes	120
2180302	Vance	Omega	21803	Yes	125
2180303	Nex_Ingeniarius	OnThinIce	21803	Yes	133
2180304	CalLycus	Vance	21803	No	135
2180305	Nex_Ingeniarius	NastyHobbit	21803	No	141
2180306	egons.on	Marras	21803	Yes	145
2180307	Nex_Ingeniarius	Nathan492	21803	No	163
2180308	egons.on	CalLycus	21803	Yes	164
2180309	egons.on	Nex_Ingeniarius	21803	No	169
2180401	Vance	Poseidon	21804	Yes	127
2180402	Nex_Ingeniarius	Nathan492	21804	No	142
2180403	OnThinIce	Marras	21804	No	159
2180404	Omega	OnThinIce	21804	No	167
2180405	Omega	egons.on	21804	Yes	173
2180406	NastyHobbit	Omega	21804	No	177
2180407	Nex_Ingeniarius	NastyHobbit	21804	No	181
2180408	Vance	CalLycus	21804	Yes	183
2180409	Vance	Nex_Ingeniarius	21804	No	211
2180501	Poseidon	Nathan492	21805	No	68
2180502	Vance	Nex_Ingeniarius	21805	No	76
2180503	Marras	egons.on	21805	Yes	81
2180504	Poseidon	Vance	21805	Yes	130
2180505	NastyHobbit	Poseidon	21805	No	138
2180506	Omega	OnThinIce	21805	No	146
2180507	Marras	NastyHobbit	21805	Yes	151
2180601	Poseidon	OnThinIce	21806	Yes	144
2180602	egons.on	CalLycus	21806	Yes	154
2180603	Nathan492	Poseidon	21806	No	157
2180604	Omega	Nathan492	21806	No	165
2180605	Vance	Omega	21806	Yes	173
2180606	Marras	Vance	21806	Yes	178
2180701	OnThinIce	CalLycus	21807	No	73
2180702	OnThinIce	Marras	21807	No	75
2180703	Nex_Ingeniarius	OnThinIce	21807	No	95
2180704	egons.on	Nex_Ingeniarius	21807	Yes	132
2180705	Poseidon	egons.on	21807	Yes	136
2180706	Omega	Nathan492	21807	No	136
2180707	Poseidon	NastyHobbit	21807	Yes	140
2180708	Vance	Poseidon	21807	No	141
2180709	Vance	Omega	21807	Yes	177
2180801	egons.on	Marras	21808	Yes	70
2180802	OnThinIce	CalLycus	21808	No	106
2180803	Nex_Ingeniarius	egons.on	21808	No	137
2180804	Omega	NastyHobbit	21808	Yes	140
2180805	OnThinIce	Poseidon	21808	Yes	141
2180806	OnThinIce	Nex_Ingeniarius	21808	No	149
2180807	Vance	Omega	21808	Yes	178
2180901	Marras	OnThinIce	21809	Yes	125
2180902	egons.on	Poseidon	21809	No	129
2180903	Nex_Ingeniarius	NastyHobbit	21809	Yes	130
2180904	Nex_Ingeniarius	Vance	21809	Yes	132
2180905	Nex_Ingeniarius	egons.on	21809	Yes	154
2180906	Omega	Nathan492	21809	No	159
2181001	Vance	Poseidon	21810	Yes	85
2181002	Nex_Ingeniarius	OnThinIce	21810	No	85
2181003	Marras	Vance	21810	No	122
2181004	Marras	Nathan492	21810	No	125
2181005	CalLycus	egons.on	21810	No	148
2181006	Marras	NastyHobbit	21810	Yes	168
2181101	OnThinIce	CalLycus	21811	No	26
2181102	Poseidon	OnThinIce	21811	No	27
2181103	Nex_Ingeniarius	egons.on	21811	No	100
2181104	Omega	Nathan492	21811	Yes	107
2181105	Vance	Poseidon	21811	Yes	108
2181106	Nex_Ingeniarius	NastyHobbit	21811	No	160
2181107	Marras	Vance	21811	No	169
2190101	Marras	ameenHere	21901	No	98
2190102	FadeToBlue	Stan	21901	Yes	129
2190103	FadeToBlue	CalLycus	21901	Yes	141
2190104	WishMaster	Omega	21901	No	168
2190105	FadeToBlue	Marras	21901	Yes	170
2190106	Nex_Ingeniarius	polarctic	21901	No	170
2190107	WishMaster	Nex_Ingeniarius	21901	No	173
2190201	Marras	FadeToBlue	21902	No	75
2190202	Marras	Justice	21902	Yes	76
2190203	Marras	WishMaster	21902	No	83
2190204	polarctic	Stan	21902	Yes	90
2190205	Nex_Ingeniarius	polarctic	21902	Yes	134
2190206	Nex_Ingeniarius	ameenHere	21902	No	141
2190301	ameenHere	Marras	21903	No	85
2190302	ameenHere	Nex_Ingeniarius	21903	No	114
2190303	ameenHere	Omega	21903	No	133
2190304	ameenHere	CalLycus	21903	No	133
2190305	Stan	Justice	21903	Yes	150
2190306	Stan	ameenHere	21903	Yes	152
2190307	FadeToBlue	Stan	21903	No	153
2190308	Stan	FadeToBlue	21903	Yes	153
2190401	Stan	Justice	21904	No	55
2190402	ameenHere	Nex_Ingeniarius	21904	No	138
2190403	Stan	polarctic	21904	Yes	147
2190404	WishMaster	CalLycus	21904	Yes	154
2190405	Stan	FadeToBlue	21904	No	157
2190406	Stan	WishMaster	21904	Yes	171
2190407	Omega	ameenHere	21904	No	180
2190501	Stan	FadeToBlue	21905	Yes	89
2190502	Justice	Stan	21905	Yes	90
2190503	Nex_Ingeniarius	Justice	21905	No	93
2190504	CalLycus	polarctic	21905	Yes	98
2190505	CalLycus	WishMaster	21905	No	110
2190506	Nex_Ingeniarius	ameenHere	21905	No	125
2190601	Stan	FadeToBlue	21906	Yes	35
2190602	ameenHere	Marras	21906	No	97
2190603	Justice	Stan	21906	No	135
2190604	Omega	WishMaster	21906	No	172
2190605	Nex_Ingeniarius	polarctic	21906	No	173
2190606	Nex_Ingeniarius	Justice	21906	Yes	177
2190607	ameenHere	Omega	21906	Yes	185
2190608	ameenHere	Nex_Ingeniarius	21906	No	195
2190609	ameenHere	CalLycus	21906	No	210
2190701	Nex_Ingeniarius	FadeToBlue	21907	Yes	92
2190702	Justice	Stan	21907	Yes	101
2190703	ameenHere	Nex_Ingeniarius	21907	No	106
2190704	ameenHere	Omega	21907	Yes	140
2190705	polarctic	Marras	21907	No	171
2190706	ameenHere	CalLycus	21907	Yes	171
2190801	ameenHere	Nex_Ingeniarius	21908	No	89
2190802	Marras	Justice	21908	No	138
2190803	Marras	polarctic	21908	No	139
2190804	Stan	ameenHere	21908	No	149
2190805	Stan	FadeToBlue	21908	No	158
2190806	WishMaster	Marras	21908	No	161
2190807	Omega	WishMaster	21908	No	162
2190901	Nex_Ingeniarius	FadeToBlue	21909	No	81
2190902	ameenHere	Stan	21909	Yes	82
2190903	Marras	ameenHere	21909	No	85
2190904	Marras	Justice	21909	Yes	86
2190905	Marras	polarctic	21909	No	107
2190906	Omega	WishMaster	21909	No	107
2191001	FadeToBlue	Nex_Ingeniarius	21910	No	143
2191002	Stan	ameenHere	21910	Yes	147
2191003	WishMaster	Stan	21910	No	151
2191004	Omega	polarctic	21910	Yes	155
2191005	WishMaster	Omega	21910	No	156
2191006	Justice	CalLycus	21910	Yes	162
2191007	FadeToBlue	Marras	21910	Yes	164
2191101	Marras	ameenHere	21911	Yes	83
2191102	polarctic	Nex_Ingeniarius	21911	No	98
2191103	Marras	polarctic	21911	No	99
2191104	Stan	FadeToBlue	21911	No	101
2191105	WishMaster	CalLycus	21911	Yes	122
2191106	Stan	WishMaster	21911	No	152
2191107	Stan	Justice	21911	Yes	153
2191201	Marras	polarctic	21912	No	57
2191202	CalLycus	ameenHere	21912	No	63
2191203	WishMaster	CalLycus	21912	No	64
2191204	Marras	Justice	21912	No	65
2191205	WishMaster	Omega	21912	No	68
2191206	FadeToBlue	Marras	21912	No	62
2191207	Stan	WishMaster	21912	Yes	88
2191208	Stan	FadeToBlue	21912	No	94
2040101	Marras	Jimmy	20401	Yes	131
2040102	Stan	Street	20401	Yes	137
2040104	Nex_Ingeniarius	Bauer	20401	No	157
2040201	Jimmy	Nex_Ingeniarius	20402	No	90
2040202	Marras	Bauer	20402	Yes	98
2040203	Jimmy	Omega	20402	Yes	109
2040204	Marras	Street	20402	Yes	113
2040205	Jimmy	CalLycus	20402	Yes	115
2040206	Marras	TheRandomGuy	20402	Yes	121
2040207	Jimmy	Stan	20402	No	145
2040301	Marras	Street	20403	Yes	64
2040303	Bauer	Jimmy	20403	No	99
2040304	Bauer	Stan	20403	No	101
2040305	Marras	Bauer	20403	Yes	115
2200205	SaiyanbornQueen	Nathan492	22002	No	173
2200206	SaiyanbornQueen	Dante	22002	Yes	176
2200403	SaiyanbornQueen	OnThinIce	22004	Yes	111
2200801	SaiyanbornQueen	OnThinIce	22008	No	60
2200901	SaiyanbornQueen	Dante	22009	Yes	51
2200903	SaiyanbornQueen	OnThinIce	22009	Yes	76
2201003	SaiyanbornQueen	OnThinIce	22010	No	123
2201104	SaiyanbornQueen	Dante	22011	Yes	113
2201201	SaiyanbornQueen	OnThinIce	22012	Yes	72
2201401	SaiyanbornQueen	Balf	22014	Yes	127
2201503	SaiyanbornQueen	Nathan492	22015	No	99
2201403	Dante	SaiyanbornQueen	22014	No	132
2090303	Tommy	Bauer	20903	No	117
2090703	Tommy	Street	20907	Yes	98
2090704	Tommy	Jimmy	20907	Yes	98
2090706	Tommy	FrenchFrie	20907	Yes	147
2090803	Tommy	Jimmy	20908	Yes	154
2091102	Tommy	Jimmy	20911	No	68
2091104	Tommy	Street	20911	Yes	146
2091107	Tommy	Bauer	20911	No	143
2091307	Tommy	Jimmy	20913	Yes	145
2091404	Scarecrow	Tommy	20914	Yes	106
2040208	fury	Marras	20402	No	167
2040103	Marras	fury	20401	No	149
2040302	Stan	fury	20403	Yes	88
2020503	HotKebab	FadeToBlue	20205	No	148
2020506	HotKebab	Justice	20205	Yes	160
2020802	HotKebab	FadeToBlue	20208	Yes	30
2160507	HotKebab	Bauer	21605	Yes	188
2161001	HotKebab	TheRandomGuy	21610	Yes	68
2161005	HotKebab	FrenchFrie	21610	No	158
2161006	HotKebab	Scarecrow	21610	Yes	165
2060105	HotKebab	Scarecrow	20601	Yes	120
2060203	HotKebab	Scarecrow	20602	No	154
2060205	HotKebab	FrenchFrie	20602	No	164
2060304	HotKebab	Street	20603	Yes	129
2060306	HotKebab	FrenchFrie	20603	Yes	151
2060307	HotKebab	Jimmy	20603	No	154
2060504	HotKebab	Jimmy	20605	Yes	124
2060505	HotKebab	Street	20605	No	125
2060702	HotKebab	Jimmy	20607	Yes	135
2060802	HotKebab	Street	20608	Yes	171
2060903	HotKebab	FrenchFrie	20609	No	98
2061004	HotKebab	Jimmy	20610	No	139
2061101	HotKebab	Scarecrow	20611	Yes	29
2061201	HotKebab	Jimmy	20612	No	85
2061203	HotKebab	Street	20612	Yes	145
2020103	Pacmyn	HotKebab	20201	Yes	151
2020201	Pacmyn	HotKebab	20202	Yes	69
2020305	FadeToBlue	HotKebab	20203	No	154
2020406	Justice	HotKebab	20204	No	178
2160903	FrenchFrie	HotKebab	21609	Yes	115
2161003	egons.on	Bauer	21610	Yes	140
2161104	egons.on	Bauer	21611	Yes	117
2100102	Nex_Ingeniarius	Balf	21001	No	57
2100105	TwinkPeach	Stan	21001	Yes	104
2100106	TwinkPeach	CalLycus	21001	No	111
2100107	Marras	TwinkPeach	21001	Yes	114
2100108	Marras	Nathan492	21001	No	115
2100202	Marras	Nathan492	21002	Yes	69
2100203	TwinkPeach	Stan	21002	No	74
2100204	Marras	Balf	21002	No	124
2100205	Nex_Ingeniarius	TwinkPeach	21002	No	142
2100206	Balf	Marras	21002	No	145
2100301	Stan	TwinkPeach	21003	Yes	85
2100302	Marras	Balf	21003	Yes	114
2100304	Stan	Nathan492	21003	Yes	170
2100402	Stan	TwinkPeach	21004	No	54
2100103	egons.on	Nex_Ingeniarius	21001	Yes	59
2100104	Stan	egons.on	21001	Yes	61
2100208	CalLycus	egons.on	21002	No	149
2100401	Stan	egons.on	21004	No	35
2100303	HotKebab	Nex_Ingeniarius	21003	Yes	137
2100101	Nex_Ingeniarius	HotKebab	21001	Yes	46
2100201	Stan	HotKebab	21002	No	68
2110301	Stan	SaiyanbornQueen	21103	No	101
2110303	Stan	Barboryx	21103	Yes	115
2110304	speedymax	Nex_Ingeniarius	21103	Yes	125
2110305	Stan	Mastermagpie	21103	Yes	126
2110306	speedymax	Stan	21103	No	143
2110307	CalLycus	speedymax	21103	Yes	158
2110401	Marras	Barboryx	21104	Yes	50
2110404	RooClarke	Mastermagpie	21104	No	130
2110405	speedymax	Stan	21104	No	149
2110406	speedymax	CalLycus	21104	Yes	171
2110501	Stan	Mastermagpie	21105	No	67
2110502	SaiyanbornQueen	RooClarke	21105	Yes	97
2110504	Barboryx	Stan	21105	No	134
2110505	Barboryx	CalLycus	21105	No	142
2110506	Nex_Ingeniarius	Barboryx	21105	Yes	161
2110602	Marras	SaiyanbornQueen	21106	Yes	110
2110603	Barboryx	Marras	21106	No	114
2110604	Mastermagpie	Nex_Ingeniarius	21106	Yes	117
2110605	Stan	Mastermagpie	21106	Yes	118
2110606	Stan	speedymax	21106	Yes	123
2110607	CalLycus	Barboryx	21106	No	127
2110701	Stan	Mastermagpie	21107	Yes	57
2110702	speedymax	Stan	21107	Yes	75
2110703	Barboryx	CalLycus	21107	Yes	78
2110704	Marras	speedymax	21107	No	121
2110705	Marras	Barboryx	21107	No	171
2110706	Marras	SaiyanbornQueen	21107	Yes	178
2110801	Barboryx	Nex_Ingeniarius	21108	No	106
2110802	Stan	Mastermagpie	21108	Yes	114
2110803	Stan	Barboryx	21108	Yes	131
2110805	CalLycus	SaiyanbornQueen	21108	Yes	150
2110807	speedymax	RooClarke	21108	Yes	160
2110808	CalLycus	speedymax	21108	No	176
2110902	Nex_Ingeniarius	Mastermagpie	21109	Yes	111
2110903	Nex_Ingeniarius	SaiyanbornQueen	21109	Yes	115
2110906	Marras	speedymax	21109	Yes	166
2110907	Marras	Barboryx	21109	No	168
2110402	Tommy	Marras	21104	No	99
2110403	Tommy	Nex_Ingeniarius	21104	Yes	117
2110503	Tommy	Marras	21105	Yes	133
2110804	Tommy	Stan	21108	No	134
2110901	Tommy	Stan	21109	Yes	103
2110904	Tommy	Nex_Ingeniarius	21109	No	119
2110905	Tommy	CalLycus	21109	No	158
2110302	Nex_Ingeniarius	Tommy	21103	Yes	113
2110601	Stan	Tommy	21106	Yes	109
2110806	Marras	Tommy	21108	No	159
2110908	Marras	Tommy	21109	No	175
2110707	Marras	Tommy	21107	Yes	180
3010106	FrenchFrie	DiddlyLauren	30101	No	173
3010107	ameenHere	Cowboy	30101	No	173
3010108	FrenchFrie	ameenHere	30101	No	179
3010201	Stan	DiddlyLauren	30102	No	82
3010202	ameenHere	FrenchFrie	30102	Yes	87
3010203	Stan	ameenHere	30102	No	95
3010204	Stan	Anszi	30102	No	139
3010205	Stan	Balf	30102	Yes	151
3010206	Wish	Stan	30102	No	160
3010207	Scarecrow	Wish	30102	No	193
3010301	Stan	DiddlyLauren	30103	No	53
3010302	ameenHere	Stan	30103	Yes	59
3010303	ameenHere	Pac	30103	Yes	59
3010304	ameenHere	Cowboy	30103	Yes	59
3010305	ameenHere	FrenchFrie	30103	No	60
3010306	ameenHere	Scarecrow	30103	Yes	135
3010401	Stan	ameenHere	30104	No	121
3010402	Stan	Balf	30104	No	125
3010403	Anszi	Stan	30104	Yes	130
3010404	FrenchFrie	Wish	30104	No	155
3010405	Anszi	Cowboy	30104	Yes	172
3010406	Pac	DiddlyLauren	30104	No	196
3010407	Scarecrow	Anszi	30104	No	207
3010501	ameenHere	FrenchFrie	30105	No	40
3010502	Anszi	Pac	30105	No	60
3010503	Stan	Balf	30105	Yes	89
3010504	Stan	Anszi	30105	No	99
3010505	DiddlyLauren	Cowboy	30105	No	126
3010506	DiddlyLauren	Stan	30105	Yes	127
2100404	Stan	Nathan492	21004	Yes	73
2100405	Balf	Marras	21004	No	89
2100406	Nex_Ingeniarius	Balf	21004	Yes	90
2100501	Balf	Marras	21005	Yes	43
2100502	Stan	Balf	21005	Yes	44
2100504	RooClarke	Nathan492	21005	Yes	90
2100506	Stan	TwinkPeach	21005	Yes	125
2100604	Nex_Ingeniarius	Balf	21006	Yes	69
2100606	Nathan492	Nex_Ingeniarius	21006	No	82
2100607	Marras	Nathan492	21006	Yes	89
2100608	TwinkPeach	Marras	21006	Yes	92
2100609	RooClarke	TwinkPeach	21006	No	95
2100702	Marras	Nathan492	21007	No	61
2100703	TwinkPeach	Stan	21007	No	88
2100704	Balf	RooClarke	21007	Yes	115
2100705	TwinkPeach	Marras	21007	No	157
2100706	Balf	CalLycus	21007	Yes	169
2100707	Balf	Nex_Ingeniarius	21007	No	177
2100801	Stan	Nathan492	21008	No	103
2100803	Marras	TwinkPeach	21008	No	124
2100805	Stan	Balf	21008	No	150
2010101	Spade	Stan	20101	Yes	88
2010102	Spade	CalLycus	20101	No	145
2010103	senhasen	speedymax	20101	Yes	146
2010104	Omega	MoodyCereal	20101	Yes	154
2010105	senhasen	Tommy	20101	Yes	160
2010106	Spade	Marras	20101	Yes	169
2010107	Omega	Mastermagpie	20101	Yes	171
2010108	senhasen	Spade	20101	No	171
2010201	Spade	Stan	20102	Yes	88
2010202	Mastermagpie	Marras	20102	No	94
2010203	CalLycus	Spade	20102	Yes	149
2010204	senhasen	Tommy	20102	No	150
2010205	MoodyCereal	Omega	20102	Yes	154
2010206	MoodyCereal	senhasen	20102	Yes	180
2010207	speedymax	CalLycus	20102	No	180
2010301	Tommy	Marras	20103	No	78
2010302	Stan	MoodyCereal	20103	Yes	80
2010303	Spade	Stan	20103	Yes	81
2010304	Spade	Omega	20103	Yes	100
2010305	CalLycus	speedymax	20103	No	150
2010306	CalLycus	Spade	20103	Yes	154
2010307	senhasen	Mastermagpie	20103	No	159
2010308	Tommy	CalLycus	20103	No	164
2010309	Tommy	senhasen	20103	Yes	175
2010401	Stan	Spade	20104	No	56
2010402	MoodyCereal	Stan	20104	No	132
2010403	Marras	MoodyCereal	20104	Yes	140
2010404	Omega	speedymax	20104	Yes	156
2010405	Omega	Tommy	20104	Yes	165
2010406	Mastermagpie	Omega	20104	No	176
2010501	Stan	Mastermagpie	20105	Yes	89
2010502	Stan	Tommy	20105	No	95
2010503	Spade	Stan	20105	No	102
2010504	Omega	speedymax	20105	Yes	116
2010505	Marras	Spade	20105	No	126
2010506	Omega	MoodyCereal	20105	No	137
2010601	Spade	Stan	20106	No	83
2010602	Marras	Spade	20106	Yes	86
2010603	Marras	Mastermagpie	20106	No	111
2010604	Marras	MoodyCereal	20106	No	146
2010605	Tommy	Marras	20106	Yes	155
2010606	senhasen	speedymax	20106	No	176
2010701	Stan	speedymax	20107	Yes	80
2010702	Marras	Spade	20107	Yes	87
2010703	Omega	Mastermagpie	20107	No	107
2010704	Stan	Tommy	20107	Yes	127
2010705	MoodyCereal	Stan	20107	Yes	130
2010706	MoodyCereal	Omega	20107	Yes	132
2010707	senhasen	MoodyCereal	20107	No	180
2010801	Stan	Mastermagpie	20108	Yes	56
2010802	CalLycus	Tommy	20108	No	170
2010803	Marras	Spade	20108	No	173
2010804	MoodyCereal	Marras	20108	No	175
2010901	Marras	Spade	20109	Yes	69
2010902	speedymax	Omega	20109	No	73
2010903	Marras	MoodyCereal	20109	No	101
2010904	Mastermagpie	Stan	20109	No	107
2010905	speedymax	Marras	20109	No	118
2010906	CalLycus	Mastermagpie	20109	No	121
2010907	speedymax	CalLycus	20109	No	123
2010908	speedymax	senhasen	20109	No	139
2011001	Marras	Tommy	20110	Yes	61
2011002	Spade	Stan	20110	No	130
2011003	CalLycus	Spade	20110	No	136
2011004	MoodyCereal	CalLycus	20110	Yes	138
2011005	senhasen	speedymax	20110	Yes	154
2011006	Omega	MoodyCereal	20110	Yes	156
2011007	Mastermagpie	Marras	20110	No	170
2011008	senhasen	Mastermagpie	20110	Yes	175
2011101	Stan	MoodyCereal	20111	Yes	80
2011102	CalLycus	Tommy	20111	Yes	98
2011103	Stan	Spade	20111	Yes	116
2011104	Omega	Mastermagpie	20111	Yes	180
2011105	Stan	speedymax	20111	No	180
2100207	egons.on	Nex_Ingeniarius	21002	No	149
2100505	egons.on	RooClarke	21005	Yes	102
2100507	Nex_Ingeniarius	egons.on	21005	Yes	132
2100605	Nex_Ingeniarius	egons.on	21006	Yes	71
2100701	Stan	egons.on	21007	No	59
2100802	Marras	egons.on	21008	No	123
2100601	HotKebab	CalLycus	21006	No	61
2100602	HotKebab	Stan	21006	Yes	64
2100403	Nex_Ingeniarius	HotKebab	21004	No	69
2100503	Stan	HotKebab	21005	No	46
2100603	RooClarke	HotKebab	21006	Yes	66
2100804	Nex_Ingeniarius	HotKebab	21008	No	127
2110101	Mastermagpie	Marras	21101	Yes	50
2110102	Stan	Mastermagpie	21101	Yes	54
2110103	Stan	Barboryx	21101	No	81
2110105	Stan	SaiyanbornQueen	21101	Yes	120
2110106	speedymax	Stan	21101	No	136
2110107	RooClarke	speedymax	21101	No	147
2110202	Mastermagpie	Nex_Ingeniarius	21102	Yes	107
2110203	Stan	Barboryx	21102	No	136
2110204	CalLycus	Mastermagpie	21102	Yes	142
2110205	speedymax	speedymax	21102	No	157
2110206	Stan	SaiyanbornQueen	21102	No	158
3010101	\N	Scarecrow	30101	No	114
2110201	Stan	Tommy	21102	No	93
2110104	CalLycus	Tommy	21101	Yes	87
3010102	Pac	Balf	30101	No	154
3010103	DiddlyLauren	Stan	30101	No	163
3010104	ameenHere	Pac	30101	Yes	166
3010105	FrenchFrie	Anszi	30101	No	166
3010507	Scarecrow	DiddlyLauren	30105	Yes	149
3010508	ameenHere	Scarecrow	30105	No	153
3010601	Stan	Wish	30106	Yes	47
3010602	Balf	FrenchFrie	30106	Yes	47
3010603	Stan	Balf	30106	No	71
3010604	ameenHere	Stan	30106	Yes	128
3010605	Cowboy	ameenHere	30106	No	133
3010606	Scarecrow	DiddlyLauren	30106	Yes	168
3010607	Anszi	Cowboy	30106	No	185
3010608	Scarecrow	Anszi	30106	No	186
3010701	Stan	Balf	30107	Yes	73
3010702	ameenHere	Scarecrow	30107	No	81
3010703	Stan	Wish	30107	Yes	90
3010704	Stan	DiddlyLauren	30107	Yes	157
3010705	Anszi	Stan	30107	No	163
3010706	Anszi	Pac	30107	Yes	172
3010707	FrenchFrie	ameenHere	30107	Yes	180
3010708	FrenchFrie	Anszi	30107	Yes	182
3010801	Stan	ameenHere	30108	Yes	57
3010802	Anszi	Scarecrow	30108	No	104
3010803	Balf	Cowboy	30108	No	141
3010804	Stan	Balf	30108	Yes	142
3010805	Pac	Wish	30108	Yes	150
3010806	Anszi	Stan	30108	No	154
3010807	Pac	Anszi	30108	No	157
3010808	DiddlyLauren	Pac	30108	No	158
3010809	FrenchFrie	DiddlyLauren	30108	Yes	169
3010901	Scarecrow	Balf	30109	No	92
3010902	FrenchFrie	DiddlyLauren	30109	Yes	105
3010903	Scarecrow	ameenHere	30109	Yes	116
3010904	Scarecrow	Anszi	30109	No	117
3010905	Wish	Scarecrow	30109	No	125
3010906	Wish	FrenchFrie	30109	No	126
3010907	Stan	Wish	30109	No	148
3011001	Stan	DiddlyLauren	30110	Yes	94
3011002	Scarecrow	ameenHere	30110	No	127
3011003	Cowboy	Balf	30110	Yes	157
3011004	Cowboy	Wish	30110	No	157
3011005	Scarecrow	Anszi	30110	No	160
3090101	Wes	Anszi	30901	Yes	130
3090102	Wes	DiddlyLauren	30901	Yes	132
3090103	Wes	SaltiAlpaca	30901	Yes	133
3090104	Justice	Josh	30901	Yes	140
3090105	Wes	Wish	30901	Yes	140
3090106	Wes	Justice	30901	No	167
3090201	DiddlyLauren	Aehab	30902	Yes	66
3090202	Wes	Anszi	30902	Yes	66
3090203	SaltiAlpaca	Wes	30902	No	78
3090204	Wish	Corpse	30902	No	100
3090205	Josh	Wish	30902	Yes	150
3090206	Josh	SaltiAlpaca	30902	No	160
3090207	Josh	DiddlyLauren	30902	Yes	165
3090208	Justice	Josh	30902	Yes	175
3090309	DiddlyLauren	Magpie	30902	No	175
3090301	Wes	SaltiAlpaca	30903	Yes	62
3090302	Justice	Wes	30903	No	63
3090303	Corpse	Justice	30903	Yes	64
3090304	Corpse	Anszi	30903	Yes	71
3090305	Wish	Aehab	30903	No	86
3090306	Corpse	Wish	30903	Yes	170
3090307	Josh	DiddlyLauren	30903	No	176
3090401	Wish	Wes	30904	No	78
3090402	Anszi	Aehab	30904	No	102
3090403	Corpse	Wish	30904	Yes	117
3090404	Anszi	Magpie	30904	Yes	122
3090405	Corpse	DiddlyLauren	30904	Yes	125
3090406	Josh	SaltiAlpaca	30904	No	127
3090407	Anszi	Josh	30904	Yes	140
3090408	Anszi	Corpse	30904	Yes	152
3090501	Anszi	Aehab	30905	Yes	49
3090502	Anszi	Wes	30905	No	72
3090503	Anszi	Magpie	30905	Yes	83
3090504	Josh	Anszi	30905	No	91
3090505	Josh	DiddlyLauren	30905	No	174
3090506	Wish	Josh	30905	Yes	175
3090507	DiddlyLauren	Corpse	30905	Yes	175
3090601	Wish	Corpse	30906	No	51
3090602	DiddlyLauren	Magpie	30906	No	71
3090603	Wes	SaltiAlpaca	30906	No	72
3090604	Wes	Anszi	30906	Yes	101
3090605	DiddlyLauren	Aehab	30906	No	116
3090606	Wes	Wish	30906	Yes	121
3090607	DiddlyLauren	Wes	30906	Yes	130
3090608	Josh	DiddlyLauren	30906	Yes	134
3090609	Josh	Justice	30906	No	151
3090701	Wes	DiddlyLauren	30907	No	146
3090702	Anszi	Magpie	30907	Yes	162
3090703	Anszi	Josh	30907	Yes	168
3090704	Wish	Wes	30907	Yes	171
3090705	Corpse	Wish	30907	No	180
3090706	Aehab	Anszi	30907	Yes	188
3090801	Justice	Wes	30908	Yes	30
3090802	Magpie	DiddlyLauren	30908	Yes	116
3090803	Wish	Magpie	30908	Yes	127
3090804	Justice	Josh	30908	No	163
3090805	SaltiAlpaca	Corpse	30908	Yes	168
3090806	Wish	Aehab	30908	Yes	168
3090901	Justice	Corpse	30909	No	54
3090902	Anszi	Wes	30909	No	155
3090903	Magpie	Anszi	30909	Yes	158
3090904	DiddlyLauren	Magpie	30909	Yes	161
3090905	Justice	Aehab	30909	No	171
3090906	DiddlyLauren	Josh	30909	No	174
3091001	Justice	Corpse	30910	Yes	92
3091002	Anszi	Magpie	30910	Yes	124
3091003	Wish	Wes	30910	Yes	126
3091004	Anszi	Aehab	30910	No	128
3091005	SaltiAlpaca	Josh	30910	Yes	138
3091101	Justice	Corpse	30911	Yes	51
3091102	Wish	Wes	30911	Yes	163
3091103	Wish	Aehab	30911	Yes	165
3091104	Josh	Wish	30911	No	168
3091105	Justice	Magpie	30911	Yes	169
3091106	DiddlyLauren	Josh	30911	No	170
3070101	Stan	Anszi	30701	Yes	62
3070102	Stan	Wish	30701	Yes	75
3070103	Stan	ameenHere	30701	No	108
3070104	DiddlyLauren	Nex	30701	Yes	116
3070105	Stan	DiddlyLauren	30701	Yes	145
3070106	FrenchFrie	Balf	30701	Yes	153
3070201	Balf	Cowboy	30702	Yes	79
3070202	FrenchFrie	ameenHere	30702	Yes	81
3070203	Wish	FrenchFrie	30702	No	81
3070204	Stan	DiddlyLauren	30702	Yes	93
3070205	Stan	Anszi	30702	No	96
3070206	Wish	Stan	30702	Yes	100
3070207	Wish	Scarecrow	30702	No	105
3070208	Wish	Nex	30702	No	113
3070301	DiddlyLauren	Stan	30703	Yes	94
3070302	Wish	Cowboy	30703	No	118
3070303	Balf	Nex	30703	Yes	130
3070304	Scarecrow	ameenHere	30703	Yes	139
3070305	Wish	Scarecrow	30703	Yes	140
3070306	DiddlyLauren	FrenchFrie	30703	No	155
3070401	Stan	Wish	30704	Yes	41
3070402	Nex	Anszi	30704	Yes	146
3070403	Balf	Scarecrow	30704	Yes	155
3070404	ameenHere	Nex	30704	Yes	164
3070405	Stan	DiddlyLauren	30704	Yes	170
3070406	Stan	Balf	30704	No	174
3070407	ameenHere	Stan	30704	No	177
3070408	Cowboy	ameenHere	30704	No	178
3070501	Stan	Balf	30705	Yes	55
3070502	Stan	Wish	30705	No	65
3070503	ameenHere	Nex	30705	Yes	108
3070504	ameenHere	FrenchFrie	30705	No	118
3070505	Cowboy	Anszi	30705	Yes	125
3070506	Scarecrow	ameenHere	30705	No	128
3070507	ameenHere	Scarecrow	30705	No	128
3070508	Stan	DiddlyLauren	30705	Yes	170
3070601	Scarecrow	Balf	30706	No	63
3070602	Anszi	Nex	30706	No	66
3070603	Wish	Stan	30706	Yes	79
3070604	Anszi	FrenchFrie	30706	Yes	83
3070605	Cowboy	DiddlyLauren	30706	No	111
3070606	Cowboy	Anszi	30706	No	111
3070607	Wish	Scarecrow	30706	No	145
3070608	Cowboy	Wish	30706	Yes	169
3070609	Scarecrow	ameenHere	30706	No	169
3070701	FrenchFrie	ameenHere	30707	No	101
3070702	Anszi	Stan	30707	Yes	123
3070703	Balf	Nex	30707	Yes	159
3070704	Cowboy	DiddlyLauren	30707	No	169
3070705	Wish	Cowboy	30707	No	169
3070706	Anszi	FrenchFrie	30707	Yes	175
3070707	Anszi	Scarecrow	30707	No	175
3070801	FrenchFrie	Anszi	30708	No	97
3070802	Balf	Stan	30708	Yes	115
3070803	ameenHere	Scarecrow	30708	No	157
3070804	Cowboy	ameenHere	30708	No	159
3070805	Wish	Cowboy	30708	No	170
3070806	Nex	Wish	30708	Yes	175
3070807	Nex	DiddlyLauren	30708	Yes	178
3070901	Nex	Anszi	30709	Yes	56
3070902	Wish	Stan	30709	No	100
3070903	Nex	Balf	30709	Yes	124
3070904	Nex	DiddlyLauren	30709	No	131
3070905	Wish	FrenchFrie	30709	Yes	131
3070906	Scarecrow	Wish	30709	Yes	131
3070907	ameenHere	Nex	30709	No	147
3070908	ameenHere	Cowboy	30709	No	149
3070909	ameenHere	Scarecrow	30709	Yes	210
3071001	ameenHere	FrenchFrie	30710	No	26
3071002	Wish	Scarecrow	30710	No	141
3071003	Balf	Stan	30710	Yes	168
3071004	Balf	Nex	30710	No	172
3071005	DiddlyLauren	Cowboy	30710	No	179
3071101	Stan	Balf	30711	Yes	96
3071102	DiddlyLauren	Stan	30711	Yes	133
3071103	FrenchFrie	Anszi	30711	No	134
3071104	FrenchFrie	DiddlyLauren	30711	Yes	136
3071105	\N	ameenHere	30711	No	141
3071106	Wish	Nex	30711	Yes	147
3071107	FrenchFrie	Wish	30711	No	149
3071201	Nex	Anszi	30712	No	139
3071202	Balf	Nex	30712	No	140
4071203	Scarecrow	ameenHere	40712	No	142
3071204	DiddlyLauren	Stan	30712	No	144
3071205	FrenchFrie	DiddlyLauren	30712	Yes	144
3071206	Scarecrow	Balf	30712	Yes	147
3071207	Stan	Wes	30712	No	147
3071301	ameenHere	Stan	30713	Yes	146
3071302	ameenHere	Cowboy	30713	No	148
3071303	Nex	ameenHere	30713	No	149
3071304	Wish	FrenchFrie	30713	No	153
3071305	Anszi	Nex	30713	Yes	168
3071306	Scarecrow	DiddlyLauren	30713	Yes	170
3071307	Balf	Scarecrow	30713	Yes	173
3071401	Stan	DiddlyLauren	30714	Yes	147
3071402	Stan	ameenHere	30714	Yes	150
3071403	Nex	Balf	30714	Yes	159
3071404	Anszi	Nex	30714	No	166
3071405	Wish	Scarecrow	30714	Yes	166
3071406	Wish	Stan	30714	No	170
3071407	FrenchFrie	Anszi	30714	No	171
3071408	FrenchFrie	Wish	30714	No	171
3071501	Stan	DiddlyLauren	30715	Yes	91
3071502	Balf	FrenchFrie	30715	Yes	117
3071503	Nex	ameenHere	30715	Yes	120
3071504	Wish	Scarecrow	30715	Yes	122
3071505	Stan	Balf	30715	No	141
3071506	Nex	Wish	30715	Yes	143
3071507	Stan	Anszi	30715	No	153
3050101	Fin	Wish	30501	No	110
3050102	Panick	NastyHobbit	30501	No	126
3050103	Weseley	DiddlyLauren	30501	No	127
3050104	Anszi	Panick	30501	No	135
3050105	Weseley	Rain	30501	Yes	145
3050106	Anszi	Weseley	30501	Yes	154
3050107	Fin	Anszi	30501	No	172
3050201	Weseley	Wish	30502	No	80
3050202	Anszi	Fin	30502	No	84
3050203	Anszi	Panick	30502	Yes	97
3050204	Omega	Anszi	30502	Yes	106
3050205	Weseley	Rain	30502	No	107
3050206	Street	NastyHobbit	30502	Yes	111
3050207	Omega	DiddlyLauren	30502	No	114
3050301	Anszi	Fin	30503	No	55
3050302	Wish	Panick	30503	Yes	137
3050303	Wish	Omega	30503	No	146
3050304	Wish	Street	30503	Yes	155
3050305	Weseley	Wish	30503	No	162
3050401	Fin	Wish	30504	No	27
3050402	Fin	DiddlyLauren	30504	Yes	32
3050403	Anszi	Fin	30504	No	32
3050404	Weseley	Rain	30504	Yes	35
3050405	Weseley	Anszi	30504	Yes	49
3050406	Weseley	NastyHobbit	30504	No	74
3050501	Weseley	Anszi	30505	Yes	76
3050502	Weseley	Rain	30505	No	104
3050503	Panick	Wish	30505	No	108
3050504	Fin	DiddlyLauren	30505	No	118
3050505	NastyHobbit	Street	30505	Yes	129
3050506	Weseley	NastyHobbit	30505	No	138
3050601	Wish	Fin	30506	Yes	30
3050602	Weseley	Wish	30506	No	67
3050603	Panick	Anszi	30506	Yes	83
3050604	Street	NastyHobbit	30506	No	97
3050605	Weseley	DiddlyLauren	30506	No	110
3050606	Omega	Rain	30506	No	112
3050701	Rain	Fin	30507	Yes	59
3050702	Street	NastyHobbit	30507	No	136
3050703	Street	DiddlyLauren	30507	Yes	136
3050704	Street	Wish	30507	No	136
3050705	Rain	Street	30507	No	138
3050706	Weseley	Rain	30507	No	144
3050707	Weseley	Anszi	30507	No	148
3050801	Fin	Rain	30508	Yes	79
3050802	Street	Anszi	30508	Yes	84
3050803	\N	Wish	30508	No	93
3050804	DiddlyLauren	Panick	30508	No	115
3050805	Omega	NastyHobbit	30508	Yes	134
3050806	DiddlyLauren	Omega	30508	Yes	138
3020101	Panick	Corpse	30201	No	117
3020102	Magpie	Fin	30201	Yes	165
3020103	Omega	Josh	30201	Yes	173
3020104	Omega	Magpie	30201	No	174
3020105	Wes	Omega	30201	No	175
3020106	Panick	Wes	30201	Yes	179
3020107	Liam	Jackie	30201	No	207
3020201	Fin	Wes	30202	No	64
3020202	Jackie	Panick	30202	Yes	148
3020203	Josh	Liam	30202	No	173
3020204	Magpie	Cal	30202	No	178
3020205	Magpie	Fin	30202	No	178
3020301	Fin	Wes	30203	Yes	108
3020302	Fin	Magpie	30203	Yes	112
3020303	Fin	Jackie	30203	No	115
3020304	Josh	Fin	30203	No	116
3020305	Corpse	Liam	30203	Yes	135
3020306	Corpse	Panick	30203	Yes	142
3020307	Corpse	Cal	30203	Yes	147
3020308	Corpse	Omega	30203	No	160
3020401	\N	Liam	30204	Yes	108
3020402	Josh	Omega	30204	Yes	116
3020403	Fin	Jackie	30204	No	117
3020404	Magpie	Fin	30204	Yes	126
3020405	Wes	Panick	30204	No	156
3020406	Wes	Cal	30204	No	158
3020501	Panick	Wes	30205	No	118
3020502	Magpie	Cal	30205	No	140
3020503	Liam	Magpie	30205	Yes	148
3020504	Omega	Corpse	30205	No	153
3020505	Josh	Omega	30205	Yes	154
3020506	Josh	Fin	30205	Yes	167
3020507	Liam	Josh	30205	No	172
3020508	Panick	Jackie	30205	Yes	188
3020601	Corpse	Panick	30206	No	90
3020602	Fin	Wes	30206	No	115
3020603	Omega	Josh	30206	Yes	142
3020604	Fin	Jackie	30206	No	160
3020605	Fin	Corpse	30206	No	163
3020606	Fin	Magpie	30206	No	166
3020701	Wes	Fin	30207	Yes	125
3020702	Wes	Liam	30207	No	127
3020703	Wes	Cal	30207	No	133
3020704	Omega	Josh	30207	No	149
3020705	Panick	Wes	30207	Yes	154
3020706	Panick	Magpie	30207	No	161
3020801	Wes	Fin	30208	Yes	56
3020802	Panick	Jackie	30208	No	153
3020803	Corpse	Liam	30208	No	189
3020804	Wes	Cal	30208	No	203
3020805	Josh	Panick	30208	No	205
3020806	Omega	Josh	30208	Yes	207
3020807	Wes	Omega	30208	Yes	214
3020901	Corpse	Omega	30209	Yes	105
3020902	Wes	Panick	30209	No	122
3020903	Fin	Corpse	30209	Yes	127
3020904	Fin	Magpie	30209	No	132
3020905	Jackie	Liam	30209	Yes	132
3020906	Cal	Wes	30209	Yes	138
3020907	Jackie	Fin	30209	No	144
3020908	Josh	Cal	30209	No	144
3021001	Cal	Magpie	30210	No	54
3021002	Cal	Corpse	30210	Yes	112
3021003	Wes	Cal	30210	Yes	116
3021004	Josh	Fin	30210	No	122
3021005	Omega	Wes	30210	No	144
3021006	Liam	Josh	30210	Yes	153
3021007	Omega	Jackie	30210	Yes	164
3021101	Magpie	Fin	30211	Yes	95
3021102	Corpse	Panick	30211	Yes	101
3021103	Wes	Omega	30211	Yes	146
3021104	Liam	Wes	30211	Yes	167
3021105	Jackie	Cal	30211	No	174
3021106	Magpie	Liam	30211	No	174
3021201	Wes	Fin	30212	Yes	160
3021202	Omega	Corpse	30212	Yes	165
3021203	Josh	Panick	30212	Yes	165
3021204	Wes	Cal	30212	Yes	183
3021205	Josh	Omega	30212	No	186
3021206	Liam	Josh	30212	Yes	187
3021207	Wes	Liam	30212	No	198
3030101	Scarecrow	Speedy	30301	No	105
3030102	Aehab	Scarecrow	30301	Yes	113
3030103	Aehab	Nex	30301	No	132
3030104	Stan	Aehab	30301	Yes	135
3030105	Wes	FrenchFrie	30301	Yes	139
3030106	Stan	Corpse	30301	No	140
3030107	Cowboy	Wes	30301	No	146
3030108	Magpie	Cowboy	30301	Yes	152
3030109	Wes	Stan	30301	No	152
3030201	Corpse	Stan	30302	No	110
3030202	FrenchFrie	Corpse	30302	No	111
3030203	Aehab	FrenchFrie	30302	No	123
3030204	Scarecrow	Magpie	30302	Yes	130
3030205	Cowboy	Wes	30302	Yes	151
3030206	\N	Cowboy	30302	No	152
3030207	Scarecrow	Aehab	30302	Yes	166
3030208	Nex	Speedy	30302	No	170
3030301	Stan	Magpie	30303	No	105
3030302	Cowboy	Corpse	30303	No	143
3030303	Stan	Aehab	30303	No	162
3030304	Speedy	Cowboy	30303	No	162
3030305	Nex	Speedy	30303	Yes	166
3030306	Wes	Nex	30303	Yes	169
3030307	Stan	Wes	30303	No	183
3030401	Stan	Wes	30304	Yes	116
3030402	FrenchFrie	Magpie	30304	Yes	130
3030403	Corpse	FrenchFrie	30304	Yes	132
3030404	Stan	Speedy	30304	No	150
3030405	Scarecrow	Aehab	30304	No	158
3030406	Corpse	Stan	30304	Yes	161
3030407	Corpse	Scarecrow	30304	No	166
3030408	Nex	Corpse	30304	Yes	171
3030409	Corpse	Nex	30304	Yes	171
3030501	Speedy	Stan	30305	No	43
3030502	Nex	Speedy	30305	No	46
3030503	Scarecrow	Aehab	30305	Yes	117
3030504	Corpse	Scarecrow	30305	Yes	119
3030505	FrenchFrie	Wes	30305	No	125
3030506	Cowboy	Corpse	30305	Yes	143
3030507	FrenchFrie	Magpie	30305	No	179
3030601	Nex	Magpie	30306	Yes	60
3030602	Corpse	Stan	30306	Yes	81
3030603	Scarecrow	Speedy	30306	Yes	107
3030604	Corpse	Nex	30306	Yes	147
3030605	Corpse	Scarecrow	30306	No	148
3030606	Corpse	FrenchFrie	30306	Yes	150
3030607	Corpse	Cowboy	30306	Yes	156
3030701	Corpse	FrenchFrie	30307	Yes	63
3030702	Wes	Stan	30307	No	102
3030703	Corpse	Cowboy	30307	Yes	125
3030704	Wes	Nex	30307	Yes	136
3030705	Scarecrow	Wes	30307	No	140
3030706	Speedy	Scarecrow	30307	Yes	141
3030801	Aehab	Nex	30308	Yes	67
3030802	Stan	Wes	30308	No	74
3030803	Stan	Magpie	30308	No	142
3030804	Speedy	Stan	30308	Yes	149
3030805	Corpse	Scarecrow	30308	Yes	163
3030806	FrenchFrie	Speedy	30308	No	169
3030807	Corpse	FrenchFrie	30308	Yes	191
3030808	Corpse	Cowboy	30308	Yes	192
3030901	Wes	Stan	30309	No	156
3030902	Speedy	Scarecrow	30309	Yes	161
3030903	Nex	Magpie	30309	Yes	163
3030904	Speedy	Nex	30309	No	166
3030905	FrenchFrie	Wes	30309	Yes	167
3030906	Cowboy	Corpse	30309	No	174
3030907	Cowboy	Speedy	30309	No	187
3030908	FrenchFrie	Aehab	30309	No	193
3031001	Stan	Speedy	30310	No	27
3031002	Stan	Corpse	30310	Yes	90
3031003	Stan	Magpie	30310	Yes	93
3031004	FrenchFrie	Wes	30310	Yes	117
3031005	Aehab	Stan	30310	Yes	117
3031006	Aehab	FrenchFrie	30310	Yes	145
3031007	Cowboy	Aehab	30310	No	167
3031101	Wes	Stan	30311	Yes	62
3031102	Corpse	Scarecrow	30311	No	69
3031103	Nex	Aehab	30311	No	138
3031104	Corpse	FrenchFrie	30311	No	164
3031105	Nex	Speedy	30311	Yes	165
3031106	Corpse	Nex	30311	No	171
3031201	Nex	Corpse	30312	Yes	44
3031202	Scarecrow	Magpie	30312	Yes	95
3031203	Nex	Wes	30312	Yes	111
3031204	Stan	Aehab	30312	No	133
3031205	Scarecrow	Speedy	30312	Yes	136
3040101	DiddlyLauren	Josh	30401	No	47
3040102	Corpse	Balf	30401	Yes	83
3040103	Jackie	ameenHere	30401	No	87
3040104	Corpse	Rain	30401	Yes	114
3040105	Anszi	Jackie	30401	No	124
3040106	Anszi	Corpse	30401	Yes	125
3040107	Magpie	DiddlyLauren	30401	No	139
3040108	Anszi	Magpie	30401	No	139
3040109	Aehab	Anszi	30401	Yes	176
3040201	Anszi	Magpie	30402	No	89
3040202	Josh	ameenHere	30402	Yes	121
3040203	Anszi	Corpse	30402	Yes	150
3040204	Balf	Josh	30402	No	164
3040205	Rain	Jackie	30402	No	165
3040206	Aehab	Anszi	30402	No	168
3040207	Aehab	Rain	30402	No	170
3040208	Balf	Aehab	30402	No	170
3040301	Corpse	Anszi	30403	Yes	33
3040302	Corpse	Rain	30403	Yes	75
3040303	Corpse	DiddlyLauren	30403	Yes	87
3040304	Corpse	ameenHere	30403	Yes	99
3040305	Corpse	Balf	30403	Yes	100
3040401	Josh	Rain	30404	Yes	73
3040402	Magpie	ameenHere	30404	Yes	73
3040403	DiddlyLauren	Magpie	30404	Yes	92
3040404	Balf	Aehab	30404	No	158
3040405	Josh	Anszi	30404	No	161
3040406	Corpse	DiddlyLauren	30404	Yes	171
3040407	Corpse	Balf	30404	No	172
3040501	Corpse	Anszi	30405	No	108
3040502	Corpse	Balf	30405	Yes	121
3040503	DiddlyLauren	Jackie	30405	No	124
3040504	DiddlyLauren	Corpse	30405	No	125
3040505	Magpie	DiddlyLauren	30405	No	129
3040506	Josh	Rain	30405	Yes	141
3040507	Josh	ameenHere	30405	No	173
3040601	Anszi	Corpse	30406	No	70
3040602	Magpie	Rain	30406	Yes	160
3040603	Balf	Josh	30406	Yes	165
3040604	ameenHere	Magpie	30406	No	170
3040605	DiddlyLauren	Jackie	30406	Yes	171
3040606	Aehab	Anszi	30406	No	174
3040607	Aehab	DiddlyLauren	30406	Yes	179
3040608	Aehab	ameenHere	30406	No	208
3040609	Balf	Aehab	30406	Yes	208
3040701	Corpse	Rain	30407	Yes	74
3040702	ameenHere	Magpie	30407	No	133
3040703	Corpse	DiddlyLauren	30407	Yes	155
3040704	Corpse	Anszi	30407	Yes	157
3040705	Josh	ameenHere	30407	No	161
3040706	\N	Aehab	30407	No	164
3040707	Balf	Jackie	30407	No	164
3040708	Corpse	Balf	30407	No	178
3040801	Rain	Aehab	30408	Yes	125
3040802	Josh	Rain	30408	Yes	138
3040803	DiddlyLauren	Corpse	30408	Yes	152
3040804	Magpie	DiddlyLauren	30408	No	159
3040805	ameenHere	Josh	30408	Yes	163
3040806	ameenHere	Jackie	30408	No	164
3040807	Jackie	ameenHere	30408	No	164
3040808	Anszi	Magpie	30408	Yes	177
3040901	Josh	Rain	30409	No	66
3040902	ameenHere	Jackie	30409	No	90
3040903	Josh	ameenHere	30409	No	92
3040904	Aehab	Anszi	30409	No	106
3040905	Corpse	Balf	30409	No	138
3040906	DiddlyLauren	Aehab	30409	No	149
3040907	Josh	DiddlyLauren	30409	Yes	153
3041001	Josh	Anszi	30410	Yes	107
3041002	Corpse	DiddlyLauren	30410	Yes	108
3041003	Corpse	Balf	30410	Yes	111
3041004	ameenHere	Aehab	30410	No	116
3041005	ameenHere	Josh	30410	No	144
3041006	Rain	Magpie	30410	Yes	158
3041007	Jackie	Rain	30410	Yes	160
3041008	Rain	Corpse	30410	No	162
3041009	ameenHere	Jackie	30410	Yes	182
3041101	Balf	Josh	30411	No	121
3041102	Magpie	DiddlyLauren	30411	Yes	133
3041103	Rain	Jackie	30411	No	137
3041104	Aehab	Rain	30411	No	142
3041105	Anszi	Aehab	30411	No	144
3041106	Corpse	ameenHere	30411	No	167
3041107	Anszi	Corpse	30411	Yes	180
3041201	Corpse	ameenHere	30412	No	35
3041202	Magpie	DiddlyLauren	30412	Yes	48
3041203	Josh	Rain	30412	No	59
3041204	Anszi	Jackie	30412	Yes	76
3041205	Anszi	Josh	30412	No	77
3041206	Balf	Corpse	30412	No	85
3041207	Balf	Magpie	30412	No	153
3041208	Aehab	Balf	30412	Yes	154
3041209	Anszi	Aehab	30412	Yes	154
3041301	ameenHere	Jackie	30413	No	48
3041302	Rain	Corpse	30413	Yes	126
3041303	Magpie	DiddlyLauren	30413	Yes	145
3041304	Josh	Rain	30413	No	160
3041305	ameenHere	Josh	30413	Yes	162
3041306	Anszi	Magpie	30413	No	170
3041307	ameenHere	Aehab	30413	Yes	170
3041401	Josh	Balf	30414	Yes	44
3041402	Josh	Anszi	30414	Yes	46
3041403	Rain	Josh	30414	Yes	47
3041404	Aehab	Rain	30414	No	51
3041405	Aehab	ameenHere	30414	No	57
3041406	Corpse	DiddlyLauren	30414	Yes	61
3041501	ameenHere	Magpie	30415	No	125
3041502	ameenHere	Jackie	30415	No	148
3041503	Balf	Corpse	30415	Yes	154
3041504	Anszi	Josh	30415	Yes	156
3041505	ameenHere	Aehab	30415	No	173
3060101	Jimmy	Panick	30601	Yes	99
3060102	Pac	Weseley	30601	Yes	102
3060103	Stan	Roo	30601	No	106
3060104	Stan	Cal	30601	No	137
3060105	Pac	Fin	30601	Yes	168
3060201	Fin	Stan	30602	Yes	56
3060202	Fin	Jimmy	30602	No	140
3060203	Scarecrow	Roo	30602	No	153
3060204	Pac	Fin	30602	Yes	157
3060205	Pac	Pac	30602	Yes	160
3060206	Pac	Cal	30602	No	171
3060207	Weseley	Pac	30602	No	183
3060208	Weseley	Weseley	30602	No	184
3060301	Roo	Jimmy	30603	No	45
3060302	Roo	Stan	30603	No	63
3060303	Panick	FrenchFrie	30603	Yes	116
3060304	Roo	Pac	30603	No	124
3060305	Scarecrow	Fin	30603	Yes	130
3060306	Weseley	Scarecrow	30603	Yes	179
3060401	Cal	Pac	30604	No	114
3060402	Stan	Fin	30604	Yes	127
3060403	Panick	FrenchFrie	30604	Yes	167
3060404	Weseley	Stan	30604	No	174
3060405	Jimmy	Cal	30604	No	178
3060406	Weseley	Jimmy	30604	Yes	186
3060407	Panick	Scarecrow	30604	No	186
3060501	Stan	Fin	30605	Yes	70
3060502	Roo	Stan	30605	No	114
3060503	Panick	Pac	30605	Yes	130
3060504	FrenchFrie	Weseley	30605	No	150
3060505	Roo	Scarecrow	30605	No	167
3060506	FrenchFrie	Cal	30605	Yes	167
3060507	Roo	Jimmy	30605	No	184
3060508	FrenchFrie	Panick	30605	No	188
3060509	Roo	FrenchFrie	30605	Yes	195
3060601	Fin	Stan	30606	Yes	47
3060602	Fin	Pac	30606	Yes	75
3060603	Jimmy	Cal	30606	No	139
3060604	FrenchFrie	Fin	30606	Yes	144
3060605	Jimmy	Panick	30606	No	153
3060606	Weseley	FrenchFrie	30606	Yes	176
3060607	Jimmy	Roo	30606	No	179
3060701	Scarecrow	Roo	30607	Yes	90
3060702	Fin	Pac	30607	Yes	101
3060703	Jimmy	Weseley	30607	Yes	126
3060704	Scarecrow	Fin	30607	No	142
3060705	Stan	Panick	30607	Yes	147
3060706	Cal	FrenchFrie	30607	Yes	148
3060707	Stan	Cal	30607	No	148
3060801	Pac	Fin	30608	Yes	53
3060802	Stan	Weseley	30608	Yes	92
3060803	FrenchFrie	Panick	30608	Yes	135
3060804	Stan	Cal	30608	Yes	142
3060805	Pac	Roo	30608	No	178
3060901	Fin	Stan	30609	Yes	102
3060902	Fin	Scarecrow	30609	Yes	106
3060903	FrenchFrie	Fin	30609	No	112
3060904	Pac	Roo	30609	No	140
3060905	Panick	Jimmy	30609	No	171
3060906	Panick	FrenchFrie	30609	No	175
3061001	Stan	Roo	30610	No	73
3061002	Fin	FrenchFrie	30610	Yes	125
3061003	Stan	Panick	30610	Yes	141
3061004	Jimmy	Weseley	30610	Yes	145
3061005	Fin	Jimmy	30610	Yes	172
3061006	Fin	Stan	30610	No	176
3061007	Scarecrow	Cal	30610	Yes	179
3061008	Fin	Scarecrow	30610	No	190
3061009	Pac	Fin	30610	Yes	201
3061101	Pac	Fin	30611	No	121
3061102	Stan	Cal	30611	Yes	154
3061103	Weseley	Scarecrow	30611	No	169
3061104	Weseley	Jimmy	30611	No	169
3061105	Panick	Stan	30611	Yes	170
3061106	FrenchFrie	Panick	30611	No	173
3061107	Pac	Roo	30611	Yes	177
3061201	FrenchFrie	Roo	30612	Yes	61
3061202	Panick	Jimmy	30612	No	96
3061203	Panick	Stan	30612	No	106
3061204	Weseley	Scarecrow	30612	Yes	132
3061205	Pac	Fin	30612	Yes	158
3061206	Panick	FrenchFrie	30612	No	160
3061207	Weseley	Pac	30612	No	164
3080101	Fin	Corpse	30801	No	155
3080102	Panick	Wes	30801	No	171
3080103	Speedy	Moisty	30801	No	183
3080104	Speedy	Cal	30801	No	187
3080105	Fin	Jackie	30801	No	193
3080106	Josh	Fin	30801	No	200
3080107	Speedy	Omega	30801	No	205
3080108	Speedy	Panick	30801	No	211
3080201	Speedy	Fin	30802	No	150
3080202	Speedy	Cal	30802	No	156
3080203	Panick	Speedy	30802	Yes	158
3080204	Josh	Moisty	30802	Yes	161
3080205	Panick	Josh	30802	No	164
3080206	Corpse	Panick	30802	Yes	166
3080207	Omega	Corpse	30802	Yes	169
3080301	Fin	Jackie	30803	No	114
3080302	Moisty	Josh	30803	Yes	131
3080303	Wes	Fin	30803	Yes	136
3080304	Corpse	Moisty	30803	Yes	137
3080305	Omega	Speedy	30803	Yes	179
3080306	Cal	Wes	30803	No	159
3080307	Corpse	Cal	30803	No	168
3080308	Corpse	Panick	30803	No	181
3080309	Omega	Corpse	30803	No	188
3080401	Panick	Speedy	30804	Yes	88
3080402	Jackie	Moisty	30804	Yes	135
3080403	Fin	Jackie	30804	Yes	138
3080404	Corpse	Cal	30804	Yes	147
3080405	Omega	Wes	30804	No	168
3080406	Josh	Panick	30804	No	170
3080407	Josh	Fin	30804	No	171
3080408	Corpse	Omega	30804	No	171
3080501	Moisty	Wes	30805	Yes	151
3080502	Fin	Speedy	30805	No	156
3080503	Panick	Jackie	30805	No	165
3080504	Moisty	Corpse	30805	No	167
3080505	Panick	Josh	30805	No	182
3080601	Moisty	Wes	30806	Yes	129
3080602	Omega	Speedy	30806	No	166
3080603	Fin	Josh	30806	No	168
3080604	Omega	Jackie	30806	No	170
3080605	Corpse	Fin	30806	No	183
3080606	Panick	Corpse	30806	No	188
3080701	Corpse	Fin	30807	No	127
3080702	Panick	Josh	30807	No	169
3080703	Wes	Moisty	30807	No	170
3080704	Corpse	Cal	30807	Yes	176
3080705	Wes	Omega	30807	No	176
3080801	Josh	Moisty	30808	No	61
3080802	Corpse	Cal	30808	No	62
3080803	Fin	Corpse	30808	Yes	81
3080804	Josh	Fin	30808	No	96
3080805	Josh	Panick	30808	Yes	131
3080806	Omega	Josh	30808	No	134
3080807	Wes	Omega	30808	No	135
3080901	Fin	Speedy	30809	No	109
3080902	Panick	Corpse	30809	Yes	112
3080903	Fin	Josh	30809	No	114
3080904	Fin	Wes	30809	Yes	141
3080905	Fin	Jackie	30809	No	145
3081001	Wes	Omega	30810	No	80
3081002	Moisty	Wes	30810	Yes	85
3081003	Moisty	Corpse	30810	Yes	100
3081004	Josh	Moisty	30810	No	103
3081005	Josh	Cal	30810	No	106
3081006	Fin	Jackie	30810	No	116
3081007	Josh	Panick	30810	Yes	117
3081008	Josh	Fin	30810	No	122
3081101	Speedy	Moisty	30811	Yes	142
3081102	Wes	Fin	30811	No	149
3081103	Speedy	Panick	30811	No	150
3081104	Wes	Omega	30811	Yes	152
3081105	Speedy	Cal	30811	No	153
3081201	Speedy	Fin	30812	No	35
3081202	Cal	Speedy	30812	Yes	98
3081203	Jackie	Cal	30812	No	126
3081204	Omega	Wes	30812	Yes	143
3081205	Moisty	Corpse	30812	No	152
3081206	Josh	Moisty	30812	No	160
3081207	Panick	Josh	30812	No	165
3081208	Omega	Jackie	30812	No	169
3081301	Josh	Fin	30813	Yes	96
3081302	Panick	Corpse	30813	No	118
3081303	Jackie	Omega	30813	No	143
3081304	Cal	Wes	30813	No	143
3081305	Josh	Cal	30813	No	146
3081306	Josh	Moisty	30813	No	157
3081307	Josh	Panick	30813	No	167
3081401	Jackie	Cal	30814	Yes	93
3081402	Fin	Speedy	30814	No	106
3081403	Omega	Jackie	30814	No	121
3081404	Fin	Wes	30814	No	129
3081405	Fin	Josh	30814	No	143
3081406	Corpse	Fin	30814	Yes	153
3081407	Moisty	Moisty	30814	No	156
3081501	Fin	Speedy	30815	Yes	105
3081502	Corpse	Fin	30815	Yes	106
3081503	Corpse	Omega	30815	Yes	127
3081504	Wes	Cal	30815	No	137
3081505	Corpse	Panick	30815	Yes	148
3081506	Corpse	Moisty	30815	No	158
3100101	Weseley	ameenHere	31001	Yes	105
3100102	Weseley	Wish	31001	Yes	112
3100103	Moisty	SaltiAlpaca	31001	No	131
3100104	Omega	Dante	31001	No	147
3100105	DiddlyLauren	Omega	31001	Yes	150
3100106	Weseley	DiddlyLauren	31001	No	160
3100201	Weseley	Dante	31002	No	155
3100202	ameenHere	Weseley	31002	No	170
3100203	DiddlyLauren	Roo	31002	Yes	173
3100204	Omega	ameenHere	31002	No	174
3100205	Moisty	SaltiAlpaca	31002	No	177
3100206	DiddlyLauren	Moisty	31002	Yes	202
3100207	Omega	Wish	31002	No	205
3100208	DiddlyLauren	Omega	31002	Yes	212
3100301	Omega	SaltiAlpaca	31003	No	149
3100302	Omega	Dante	31003	No	171
3100303	Omega	Wish	31003	No	172
3100304	Moisty	DiddlyLauren	31003	No	178
3100305	ameenHere	Moisty	31003	Yes	189
3100306	ameenHere	Omega	31003	No	192
3100307	Panick	ameenHere	31003	No	220
3100401	ameenHere	Weseley	31004	No	30
3100402	Moisty	Dante	31004	Yes	92
3100403	Omega	SaltiAlpaca	31004	No	108
3100404	Wish	Moisty	31004	Yes	143
3100405	DiddlyLauren	Omega	31004	No	179
3100501	Moisty	Dante	31005	Yes	98
3100502	ameenHere	Omega	31005	Yes	128
3100503	DiddlyLauren	Moisty	31005	No	129
3100504	ameenHere	Weseley	31005	No	147
3100505	Panick	SaltiAlpaca	31005	No	154
3100506	ameenHere	Panick	31005	No	176
3100507	Wish	Roo	31005	No	179
3100601	Roo	SaltiAlpaca	31006	No	81
3100602	Omega	ameenHere	31006	No	100
3100603	Wish	Panick	31006	Yes	108
3100604	Wish	Weseley	31006	No	113
3100605	Omega	Wish	31006	No	123
3100606	Roo	Dante	31006	Yes	129
3100607	DiddlyLauren	Moisty	31006	Yes	214
3100608	Roo	DiddlyLauren	31006	No	218
3100701	Weseley	Dante	31007	Yes	115
3100702	Omega	ameenHere	31007	Yes	117
3100703	Panick	Wish	31007	No	130
3100704	Weseley	SaltiAlpaca	31007	No	160
3100705	Weseley	DiddlyLauren	31007	No	163
3100801	Weseley	Wish	31008	Yes	26
3100802	Weseley	DiddlyLauren	31008	Yes	105
3100803	Weseley	SaltiAlpaca	31008	Yes	124
3100804	Dante	Weseley	31008	Yes	130
3100805	Roo	Dante	31008	Yes	165
3100806	ameenHere	Roo	31008	No	168
3100807	Omega	ameenHere	31008	No	169
3100901	Weseley	ameenHere	31009	No	64
3100902	DiddlyLauren	Weseley	31009	No	66
3100903	Roo	DiddlyLauren	31009	No	76
3100904	Dante	Moisty	31009	Yes	110
3100905	SaltiAlpaca	Omega	31009	No	137
3100906	Panick	Dante	31009	Yes	159
3100907	Roo	SaltiAlpaca	31009	Yes	166
3100908	Panick	Wish	31009	No	166
3110101	Corpse	Stan	31101	No	147
3110102	Speedy	Pac	31101	Yes	149
3110103	FrenchFrie	Speedy	31101	No	172
3110104	Cowboy	Corpse	31101	No	172
3110105	Cowboy	Jackie	31101	Yes	173
3110106	Scarecrow	Josh	31101	No	173
3110107	Street	FrenchFrie	31101	No	175
3110108	Scarecrow	Street	31101	No	178
3110201	Stan	Corpse	31102	Yes	78
3110202	Street	Stan	31102	No	97
3110203	Pac	Speedy	31102	Yes	137
3110204	FrenchFrie	Street	31102	Yes	156
3110205	\N	Josh	31102	Yes	158
3110206	FrenchFrie	Jackie	31102	Yes	158
3110301	Stan	Street	31103	Yes	70
3110302	Speedy	Stan	31103	No	82
3110303	Corpse	Cowboy	31103	Yes	92
3110304	Corpse	Scarecrow	31103	Yes	110
3110305	Speedy	FrenchFrie	31103	No	114
3110306	Corpse	Pac	31103	No	145
3110401	Stan	Josh	31104	No	53
3110402	Street	Stan	31104	No	61
3110403	Pac	Street	31104	Yes	163
3110404	Corpse	Scarecrow	31104	Yes	171
3110405	\N	Speedy	31104	No	171
3110406	Jackie	FrenchFrie	31104	Yes	172
3110501	Street	Stan	31105	Yes	72
3110502	Pac	Corpse	31105	Yes	81
3110503	Scarecrow	Street	31105	No	102
3110504	FrenchFrie	Speedy	31105	Yes	121
3110505	FrenchFrie	Josh	31105	Yes	132
3110506	\N	Scarecrow	31105	No	144
3110507	FrenchFrie	Jackie	31105	No	172
3110601	FrenchFrie	Jackie	31106	Yes	68
3110602	Corpse	Stan	31106	No	82
3110603	Corpse	Scarecrow	31106	No	108
3110604	Pac	Josh	31106	Yes	152
3110605	FrenchFrie	Speedy	31106	Yes	161
3110606	Cowboy	Street	31106	Yes	166
3110607	Corpse	Cowboy	31106	No	171
3110608	FrenchFrie	Corpse	31106	No	173
3110701	Corpse	Scarecrow	31107	Yes	101
3110702	Street	FrenchFrie	31107	No	101
3110703	Stan	Jackie	31107	No	117
3110704	Corpse	Cowboy	31107	Yes	131
3110705	Pac	Corpse	31107	No	135
3110706	Josh	Pac	31107	Yes	141
3110801	Stan	Jackie	31108	No	131
3110802	Scarecrow	Josh	31108	Yes	139
3110803	Stan	Corpse	31108	No	153
3110804	Stan	Street	31108	Yes	158
3110805	Pac	Speedy	31108	Yes	160
3110901	Street	Stan	31109	Yes	135
3110902	FrenchFrie	Corpse	31109	No	156
3110903	Josh	FrenchFrie	31109	Yes	166
3110904	Street	Cowboy	31109	No	168
3110905	Speedy	Scarecrow	31109	No	171
3110906	Street	Pac	31109	No	182
3111001	Corpse	Scarecrow	31110	Yes	90
3111002	Corpse	Cowboy	31110	Yes	138
3111003	Corpse	Pac	31110	Yes	143
3111004	Stan	Josh	31110	No	149
3111005	FrenchFrie	Speedy	31110	Yes	160
3111006	Corpse	Stan	31110	Yes	165
3111007	Corpse	FrenchFrie	31110	Yes	168
3111101	Street	FrenchFrie	31111	No	78
3111102	Corpse	Pac	31111	Yes	92
3111103	Stan	Street	31111	Yes	113
3111104	Stan	Josh	31111	No	145
3111105	Cowboy	Speedy	31111	No	150
3111106	Corpse	Stan	31111	No	155
3111107	Corpse	Cowboy	31111	Yes	165
3111108	Jackie	Scarecrow	31111	No	175
3111201	Cowboy	Corpse	31112	Yes	21
3111202	Speedy	FrenchFrie	31112	No	99
3111203	Stan	Josh	31112	No	147
3111204	\N	Scarecrow	31112	No	156
3111205	Stan	Speedy	31112	No	157
3111206	Stan	Street	31112	No	160
3111207	Jackie	Pac	31112	Yes	165
3111208	Stan	Jackie	31112	No	192
3120101	Nex	Cal	31201	Yes	56
3120102	Weseley	Stan	31201	Yes	56
3120103	Panick	FrenchFrie	31201	Yes	82
3120104	Nex	Panick	31201	Yes	91
3120105	Omega	Nex	31201	No	110
3120106	Nex	Omega	31201	Yes	110
3120107	Weseley	Blue	31201	Yes	137
3120108	Pac	Moisty	31201	Yes	195
3120109	Weseley	Pac	31201	No	212
3120201	Pac	Panick	31202	Yes	153
3120202	Stan	Moisty	31202	Yes	166
3120203	FrenchFrie	Omega	31202	Yes	166
3120204	Nex	Weseley	31202	Yes	167
3120205	Cal	FrenchFrie	31202	Yes	167
3120206	Nex	Cal	31202	No	170
3120301	Weseley	Nex	31203	Yes	114
3120302	Stan	Weseley	31203	Yes	124
3120303	FrenchFrie	Omega	31203	Yes	151
3120304	Stan	Panick	31203	Yes	173
3120305	Moisty	Stan	31203	No	176
3120401	Nex	Panick	31204	No	62
3120402	Omega	Stan	31204	No	70
3120403	Weseley	Nex	31204	Yes	77
3120404	Weseley	FrenchFrie	31204	Yes	152
3120405	Weseley	Blue	31204	Yes	169
3120406	Weseley	Pac	31204	Yes	181
3120501	Stan	Cal	31205	Yes	26
3120502	Stan	Omega	31205	Yes	75
3120503	Moisty	Stan	31205	No	83
3120504	FrenchFrie	Panick	31205	Yes	102
3120505	\N	Weseley	31205	Yes	151
3120506	Moisty	Pac	31205	Yes	158
3120507	Moisty	FrenchFrie	31205	No	160
3120508	Nex	Moisty	31205	No	160
3120601	Stan	Panick	31206	No	123
3120602	Stan	Cal	31206	No	140
3120603	Pac	Omega	31206	Yes	150
3120604	Nex	Weseley	31206	No	160
3120605	Nex	Moisty	31206	No	160
3120701	Panick	Stan	31207	No	44
3120702	FrenchFrie	Weseley	31207	No	147
3120703	Pac	Panick	31207	Yes	152
3120704	Panick	Pac	31207	No	154
3120705	FrenchFrie	Moisty	31207	No	156
3120706	Omega	Nex	31207	No	159
3120707	Blue	Omega	31207	Yes	160
3120708	FrenchFrie	Cal	31207	Yes	161
3120801	Omega	Pac	31208	Yes	20
3120802	Panick	Stan	31208	No	85
3120803	Weseley	FrenchFrie	31208	No	116
3120804	Blue	Weseley	31208	Yes	122
3120805	Panick	Nex	31208	No	154
3120806	Omega	Blue	31208	No	168
3120901	Weseley	Stan	31209	No	142
3120902	Nex	Omega	31209	Yes	148
3120903	FrenchFrie	Weseley	31209	No	150
3120904	Moisty	Nex	31209	No	154
3120905	Pac	Cal	31209	Yes	167
3120906	Moisty	FrenchFrie	31209	No	174
3120907	Pac	Moisty	31209	No	176
3121001	Moisty	Nex	31210	No	76
3121002	Moisty	Blue	31210	No	79
3121003	Weseley	Stan	31210	Yes	86
3121004	FrenchFrie	Weseley	31210	No	91
3121005	FrenchFrie	Moisty	31210	No	94
3121006	Cal	FrenchFrie	31210	No	108
3121007	Pac	Omega	31210	No	113
3121008	Pac	Panick	31210	Yes	165
3121101	Panick	Blue	31211	No	63
3121102	Panick	Nex	31211	No	124
3121103	FrenchFrie	Weseley	31211	No	126
3121104	Stan	Panick	31211	No	130
3121105	Moisty	FrenchFrie	31211	No	131
3121106	Moisty	Pac	31211	No	148
3121107	Moisty	Stan	31211	Yes	155
3121201	Weseley	Stan	31212	Yes	113
3121202	Nex	Panick	31212	Yes	147
3121203	Weseley	FrenchFrie	31212	Yes	154
3121204	Blue	Weseley	31212	Yes	156
3121205	Moisty	Blue	31212	No	161
3121206	Pac	Omega	31212	Yes	164
3121207	Pac	Cal	31212	No	170
3121208	Moisty	Nex	31212	Yes	179
\.


--
-- TOC entry 3143 (class 0 OID 1997838)
-- Dependencies: 198
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches (season, match_id, map, home_team, away_team, winner, loser, h1, h2, h3, h4, h5, a1, a2, a3, a4, a5, map2) FROM stdin;
1	112	Chalet	Green	Blue	Green	Blue	Marras	Justice	CalLycus	Mastermagpie	HaiDing	SaiyanbornQueen	HotKebab	Bauer	NastyHobbit	FadeToBlue	\N
2	201	Chalet	Magnificent Pies	Team TargetBanned	Team TargetBanned	Magnificent Pies	Mastermagpie	Tommy	Spade	MoodyCereal	speedymax	Stan	Marras	CalLycus	Omega	senhasen	Chalet
2	203	Kafe	Spaghetti Patrol	Justice League	Justice League	Spaghetti Patrol	Street	FrenchFrie	Jimmy	Scarecrow	TheRandomGuy	Justice	ameenHere	WishMaster	Pacmyn	polarctic	Kafe
2	204	Chalet	Team TargetBanned	Spaghetti Patrol	Team TargetBanned	Spaghetti Patrol	Stan	Marras	CalLycus	Omega	Nex_Ingeniarius	Street	fury	Jimmy	Bauer	TheRandomGuy	Chalet
2	205	Clubhouse	Justice League	Magnificent Pies	Justice League	Magnificent Pies	Justice	ameenHere	FadeToBlue	WishMaster	Pacmyn	Mastermagpie	GetMoisty	SaiyanbornQueen	MoodyCereal	speedymax	Clubhouse
1	101	Villa	Red	Blue	Blue	Red	Jimmy	FrenchFrie	Stan	Wes	Omega	Street	HotKebab	NastyHobbit	SaiyanbornQueen	Next	\N
1	105	Oregon	Orange	Red	Red	Orange	ameenHere	MoodyCereal	speedymax	OnThinIce	Bauer	Jimmy	FrenchFrie	Stan	Wes	Nex_Ingeniarius	\N
1	111	Chalet	Red	Orange	\N	\N	Wes	egons.on	Stan	Jimmy	Nex_Ingeniarius	ameenHere	speedymax	Bauer	MoodyCereal	Justice	\N
1	102	Oregon	Green	Orange	Orange	Green	Marras	Justice	CalLycus	crimsonfever	Scarecrow	ameenHere	OnThinIce	Bauer	lxrde	speedymax	\N
1	103	Villa	Blue	Orange	Blue	Orange	Street	HotKebab	Next	NastyHobbit	MrLiam	ameenHere	OnThinIce	Bauer	lxrde	MoodyCereal	\N
1	104	Clubhouse	Green	Red	Red	Green	Marras	HaiDing	crimsonfever	Mastermagpie	Justice	FrenchFrie	Wes	Stan	Jimmy	Nex_Ingeniarius	\N
1	107	Coastline	Blue	Red	Red	Blue	ameenHere	HotKebab	NastyHobbit	SaiyanbornQueen	Mastermagpie	egons.on	Wes	Stan	Jimmy	Omega	\N
1	108	Clubhouse	Orange	Green	Green	Orange	ameenHere	OnThinIce	Bauer	lxrde	speedymax	Marras	Scarecrow	Justice	CalLycus	Mastermagpie	\N
1	109	Consulate	Orange	Blue	\N	\N	ameenHere	OnThinIce	Bauer	MoodyCereal	speedymax	NastyHobbit	MrLiam	SaiyanbornQueen	HotKebab	FadeToBlue	\N
1	110	Clubhouse	Red	Green	Green	Red	Stan	Wes	FrenchFrie	Nex_Ingeniarius	Omega	Marras	HaiDing	CalLycus	crimsonfever	Mastermagpie	\N
1	106	Chalet	Blue	Green	Blue	Green	FadeToBlue	HotKebab	NastyHobbit	Street	Next	Marras	Justice	CalLycus	crimsonfever	Mastermagpie	\N
2	210	Coastline	Nasty Pestilence	Team TargetBanned	Team TargetBanned	Nasty Pestilence	NastyHobbit	HotKebab	Nathan492	Balf	TwinkPeach	Stan	Marras	CalLycus	RooClarke	Nex_Ingeniarius	Coastline
2	217	Clubhouse	Magnificent Pies	Spaghetti Patrol	Spaghetti Patrol	Magnificent Pies	Spade	GetMoisty	Barboryx	MoodyCereal	speedymax	Street	fury	Jimmy	Bauer	TheRandomGuy	Clubhouse
2	218	Villa	Nasty Pestilence	Team TargetBanned	Team TargetBanned	Nasty Pestilence	NastyHobbit	Vance	OnThinIce	Nathan492	egons.on	Poseidon	Marras	CalLycus	Omega	Nex_Ingeniarius	Villa
2	219	Villa	Justice League	Team TargetBanned	Team TargetBanned	Justice League	Justice	ameenHere	FadeToBlue	WishMaster	polarctic	Stan	Marras	CalLycus	Omega	Nex_Ingeniarius	Villa
2	207	Coastline	Team TargetBanned	Justice League	Team TargetBanned	Justice League	Stan	Marras	CalLycus	Poseidon	Nex_Ingeniarius	Justice	ameenHere	FadeToBlue	WishMaster	Pacmyn	Coastline
2	209	Oregon	Spaghetti Patrol	Magnificent Pies	Magnificent Pies	Spaghetti Patrol	Street	FrenchFrie	Jimmy	Scarecrow	Bauer	Mastermagpie	Tommy	Spade	GetMoisty	speedymax	Oregon
2	211	Villa	Team TargetBanned	Magnificent Pies	Team TargetBanned	Magnificent Pies	Stan	Marras	CalLycus	RooClarke	Nex_Ingeniarius	Mastermagpie	Tommy	SaiyanbornQueen	Barboryx	speedymax	Villa
2	212	Coastline	Justice League	Nasty Pestilence	Justice League	Nasty Pestilence	Justice	ameenHere	WishMaster	Pacmyn	polarctic	NastyHobbit	crimsonfever	Nathan492	Balf	OnThinIce	Coastline
2	213	Consulate	Justice League	Spaghetti Patrol	Justice League	Spaghetti Patrol	Justice	ameenHere	WishMaster	Pacmyn	polarctic	TheRandomGuy	FrenchFrie	Jimmy	fury	Bauer	Consulate
2	214	Clubhouse	Spaghetti Patrol	Team TargetBanned	Spaghetti Patrol	Team TargetBanned	Street	fury	Jimmy	Bauer	Scarecrow	Stan	Marras	CalLycus	Omega	Nex_Ingeniarius	Clubhouse
2	215	Oregon	Magnificent Pies	Justice League	Justice League	Magnificent Pies	Spade	GetMoisty	Barboryx	MoodyCereal	speedymax	Justice	ameenHere	FadeToBlue	WishMaster	Pacmyn	Oregon
2	208	Chalet	Magnificent Pies	Nasty Pestilence	Magnificent Pies	Nasty Pestilence	Mastermagpie	GetMoisty	Barboryx	MoodyCereal	speedymax	HotKebab	NastyHobbit	Balf	OnThinIce	TwinkPeach	Chalet
2	216	Oregon	Spaghetti Patrol	Nasty Pestilence	Spaghetti Patrol	Nasty Pestilence	TheRandomGuy	FrenchFrie	Jimmy	Bauer	Scarecrow	NastyHobbit	HotKebab	OnThinIce	Balf	egons.on	Oregon
2	206	Clubhouse	Nasty Pestilence	Spaghetti Patrol	Spaghetti Patrol	Nasty Pestilence	HotKebab	crimsonfever	Balf	OnThinIce	egons.on	Street	FrenchFrie	Jimmy	Scarecrow	Bauer	Clubhouse
2	220	Coastline	Nasty Pestilence	Magnificent Pies	Nasty Pestilence	Magnificent Pies	Dante	egons.on	OnThinIce	Balf	Nathan492	Mastermagpie	GetMoisty	SaiyanbornQueen	Tommy	speedymax	Coastline
2	202	Villa	Nasty Pestilence	Justice League	Justice League	Nasty Pestilence	NastyHobbit	HotKebab	OnThinIce	Balf	TwinkPeach	Justice	ameenHere	FadeToBlue	Pacmyn	polarctic	Villa
3	301	Chalet	The Dark Horse	Baguette Bandits	Baguette Bandits	The Dark Horse	ameenHere	DiddlyLauren	Wish	Anszi	Balf	Pac	FrenchFrie	Cowboy	Stan	Scarecrow	\N
3	302	Bank	Omegaminds	Joshs Empire	Joshs Empire	Omegaminds	Cal	Omega	Fin	Panick	Liam	Magpie	Josh	Wes	Corpse	Jackie	\N
3	303	Oregon	Joshs Empire	Baguette Bandits	Baguette Bandits	Joshs Empire	Cowboy	FrenchFrie	Stan	Nex	Scarecrow	Magpie	Speedy	Wes	Corpse	Aehab	\N
3	304	Kafe	Joshs Empire	The Dark Horse	The Dark Horse	Joshs Empire	Magpie	Josh	Wes	Corpse	Aehab	ameenHere	DiddlyLauren	Rain	Anszi	Balf	\N
3	305	Coastline	Omegaminds	The Dark Horse	Omegaminds	The Dark Horse	Weseley	Omega	Fin	Panick	Street	Rain	DiddlyLauren	Wish	Anszi	NastyHobbit	\N
3	306	Kafe	Baguette Bandits	Omegaminds	Omegaminds	Baguette Bandits	Pac	FrenchFrie	Jimmy	Stan	Scarecrow	Weseley	Cal	Fin	Panick	Roo	\N
3	307	Oregon	Baguette Bandits	The Dark Horse	Baguette Bandits	The Dark Horse	Nex	FrenchFrie	Cowboy	Stan	Scarecrow	ameenHere	DiddlyLauren	Wish	Anszi	Balf	\N
3	308	Clubhouse	Josh's Empire	Omegaminds	Joshs Empire	Omegaminds	Speedy	Josh	Wes	Corpse	Jackie	Cal	Omega	Fin	Panick	Moisty	\N
3	309	Villa	The Dark Horse	Joshs Empire	The Dark Horse	Joshs Empire	Justice	DiddlyLauren	Wish	Anszi	SaltiAlpaca	Magpie	Josh	Wes	Corpse	Aehab	\N
3	310	Kafe	The Dark Horse	Omegaminds	Omegaminds	The Dark Horse	ameenHere	DiddlyLauren	Wish	Dante	SaltiAlpaca	Weseley	Omega	Fin	Panick	Street	\N
3	311	Kafe	Baguette Bandits	Joshs Empire	Baguette Bandits	Joshs Empire	Cowboy	FrenchFrie	Stan	Pac	Scarecrow	Speedy	Josh	Street	Corpse	Jackie	\N
3	312	Chalet	Omegaminds	Baguette Bandits	Omegaminds	Baguette Bandits	Cal	Omega	Weseley	Panick	Moisty	Blue	FrenchFrie	Stan	Pac	Nex	\N
\.


--
-- TOC entry 3144 (class 0 OID 1997850)
-- Dependencies: 199
-- Data for Name: rounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rounds (round_id, winner, match_id, planted_by, defused_by) FROM stdin;
10101	Blue	101	\N	\N
10102	Red	101	HotKebab	Stan
10103	Blue	101	HotKebab	\N
10104	Red	101	\N	\N
10105	Red	101	\N	\N
10106	Blue	101	\N	\N
10107	Blue	101	Wes	Street
10108	Blue	101	\N	\N
10109	Blue	101	\N	\N
10501	Orange	105	\N	\N
10502	Orange	105	FrenchFrie	MoodyCereal
10503	Red	105	Nex_Ingeniarius	\N
10504	Orange	105	Stan	speedymax
10505	Orange	105	\N	\N
10506	Red	105	\N	\N
10507	Red	105	\N	\N
10508	Red	105	\N	\N
10509	Orange	105	speedymax	\N
10510	Red	105	\N	\N
10511	Red	105	\N	\N
10512	Orange	105	Nex_Ingeniarius	ameenHere
10513	Red	105	\N	\N
10301	Orange	103	Bauer	\N
10302	Blue	103	\N	\N
10303	Blue	103	\N	\N
10304	Blue	103	\N	\N
10305	Orange	103	\N	\N
10306	Orange	103	\N	\N
10307	Orange	103	\N	\N
10308	Blue	103	\N	\N
10309	Orange	103	HotKebab	MoodyCereal
10310	Blue	103	Next	\N
10311	Orange	103	\N	\N
10312	Blue	103	\N	\N
10313	Blue	103	HotKebab	\N
10701	Red	107	egons.on	\N
10702	Red	107	Jimmy	\N
10703	Blue	107	\N	\N
10704	Red	107	egons.on	\N
10705	Blue	107	\N	\N
10706	Red	107	NastyHobbit	Omega
10707	Red	107	\N	\N
10708	Red	107	\N	\N
11001	Green	110	CalLycus	\N
11002	Green	110	crimsonfever	\N
11003	Green	110	\N	\N
11004	Red	110	\N	\N
11005	Red	110	\N	\N
11006	Green	110	\N	\N
11007	Red	110	\N	\N
11008	Red	110	\N	\N
11009	Green	110	\N	\N
11010	Green	110	\N	\N
11201	Blue	112	NastyHobbit	\N
11202	Green	112	\N	\N
11203	Green	112	NastyHobbit	Justice
11204	Blue	112	Bauer	\N
11205	Green	112	\N	\N
11206	Blue	112	\N	\N
11207	Blue	112	\N	\N
11208	Green	112	CalLycus	\N
11209	Green	112	CalLycus	\N
11210	Green	112	CalLycus	\N
10401	Green	104	\N	\N
10402	Red	104	\N	\N
10403	Green	104	\N	\N
10404	Red	104	Nex_Ingeniarius	\N
10405	Red	104	Nex_Ingeniarius	\N
10406	Red	104	\N	\N
10407	Red	104	\N	\N
10408	Red	104	\N	\N
11101	Orange	111	ameenHere	\N
11102	Orange	111	ameenHere	\N
11103	Orange	111	ameenHere	\N
11104	Red	111	\N	\N
11105	Orange	111	ameenHere	\N
11106	Orange	111	\N	\N
11107	Orange	111	\N	\N
10201	Green	102	\N	\N
10202	Green	102	ameenHere	Scarecrow
10203	Orange	102	speedymax	\N
10204	Orange	102	\N	\N
10205	Orange	102	\N	\N
10206	Orange	102	\N	\N
10207	Green	102	CalLycus	\N
10208	Orange	102	\N	\N
10209	Orange	102	\N	\N
10901	Orange	109	\N	\N
10902	Orange	109	\N	\N
10903	Orange	109	\N	\N
10904	Orange	109	\N	\N
10905	Orange	109	\N	\N
10801	Green	108	Scarecrow	\N
10802	Orange	108	\N	\N
10803	Orange	108	\N	\N
10804	Green	108	\N	\N
10805	Orange	108	\N	\N
10806	Green	108	\N	\N
10807	Green	108	\N	\N
10808	Orange	108	speedymax	\N
10809	Green	108	\N	\N
10810	Green	108	\N	\N
10601	Blue	106	\N	\N
10602	Blue	106	\N	\N
10603	Blue	106	\N	\N
10604	Blue	106	\N	\N
10605	Blue	106	\N	\N
10606	Green	106	\N	\N
10607	Green	106	HotKebab	Justice
10608	Blue	106	NastyHobbit	\N
20201	Justice League	202	ameenHere	\N
20202	Nasty Pestilence	202	\N	\N
20203	Justice League	202	ameenHere	\N
20204	Justice League	202	ameenHere	\N
20205	Justice League	202	Pacmyn	\N
20206	Justice League	202	Pacmyn	\N
20207	Justice League	202	\N	\N
20208	Justice League	202	\N	\N
21301	Spaghetti Patrol	213	\N	\N
21302	Justice League	213	Pacmyn	\N
21303	Justice League	213	Pacmyn	\N
21304	Spaghetti Patrol	213	\N	\N
21305	Justice League	213	Pacmyn	\N
21306	Spaghetti Patrol	213	\N	\N
21307	Justice League	213	\N	\N
21308	Spaghetti Patrol	213	FrenchFrie	\N
21309	Justice League	213	\N	\N
21310	Justice League	213	\N	\N
21311	Justice League	213	\N	\N
21201	Justice League	212	ameenHere	\N
21202	Justice League	212	ameenHere	\N
21203	Justice League	212	ameenHere	\N
21204	Justice League	212	Justice	\N
21205	Nasty Pestilence	212	\N	\N
21206	Nasty Pestilence	212	\N	\N
21207	Justice League	212	\N	\N
21208	Justice League	212	\N	\N
21209	Justice League	212	\N	\N
21501	Magnificent Pies	215	\N	\N
21502	Justice League	215	\N	\N
21503	Justice League	215	\N	\N
21504	Justice League	215	MoodyCereal	ameenHere
21505	Justice League	215	\N	\N
21506	Justice League	215	\N	\N
21507	Justice League	215	\N	\N
21508	Magnificent Pies	215	\N	\N
21509	Justice League	215	\N	\N
20701	Justice League	207	\N	\N
20702	Team TargetBanned	207	CalLycus	\N
20703	Team TargetBanned	207	CalLycus	\N
20704	Team TargetBanned	207	CalLycus	\N
20705	Justice League	207	\N	\N
20706	Justice League	207	\N	\N
20707	Team TargetBanned	207	\N	\N
20708	Team TargetBanned	207	\N	\N
20709	Team TargetBanned	207	\N	\N
20710	Team TargetBanned	207	\N	\N
22001	Nasty Pestilence	220	Nathan492	\N
22002	Magnificent Pies	220	\N	\N
22003	Magnificent Pies	220	\N	\N
22004	Nasty Pestilence	220	egons.on	\N
22005	Nasty Pestilence	220	Nathan492	\N
22006	Magnificent Pies	220	\N	\N
22007	Nasty Pestilence	220	\N	\N
22008	Nasty Pestilence	220	\N	\N
22009	Magnificent Pies	220	\N	\N
22010	Magnificent Pies	220	GetMoisty	\N
22011	Nasty Pestilence	220	\N	\N
22012	Magnificent Pies	220	speedymax	\N
22013	Magnificent Pies	220	speedymax	\N
22014	Nasty Pestilence	220	\N	\N
22015	Nasty Pestilence	220	\N	\N
20801	Magnificent Pies	208	speedymax	\N
20802	Magnificent Pies	208	\N	\N
20803	Magnificent Pies	208	\N	\N
20804	Magnificent Pies	208	\N	\N
20805	Magnificent Pies	208	\N	\N
20806	Magnificent Pies	208	speedymax	\N
20807	Magnificent Pies	208	\N	\N
20901	Magnificent Pies	209	\N	\N
20902	Magnificent Pies	209	speedymax	\N
20903	Magnificent Pies	209	\N	\N
20904	Magnificent Pies	209	\N	\N
20905	Spaghetti Patrol	209	\N	\N
20906	Spaghetti Patrol	209	\N	\N
20907	Spaghetti Patrol	209	FrenchFrie	\N
20908	Magnificent Pies	209	\N	\N
20909	Spaghetti Patrol	209	\N	\N
20910	Spaghetti Patrol	209	\N	\N
20911	Spaghetti Patrol	209	FrenchFrie	\N
20912	Magnificent Pies	209	\N	\N
20913	Magnificent Pies	209	Scarecrow	GetMoisty
20914	Magnificent Pies	209	speedymax	\N
21701	Spaghetti Patrol	217	Jimmy	\N
21702	Spaghetti Patrol	217	Jimmy	\N
21703	Spaghetti Patrol	217	\N	\N
21704	Spaghetti Patrol	217	fury	\N
21705	Spaghetti Patrol	217	Jimmy	\N
21706	Spaghetti Patrol	217	\N	\N
21707	Magnificent Pies	217	Spade	\N
21708	Spaghetti Patrol	217	\N	\N
21601	Nasty Pestilence	216	\N	\N
21602	Spaghetti Patrol	216	\N	\N
21603	Spaghetti Patrol	216	\N	\N
21604	Spaghetti Patrol	216	\N	\N
21605	Nasty Pestilence	216	OnThinIce	\N
21606	Spaghetti Patrol	216	\N	\N
21607	Spaghetti Patrol	216	Bauer	\N
21608	Nasty Pestilence	216	\N	\N
21609	Spaghetti Patrol	216	\N	\N
21610	Nasty Pestilence	216	\N	\N
21611	Spaghetti Patrol	216	Scarecrow	\N
20301	Spaghetti Patrol	203	\N	\N
20302	Spaghetti Patrol	203	\N	\N
20303	Spaghetti Patrol	203	\N	\N
20304	Justice League	203	\N	\N
20305	Justice League	203	\N	\N
20306	Justice League	203	\N	\N
20307	Spaghetti Patrol	203	\N	\N
20308	Spaghetti Patrol	203	\N	\N
20309	Spaghetti Patrol	203	Justice	FrenchFrie
20310	Justice League	203	\N	\N
20311	Justice League	203	WishMaster	\N
20312	Justice League	203	WishMaster	\N
20313	Spaghetti Patrol	203	\N	\N
20314	Justice League	203	\N	\N
20315	Justice League	203	\N	\N
20501	Justice League	205	\N	\N
20502	Magnificent Pies	205	\N	\N
20503	Magnificent Pies	205	\N	\N
20504	Magnificent Pies	205	\N	\N
20505	Justice League	205	ameenHere	\N
20506	Justice League	205	WishMaster	\N
20507	Justice League	205	\N	\N
20508	Justice League	205	\N	\N
20509	Justice League	205	\N	\N
20510	Justice League	205	\N	\N
20601	Nasty Pestilence	206	Jimmy	OnThinIce
20602	Spaghetti Patrol	206	FrenchFrie	\N
20603	Spaghetti Patrol	206	\N	\N
20604	Spaghetti Patrol	206	\N	\N
20605	Nasty Pestilence	206	\N	\N
20606	Nasty Pestilence	206	\N	\N
20607	Nasty Pestilence	206	crimsonfever	\N
20608	Spaghetti Patrol	206	\N	\N
20609	Spaghetti Patrol	206	\N	\N
20610	Spaghetti Patrol	206	\N	\N
20611	Nasty Pestilence	206	\N	\N
20612	Nasty Pestilence	206	\N	\N
20613	Spaghetti Patrol	206	\N	\N
20614	Spaghetti Patrol	206	\N	\N
21401	Spaghetti Patrol	214	\N	\N
21402	Team TargetBanned	214	\N	\N
21403	Spaghetti Patrol	214	\N	\N
21404	Spaghetti Patrol	214	\N	\N
21405	Spaghetti Patrol	214	\N	\N
21406	Spaghetti Patrol	214	\N	\N
21407	Spaghetti Patrol	214	Scarecrow	\N
21408	Team TargetBanned	214	\N	\N
21409	Team TargetBanned	214	\N	\N
21410	Spaghetti Patrol	214	fury	\N
21801	Team TargetBanned	218	CalLycus	\N
21802	Team TargetBanned	218	\N	\N
21803	Nasty Pestilence	218	CalLycus	egons.on
21804	Team TargetBanned	218	CalLycus	\N
21805	Team TargetBanned	218	\N	\N
21806	Nasty Pestilence	218	\N	\N
21807	Nasty Pestilence	218	\N	\N
21808	Nasty Pestilence	218	Vance	\N
21809	Team TargetBanned	218	\N	\N
21810	Team TargetBanned	218	\N	\N
21811	Team TargetBanned	218	\N	\N
21901	Justice League	219	\N	\N
21902	Team TargetBanned	219	\N	\N
21903	Justice League	219	\N	\N
21904	Team TargetBanned	219	\N	\N
21905	Team TargetBanned	219	Omega	\N
21906	Justice League	219	CalLycus	ameenHere
21907	Justice League	219	\N	\N
21908	Team TargetBanned	219	\N	\N
21909	Team TargetBanned	219	\N	\N
21910	Justice League	219	WishMaster	\N
21911	Team TargetBanned	219	\N	\N
21912	Team TargetBanned	219	WishMaster	Stan
20401	Team TargetBanned	204	\N	\N
20403	Team TargetBanned	204	\N	\N
20402	Spaghetti Patrol	204	fury	\N
21001	Team TargetBanned	210	\N	\N
21002	Team TargetBanned	210	\N	\N
21003	Team TargetBanned	210	\N	\N
21004	Team TargetBanned	210	\N	\N
21005	Team TargetBanned	210	\N	\N
21006	Team TargetBanned	210	Balf	RooClarke
21007	Nasty Pestilence	210	\N	\N
21008	Team TargetBanned	210	CalLycus	\N
20101	Team TargetBanned	201	\N	\N
20102	Magnificent Pies	201	speedymax	\N
20103	Magnificent Pies	201	\N	\N
20104	Team TargetBanned	201	\N	\N
20105	Team TargetBanned	201	\N	\N
20106	Team TargetBanned	201	\N	\N
20107	Team TargetBanned	201	CalLycus	\N
20108	Magnificent Pies	201	\N	\N
20109	Magnificent Pies	201	\N	\N
20110	Team TargetBanned	201	\N	\N
20111	Team TargetBanned	201	CalLycus	\N
21101	Team TargetBanned	211	CalLycus	\N
21102	Team TargetBanned	211	\N	\N
21103	Team TargetBanned	211	CalLycus	\N
21104	Magnificent Pies	211	\N	\N
21105	Magnificent Pies	211	\N	\N
21106	Team TargetBanned	211	\N	\N
21107	Team TargetBanned	211	\N	\N
21108	Magnificent Pies	211	\N	\N
21109	Magnificent Pies	211	\N	\N
30101	The Dark Horse	301	\N	\N
30102	Baguette Bandits	301	Pac	\N
30103	The Dark Horse	301	\N	\N
30104	Baguette Bandits	301	Scarecrow	\N
30105	The Dark Horse	301	\N	\N
30106	Baguette Bandits	301	Pac	\N
30107	Baguette Bandits	301	\N	\N
30108	Baguette Bandits	301	DiddlyLauren	FrenchFrie
30109	Baguette Bandits	301	\N	\N
30110	Baguette Bandits	301	\N	\N
30901	Joshs Empire	309	Magpie	\N
30902	The Dark Horse	309	\N	\N
30903	Joshs Empire	309	Magpie	\N
30904	The Dark Horse	309	\N	\N
30905	The Dark Horse	309	\N	\N
30906	Joshs Empire	309	\N	\N
30907	Joshs Empire	309	Wish	Corpse
30908	The Dark Horse	309	Wish	\N
30909	The Dark Horse	309	\N	\N
30910	The Dark Horse	309	\N	\N
30911	The Dark Horse	309	DiddlyLauren	\N
30701	Baguette Bandits	307	\N	\N
30702	The Dark Horse	307	Balf	\N
30703	The Dark Horse	307	Anszi	\N
30704	Baguette Bandits	307	\N	\N
30705	Baguette Bandits	307	\N	\N
30706	Baguette Bandits	307	\N	\N
30707	The Dark Horse	307	\N	\N
30708	The Dark Horse	307	\N	\N
30709	The Dark Horse	307	Scarecrow	ameenHere
30710	The Dark Horse	307	\N	\N
30711	Baguette Bandits	307	\N	\N
30712	Baguette Bandits	307	\N	\N
30713	The Dark Horse	307	\N	\N
30714	Baguette Bandits	307	\N	\N
30715	Baguette Bandits	307	\N	\N
30501	Omegaminds	305	Street	\N
30502	Omegaminds	305	\N	\N
30503	The Dark Horse	305	\N	\N
30504	Omegaminds	305	Omega	\N
30505	Omegaminds	305	Omega	\N
30506	Omegaminds	305	\N	\N
30507	Omegaminds	305	\N	\N
30508	Omegaminds	305	\N	\N
30201	Omegaminds	302	Cal	\N
30202	Joshs Empire	302	\N	\N
30203	Joshs Empire	302	\N	\N
30204	Joshs Empire	302	\N	\N
30205	Omegaminds	302	Panick	\N
30206	Omegaminds	302	\N	\N
30207	Omegaminds	302	\N	\N
30208	Joshs Empire	302	Magpie	\N
30209	Joshs Empire	302	\N	\N
30210	Omegaminds	302	\N	\N
30211	Joshs Empire	302	\N	\N
30212	Joshs Empire	302	Jackie	\N
30301	Joshs Empire	303	\N	\N
30302	Baguette Bandits	303	\N	\N
30303	Baguette Bandits	303	Scarecrow	\N
30304	Baguette Bandits	303	\N	\N
30305	Baguette Bandits	303	Nex	\N
30306	Joshs Empire	303	\N	\N
30307	Joshs Empire	303	Aehab	\N
30308	Joshs Empire	303	Aehab	\N
30309	Joshs Empire	303	Aehab	Cowboy
30310	Baguette Bandits	303	\N	\N
30311	Joshs Empire	303	Aehab	\N
30312	Joshs Empire	303	\N	\N
30401	Joshs Empire	304	\N	\N
30402	The Dark Horse	304	\N	\N
30403	Joshs Empire	304	\N	\N
30404	Joshs Empire	304	\N	\N
30405	Joshs Empire	304	\N	\N
30406	The Dark Horse	304	ameenHere	\N
30407	Joshs Empire	304	\N	\N
30408	The Dark Horse	304	\N	\N
30409	Joshs Empire	304	\N	\N
30410	The Dark Horse	304	\N	\N
30411	The Dark Horse	304	\N	\N
30412	The Dark Horse	304	\N	\N
30413	The Dark Horse	304	\N	\N
30414	Joshs Empire	304	ameenHere	Aehab
30415	The Dark Horse	304	\N	\N
30601	Baguette Bandits	306	\N	\N
30602	Omegaminds	306	Panick	\N
30603	Omegaminds	306	Panick	\N
30604	Omegaminds	306	Panick	\N
30605	Omegaminds	306	Panick	\N
30606	Baguette Bandits	306	\N	\N
30607	Baguette Bandits	306	\N	\N
30608	Baguette Bandits	306	Jimmy	\N
30609	Omegaminds	306	\N	\N
30610	Baguette Bandits	306	Scarecrow	\N
30611	Omegaminds	306	\N	\N
30612	Omegaminds	306	\N	\N
30801	Joshs Empire	308	Cal	Josh
30802	Joshs Empire	308	\N	\N
30803	Omegaminds	308	Panick	\N
30804	Joshs Empire	308	\N	\N
30805	Omegaminds	308	Cal	\N
30806	Omegaminds	308	Cal	\N
30807	Omegaminds	308	\N	\N
30808	Joshs Empire	308	\N	\N
30809	Omegaminds	308	\N	\N
30810	Joshs Empire	308	Jackie	\N
30811	Joshs Empire	308	\N	\N
30812	Omegaminds	308	Jackie	Panick
30813	Joshs Empire	308	Jackie	\N
30814	Omegaminds	308	\N	\N
30815	Joshs Empire	308	\N	\N
31001	Omegaminds	310	\N	\N
31002	Omegaminds	310	Panick	\N
31003	Omegaminds	310	Panick	\N
31004	The Dark Horse	310	\N	\N
31005	The Dark Horse	310	\N	\N
31006	Omegaminds	310	Roo	\N
31007	Omegaminds	310	\N	\N
31008	Omegaminds	310	\N	\N
31009	Omegaminds	310	\N	\N
31101	Baguette Bandits	311	\N	\N
31102	Baguette Bandits	311	Josh	Scarecrow
31103	Joshs Empire	311	\N	\N
31104	Baguette Bandits	311	\N	\N
31105	Baguette Bandits	311	\N	\N
31106	Baguette Bandits	311	\N	\N
31107	Baguette Bandits	311	\N	\N
31108	Joshs Empire	311	\N	\N
31109	Joshs Empire	311	\N	\N
31110	Joshs Empire	311	\N	\N
31111	Joshs Empire	311	\N	\N
31112	Baguette Bandits	311	Stan	\N
31201	Omegaminds	312	Weseley	\N
31202	Baguette Bandits	312	\N	\N
31203	Baguette Bandits	312	\N	\N
31204	Omegaminds	312	Weseley	\N
31205	Baguette Bandits	312	\N	\N
31206	Baguette Bandits	312	\N	\N
31207	Baguette Bandits	312	\N	\N
31208	Omegaminds	312	\N	\N
31209	Omegaminds	312	\N	\N
31210	Omegaminds	312	\N	\N
31211	Omegaminds	312	\N	\N
31212	Omegaminds	312	\N	\N
\.


--
-- TOC entry 3013 (class 2606 OID 1997857)
-- Name: kills Kills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kills
    ADD CONSTRAINT "Kills_pkey" PRIMARY KEY (kill_id);


--
-- TOC entry 3016 (class 2606 OID 1997859)
-- Name: matches Matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT "Matches_pkey" PRIMARY KEY (match_id);


--
-- TOC entry 3019 (class 2606 OID 2458866)
-- Name: rounds rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rounds
    ADD CONSTRAINT rounds_pkey PRIMARY KEY (round_id);


--
-- TOC entry 3014 (class 1259 OID 1997864)
-- Name: fki_KillsToRounds; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_KillsToRounds" ON public.kills USING btree (round_id);


--
-- TOC entry 3017 (class 1259 OID 1997865)
-- Name: fki_RoundsToMatches; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_RoundsToMatches" ON public.rounds USING btree (match_id);


--
-- TOC entry 3020 (class 2606 OID 1997866)
-- Name: rounds RoundsToMatches; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rounds
    ADD CONSTRAINT "RoundsToMatches" FOREIGN KEY (match_id) REFERENCES public.matches(match_id);


-- Completed on 2022-07-31 22:38:15 CEST

--
-- PostgreSQL database dump complete
--

