
ALTER TABLE CATALOGOS.dbo.tc_blockedUsers
ADD blocked_status INT 
ALTER TABLE CATALOGOS.dbo.tc_blockedUsers
ADD CONSTRAINT blockedUsers_blkd_status DEFAULT 1 FOR blocked_status


UPDATE CATALOGOS.dbo.tc_blockedUsers SET
	blocked_status = 1

UPDATE CATALOGOS.dbo.tc_blockedUsers SET
	blocked_status = 0
WHERE empleados_id = 422

INSERT INTO CATALOGOS.dbo.tc_blockedUsers (
	empleados_id
	, motivo
	, date_block
	, blocked_by
	, blocked_status
) VALUES(
	1355
	, 'Bloqueo de precios SIVE'
	, GETDATE()
	, 1024
	, 0
)
