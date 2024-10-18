DECLARE @tenant1 nvarchar(30) = 'SynapseTest6'
EXECUTE [dbo].[createcustomerschema1]
	@tenant = @tenant1
