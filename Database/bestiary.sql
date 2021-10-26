create database Bestiary;
use Bestiary;

-- Enums --
create type Alignment as enum (
	"Unaligned",
	"LG", "NG", "CG",
	"LN",  "N", "CN",
	"LE", "NE", "CE"
);
create type AlignmentSpecifier as enum (
	"Unaligned",
	"LG", "NG", "CG",
	"LN",  "N", "CN",
	"LE", "NE", "CE",
	"AL", "AG", "AN", "AE", "AC"
);
create type Climate as enum (
	"Any",
	"Cold",
	"Temperate",
	"Warm"
);
create type CreatureSize as enum (
	"Fine",
	"Diminutive",
	"Tiny",
	"Small",
	"Medium",
	"Large",
	"Huge",
	"Gargantuan",
	"Colossal"
);
create type CreatureType as enum (
	"Abberation",
	"Animal",
	"Construct",
	"Dragon",
	"Fey",
	"Humanoid",
	"Magical Beast",
	"Monstrous Humanoid",
	"Ooze",
	"Outsider",
	"Plant",
	"Undead",
	"Vermin"
);

-- Read Only Tables --
create table AlignmentStrings (
	Id				Alignment,
	AxisLawChaos	char(7),
	AxisGoodEvil	char(7),
);
insert into AlignmentStrings
values
	("", ""),
	("Lawful", "Good"),
	("Neutral", "Good"),
	("Chaotic", "Good"),
	("Lawful", "Neutral"),
	("Neutral", "Neutral"),
	("Chaotic", "Neutral"),
	("Lawful", "Evil"),
	("Neutral", "Evil"),
	("Chaotic", "Evil");

create table AlignmentSpecifierStrings (
	Id				Alignment,
	AxisLawChaos	char(7),
	AxisGoodEvil	char(7),
);
insert into AlignmentSpecifierStrings
values
	("", ""),
	("Lawful", "Good"),
	("Neutral", "Good"),
	("Chaotic", "Good"),
	("Lawful", "Neutral"),
	("Neutral", "Neutral"),
	("Chaotic", "Neutral"),
	("Lawful", "Evil"),
	("Neutral", "Evil"),
	("Chaotic", "Evil"),
	("Any", "Lawful"),
	("Any", "Good"),
	("Any", "Neutral"),
	("Any", "Evil"),
	("Any", "Chaotic");

-- Small Tables --
create table Biome (
	Id              smallint,
	Biome           varchar(255)
);

create table CreatureEnvironments (
	Id              smallint,
	BaseCreatureId  varchar(255),
	EnvironmentId   smallint
);

create table CreatureSubtypes (
	Id              smallint,
	Subtype         varchar(255)
);

create table Environments (
	Id              smallint,
	Alignment       Alignment,
	Climate         Climate,
	BiomeId         smallint
);


-- Large Tables --
create table BaseCreatures (
	Name			varchar(255),
	Cr				tinyint,
	Source			varchar(255),
	Page			smallint,
	AlignmentId		tinyint,
	CreatureSize	CreatureSize,
	CreatureTypeId	tinyint
);
create table Races ();
create table Templates ();

-- Name
-- CR
-- Source
-- Page
-- Alignment
-- Size
-- Type
-- SubType
-- Init
-- Senses
-- Aura
-- AC
-- AC_Mods
-- HP
-- HD
-- HP_Mods
-- Saves
-- Fort
-- Ref
-- Will
-- Save_Mods
-- DefensiveAbilities
-- DR
-- Immune
-- Resist
-- SR
-- Weaknesses
-- Speed
-- Speed_Mod
-- Melee
-- Ranged
-- Space
-- Reach
-- SpecialAttacks
-- SpellLikeAbilities
-- SpellsKnown
-- SpellsPrepared
-- SpellDomains
-- AbilityScores
-- BaseAtk
-- CMB
-- CMD
-- Feats
-- Skills
-- RacialMods
-- Languages
-- SQ
-- Environment
-- Organization
-- Treasure
-- Description_Visual
-- Group
-- SpecialAbilities
-- Description
-- FullText
-- Bloodline
-- ProhibitedSchools
-- Gear
-- OtherGear
-- Vulnerability
-- Note
-- CompanionFlag
-- Fly
-- Climb
-- Burrow
-- Swim
-- Land
-- OffenseNote
-- BaseStatistics
-- ExtractsPrepared
-- AgeCategory
-- DontUseRacialHD
-- VariantParent
-- Mystery
-- Patron
-- FocusedSchool
-- AlternateNameForm
-- StatisticsNote

-- Env_Any
-- Env_Any_Cold
-- Env_Any_Temperate
-- Env_Any_Warm
-- Env_Desert_Cold
-- Env_Desert_Temperate
-- Env_Desert_Warm
-- Env_Forest_Cold
-- Env_Forest_Temperate
-- Env_Forest_Warm
-- Env_Hills_Cold
-- Env_Hills_Temperate
-- Env_Hills_Warm
-- Env_Mountains_Cold
-- Env_Mountains_Temperate
-- Env_Mountains_Warm
-- Env_Ocean_Cold
-- Env_Ocean_Temperate
-- Env_Ocean_Warm
-- Env_Plains_Cold
-- Env_Plains_Temperate
-- Env_Plains_Warm
-- Env_Swamp_Cold
-- Env_Swamp_Temperate
-- Env_Swamp_Warm
-- Env_Coastline
-- Env_Rivers/Lakes
-- Env_Ruins
-- Env_Underground
-- Env_Urban
-- Env_Vacuum
-- Env_Planar_LG
-- Env_Planar_NG
-- Env_Planar_CG
-- Env_Planar_LN
-- Env_Planar_N
-- Env_Planar_CN
-- Env_Planar_LE
-- Env_Planar_NE
-- Env_Planar_CE
-- Env_Planar_Astral
-- Env_Planar_Ethereal
-- Env_Planar_Feywild
-- Env_Planar_Shadow
-- Env_Planar_Positive
-- Env_Planar_Negative
-- Env_Planar_Air
-- Env_Planar_Earth
-- Env_Planar_Fire
-- Env_Planar_Water
