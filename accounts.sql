CREATE TABLE accounts (
    steamid varchar(20) primary key,
    privilege smallint default 0,
    playtime int default 0,
    cash int default 0,
    score int default 0,
    wins int default 0,
    deaths int default 0,
    joindate int default CURRENT_TIMESTAMP(),
    lastseen int default CURRENT_TIMESTAMP(),
    join_ip varchar(16),
    lastseen_ip varchar(16),
	hat int default 0,
    outfit int default 1
);
CREATE TABLE kicks (
    targetid varchar(20),
    adminid varchar(20),
    reason varchar(128)
);
CREATE TABLE bans (
    targetid varchar(20),
    adminid varchar(20),
    reason varchar(128),
    lifted boolean default false
);
CREATE TABLE unbans (
    targetid varchar(20),
    adminid varchar(20),
    reason varchar(128)
);
CREATE TABLE warns (
    targetid varchar(20),
    adminid varchar(20),
    reason varchar(128)
)
;