USE [SVA]
GO
/****** Object:  StoredProcedure [dbo].[sp_getInfoSVA]    Script Date: 23/08/2017 10:24:36 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_getInfoSVA](
	@codeSVA  varchar(20) = ''
)
AS
BEGIN
	DECLARE
		@message varchar(1500)= ''

	BEGIN TRY
		; WITH cteDatos AS(
			SELECT
				REPLACE(tgar.sNOMBRE, '*', ' ') as sNOMBRE
				, tgar.nCLIENTE
				, tgar.nCONTADO
				, CASE tgar.nContado 
					WHEN 0 THEN  'Apartado' 
					WHEN 1 THEN 'VENDIDO' 
					WHEN 2 THEN 'En Venta' 
					WHEN 10 THEN 'Bloqueo por Reestructura' 
				END AS [contado] 
				, CASE tgar.nStatus  
					WHEN 0 THEN 'OK' 
					WHEN 1 THEN 'Fundir' 
					WHEN 2 THEN 'Inservible'
					WHEN 3 THEN 'Incobrable'
					WHEN 5 THEN 'Bloqueo por Soporte' 
					WHEN 4 THEN 'Vendido' 
					WHEN 9 THEN 'Reparar' 
				END AS [status] 
				, CASE  
					WHEN SUBSTRING(RTRIM(LTRIM(REPLACE(REPLACE(tgar.sDESCGARANTIA, char(13), ''), char(10), ''))), 1,2) = 'tv' THEN 1 ELSE 0 END AS [valTV] 
				, UPPER(RTRIM(LTRIM(tgar.stipogarantia))) AS [stipogarantia] 
				, tgar.sdescgarantia 
				,CASE 
					WHEN LEFT(tgar.sdescgarantia, 3) = 'LAP' OR LEFT(tgar.sdescgarantia, 6) = 'TABLET' OR LEFT(tgar.sdescgarantia, 2) = 'PC' THEN 1 ELSE 0 END AS [valBackToSchool] 
				, tgar.nprecioventagarantia 
				, tgar.sCODIGOBARRAS 
				, LTRIM(RTRIM(tgar.slugar)) AS [LUGAR] 
				, tgar.nimportegarantia 
				, tgar.nfechamodificacion 
				, tgar.nfechasalidaventa 
				, tgar.nmontoapartado 
				, tgar.nImporteGarantia AS [minven] 
				, DATEDIFF(DAY, CONVERT(smalldatetime, CONVERT(varchar(8), tgar.nfechasalidaventa)), CONVERT(smalldatetime, GETDATE())) AS [dias_vit] 
				, tgar.FOLIO_CTC 
				, ISNULL(CAST(((tgar.nPRECIOVENTAGARANTIA-tgar.nIMPORTEGARANTIA)/NULLIF(tgar.nPRECIOVENTAGARANTIA, 0)) AS decimal(18,3)), 0) AS [percentMargin] 
				, tgar.nIMPORTEGARANTIA AS [cost] 
				, tgar.nPRECIOVENTAGARANTIA AS [priceSale] 
				, CONVERT(varchar, GETDATE(), 112) AS [dateAct] 
				, stInv.sinv_name + ' » ' + stInv.sinv_description AS [statusProcess] 
				, inv.cantidad AS [gramos] 
				, inv.cantidad
				, CASE 
					WHEN UPPER(LEFT(inv.descripcion, 6)) = 'PLATA' AND inv.descripcion LIKE '%920%' THEN 'PLATA 0.920'
					WHEN UPPER(LEFT(inv.descripcion, 6)) = 'PLATA' AND inv.descripcion LIKE '%720%' THEN 'PLATA 0.720'
					ELSE LEFT(inv.descripcion, 6) END AS [typeMetal]
				, inv.cod_bar_rack AS [ubication] 
				, CASE 
					WHEN UPPER(INVENTARIO.dbo.fnStripSpaces(tgar.stipogarantia)) = 'METAL' THEN 'METAL'
					WHEN UPPER(INVENTARIO.dbo.fnStripSpaces(tgar.stipogarantia)) = 'RELOJ' THEN 'RELOJ'
					ELSE LEFT(UPPER(INVENTARIO.dbo.fnStripSpaces(tgar.sDESCGARANTIA)), CHARINDEX(' ,', UPPER(INVENTARIO.dbo.fnStripSpaces(tgar.sDESCGARANTIA)))) END AS [family]
				, racks.cve_suc AS [departament]
				, ISNULL(tgar.reestruc, 0) AS [reestructura]
			FROM SVA.dbo.T_GARANTIA tgar 
				INNER JOIN ISILOANSWEB.dbo.T_CRED ti ON (sCREDITO = ti.NUMERO) 
				LEFT JOIN INVENTARIO.dbo.tp_inventarios inv ON (tgar.sCODIGOBARRAS = inv.codigo_garantia) 
				LEFT JOIN INVENTARIO.dbo.tc_statusInventory stInv ON (inv.estatus = stInv.sinv_id) 
				LEFT JOIN ISILOANSWEB.dbo.T_GARANTIAS tg ON (CAST(tgar.sCREDITO AS int) = tg.NUMERO AND CAST(tgar.sNUMGARANTIA AS int) = tg.NUMGARAN)
				LEFT JOIN INVENTARIO.dbo.tc_racks racks ON (inv.cod_bar_rack = racks.codigo)
			WHERE sCODIGOBARRAS = @codeSVA
		)
		SELECT 
			a.*
			, ISNULL(b.tipo, '') AS [tipo]
			, ISNULL(b.precioMinGramo, 0) AS [precioMinGramo]
			, a.cantidad*ISNULL(b.precioMinGramo, 0) AS [precioMinimoVenta]
		INTO #getInfoSVA
		FROM cteDatos a
			LEFT JOIN SVA.dbo.t_precioMetal b ON (a.typeMetal = b.tipo)

		SELECT
			ROW_NUMBER() OVER (ORDER BY a.fechaMod, a.hora) as [row_id]
			, a.* 
			, CONVERT(date, CAST(a.fechaMod AS varchar)) AS [fecha] 
			, DATEDIFF(DAY, CONVERT(date, CONVERT(varchar, a.fechaMod))
			, CONVERT(date, GETDATE())) AS [dias] 
		INTO #getManagamentSVA
		FROM SVA.dbo.T_Precios_Hist a 
		WHERE a.sCODIGOBARRAS = @codeSVA

		DECLARE
			@priceSale decimal(18,0) = 0
			, @percentMargin decimal(12,2) = 0
			, @priceMinSale decimal(18,0) = 0
			, @percentDiscount decimal(12,2) = 0
			, @showcaseDays int = 0
			, @managementDays int = 0
			, @iManagement int = 0
			, @iLastManagement  int = 0
			, @typeWarranty varchar(100) = ''
			, @iPromotions int = 0
			, @priceSaleDiscountM decimal(18,0) = 0
			, @family varchar(30) = ''
			, @departament int = 0
			, @promotion tinyint = 0

		SELECT
			@priceSale = CAST(a.nPRECIOVENTAGARANTIA AS decimal(18,0))
			, @percentMargin = CAST(a.percentMargin AS decimal(12,2))
			, @priceMinSale = CAST(a.precioMinimoVenta AS decimal(18,0))
			, @showcaseDays = a.dias_vit
			, @iManagement = CASE 
								WHEN (SELECT COUNT(x.row_id) FROM #getManagamentSVA x WHERE x.Usuario <> 'BATCH') = 0 THEN a.dias_vit 
								ELSE (SELECT COUNT(x.row_id) FROM #getManagamentSVA x WHERE x.Usuario <> 'BATCH') END
			, @typeWarranty = UPPER(RTRIM(LTRIM(a.stipogarantia)))
			, @family = RTRIM(LTRIM(a.family))
			, @departament = a.departament
		FROM #getInfoSVA a

		IF EXISTS (SELECT TOP 1 dias FROM #getManagamentSVA ORDER BY row_id DESC)
			SET @iLastManagement = 	(SELECT TOP 1 dias FROM #getManagamentSVA ORDER BY row_id DESC)
		ELSE
			SET @iLastManagement = @showcaseDays

		IF @typeWarranty <> 'METAL'
			BEGIN
				SET @percentDiscount = ISNULL((SELECT TOP 1 ABS(a.wpd_discountRate)
												FROM SVA.dbo.td_discountPricesW a
												WHERE a.wpd_codeSVA = @codeSVA
													AND CONVERT(varchar, GETDATE(), 112) BETWEEN CONVERT(varchar, a.wpd_sDate, 112) AND CONVERT(varchar, a.wpd_eDate, 112)
													AND a.wpd_statusPromotion = 1
												ORDER BY a.wpd_id DESC), 0)
				IF @percentDiscount = 0
					BEGIN
						SET @percentDiscount  = 0.05

						SELECT
							@managementDays = ISNULL(a.dwtr_managementDays, 10)
						FROM SVA.dbo.tc_rotationTypeW_Departaments a
							INNER JOIN SVA.dbo.tc_warrantyTypes b ON (a.twarranty_id = b.twarranty_id)
						WHERE a.id_departamento = @departament						
							AND b.twarranty_name = @family
					END
				ELSE
					BEGIN
						SET @iLastManagement = -1
						SET @promotion = 1
					END

				SET @priceSale = CASE 
									WHEN (SELECT reestructura FROM #getInfoSVA) <> 0 THEN @priceSale
									WHEN @showcaseDays <= 10 THEN @priceSale
									WHEN @showcaseDays > 10 AND @iLastManagement >= @managementDays THEN @priceSale/1.05
									ELSE @priceSale END
			END
		ELSE
			BEGIN
				IF @percentMargin > 0
					BEGIN 
						SET @percentDiscount = ISNULL((SELECT TOP 1 ABS(a.wpd_discountRate)
														FROM SVA.dbo.td_discountPricesW a
														WHERE a.wpd_codeSVA = @codeSVA
															AND CONVERT(varchar, GETDATE(), 112) BETWEEN CONVERT(varchar, a.wpd_sDate, 112) AND CONVERT(varchar, a.wpd_eDate, 112)
															AND a.wpd_statusPromotion = 1
														ORDER BY a.wpd_id DESC), 0)

						IF @percentDiscount <> 0
							SET @promotion = 1
						ELSE 
							SET @percentDiscount = 0.05

						SET @priceSaleDiscountM = @priceSale - (@priceSale*@percentDiscount)

						IF @priceSaleDiscountM >= @priceMinSale
							SET @percentDiscount = @percentDiscount
						ELSE
							BEGIN
								SET @percentDiscount = 0

								IF @promotion = 1
									SET @promotion = 0
							END
					END 
				
				IF @percentMargin > 0 AND @percentMargin <= 0.10
					BEGIN
						SET @priceSaleDiscountM = @priceSale - (@priceSale*0.05)
						IF @priceSaleDiscountM >= @priceMinSale
							SET @percentDiscount = 0.05
						ELSE
							SET @percentDiscount = 0
					END

				IF @percentMargin > 0.10 AND @percentMargin <= 0.25
					BEGIN
						SET @priceSaleDiscountM = @priceSale - (@priceSale*0.10)
						IF @priceSaleDiscountM >= @priceMinSale
							SET @percentDiscount = 0.10
						ELSE
							SET @percentDiscount = 0.05
					END

				IF @percentMargin > 0.25 AND @percentMargin <= 0.30
					BEGIN
						SET @priceSaleDiscountM = @priceSale - (@priceSale*0.15)
						IF @priceSaleDiscountM >= @priceMinSale
							SET @percentDiscount = 0.15
						ELSE
							SET @percentDiscount = 0.10
					END

				IF @percentMargin > 0.30 AND @percentMargin <= 0.40
					BEGIN
						SET @priceSaleDiscountM = @priceSale - (@priceSale*0.20)
						IF @priceSaleDiscountM >= @priceMinSale
							SET @percentDiscount = 0.20
						ELSE
							SET @percentDiscount = 0.15
					END

				IF @percentMargin > 0.40
					BEGIN
						SET @priceSaleDiscountM = @priceSale - (@priceSale*0.25)
						IF @priceSaleDiscountM >= @priceMinSale
							SET @percentDiscount = 0.25
						ELSE
							SET @percentDiscount = 0.20
					END
			END

		-- Se valida que la garantía no esta habilitada la bandera de reestrutura
		IF (SELECT reestructura FROM #getInfoSVA) <> 0
			BEGIN
				SET @percentDiscount = 0
			END

		SELECT * 
		FROM #getInfoSVA

		SELECT *
		FROM #getManagamentSVA

		SELECT
			@priceSale AS [priceSale] --Precio de Venta
			, @percentDiscount AS [percentDiscount] --% de descuento a ofrecer
			, @iManagement AS [iManagement] --Gestiones por el Usuario
			, @iLastManagement AS [iLastManagament] --Días desde la última gestión
			, @managementDays AS [managementDays] --Días requerido para permitir la gestión
			, @showcaseDays AS [showcaseDays] --Días en Vitrina
			, @promotion AS [promotion] --Tiene promoción
			, @departament AS [departament] --Sucursal a la que pertenece la garantía
			, @family AS [family] --Familia

		DROP TABLE #getInfoSVA
		DROP TABLE #getManagamentSVA
	END TRY
	BEGIN CATCH
		SET @message = ' <p>' + ISNULL(CAST(ERROR_MESSAGE() AS varchar(500)), '')+ '</p><p>Proc.: ' + ISNULL(CAST(ERROR_PROCEDURE() AS varchar(500)), '') + '</p><p>Línea: ' + ISNULL(CAST(ERROR_LINE() AS varchar(100)), '') + '</p>'

		RAISERROR (@message, 16, 1)
	END CATCH
END