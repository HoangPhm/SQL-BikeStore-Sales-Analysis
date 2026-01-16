/*
string function
*/

create table EmployeeErrors(
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)

Insert into EmployeeErrors Values 
('1001  ', 'Jimbo', 'Halbert')
,('  1002', 'Pamela', 'Beasely')
,('1005', 'TOby', 'Flenderson - Fired')



--using TRIM, LTRIM, RTRIM
--1
select EmployeeID, trim(EmployeeID) as IDtrim
from EmployeeErrors
--2
select EmployeeID, ltrim(EmployeeID) as IDtrim
from EmployeeErrors
--3
select EmployeeID, rtrim(EmployeeID) as IDtrim
from EmployeeErrors

-- Replace
select LastName, replace(LastName, '- Fired', '') LastNameFixed 
from EmployeeErrors

-- Substring
select substring(er.FirstName,1,3) err, substring(de.firstname,1,3) dem
from EmployeeErrors er
join employeeDemographics de
	on substring(er.FirstName,1,3) = substring(de.firstname,1,3)

-- upper & lower
select FirstName, lower(FirstName)
from EmployeeErrors
select FirstName, upper(FirstName)
from EmployeeErrors
