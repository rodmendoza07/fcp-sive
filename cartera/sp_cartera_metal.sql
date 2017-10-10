USE [ISILOANSWEB]
GO
/****** Object:  StORedProcedure [dbo].[sp_cartera_metal]    Script Date: 19/09/2017 05:11:53 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

---- =============================================
---- Author: <Author>
---- Create date: <Create Date>
---- Description: <Description>
---- =============================================

--ALTER PROCEDURE [dbo].[sp_cartera_metal]

--AS

BEGIN
    DECLARE @varfixplata DECIMAL(20,2) = 22.05
	   , @varfixORo DECIMAL(20,2) = 1388.95
	   , @varfixdolar DECIMAL(20,2) = 12.69

    IF OBJECT_ID('tempdb..##tempcartera') IS NOT NULL 
	   DROP TABLE ##tempcartera

    SELECT CAST(a.sucursal AS VARCHAR) + ' ' + d.descripcion AS [sucursal]
	   , tg.numero
	   , CASE 
		  WHEN tg.numero < 1000000 AND tg.numgaran < 10 THEN '0' + CONVERT(VARCHAR(8), tg.numero) + '000' + CONVERT(VARCHAR(2), tg.numgaran)
		  WHEN tg.numero < 1000000 AND tg.numgaran >= 10 THEN '0' + CONVERT(VARCHAR(8), tg.numero) + '00' + CONVERT(VARCHAR(2), tg.numgaran)
		  WHEN tg.numero >= 1000000 AND tg.numgaran < 10 THEN CONVERT(VARCHAR(8), tg.numero) + '000' + CONVERT(VARCHAR(2), tg.numgaran)
		  WHEN tg.numero >= 1000000 AND tg.numgaran BETWEEN 10 AND 99 THEN CONVERT(VARCHAR(8), tg.numero) + '00' + CONVERT(VARCHAR(3), tg.numgaran)
		  WHEN tg.numero >= 1000000 AND tg.numgaran >= 100 THEN CONVERT(VARCHAR(8), tg.numero) + '0' + CONVERT(VARCHAR(4), tg.numgaran)
		  ELSE '0'
	     END AS [codigo_sva]
	   , CASE b.CTA
		  WHEN 1 THEN 'METAL'
		  WHEN 2 THEN 'ELECTRONICO'
		  WHEN 3 THEN 'AUTOS'
		  WHEN 4 THEN 'CERTIFICADO'
		  WHEN 5 THEN 'REC BOLETAS'
		  WHEN 6 THEN 'ESPECIAL'
		  WHEN 7 THEN 'RELOJ'
		  WHEN 8 THEN 'EMPLEADOS'
		  WHEN 9 THEN 'TASA CERO'
		  WHEN 10 THEN 'REC BOL METAL'
		  WHEN 11 THEN 'REC BOL ELECT'
		  WHEN 12 THEN 'PYMES'
		  WHEN 13 THEN 'PYMES REEST'
		  WHEN 14 THEN 'APARTADO'
		  WHEN 15 THEN 'FUERZA MOVIL'
	     END AS [Destino]
	   , CASE 
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 11 OR tg.tipo_garan = 12 OR tg.tipo_garan = 17 OR tg.tipo_garan = 22) THEN '8K'
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 4 OR tg.tipo_garan = 8 OR tg.tipo_garan = 16 OR tg.tipo_garan = 21) THEN '10K'
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 27 OR tg.tipo_garan = 28 OR tg.tipo_garan = 29) THEN '12K'
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 3 OR tg.tipo_garan = 7 OR tg.tipo_garan = 15 OR tg.tipo_garan = 20) THEN '14K'
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 2 OR tg.tipo_garan = 6 OR tg.tipo_garan = 14 OR tg.tipo_garan = 19) THEN '18K'
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 23 OR tg.tipo_garan = 24 OR tg.tipo_garan = 25 OR tg.tipo_garan = 26) THEN '21K'
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 1 OR tg.tipo_garan = 5 OR tg.tipo_garan = 13 OR tg.tipo_garan = 18) THEN '24K'
		  WHEN tg.tipo_prenda = 18 AND tg.tipo_garan = 9 THEN 'Plata 720'
		  WHEN tg.tipo_prenda = 18 AND tg.tipo_garan = 10 THEN 'Plata 920'
		  WHEN tg.tipo_prenda = 16 THEN 'GEMA'
		  ELSE 'OTRO'
	     END AS [detalle]
	   , CASE 
		  WHEN tg.tipo_prenda = 18 THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC)/10)
		  ELSE 1
	     END AS cantidad
	   , CASE 
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 11 OR tg.tipo_garan = 12 OR tg.tipo_garan = 17 OR tg.tipo_garan = 22)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.333
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 4 OR tg.tipo_garan = 8 OR tg.tipo_garan = 16 OR tg.tipo_garan = 21)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.4162
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 27 OR tg.tipo_garan = 28 OR tg.tipo_garan = 29)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.4995
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 3 OR tg.tipo_garan = 7 OR tg.tipo_garan = 15 OR tg.tipo_garan = 20)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.585
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 2 OR tg.tipo_garan = 6 OR tg.tipo_garan = 14 OR tg.tipo_garan = 19)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.7492
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 23 OR tg.tipo_garan = 24 OR tg.tipo_garan = 25 OR tg.tipo_garan = 26)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.8741
		  WHEN tg.tipo_prenda = 18 AND (tg.tipo_garan = 1 OR tg.tipo_garan = 5 OR tg.tipo_garan = 13 OR tg.tipo_garan = 18)
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.9999
		  WHEN tg.tipo_prenda = 18 AND tg.tipo_garan = 10 
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.920
		  WHEN tg.tipo_prenda = 18 AND tg.tipo_garan = 9 
		  THEN (CAST(CAST(LEFT(tg.des_garantia,4) AS VARCHAR) AS NUMERIC) / 10) * 0.720
		  ELSE 0
	     END AS [fact_pureza]
	   , tg.des_garantia
	   , tg.val_prestamo
	   , ((tg.val_prestamo / th.prest_gtia_resg) * th.saldo) AS [saldo_garantia]
	   , CASE 
		  WHEN tg.estatus = 0 THEN 'RESGUARDO'
		  WHEN tg.estatus = 1 THEN 'LIBERADA'
		  WHEN tg.estatus = 2 THEN 'VITRINA'
		  WHEN tg.estatus = 3 THEN 'TIENDA PORV'
		  WHEN tg.estatus = 4 THEN 'FUNDICION'
		  WHEN tg.estatus = 9 THEN 'NO ESTA ALMAC'
	     END AS [EST_PREN_ISI]
	   , CASE
		  WHEN (b.esq_fin = 0 AND b.plazo = 1 AND  b.diASmeses = 3 AND b.subsistema = 1) THEN 'COMPRA'
		  WHEN b.esq_fin = 0 THEN 'TRADICIONAL'
		  WHEN b.esq_fin = 1 THEN 'FLEXIBLE'
		  WHEN b.esq_fin = 7 THEN 'PAGOS FIJOS'
	     END AS [esquema]
	   , tg.usu_autor
	   , (DATEDIFF(dd, CONVERT(SMALLDATETIME, CONVERT(CHAR(8), 
		  ( SELECT MAX(e.fec_opera) 
		    FROM isiloansweb.dbo.T_hist e 
		    WHERE e.aplicacion = 26 
			 AND concepto = 4 
			 AND e.fech_anula = 0 
			 AND a.numero = e.numero))), 
		  CONVERT(SMALLDATETIME, CONVERT(CHAR(8), 
			 ( SELECT MAX(e.fec_opera)
			   FROM isiloansweb.dbo.T_hist e
			 ))))
	     ) AS [diAS_estac]
	   , ( SELECT MAX(e.fec_opera) 
	       FROM isiloansweb.dbo.T_hist e 
		  WHERE e.aplicacion = 26 
			 AND concepto = 4 
			 AND e.fech_anula = 0 
			 AND a.numero = e.numero
	     ) AS [fecha_batch]
	   , 999999999999.99 AS [margen]
	   , RTRIM(LTRIM(pcte.tipo)) AS [tipo_cliente]
	   , ava.addOnDesc AS [Tipo_de_hechura]
	   , ava.densityMetal AS [Densidad_Eureka]
	   , tg.FECH_ALTA AS Fecha_alta
    INTO ##tempcartera
    FROM SGP.dbo.CARTERATOTAL A WITH(NOLOCK)
	   INNER JOIN ISILOANSWEB.dbo.T_garantiAS tg WITH(NOLOCK) ON (a.numero = tg.numero)
	   INNER JOIN ISILOANSWEB.dbo.T_cred B WITH(NOLOCK) ON (a.numero = b.numero AND a.sucursal = b.sucursal)
	   INNER JOIN CIERRE.dbo.th_cred th WITH(NOLOCK) ON (th.credito = b.numero)
	   INNER JOIN CATALOGOS.dbo.tc_departamento d WITH(NOLOCK) ON (a.sucursal = d.id_departamento)
	   INNER JOIN ISILOANSWEB.dbo.p_cte1 pcte WITH(NOLOCK) ON (pcte.cliente = B.CLIENTE)
	   LEFT OUTER JOIN ISILOANSWEB.dbo.T_Avaluo ava WITH(NOLOCK) ON (tg.FOLIO_CTC = ava.Folio AND tg.ACREDITADO = ava.Cte)
    WHERE b.codaviso <> 0
	   AND (tg.tipo_prenda = 16 OR tg.tipo_prenda = 18 OR tg.tipo_prenda = 25)
	   AND b.subsistema = 1
	   AND a.sucursal < 1000
	   AND tg.estatus <> 1
	   AND b.status = 0
	   AND th.prest_gtia_resg > 0
    GROUP BY a.sucursal
	   , d.descripcion
	   , tg.numero
	   , tg.numgaran
	   , b.CTA
	   , tg.tipo_prenda
	   , tg.tipo_garan
	   , tg.DES_GARANTIA
	   , tg.VAL_PRESTAMO
	   , th.prest_gtia_resg
	   , th.saldo
	   , tg.ESTATUS
	   , B.ESQ_FIN
	   , B.PLAZO
	   , B.DIASMESES
	   , B.SUBSISTEMA
	   , tg.USU_AUTOR
	   , a.numero
	   , pcte.tipo
	   , ava.addOnDesc
	   , ava.densityMetal
	   , tg.FECH_ALTA
    ORDER BY tg.numero

    ALTER TABLE ##tempcartera ADD ubicacion VARCHAR(30)
    ALTER TABLE ##tempcartera ADD fecha_ult_mov DATETIME

    UPDATE a 
    SET a.ubicacion = b.cod_bar_rack
	   , a.fecha_ult_mov = (SELECT TOP 1 fecha FROM INVENTARIO.dbo.td_logubica WHERE numgarantia = a.codigo_sva ORDER BY fecha DESC)
    FROM ##tempcartera a 
	   INNER JOIN inventario.dbo.tp_inventarios b WITH(NOLOCK) ON (a.codigo_sva COLLATE Modern_Spanish_CI_AS = b.codigo_garantia COLLATE Modern_Spanish_CI_AS)

    UPDATE ##tempcartera SET margen = 0

    UPDATE ##tempcartera 
    SET margen = (fact_pureza * (@varfixplata / 31.103) * @varfixdolar * 0.955) - val_prestamo 
    WHERE detalle LIKE '%PLATA%'

    UPDATE ##tempcartera 
    SET margen = (fact_pureza * (@varfixORo / 31.103) * @varfixdolar * 0.955) - val_prestamo 
    WHERE detalle NOT LIKE '%PLATA%' 
	   AND detalle NOT LIKE '%OTRO%'

    select  
	   sucursal
	   , numero
	   , codigo_sva
	   , Destino
	   , detalle
	   , cantidad
	   , fact_pureza
	   , rtrim(ltrim(des_garantia))
	   , val_prestamo
	   , saldo_garantia
	   , EST_PREN_ISI
	   , esquema
	   , usu_autor
	   , dias_estac
	   , fecha_batch
	   , margen
	   , ubicacion
	   , tipo_cliente
	   , fecha_ult_mov
	   , Tipo_de_hechura
	   , Densidad_Eureka
	   , Fecha_alta
    from ##tempcartera

    --SELECT sucursal, numero, codigo_sva, Destino, detalle, cantidad, fact_pureza, rtrim(ltrim(des_garantia)), val_prestamo, saldo_garantia, EST_PREN_ISI, esquema, usu_autor, dias_estac, fecha_batch, margen, ubicacion, tipo_cliente, fecha_ult_mov, Tipo_de_hechura, Densidad_Eureka, CONVERT(varchar, Fecha_alta, 112) FROM ##tempcartera

    EXEC master..XP_CMDSHELL 'bcp "SELECT sucursal, numero, codigo_sva, Destino, detalle, cantidad, fact_pureza, rtrim(ltrim(des_garantia)), val_prestamo, saldo_garantia, EST_PREN_ISI, esquema, usu_autor, dias_estac, fecha_batch, margen, ubicacion, tipo_cliente, fecha_ult_mov, Tipo_de_hechura, Densidad_Eureka, Fecha_alta FROM ##tempcartera" queryout \\gcpporvenir\auditoria\carterametal.txt -c -t^| -T'
END