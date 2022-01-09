-- This should work with other flavors of sql, but not postgresql.
-- Make sure to create and connect to a bestiary database before running this script.

--create database bestiary;
--use bestiary;

create extension if not exists "uuid-ossp";


create type alignment as enum (
	'LG', 'NG', 'CG',
	'LN',  'N', 'CN',
	'LE', 'NE', 'CE',
	'Unaligned'
);
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
	return uuid_generate_v5((select namespace_uuid from uuid_namespaces where namespace_name = namespace), string);
end;
$hash$ language plpgsql;

create table uuid_namespaces (
	namespace_uuid      uuid not null,
	namespace_name      varchar(256) not null,
	primary key (namespace_uuid)
);


-------------
-- sources --
-------------

create table sources (
	source_uuid         uuid not null,
	source_title        varchar(256) not null,
	isbn                char(17),
	is_official         boolean,
	primary key (source_uuid)
);

create function createSource(sourceTitle text, isbn text, isOfficial boolean)
returns void as $$
begin
	insert into sources (source_uuid, isbn, source_title, is_official) values (
		uuidHash('sources', sourceTitle), isbn, sourceTitle, isOfficial
	);
end;
$$ language plpgsql;


--------------------
-- base_creatures --
--------------------

create table base_creatures (
	creature_uuid       uuid not null,
	creature_name       varchar(256) not null,
	cr                  smallint not null,
	source_uuid         uuid not null,
	page                smallint,
	alignment           alignment not null,
	creature_size       creature_size not null,
	creature_type       creature_type not null,
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
	variant_parent      uuid,
	alternate_name      varchar(256),
	primary key (creature_uuid),
	foreign key (source_uuid) references sources (source_uuid),
	foreign key (variant_parent) references base_creatures (creature_uuid)
);


--------------
-- subtypes --
--------------

create table subtypes (
	subtype_uuid      uuid not null,
	subtype_name      varchar(256) not null,
	source_uuid       uuid not null,
	primary key (subtype_uuid),
	foreign key (source_uuid) references sources (source_uuid)
);

create function createSubtype(sourceTitle text, subtype text)
returns void as $$
begin
	insert into subtypes values (
		uuid_generate_v5((select namespace_uuid from uuid_namespaces where namespace_name = 'subtypes'), subtype),
		subtype,
		(select source_uuid from sources where source_title = sourceTitle)
	);
end;
$$ language plpgsql;

create table map_base_creature_subtype (
	creature_uuid     uuid not null,
	subtype_uuid      uuid not null,
	foreign key (creature_uuid) references base_creatures (creature_uuid),
	foreign key (subtype_uuid) references subtypes (subtype_uuid),
	unique (creature_uuid, subtype_uuid)
);

create function addSubtype(creature text, subtype text)
returns void as $$
begin
	insert into map_base_creature_subtype values (
		uuid_generate_v5((select namespace_uuid from uuid_namespaces where namespace_name = 'base_creatures'), creature),
		uuid_generate_v5((select namespace_uuid from uuid_namespaces where namespace_name = 'subtypes'), subtype)
	);
end;
$$ language plpgsql;
