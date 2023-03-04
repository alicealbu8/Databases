create database Zoo
go 
use Zoo
go

create table Animal(
AId int  primary key identity, 
Type varchar(50), 
Weight int)

create table Zookeeper(
ZId int  primary key identity, 
Name varchar(50), 
Surname varchar(50), 
Age int)

create table Cage(
Cid int primary key identity,
Noofcages int,
Noofanimals int,
Zid int foreign key references Zookeeper(ZId),
AId int foreign key references Animal(AId))

create table Visitor(
Vid int primary key identity,
Name varchar(10),
Age int)

create table AnimalVisitor(
Vid int foreign key references Visitor(Vid),
Aid int foreign key references Animal(Aid),
constraint pk_AnimalVisitor primary key(Vid, Aid))

create table Shop(
Sid int primary key identity,
floor_ int,
name varchar(10)
)
create table ShopVisitor(
Vid int foreign key references Visitor(Vid),
Sid int foreign key references Shop(Sid),
constraint pk_ShopVisitor primary key(Vid, Sid)
)

create table Souvenir(
Suvid int primary key,
price float
)

create table SouvenirShops(
souvshopid int,
Sid int foreign key references Shop(Sid),
Suvid int foreign key references Souvenir(Suvid)
)

--INSERT

insert into Souvenir values(23)
insert into Souvenir values(5, 9)
insert into Animal values( 'mammal', 56)
insert into Visitor values('Tudor', 8)
insert into Zookeeper values('Popescu', 'Ioan', 45, 3)
insert into Zookeeper values('Elena', 'Bogdan', 50)

select * from Animal
select * from Zookeeper
select * from Souvenir

update Zookeeper

set Age = 60
where Name = 'Popescu'

select * from Zookeeper

alter table Animal
add Name varchar(30)

select * from Animal

alter table Animal
drop column Name

alter table Animal
add Name varchar(30) default 'No name'

alter table Zookeeper
add constraint df_18 default 18 
for Age

alter table Zookeeper
drop constraint df_18

create table Address(
AdrId int not null primary key,
Street varchar(30),
Number int 
)

drop table Address

create table Duties(
DId int not null primary key,
Zid int constraint fk_Duties_Zookeeper foreign key (Zid) references Zookeeper(Zid)
)

drop table Duties

alter table Cage 
add constraint fk_Cage_Visitor foreign key (Vid) references Visitor(Vid) --todo

alter table Cage
drop constraint fk_Cage_Visitor

create table Version(
noVersion int primary key default 0
)

create procedure do_Procedure_1
as
begin
	alter table Animal
	add Breed varchar(30)
	select * from Animal
end

create procedure do_Procedure_2
as 
begin
	alter table Zookeeper
	add constraint df_18 default 18 
	for Age
	select * from Zookeeper
end


create procedure do_Procedure_3
as
begin
	create table Duties(
		DId int not null primary key,
		difficuly varchar(30)
	)
	select * from Duties
end

alter  table Cage
add Vid int

create procedure do_Procedure_4 -- FIX THIS
as
begin
	alter table Cage
	add constraint fk_Cage_Visitor
	foreign key(Vid) 
	references Visitor(Vid)
	select * from Cage
end
select * from Visitor
select * from Cage
drop procedure do_Procedure_4
create procedure undo_Procedure_1
as
begin 
	alter Table Animal
	drop column Breed
	select * from Animal
end

create procedure undo_Procedure_2
as
begin
	alter table Zookeeper
	drop constraint df_18
	select * from Zookeeper
end


create procedure undo_Procedure_3
as
begin 
	drop table Duties
end

create procedure undo_Procedure_4
as 
begin
	alter table Cage
	drop constraint fk_Cage_Visitor
end
drop procedure undo_Procedure_4

insert into Version values(0)
update Version
set noVersion = 0
select * from Version

select * from Cage
create procedure Test 
@version int
as
begin
	if @version > 4
	begin
	print 'Version does not exist'
	end
	else 
	begin
	declare @current_version int
	select @current_version = noVersion from Version
	print @current_version -- for testing
	if @current_version = @version 
				print 'current version is the wanted version'
		while @current_version!=@version
		begin
			if @current_version < @version 
			begin
			print 'current version is smaller'
				if @current_version=0
				begin
					exec do_Procedure_1
				end
				if @current_version=1
				begin
					exec do_Procedure_2
				end
				if @current_version=2
				begin
					exec do_Procedure_3
				end
				if @current_version=3
				begin
					exec do_Procedure_4
				end
			set @current_version = @current_version + 1
			update Version
			set noVersion=@current_version

			end
			if @current_version > @version 
			begin
				if @current_version=1
					exec undo_Procedure_1
				if @current_version=2
					exec undo_Procedure_2
				if @current_version=3
					exec undo_Procedure_3
				if @current_version=4
					exec undo_Procedure_4

			set @current_version = @current_version - 1
			end

			update Version
			set noVersion=@current_version
	
		end
	end
end

drop procedure Test

--check an int
create function checkInt(@n int)
returns int as
begin
	declare @no int
	if @n>18 and @n<=60
		set @no=1
	else 
		set @no=0
	return @no
end 
go

