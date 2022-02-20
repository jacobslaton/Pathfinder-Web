-- This should work with other flavors of sql, but not postgresql.
-- Make sure to create and connect to a database named pathfinder before running this script.

--create database pathfinder;
--use pathfinder;

create extension if not exists "uuid-ossp";
drop procedure if exists addEnvironment;
drop procedure if exists createTerrain;
drop procedure if exists createPlane;
drop procedure if exists createEnvironment;
drop table if exists map_base_creature_environment;
drop table if exists environments;
drop type if exists climate;
drop table if exists terrains;
drop table if exists planes;
drop type if exists plane_magic_traits;
drop type if exists plane_alignment_traits;
drop type if exists plane_essence_traits;
drop type if exists plane_structural_traits;
drop type if exists plane_realm_traits;
drop type if exists plane_time_traits;
drop type if exists plane_gravity_traits;
drop procedure if exists addSubtype;
drop table if exists map_base_creature_subtype;
drop procedure if exists createSubtype;
drop table if exists subtypes;
drop table if exists base_creatures;
drop procedure if exists createSource;
drop table if exists sources;
drop table if exists uuid_namespaces;
drop function if exists uuidHash;
drop type if exists maneuverability;
drop type if exists creature_type;
drop type if exists creature_size;
drop type if exists alignment_moral;
drop type if exists alignment_ethical;

