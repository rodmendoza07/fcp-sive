USE [CATALOGOS]
GO

/****** Object:  Table [dbo].[tc_blockedUsers]    Script Date: 06/10/2017 11:26:33 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tc_blockedUsers](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[empleados_id] [int] NOT NULL,
	[motivo] [varchar](max) NULL,
	[date_block] [datetime] NOT NULL,
	[blocked_by] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tc_blockedUsers]  WITH CHECK ADD FOREIGN KEY([blocked_by])
REFERENCES [dbo].[tc_empleados] ([id_empleados])
GO

ALTER TABLE [dbo].[tc_blockedUsers]  WITH CHECK ADD FOREIGN KEY([empleados_id])
REFERENCES [dbo].[tc_empleados] ([id_empleados])
GO

ALTER TABLE dbo.tc_blockedUsers
ADD CONSTRAINT def_date_block DEFAULT (GETDATE()) for date_block

ALTER TABLE dbo.tc_blockedUsers
ADD CONSTRAINT def_blocked_by DEFAULT (0) for blocked_by
