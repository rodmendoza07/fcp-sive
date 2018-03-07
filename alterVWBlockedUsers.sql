USE CATALOGOS
GO

BEGIN
	DECLARE
		@msg VARCHAR(300) =''

	ALTER TABLE CATALOGOS.dbo.tc_blockedUsers
	ADD blocked_status INT 
	ALTER TABLE CATALOGOS.dbo.tc_blockedUsers
	ADD CONSTRAINT blockedUsers_blkd_status DEFAULT 1 FOR blocked_status
	
	BEGIN TRY
		UPDATE CATALOGOS.dbo.tc_blockedUsers SET
			blocked_status = 1

		UPDATE CATALOGOS.dbo.tc_blockedUsers SET
			blocked_status = 0
		WHERE empleados_id = 422
	END TRY
	BEGIN CATCH
		SET @msg = (SELECT SUBSTRING(ERROR_MESSAGE(), 1, 300))
		RAISERROR(@msg, 16, 1)
	END CATCH
END