create database Bestiary;
use Bestiary;

-- Enums --
create type Alignment as enum (
	'Unaligned',
	'LG', 'NG', 'CG',
	'LN',  'N', 'CN',
	'LE', 'NE', 'CE'
);
-- null - Unaligned
-- 1010 - Lawful Good
-- 0110 - Neutral Good
-- 0010 - Chaotic Good
-- 1001 - Lawful Neutral
-- 0101 - Neutral
-- 0001 - Chaotic Neutral
-- 1000 - Lawful Evil
-- 0100 - Neutral Evil
-- 0000 - Chaotic Evil
-- 1011 - Any Lawful
-- 1110 - Any Good
-- 0111 - Any Neutral
-- 1101 - Any Neutral
-- 1100 - Any Evil
-- 0011 - Any Chaotic
-- 1111 - Any

-- null - NaN - Unaligned
-- 0000 -  0  - Chaotic Evil
-- 0001 -  1  - Chaotic Neutral
-- 0010 -  2  - Chaotic Good
-- 0011 -  3  - Any Chaotic
-- 0100 -  4  - Neutral Evil
-- 0101 -  5  - Neutral
-- 0110 -  6  - Neutral Good
-- 0111 -  7  - Any Neutral
-- 1000 -  8  - Lawful Evil
-- 1001 -  9  - Lawful Neutral
-- 1010 - 10  - Lawful Good
-- 1011 - 11  - Any Lawful
-- 1100 - 12  - Any Evil
-- 1101 - 13  - Any Neutral
-- 1110 - 14  - Any Good
-- 1111 - 15  - Any

create type AlignmentSpecifier as enum (
	'Unaligned',
	'LG', 'NG', 'CG',
	'LN',  'N', 'CN',
	'LE', 'NE', 'CE',
	'AL', 'AG', 'AN', 'AE', 'AC', 'A'
);

create type Role as enum (
	'None',
	'Combat',
	'Skill',
	'Special',
	'Spell',
	'Any'
);

-- 0000 - None
-- 0001 - Combat
-- 0010 - Skill
-- 0100 - Special
-- 1000 - Spell
-- 1111 - Any

create type Climate as enum (
	'Any',
	'Cold',
	'Temperate',
	'Warm'
);
create type CreatureSize as enum (
	'Fine',
	'Diminutive',
	'Tiny',
	'Small',
	'Medium',
	'Large',
	'Huge',
	'Gargantuan',
	'Colossal'
);
create type CreatureType as enum (
	'Abberation',
	'Animal',
	'Construct',
	'Dragon',
	'Fey',
	'Humanoid',
	'Magical Beast',
	'Monstrous Humanoid',
	'Ooze',
	'Outsider',
	'Plant',
	'Undead',
	'Vermin'
);
create type Maneuverability as enum (
	'Clumsy',
	'Poor',
	'Average',
	'Good',
	'Perfect'
);

-- Read Only Tables --
create table AlignmentStrings (
	Id				Alignment,
	AxisLawChaos	char(7),
	AxisGoodEvil	char(7),
);
insert into AlignmentStrings
values
	('Unaligned', '', ''),
	('LG', 'Lawful', 'Good'),
	('NG', 'Neutral', 'Good'),
	('CG', 'Chaotic', 'Good'),
	('LN', 'Lawful', 'Neutral'),
	('N', 'Neutral', 'Neutral'),
	('CN', 'Chaotic', 'Neutral'),
	('LE', 'Lawful', 'Evil'),
	('NE', 'Neutral', 'Evil'),
	('CE', 'Chaotic', 'Evil');

create table AlignmentSpecifierStrings (
	Id				Alignment,
	AxisLawChaos	char(7),
	AxisGoodEvil	char(7),
);
insert into AlignmentSpecifierStrings
values
	('', ''),
	('LG', 'Lawful', 'Good'),
	('NG', 'Neutral', 'Good'),
	('CG', 'Chaotic', 'Good'),
	('LN', 'Lawful', 'Neutral'),
	('N', 'Neutral', 'Neutral'),
	('CN', 'Chaotic', 'Neutral'),
	('LE', 'Lawful', 'Evil'),
	('NE', 'Neutral', 'Evil'),
	('CE', 'Chaotic', 'Evil'),
	('AL', 'Any', 'Lawful'),
	('AG', 'Any', 'Good'),
	('AN', 'Any', 'Neutral'),
	('AE', 'Any', 'Evil'),
	('AC', 'Any', 'Chaotic'),
	('A', 'Any', 'Any');

create table Sources (
	Isbn			char(13),
	Title			varchar(100)
);
insert into Sources
values
	('', ''),
	('9781640781078', 'Wilderness Origins');

-- Small Tables --
create table Biome (
	Id              smallint,
	Biome           varchar(255)
);
insert into Biome
values
	('Any'),
	('Desert'),
	('Forest'),
	('Hills'),
	('Mountain'),
	('Ocean'),
	('Plains'),
	('Swamp'),
	('Coastline'),
	('Rivers/Lakes'),
	('Ruins'),
	('Underground'),
	('Urban'),
	('Vacuum'),
	('Planar'),
	('Planar, Astral'),
	('Planar, Ethereal'),
	('Planar, Feywild'),
	('Planar, Shadow'),
	('Planar, Positive'),
	('Planar, Negative'),
	('Planar, Air'),
	('Planar, Earth'),
	('Planar, Fire'),
	('Planar, Water');

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

create table Environments (
	Id              smallint,
	Alignment       Alignment,
	Climate         Climate,
	BiomeId         smallint
);

create table CreatureEnvironmentsMap (
	Id              smallint,
	BaseCreatureId  varchar(255),
	EnvironmentId   smallint
);

create table CreatureSubtypes (
	Id              smallint,
	Subtype         varchar(255)
);
insert into CreatureSubtypes
values
	('Augmented Abberation'),
	('Augmented Abberation'),
	('Augmented Animal'),
	('Augmented Construct'),
	('Augmented Dragon'),
	('Augmented Fey'),
	('Augmented Humanoid'),
	('Augmented Magical Beast'),
	('Augmented Monstrous Humanoid'),
	('Augmented Ooze'),
	('Augmented Outsider'),
	('Augmented Plant'),
	('Augmented Undead'),
	('Augmented Vermin'),
	('');

create table CreatureSubtypesMap (
	Id              smallint,
	SubtypeId       varchar(255)
);


-- Large Tables --
create table BaseCreatures (
	Name				varchar(255),
	Cr					tinyint,
	SourceId			tinyint,
	Page				smallint,
	AlignmentId			tinyint,
	CreatureSize		CreatureSize,
	CreatureType		CreatureType,
	Initiative			tinyint,
	Ac					tinyint,
	AcFf				tinyint,
	AcTouch				tinyint,
	Hp					tinyint,
	Hd					tinyint,
	Fort				tinyint,
	Ref					tinyint,
	Will				tinyint,
	Sr					tinyint,
	Bab					tinyint,
	Cmb					tinyint,
	Cmd					tinyint,
	Treasure			tinyint,
	DescriptionVisual	varchar(),
	Description			varchar(),
	SpeedBurrow			tinyint,
	SpeedClimb			tinyint,
	SpeedFly			tinyint,
	Maneuverability		Maneuverability,
	SpeedLand			tinyint,
	SpeedSwim			tinyint
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
