USE [CATALOGOS]
GO

/****** Object:  View [dbo].[vw_BlockedUsers]    Script Date: 07/03/2018 01:15:02 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER View [dbo].[vw_BlockedUsers]
AS
	SELECT bl.id as id_BlockedUser,
		emp.id_empleados,
		bl.blocked_by as blocked_by_id,
		emp.cve_puesto,
		emp.Nombre,
		emp.ap_paterno,
		emp.ap_materno,
		emp.usuario,
		job.descripcion,
		dpto.descripcion as Departamento,
		bl.motivo,
		bl.date_block as 'Fecha de bloqueo'
	FROM CATALOGOS.dbo.tc_blockedUsers bl
	INNER JOIN CATALOGOS.dbo.tc_empleados emp ON bl.empleados_id = emp.id_empleados
	INNER JOIN CATALOGOS.dbo.tc_departamento dpto on emp.cve_depto = dpto.id_departamento
	INNER JOIN CATALOGOS.dbo.tc_puesto job on emp.cve_puesto = job.id_puesto
	WHERE bl.blocked_status = 1
GO


