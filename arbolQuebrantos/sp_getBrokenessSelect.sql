USE [SVA]
GO
/****** Object:  StoredProcedure [dbo].[sp_getBrokenessSelect]    Script Date: 29/11/2017 04:10:48 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_getBrokenessSelect] 
	(
		@parent			INT = 0
		, @opt			INT = 0
		, @userLogin	VARCHAR(30) = ''
		, @sucursal		INT = 0
		, @rowcount		INT = 0
		, @sva			VARCHAR(30) = ''
	)
	
AS
DECLARE
	@id_empleados		INT = 0
	, @cve_puesto		INT = 0
	, @cve_depto		INT = 0
	, @userAll			INT = 1
	, @noUSers			INT = 0
	, @userResp			VARCHAR(30) = ''
	, @userRespRepair	VARCHAR(30) = ''
	, @wlc_id			INT = 0
	, @wlc_resp			VARCHAR(30) = ''
	, @userStatus		INT = 0
BEGIN
	SELECT 
		@id_empleados = id_empleados
		, @cve_puesto = cve_puesto
		, @cve_depto = cve_depto 
	FROM CATALOGOS.dbo.tc_empleados
	WHERE usuario = @userLogin
		AND estatus = 1
	IF (@opt = 0) BEGIN
		SELECT 
			a.bknp_cId AS id
			, b.tbrokeness_name AS [name]
			, a.bknp_userDisplay
			, COUNT(a.bknp_cId) AS [contador]
		FROM SVA.dbo.tc_brokenessPermissions a
			INNER JOIN SVA.dbo.tc_brokenessTypes b ON (a.bknp_cId = b.tbrokeness_id)
		WHERE bknp_operation = @opt
			AND b.tbrokeness_parent = @parent
			AND a.bknp_userDisplay = @cve_puesto
			AND a.bknp_status = 1
			AND b.tbrokeness_status = 1
		GROUP BY 
			a.bknp_cId
			, b.tbrokeness_name
			, a.bknp_userDisplay
	END
	ELSE IF (@opt = 1 AND @rowcount <> 0) BEGIN
		
		SELECT 
			@wlc_id = wlc_id
			, @wlc_resp = wlc_respStageUser
		FROM INVENTARIO.dbo.tp_checkListWarranty 
		WHERE wlc_codeSVA = @sva
			AND sinv_id = 52

		IF @wlc_id = 0 BEGIN
			IF (@parent = 8 OR @parent = 9 OR @parent = 35 OR @parent = 37 OR @parent = 40 OR @parent = 48 OR @parent = 51 OR @parent = 52 OR @parent = 58 OR @parent = 59 OR @parent = 62 OR @parent = 63 OR @parent = 66
			OR @parent = 55) BEGIN
				SET @sucursal = 0
			END
			IF (@parent = 39 OR @parent = 47 OR @parent = 49 OR @parent = 50) BEGIN
				SELECT 
					@userResp = a.USU_AUTOR
				FROM ISILOANSWEB.dbo.T_GARANTIAS a
					INNER JOIN SVA.dbo.T_GARANTIA b ON (a.NUMERO = b.sCREDITO and a.NUMGARAN = b.sNUMGARANTIA)
				WHERE b.sCODIGOBARRAS = @sva
				SELECT 
					@noUSers = COUNT(*)
				FROM CATALOGOS.dbo.tc_empleados a
				WHERE estatus = 1
					AND usuario = @userResp
				IF @noUSers <> 0 BEGIN
					SELECT
						a.usuario AS id
						, a.nombre AS n
						, a.ap_paterno AS ap
						, a.ap_materno AS am
						, c.descripcion AS puesto
						, REPLICATE('0',5 - LEN(b.id_departamento)) + CAST(b.id_departamento AS varchar) AS id_depto
						, b.descripcion AS sucursal
					FROM CATALOGOS.dbo.tc_empleados a
						INNER JOIN CATALOGOS.dbo.tc_departamento b ON (a.cve_depto = b.id_departamento)
						INNER JOIN CATALOGOS.dbo.tc_puesto c ON (a.cve_puesto = c.id_puesto)
					WHERE a.estatus = 1
						AND a.usuario = @userResp
				END
				ELSE BEGIN
					SELECT 
						a.usuario AS id
						, a.nombre AS n
						, a.ap_paterno AS ap
						, a.ap_materno AS am
						, b.descripcion AS puesto
						, c.id_departamento AS id_depto
						, c.descripcion AS sucursal 
					FROM CATALOGOS.dbo.tc_empleados a
						INNER JOIN CATALOGOS.dbo.tc_puesto b ON (a.cve_puesto = b.id_puesto)
						INNER JOIN CATALOGOS.dbo.tc_departamento c ON (a.cve_depto = c.id_departamento)
					WHERE a.estatus =  1
						AND a.id_empleados = 72
				END
			END
			ELSE IF @parent = 61 BEGIN
				SELECT 
					@userRespRepair = CASE WHEN a.wlc_respRepairUser IS NULL OR (a.wlc_respRepairUser = '') THEN
						 '0'
					ELSE 
						a.wlc_respRepairUser 
					END
				FROM INVENTARIO.dbo.tp_checkListWarranty a
				WHERE a.wlc_codeSVA = @sva
				IF @userRespRepair <> '0' BEGIN
					SELECT 
						@noUSers = COUNT(*)
					FROM CATALOGOS.dbo.tc_empleados
					WHERE estatus =  1 AND usuario = @userRespRepair
					IF @noUSers <> 0 BEGIN
						SELECT 
							a.usuario AS id
							, a.nombre AS n
							, a.ap_paterno AS ap
							, a.ap_materno AS am
							, b.descripcion AS puesto
							, REPLICATE('0',5 - LEN(a.cve_depto)) + CAST(a.cve_depto AS varchar) AS id_depto
							, c.descripcion AS sucursal
						FROM CATALOGOS.dbo.tc_empleados a
							INNER JOIN CATALOGOS.dbo.tc_puesto b ON (a.cve_puesto = b.id_puesto)
							INNER JOIN CATALOGOS.dbo.tc_departamento c ON (a.cve_depto = c.id_departamento)
						WHERE usuario = @userRespRepair
					END
					ELSE BEGIN
						SELECT 
							a.usuario AS id
							, a.nombre AS n
							, a.ap_paterno AS ap
							, a.ap_materno AS am
							, b.descripcion AS puesto
							, c.id_departamento AS id_depto
							, c.descripcion AS sucursal 
						FROM CATALOGOS.dbo.tc_empleados a
							INNER JOIN CATALOGOS.dbo.tc_puesto b ON (a.cve_puesto = b.id_puesto)
							INNER JOIN CATALOGOS.dbo.tc_departamento c ON (a.cve_depto = c.id_departamento)
						WHERE a.estatus =  1
							AND a.id_empleados = 72
					END
				END
				ELSE BEGIN
					SELECT '3000' AS id --El 3000 solo se usa para enviar el mensaje de que esa garantía no tiene usuario asignado para que la repare.
				END
			END
			ELSE BEGIN
				SELECT 
					@userAll = bknp_userDisplay
				FROM SVA.dbo.tc_brokenessPermissions
				WHERE bknp_cId = @parent
					AND bknp_operation = @opt
				IF @userAll = 16 BEGIN
					SELECT 
						b.usuario AS id
						, b.nombre AS n
						, b.ap_paterno AS ap
						, b.ap_materno AS am
						, b.cve_puesto AS puesto
						, b.cve_depto  AS id_depto
						, c.descripcion AS sucursal
					FROM SVA.dbo.tc_brokenessPermissions a
						INNER JOIN CATALOGOS.dbo.tc_empleados b ON (a.bknp_userDisplay = b.cve_puesto OR @userAll = 0)
						INNER JOIN CATALOGOS.dbo.tc_departamento c ON (b.cve_depto = c.id_departamento)
					WHERE a.bknp_cId = @parent
						AND a.bknp_operation = @opt
						AND b.estatus = 1
						AND b.id_empleados = 72
				END
				ELSE BEGIN
					SELECT 
						@noUSers = COUNT(*)
					FROM SVA.dbo.tc_brokenessPermissions a
						INNER JOIN CATALOGOS.dbo.tc_empleados b ON (b.cve_puesto = a.bknp_userDisplay)
					WHERE a.bknp_cId = @parent
						AND a.bknp_operation = @opt
						AND b.estatus = 1
						AND (@sucursal = 0 OR b.cve_depto = @sucursal)
					IF (@noUSers = 0) BEGIN
						SET @userAll = 0
					END
					SELECT 
						b.usuario AS id
						, b.nombre AS n
						, b.ap_paterno AS ap
						, b.ap_materno AS am
						, d.descripcion AS puesto
						, REPLICATE('0',5 - LEN(b.cve_depto)) + CAST(b.cve_depto AS varchar) AS id_depto
						, c.descripcion AS sucursal
					FROM SVA.dbo.tc_brokenessPermissions a
						INNER JOIN CATALOGOS.dbo.tc_empleados b ON (a.bknp_userDisplay = b.cve_puesto OR @userAll = 0)
						INNER JOIN CATALOGOS.dbo.tc_departamento c ON (b.cve_depto = c.id_departamento)
						INNER JOIN CATALOGOS.dbo.tc_puesto d ON (b.cve_puesto = d.id_puesto)
					WHERE a.bknp_cId = @parent
						AND a.bknp_operation = @opt
						AND b.estatus = 1
						AND (@sucursal = 0 OR b.cve_depto = @sucursal)
				END
			END
		END 
		ELSE BEGIN
			SELECT @userStatus = estatus FROM CATALOGOS.dbo.tc_empleados WHERE usuario = @wlc_resp
			IF @userStatus = 1 BEGIN
				SELECT
					a.usuario AS id
					, a.nombre AS n
					, a.ap_paterno AS ap
					, a.ap_materno AS am
					, b.descripcion AS puesto
					, REPLICATE('0',5 - LEN(a.cve_depto)) + CAST(a.cve_depto AS varchar) AS id_depto
					, c.descripcion AS sucursal
				FROM CATALOGOS.dbo.tc_empleados a
					INNER JOIN CATALOGOS.dbo.tc_puesto b ON (a.cve_puesto = b.id_puesto)
					INNER JOIN CATALOGOS.dbo.tc_departamento c ON (a.cve_depto = c.id_departamento)
				WHERE a.usuario = @wlc_resp
					AND a.estatus = 1
			END
			ELSE BEGIN
				SELECT
					a.usuario AS id
					, a.nombre AS n
					, a.ap_paterno AS ap
					, a.ap_materno AS am
					, b.descripcion AS puesto
					, REPLICATE('0',5 - LEN(a.cve_depto)) + CAST(a.cve_depto AS varchar) AS id_depto
					, c.descripcion AS sucursal
				FROM CATALOGOS.dbo.tc_empleados a
					INNER JOIN CATALOGOS.dbo.tc_puesto b ON (a.cve_puesto = b.id_puesto)
					INNER JOIN CATALOGOS.dbo.tc_departamento c ON (a.cve_depto = c.id_departamento)
				WHERE a.estatus = 1
					AND a.id_empleados = 72
			END
		END
	END
END
