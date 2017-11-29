USE CATALOGOS

BEGIN TRAN
	BEGIN TRY
		EXEC CATALOGOS.dbo.sp_BlockUser 334, 'Requerimiento Gonzalo Vargas', 11, 'eduahc'
		EXEC CATALOGOS.dbo.sp_BlockUser 969, 'Requerimiento Gonzalo Vargas', 11, 'eduahc'
		EXEC CATALOGOS.dbo.sp_BlockUser 796, 'Requerimiento Gonzalo Vargas', 11, 'eduahc'


	IF @@TRANCOUNT> 0
		Commit tran

 END TRY
BEGIN CATCH
	IF @@TRANCOUNT> 0
		BEGIN
			rollback tran
			SELECT   
        ERROR_NUMBER() AS ErrorNumber  
       ,ERROR_MESSAGE() AS ErrorMessage;  
		 END
END CATCH