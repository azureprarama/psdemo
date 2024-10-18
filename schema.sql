DECLARE @tenant1 nvarchar(30) = 'SynapseTest6'
EXECUTE [dbo].[createcustomerschema1]
	@tenant = @tenant1

CREATE TABLE @tenant1.Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);
