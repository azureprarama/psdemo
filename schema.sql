DECLARE @tenant1 nvarchar(30) = 'SynapseTest7'
EXECUTE [dbo].[createcustomerschema1]
	@tenant = @tenant1