create type alignment_ethical as enum ('L', 'N', 'C');
create type alignment_moral as enum ('G', 'N', 'E');
create type creature_size as enum (
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
create type creature_type as enum (
	'Aberration',
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
create type maneuverability as enum (
	'Clumsy',
	'Poor',
	'Average',
	'Good',
	'Perfect'
);


---------------------
-- uuid_namespaces --
---------------------

create function uuidHash(namespace text, string text)
returns uuid as $hash$
begin
	return uuid_generate_v5((select uuid from uuid_namespaces where name = namespace), string);
end;
$hash$ language plpgsql;

create table uuid_namespaces (
	uuid                uuid not null,
	name                varchar(256) not null,
	primary key (uuid),
	check (not name = ''),
	unique (uuid, name)
);


-------------
-- sources --
-------------

create table sources (
	uuid                uuid not null,
	title               varchar(256) not null,
	abbreviation        varchar(4),
	isbn                char(17),
	is_official         boolean not null,
	primary key (uuid),
	check (not title = ''),
	check (uuid = uuidHash('sources', title)),
	unique (uuid, title),
	check (not abbreviation = ''),
	unique (isbn)
);

create procedure createSource(
	title               text,
	abbreviation        text,
	isbn                text,
	isOfficial          boolean
)
language plpgsql as $$
begin
	insert into sources (uuid, title, abbreviation, isbn, is_official) values (
		uuidHash('sources', title), title, abbreviation, isbn, isOfficial
	);
	commit;
end;$$;

--------------------
-- base_creatures --
--------------------

create table base_creatures (
	uuid                uuid not null,
	name                varchar(256) not null,
	cr                  smallint not null,
	source_uuid         uuid not null,
	page                smallint,
	alignment_ethical   alignment_ethical not null,
	alignment_moral     alignment_moral not null,
	size                creature_size not null,
	type                creature_type not null,
	initiative          smallint not null,
	ac                  smallint not null,
	ac_touch            smallint not null,
	ac_ff               smallint not null,
	hp                  smallint not null,
	hd_count            smallint not null,
	hd_size             smallint not null,
	fort                smallint not null,
	ref                 smallint not null,
	will                smallint not null,
	sr                  smallint,
	strength            smallint,
	dexterity           smallint,
	constitution        smallint,
	intelligence        smallint,
	wisdom              smallint,
	charisma            smallint,
	bab                 smallint not null,
	cmb                 smallint,
	cmd                 smallint,
	speed_burrow        smallint not null,
	speed_climb         smallint not null,
	speed_fly           smallint not null,
	maneuverability     maneuverability,
	speed_land          smallint not null,
	speed_swim          smallint not null,
	role_combat			boolean not null,
	role_spell			boolean not null,
	role_skill			boolean not null,
	role_special		boolean not null,
	variant_parent      uuid,
	alternate_name      varchar(256),
	primary key (uuid),
	check (not name = ''),
	check (uuid = uuidHash('base_creatures', name)),
	unique (uuid, name),
	check (cr > -5),
	foreign key (source_uuid) references sources (uuid),
	check (page > 0),
	check (hp > 0),
	check (hd_count > 0),
	check (hd_size > 0),
	check (strength > 0),
	check (dexterity > 0),
	check (constitution > 0),
	check (intelligence > 0),
	check (wisdom > 0),
	check (charisma > 0),
	check (bab >= 0),
	check (speed_burrow >= 0),
	check (speed_climb >= 0),
	check (speed_fly >= 0),
	check (speed_land >= 0),
	check (speed_swim >= 0),
	foreign key (variant_parent) references base_creatures (uuid)
);


--------------
-- subtypes --
--------------

create table subtypes (
	uuid                uuid not null,
	name                varchar(256) not null,
	source_uuid         uuid not null,
	primary key (uuid),
	foreign key (source_uuid) references sources (uuid),
	check (not name = ''),
	check (uuid = uuidHash('subtypes', name)),
	unique (uuid, name)
);

create procedure createSubtype(
	sourceTitle         text,
	subtype             text
)
language plpgsql as $$
begin
	insert into subtypes values (
		uuidHash('subtypes', subtype),
		subtype,
		(select uuid from sources where title = sourceTitle)
	);
	commit;
end;$$;

create table map_base_creature_subtype (
	creature_uuid     uuid not null,
	subtype_uuid      uuid not null,
	foreign key (creature_uuid) references base_creatures (uuid),
	foreign key (subtype_uuid) references subtypes (uuid),
	unique (creature_uuid, subtype_uuid)
);

create procedure addSubtype(
	creature            text,
	subtype             text
)
language plpgsql as $$
begin
	insert into map_base_creature_subtype values (
		uuidHash('base_creatures', creature),
		uuidHash('subtypes', subtype)
	);
	commit;
end;$$;


------------
-- planes --
------------

create type plane_gravity_traits as enum (
	'Normal Gravity',
	'Heavy Gravity',
	'Light Gravity',
	'No Gravity',
	'Objective Directional Gravity',
	'Subjective Directional Gravity'
);
create type plane_time_traits as enum (
	'Normal Time',
	'Erratic Time',
	'Flowing Time',
	'Timeless'
);
create type plane_realm_traits as enum (
	'Finite',
	'Immeasurable',
	'Unbounded'
);
create type plane_structural_traits as enum (
	'Lasting Structure',
	'Morphic Structure',
	'Sentient Structure',
	'Static Structure'
);
create type plane_essence_traits as enum (
	'Mixed Essence',
	'Air-Essence',
	'Earth-Essence',
	'Fire-Essence',
	'Water-Essence',
	'Negative-Essence',
	'Positive-Essence'
);
create type plane_alignment_traits as enum (
	'Unaligned',
	'Mildly Aligned',
	'Strongly Aligned'
);
create type plane_magic_traits as enum (
	'Normal Magic',
	'Dead Magic',
	'Enhanced Magic',
	'Impeded Magic',
	'Limited Magic',
	'Wild Magic'
);

create table planes (
	uuid                uuid not null,
	name                varchar(256) not null,
	trait_gravity       plane_gravity_traits,
	trait_time          plane_time_traits,
	trait_realm         plane_realm_traits,
	trait_structural    plane_structural_traits,
	trait_essence       plane_essence_traits,
	trait_alignment     plane_alignment_traits,
	alignment_ethical   alignment_ethical,
	alignment_moral     alignment_moral,
	trait_magic         plane_magic_traits,
	primary key (uuid),
	check (not name = ''),
	check (uuid = uuidHash('planes', name)),
	unique (uuid, name)
);

------------------
-- environments --
------------------

create table terrains (
	uuid                uuid not null,
	name                varchar(256) not null,
	primary key (uuid),
	check (not name = ''),
	check (uuid = uuidHash('terrains', name)),
	unique (uuid, name)
);
create type climate as enum (
	'cold',
	'temperate',
	'warm'
);
create table environments (
	uuid                uuid not null,
	plane_uuid          uuid,
	terrain_uuid        uuid,
	climate             climate,
	primary key (uuid),
	foreign key (plane_uuid) references planes (uuid),
	foreign key (terrain_uuid) references terrains (uuid),
	check (uuid = uuidHash('environments', concat(
		plane_uuid, '|', terrain_uuid, '|', climate
	))),
	check (not (plane_uuid is null and terrain_uuid is null and climate is null)),
	unique (uuid, plane_uuid, terrain_uuid, climate)
);
create table map_base_creature_environment (
	creature_uuid       uuid not null,
	environment_uuid    uuid not null,
	foreign key (creature_uuid) references base_creatures (uuid),
	foreign key (environment_uuid) references environments (uuid),
	unique (creature_uuid, environment_uuid)
);

create procedure createEnvironment(
	plane               text,
	terrain             text,
	climate             climate
)
language plpgsql as $$
declare
	plane_uuid          uuid := uuidHash('planes', plane);
	terrain_uuid        uuid := uuidHash('terrains', terrain);
begin
	insert into environments values (
		uuidHash('environments', concat(
			plane_uuid, '|', terrain_uuid, '|', climate
		)),
		plane_uuid,
		terrain_uuid,
		climate
	);
	commit;
end;$$;

create procedure createPlane(plane text)
language plpgsql as $$
begin
	insert into planes values (uuidHash('planes', plane), plane);
	call createEnvironment(plane, null, null);
	commit;
end;$$;

create procedure createTerrain(terrain text)
language plpgsql as $$
begin
	insert into terrains values (uuidHash('terrains', terrain), terrain);
	call createEnvironment(null, terrain, null);
	commit;
end;$$;

create procedure addEnvironment(
	creature            text,
	plane               text,
	terrain             text,
	climate             climate
)
language plpgsql as $$
begin
	raise notice 'Creature: %', creature;
	raise notice 'Plane: %', plane;
	raise notice 'Terrain: %', terrain;
	raise notice 'Climate: %', climate;
	-- perform uuid from planes where name = plane;
	-- if not found then
	-- 	call createPlane(plane);
	-- end if;
	-- perform uuid from terrains where name = terrain;
	-- if not found then
	-- 	call createTerrain(terrain);
	-- end if;
	-- perform uuid from environments
	-- 	where plane_uuid = uuidHash('planes', plane)
	-- 	and terrain_uuid = uuidHash('terrains', terrain)
	-- 	and climate = climate;
	-- if not found then
	-- 	call createEnvironment(plane, terrain, climate);
	-- end if;
	insert into map_base_creature_environment values (
		uuidHash('base_creatures', creature),
		uuidHash('environments', concat(
			uuidHash('planes', plane), '|',
			uuidHash('terrains', terrain), '|',
			climate
		))
	);
	commit;
end;$$;
