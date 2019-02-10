-- COMP9311 18s2 Assignment 1
-- Schema for the myPhotos.net photo-sharing site
--
-- Written by:
--    Name:  <<Haoze Li>>
--    Date:  02/09/2018
--
-- Conventions:
-- * all entity table names are plural
-- * most entities have an artifical primary key called "id"
-- * foreign keys are named after either:
--   * the relationship they represent
--   * the table being referenced

-- Domains (you may add more)

create domain URLValue as
	varchar(100) check (value like 'http://%');

create domain EmailValue as
	varchar(100) check (value like '%@%.%');

create domain GenderValue as
	varchar(6) check (value in ('male','female'));

create domain GroupModeValue as
	varchar(15) check (value in ('private','by-invitation','by-request'));

create domain ContactListTypeValue as
	varchar(10) check (value in ('friends','family'));

create domain NameValue as varchar(50);

create domain LongNameValue as varchar(100);

create domain SafetyLevelValue as
    text check (value in ('safe','moderate','restricted'));

create domain VisibilityValue as
    text check (value in ('private','friends','family','friends+family','public'));

-- Tables (you must add more)

create table People (
	id          serial,
	given_names  NameValue not null,
    family_name  NameValue,
    displayed_name   LongNameValue not null,
    email_address    EmailValue unique not null,
	primary key (id)
);

create table Users (
    id  integer references People(id),
	website URLValue unique,
    date_registered  date,
    gender  GenderValue,
    birthday    date,
    password  text not null,
    portrait    integer,
	primary key (id)
);

create table Groups (
	id  serial,
    title   text not null,
    mode    GroupModeValue not null,
    ownedBy integer not null references Users(id),
	primary key (id)
);

create table Users_member_Groups (
    "user"  integer,
    "group"   integer,
    primary key ("user","group"),
    foreign key ("user") references Users(id),
    foreign key ("group") references Groups(id)
);

create table Contact_lists (
	id  serial,
    type  ContactListTypeValue,
    title   text not null,
    ownedBy integer not null references Users(id),
	primary key (id)
);

create table People_member_Contact_lists (
    person  integer,
    contact_list integer,
    primary key (person,contact_list),
    foreign key (person) references People(id),
    foreign key (contact_list) references Contact_lists(id)
);

create table Discussions (
    id  serial,
    title   NameValue,
    primary key (id)
);

create table Group_has_Discussions (
    "group"   integer,
    discussion  integer,
    primary key ("group",discussion),
    foreign key ("group") references Groups(id),
    foreign key (discussion) references Discussions(id)
);

create table Photos (
	id  serial,
    date_taken   date,
    title   NameValue not null,
    date_uploaded    date not null,
    description   text,
    technical_details    text,
    safety_level SafetyLevelValue not null,
    visibility  VisibilityValue not null,
    file_size    integer not null check (file_size > 0),
    discussion  integer references Discussions(id),
    ownedBy integer not null references Users(id) deferrable,
	primary key (id)
);

alter table Users add foreign key (portrait) references Photos(id) deferrable;

create table Tags (
    id  serial,
    name  NameValue unique not null,
    freq    integer not null check (freq >= 0),
    primary key (id)
);

create table Photos_have_Tags_by_Users (
    tag integer references Tags(id),
    photo   integer references Photos(id),
    "user"  integer references Users(id),
    when_tagged timestamp not null,
    primary key (tag,photo,"user",when_tagged)
);

create table Users_rate_Photos (
    photo   integer,
    "user"  integer,
    when_rated    timestamp not null,
    rating  integer check (rating > 0 and rating < 6),
    primary key (photo,"user",when_rated),
    foreign key (photo) references Photos(id),
    foreign key ("user") references Users(id)
);

create table Collections (
    id  serial,
    title NameValue not null,
    description   text,
    key   integer not null references Photos(id),
    primary key (id)
);

create table Photos_in_Collections (
    collection    integer references Collections(id),
    photo   integer references Photos(id),
    "order"   integer not null check ("order" > 0),
    primary key (collection,photo)
);

create table User_Collections (
    id  integer references Collections(id),
    ownedBy integer not null references Users(id),
    primary key (id)
);

create table Group_Collections (
    id integer references Collections(id),
    ownedBy integer not null references Groups(id),
    primary key (id)
);

create table Comments (
    id  serial,
    author  integer not null references Users(id),
    containedBy    integer not null references Discussions(id),
    when_posted    timestamp not null,
    content text not null,
    replyTo integer,
    primary key (id)
);

alter table Comments add foreign key (replyTo) references Comments(id);
