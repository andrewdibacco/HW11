use master
GO

if db_id('DBObjects') is not null
	drop database DBObjects

create database DBObjects
GO

use DBObjects
GO

if object_id('dbo.Employees') is not null
	drop table dbo.Employees

create table Employees(
	Id nvarchar(40) primary key not null default newid(),
	BadgeNum int unique not null,
	SSN int not null default Round(rand()* 899999999 + 100000000,0),
	Title varchar(20) null,
	DateHired datetime2 not null default getdate()
)
GO

create trigger UpdateTitle on Employees after insert as

	declare @BadegNum int = (select BadgeNum from inserted)
	declare @Id nvarchar(40) = (select Id from inserted)
	declare @Title varchar(20);
	
	
	if @BadegNum < 300
		set @Title = 'Clerk'
	if @BadegNum >= 300 and @BadegNum < 700
		set @Title = 'Office Employee'
	if @BadegNum >= 700 and @BadegNum < 900
		set @Title = 'Manager'
	if @BadegNum >= 900
		set @Title = 'Director'

	update Employees
	set Title = @Title
	where Id = @Id
GO

declare @count int = 1;
set nocount on
while @count <=25
begin

	declare @RndBadgeNum int = round(rand() * 1000,0)

	while (select count(BadgeNum) from Employees where BadgeNum = @RndBadgeNum) > 0 
		set @RndBadgeNum = round(rand() * 1000,0)
		
	insert into Employees(BadgeNum)
		values(@RndBadgeNum)

	set @count +=1
end

select * from Employees
GO

declare EmployeesCursor Cursor fast_forward for
	select * from Employees
GO

Open EmployeesCursor
GO

declare @Id nvarchar(40);
declare @BadgeNum int;
declare @SSN int;
declare @Title varchar(20);
declare @DateHired datetime2;

fetch next from EmployeesCursor into @Id, @BadgeNum, @SSN, @Title, @DateHired

while @@FETCH_STATUS = 0
begin
	print('ID: '+ @ID + '; BadgeNum: ' + cast(@BadgeNum as varchar(5)) + '; SSN: ' + cast(@SSN as varchar(10)) + '; Title: ' + @Title + '; DateHired: ' + cast(@DateHired as varchar(50)) + ';')
	fetch next from EmployeesCursor into @Id, @BadgeNum, @SSN, @Title, @DateHired
end

close EmployeesCursor
deallocate EmployeesCursor
GO

if object_id('dbo.vw_employees') is not null
	drop view dbo.vw_employees
GO

create view vw_employees as select Id, BadgeNum, Title from Employees
Go

select * from vw_employees
GO