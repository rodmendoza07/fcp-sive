USE SVA
GO

ALTER PROCEDURE [dbo].[sp_changeprice]
(
	@price DECIMAL(18,2) = 0
	, @last_price DECIMAL(18,2) = 0
	, @profile INT = 0
	, @user VARCHAR(20) = ''
	, @codesva VARCHAR(30) = ''
	, @branchoffice INT = 0
	, @days INT = 0
	, @saleexit VARCHAR(50) = ''
	, @saleprice DECIMAL(18,2) = 0
	, @descriptionW VARCHAR(MAX) = ''
	, @locationW VARCHAR(50) = ''
	, @pageref VARCHAR(50) = ''
	, @type VARCHAR(50) = ''
	, @ipaddress VARCHAR(20) = ''
)
AS
BEGIN
	DECLARE
		@msg VARCHAR(300) = '' 
		, @valprice DECIMAL(18,2) = 0
		, @warrantyimport DECIMAL(18,2) = 0

	BEGIN TRY
		BEGIN TRAN
				IF @last_price <= @price BEGIN

					IF @profile <> 13 AND @profile <> 16 BEGIN
						UPDATE SVA.dbo.T_GARANTIA SET
							nPRECIOVENTAGARANTIA = @price
							, sModifUsuario = @user
							, nFechaModificacion = CONVERT(varchar, GETDATE(), 112)
						WHERE sCODIGOBARRAS = @codesva
							AND sTIPOGARANTIA <> 'METAL'
							AND reestruc IS NULL 
							AND (nSUCURSAL = @branchoffice OR nSucVitrina = @branchoffice)

						SELECT 
							@valprice = nPRECIOVENTAGARANTIA
						FROM SVA.dbo.T_GARANTIA
						WHERE sCODIGOBARRAS = @codesva

						IF @valprice = @price BEGIN
							SELECT 'OK' AS respuesta
						END
						ELSE BEGIN
							SET @msg = 'El precio mínimo de venta debe ser: $' + CONVERT(varchar,@last_price)
							RAISERROR(@msg, 16, 1)
							RETURN
						END

					END
					ELSE BEGIN 
						UPDATE SVA.dbo.T_GARANTIA SET
								nPRECIOVENTAGARANTIA = @price
								, sModifUsuario = @user
								, nFechaModificacion = CONVERT(varchar, GETDATE(), 112)
						WHERE sCODIGOBARRAS = @codesva

						SELECT 'OK' AS respuesta
					END
					
					INSERT INTO SVA.dbo.T_Precios_Hist (
						scodigobarras
						, precio
						, Usuario
						, fechaMod
						, hora
						, ip
					) VALUES (
						@codesva
						, @price
						, @user
						, CONVERT(varchar, GETDATE(), 112)
						, CONVERT(varchar, GETDATE(), 108)
						, @ipaddress
					)

				END
				ELSE BEGIN
					IF (@profile = 16) OR (@profile = 13) BEGIN
						SELECT 
							@warrantyimport = nIMPORTEGARANTIA
						FROM SVA.dbo.T_GARANTIA
						WHERE sCODIGOBARRAS = @codesva

						IF @warrantyimport > @price BEGIN
							SELECT 'prg_validateBrokeness.asp?userLogin=' + @user + '&cveSuc=' + CONVERT(varchar,@branchoffice) + '&codeSVA=' + @codesva + '&limite=' + CONVERT(varchar,@last_price) + '&perfil=' + CONVERT(varchar,@profile) + '&dias_sva=' + CONVERT(varchar,@days) + '&monto=' + CONVERT(varchar,@price) + '&capital=' + CONVERT(varchar,@warrantyimport) + '&nFechaSalidaVenta=' + @saleexit + '&nPrecioVenta=' + CONVERT(varchar,@saleprice) + '&descriptionW=' + @descriptionW + '&locationW=' + @locationW + '&pageReferer=' + @pageref + '&tipo=' + @type AS respuesta
						END

						ELSE BEGIN
							UPDATE SVA.dbo.T_GARANTIA SET
								nPRECIOVENTAGARANTIA = @price
								, sModifUsuario = @user
								, nFechaModificacion = CONVERT(varchar, GETDATE(), 112)
							WHERE sCODIGOBARRAS = @codesva

							INSERT INTO SVA.dbo.T_Precios_Hist (
								scodigobarras
								, precio
								, Usuario
								, fechaMod
								, hora
								, ip
							) VALUES (
								@codesva
								, @price
								, @user
								, CONVERT(varchar, GETDATE(), 112)
								, CONVERT(varchar, GETDATE(), 108)
								, @ipaddress
							)

							SELECT 'OK' AS respuesta
						END
					END
					ELSE BEGIN
						SET @msg = 'El precio mínimo de venta debe ser: $' + CONVERT(varchar,@last_price)
						RAISERROR(@msg, 16, 1)
						RETURN
					END
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