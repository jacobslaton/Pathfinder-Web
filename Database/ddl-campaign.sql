drop procedure if exists addXpLedgerEntry(text, int, int, int, int, int, varchar(100));
drop procedure if exists addXpLedgerEntry(text, int, int, int, int, varchar(100));
drop procedure if exists addXpLedgerEntry(text, int, int);
drop table if exists xp_ledger;
drop procedure if exists createCharacter;
drop table if exists characters;
drop procedure if exists createPlayer;
drop table if exists players;

create table players (
	uuid                uuid not null,
	name                varchar(100) not null,
	primary key (uuid),
	check (not name = ''),
	check (uuid = uuidHash('players', name)),
	unique (uuid, name)
);

create procedure createPlayer(name text)
language plpgsql as $$
begin
	insert into players (uuid, name) values (uuidHash('players', name), name);
	commit;
end;$$;

create table characters (
	uuid                uuid not null,
	name                varchar(100) not null,
	player_uuid         uuid,
	level               int default 1,
	experience          int default 0,
	lifetime_copper     int default 0,
	primary key (uuid),
	check (not name = ''),
	foreign key (player_uuid) references players (uuid),
	check (level > 0),
	check (experience >= 0),
	check (lifetime_copper >= 0),
	check (uuid = uuidHash('characters', name))
);

create procedure createCharacter(
	name                text,
	player_name         text
)
language plpgsql as $$
begin
	insert into characters (uuid, name, player_uuid) values (
		uuidHash('characters', name),
		name,
		uuidHash('players', player_name)
	);
	commit;
end;$$;

create table xp_ledger (
	id                  serial not null,
	character_uuid      uuid not null,
	xp_gained           int not null,
	copper_gained       int,
	cr_count            int,
	cr_value            int,
	split               int,
	notes               varchar(100) not null default '',
	primary key (id),
	foreign key (character_uuid) references characters (uuid),
	check (xp_gained > 0),
	check (copper_gained > 0),
	check (cr_count > 0),
	check (cr_value > -5),
	check (split > 0),
	check (
		(cr_count is null and cr_value is null) or
		(cr_count is not null and cr_value is not null)
	),
	check (copper_gained is not null or (cr_count is not null and cr_value is not null))
);

create procedure addXpLedgerEntry(
	name                text,
	xp_gained           int,
	copper_gained       int
)
language plpgsql as $$
begin
	insert into xp_ledger (character_uuid, xp_gained, copper_gained) values (
		uuidHash('characters', name),
		xp_gained,
		copper_gained
	);
	commit;
end;$$;
create procedure addXpLedgerEntry(
	name                text,
	xp_gained           int,
	cr_count            int,
	cr_value            int,
	split               int,
	notes               varchar(100)
)
language plpgsql as $$
begin
	insert into xp_ledger (character_uuid, xp_gained, cr_count, cr_value, split, notes) values (
		uuidHash('characters', name),
		xp_gained,
		cr_count,
		cr_value,
		split,
		notes
	);
	commit;
end;$$;
create procedure addXpLedgerEntry(
	name                text,
	xp_gained           int,
	copper_gained       int,
	cr_count            int,
	cr_value            int,
	split               int,
	notes               varchar(100)
)
language plpgsql as $$
begin
	insert into xp_ledger (character_uuid, xp_gained, copper_gained, cr_count, cr_value, split, notes) values (
		uuidHash('characters', name),
		xp_gained,
		copper_gained,
		cr_count,
		cr_value,
		split,
		notes
	);
	commit;
end;$$;