create function checkVarchar(@v varchar(50))
returns bit as
begin
	declare @b bit
	if @v like '[a-z]'
		set @b=1
	else 
		set @b=0
	return @b
end
go

create procedure addZookeeper(@n varchar(50), @s varchar(50), @a int, @y int)
as
begin
--validate the parameters
if dbo.checkInt(@a)=1 and dbo.checkVarchar(@n)=1
	begin
	insert into Zookeeper(Name, Surname, Age, yearsExperience) values ( @n, @s, @a, @y)
	print 'values added'
	select * from Zookeeper
	end
	else
	begin
		print 'the parameters are not correct'
		select * from Zookeeper
	end
end
go
select *from Animal

create procedure addCage(@noc int, @noa int)
as 
begin
if dbo.checkInt(@noa)=1
	begin
	declare @zId int 
	declare @aId int
	--SET @val=(SELECT Top 1 gid FROM Groups)
	set @zId = (select top 1 ZId from Zookeeper)
	set @aId = (select top 1 AId from Animal)
	insert into Cage(Noofcages, Noofanimals, Zid, AId) values (@noc, @noa, @zId, @aId)
	print 'values added'
	select * from Cage

	end
	else
	begin
		print 'the parameters are not correct'
		select * from Cage
	end
end

drop procedure [addCage]
drop procedure [addZookeeper]

--show corresponding to each zookeeper the cage with the animals and animalvisitors
create view viewAll
as 

select z.ZId, c.Noofanimals, a.Type, av.Vid
from Zookeeper z inner join Cage c on z.ZId = c.Zid
inner join Animal a on a.Aid = c.AId
inner join AnimalVisitor av on av.Aid = a.AId
go

select * from viewAll

create table Logs(
tid int primary key identity,
TriggerDate date,
TriggerType varchar(30),
NameAffectedTavle varchar(30),
NoADMRows int
)
drop table Logs

select * from Logs

--INSERT
--create a copy for the table
create table ZookeeperT(
ZId int  primary key identity, 
Name varchar(50), 
Surname varchar(50), 
Age int,
yearsExperience int
)
create trigger addZookeeperwithTrigger on Zookeeper for
insert as
begin
insert into ZookeeperT(Name, Surname, Age, yearsExperience)
select Name, Surname, Age, yearsExperience 
from inserted
--insert into Logs
insert into Logs(TriggerDate, TriggerType, NameAffectedTavle, NoADMRows) values(GETDATE(), 'INSERT', 'Zookeeper', @@ROWCOUNT )

end
go

drop trigger [addZookeeperwithTrigger]

select * from Zookeeper
select * from ZookeeperT
insert into Zookeeper values ('Name', 'Surname', 20, 2)
select * from Zookeeper
select * from ZookeeperT

select * from Logs

create trigger deleteZookeeper on Zookeeper for
delete 
as 
begin
delete from ZookeeperT where Name = 'Name'
select  Name, Surname, Age, yearsExperience 
from deleted
insert into Logs(TriggerDate, TriggerType, NameAffectedTavle, NoADMRows) values(GETDATE(), 'DELETE', 'Zookeeper', @@ROWCOUNT )
end 
go

select * from Zookeeper
select * from ZookeeperT
delete from Zookeeper where Name = 'Name'
select * from Zookeeper
select * from ZookeeperT

create trigger updateZookeeper on Zookeeper for
update
as
begin
update ZookeeperT
set Name = 'UpdatedName' where Name = 'Name'
select Name, Surname, Age, yearsExperience
---????
insert into Logs(TriggerDate, TriggerType, NameAffectedTavle, NoADMRows) values(GETDATE(), 'DELETE', 'Zookeeper', @@ROWCOUNT )

end 
go

drop trigger [updateZookeeper]

select * from Zookeeper
select * from ZookeeperT
update Zookeeper
set Name = 'UpdatedName' where Name = 'Name'
select * from Zookeeper
select * from ZookeeperT

------------------------------------------------------
select * from Animal
order by AId

select * from sys.indexes

select name from sys.indexes

select * from Animal
order by Weight
--only the clustered index is used

if exists (select name from sys.indexes where name = N'N_idx_Animal_Weight')
	drop index N_idx_Animal_Weight on Animal

create nonclustered index N_idx_Animal_Weight on Animal(Weight)

--nonClustered index scan, key lookup
select * from Animal
order by Weight

--with where
--nonclustered index seek
select *from Animal 
where Weight > 20
order by Weight

--clustered index seek
select *from Animal where Aid = 2 

--with inner join 
--clustered index scan and clustered index seek
select *from Animal a inner join Cage c on a.AId = c.Cid where Weight > 20


if exists (select name from sys.indexes where name = N'N_idx_Cage_Noofcages')
	drop index N_idx_Animal_Weight on Animal

create nonclustered index N_idx_Cage_Noofcages on Cage(Noofcages)

--nonClustered index scan, key lookup
select * from Cage 
order by Noofcages

--with where
--nonclustered index seek
select * from Cage
where Noofcages > 10
order by Noofcages

--clustered index seek
select * from Cage order by Cid

update Cage
set Cid = 0, Noofcages = 1
where Noofanimals > Noofcages

--with inner join 
--clustered index scan and clustered index seek
select * from Cage c inner join Zookeeper z on c.Zid = z.ZId where Noofcages > 3



