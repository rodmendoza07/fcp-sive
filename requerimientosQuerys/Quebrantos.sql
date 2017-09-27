USE SVA
GO
BEGIN
	DECLARE
		@fecha VARCHAR(30) = '20170901'

	SELECT
		'GCP' AS EMPRESA
		, CASE
			WHEN inv.wlc_respStageUser = 'gvargas' THEN 'GCP'
			ELSE inv.wlc_respStageUser
		END AS USUARIO
		, CASE
			WHEN inv.wlc_respStageUser = 'gvargas' THEN 'GCP'
			ELSE cat.nombre + ' ' + cat.ap_paterno + '' + cat.ap_materno	
		END AS NOMBRE
		, CASE
			WHEN inv.wlc_respStageUser = 'gvargas' THEN 'GCP'
			ELSE job.descripcion
		END AS PUESTO
		, CASE
			WHEN inv.wlc_respStageUser = 'gvargas' THEN 'GCP'
			ELSE bo.descripcion
		END AS SUCURSAL
		, ty1.tbrokeness_name AS CONCEPTO_1
		, ty2.tbrokeness_name AS CONCEPTO_2
		, ty3.tbrokeness_name AS CONCEPTO_3
		, 'Cobro normal' AS POLITICA_APLICADA
		, 'Vitrina' AS AREA_EMISORA
		, inv.wlc_createUser AS USUARIO_CREADOR
		, inv.wlc_codeSVA AS FOLIO
		, '' AS SI_TE_APARECE_EL_FOLIO
		, CONVERT(varchar, inv.wlc_createDate, 120) AS FECHA_SUCESO
		, 'Activo' AS ESTATUS_EMPLEADO
		, inv.wlc_amount AS MONTO_PRESTAMO
		, 'No' AS MUEVE_FLUJO
		, '' AS MONTO_LIQUIDACION
		, '' AS IMPORTA_AJUSTADO
		, '' AS MONTO_CAPITAL_EN_RIESGO
		, '' AS MONTO_INFLADO
		, '' AS INGRESO
		, brkd.bknd_amountCharge AS IMPORTE_A_COBRAR
		, ty1.tbrokeness_name AS COMENTARIO
		, tgar.sTIPOGARANTIA AS TIPO_GARANTIA
	FROM INVENTARIO.dbo.tp_checkListWarranty inv
		INNER JOIN CATALOGOS.dbo.tc_empleados cat ON (inv.wlc_respStageUser = cat.usuario)
		INNER JOIN CATALOGOS.dbo.tc_puesto job ON (cat.cve_puesto = job.id_puesto)
		INNER JOIN CATALOGOS.dbo.tc_departamento bo ON (cat.cve_depto = bo.id_departamento)
		INNER JOIN INVENTARIO.dbo.tp_brokenness brk ON (inv.wlc_id = brk.wlc_id)
		INNER JOIN SVA.dbo.tc_brokenessTypes ty3 ON (ty3.tbrokeness_id = brk.bkn_typeBrokenness)
		INNER JOIN SVA.dbo.tc_brokenessTypes ty2 ON (ty2.tbrokeness_id = ty3.tbrokeness_parent)
		INNER JOIN SVA.dbo.tc_brokenessTypes ty1 ON (ty1.tbrokeness_id = ty2.tbrokeness_parent)
		INNER JOIN INVENTARIO.dbo.td_brokenness brkd ON (brk.bkn_id = brkd.bkn_id)
		INNER JOIN SVA.dbo.T_GARANTIA tgar ON (inv.wlc_codeSVA = tgar.sCODIGOBARRAS)
	WHERE inv.sinv_id = 52
		AND CONVERT(varchar, inv.wlc_createDate, 112) >= @fecha
		ORDER BY inv.wlc_createDate ASC

END