USE [CATALOGOS]
GO

/****** Object:  StoredProcedure [dbo].[sp_BlockUser]    Script Date: 06/10/2017 11:27:43 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_BlockUser]
(
	@id_empleados INT = 0 --Employee to be blocked
	, @Motive VARCHAR(MAX) = '' --Reason why the employee will be blocked
	, @profile INT = 0 --Profile from user trying to block
	, @user VARCHAR(20) = '' --User trying to block
)
AS
BEGIN
	DECLARE 
	@user_id INT = 0,
	@msg VARCHAR(300) = '', 
	@isBlocked TINYINT = 0
	BEGIN TRY
		BEGIN TRAN
			--Gets the user id (The one that is going to block)
			SET @user_id = (SELECT id_empleados 
							FROM CATALOGOS.dbo.tc_empleados 
							WHERE usuario = @user)
			--Determines if the user is already blocked
			SET @isBlocked = (SELECT COUNT(*) 
								FROM CATALOGOS.dbo.tc_blockedUsers 
								WHERE empleados_id = @id_empleados)
			IF @isBlocked = 0
			BEGIN 
				IF @profile > 0 
				BEGIN
					INSERT INTO  CATALOGOS.dbo.tc_blockedUsers (
						empleados_id
						, motivo
						, blocked_by
					) VALUES (
						@id_empleados
						, @Motive
						, @user_id 
					)
				END
				ELSE BEGIN
					SET @msg = 'Permiso denegado para el usuario ' + @user
					RAISERROR(@msg, 16, 1)
					RETURN
				END
			END
			ELSE BEGIN
				SET @msg = 'El usuario ya ha sido bloqueado'
				RAISERROR(@msg, 16, 1)
				RETURN
			END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		IF(LEN(@msg) = 0)
		BEGIN
			SET @msg = (SELECT SUBSTRING(ERROR_MESSAGE(), 1, 300))
		END
		RAISERROR(@msg, 16, 1)
	END CATCH
END
GO


