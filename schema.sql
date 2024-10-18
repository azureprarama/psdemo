 EXECUTE [dbo].[createcustomerschema1]
	@tenant = 'SynapseTest6'

CREATE TABLE @tenant.Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);
