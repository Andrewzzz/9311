create domain CustNumType as
	char(7) check (value ~ '[0-9]{7}');

create table Branch (
	branchName  text,
	address     text,
	assets      integer,
	primary key (branchName)
);

create table Account (
	-- 'A-101', 'B-502' ... not 'XXX-3' 'hello' 'xxA-101!!'
	accountNo   text check (accountNo ~ '^[A-Z]-[0-9]{3}$'),
	branchName  text,
	balance     integer check (balance >= 0),
--	Can you constrain that all branches have > $100000 in 
--	constraint  bigbalance check (sum(balance) > 100000), ???
	primary key (accountNo),
	foreign key (branchName) references Branch(branchName)
);

create table Customer (
--	customerNo  char(7) check (customerNo ~ '[0-9]{7}'),
--	customerNo  integer check (customerNo::char(7) ~ '[0-9]{7}'), ???
--	customerNo  integer check (customerNo between 1000000 and 9999999),
	customerNo  CustNumType,
	name        text,
	address     text unique not null,
--	homeBranch  foreign key references Branch(branchName), ???
--	homeBranch  text foreign key references Branch(branchName),
	homeBranch  text,
	primary key (customerNo),
	foreign key (homeBranch) references Branch(branchName)
);

create table HeldBy (
	account     text,
	customer    CustNumType,
	primary key (account,customer),
	foreign key (account) references Account(accountNo),
	foreign key (customer) references Customer(customerNo)
);

create table t (
	x integer,
	y integer,
	constraint xBiggerThanY check (x > y)
);
