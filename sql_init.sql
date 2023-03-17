create table if not exists users(
    id          serial      	primary key,
    name        varchar(50) 	not null,
    email       varchar(50) 	not null unique,
    password    varchar(100)	not null,
    created_at  timestamp   	not null default now(),
    last_online timestamp   	not null default now()
);

create table if not exists todos(
	id			serial			primary key,
	user_id		int				not null,
	title		varchar(50)		not null,
	description	varchar(200)	,
	created_at	timestamp		not null default now(),
	done		bool			not null default false,
	finished_at	timestamp		,
	foreign key(user_id) references users(id) on delete cascade
);
