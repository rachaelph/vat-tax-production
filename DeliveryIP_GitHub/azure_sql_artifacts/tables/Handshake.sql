/****** Object:  Table [dbo].[Handshake]    Script Date: 5/19/2023 10:57:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Handshake](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataContractID] [nvarchar](200) NULL,
	[DataSourceName] [nvarchar](255) NOT NULL,
	[Publisher] [nvarchar](255) NOT NULL,
	[CreatedBy] [nvarchar](max) NOT NULL,
	[CreatedByDate] [datetime2](7) NOT NULL,
	[EditedBy] [nvarchar](max) NULL,
	[EditedByDate] [datetime2](7) NULL,
	[Active] [bit] NOT NULL,
	[ActiveDate] [datetime2](7) NULL,
	[InactiveDate] [datetime2](7) NULL,
	[DataAssetTechnicalInformation] [nvarchar](max) NOT NULL,
	[SourceTechnicalInformation] [nvarchar](max) NOT NULL,
	[ConnectionType] [nvarchar](max) NOT NULL,
	[IngestionSchedule] [nvarchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Handshake] ADD  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [dbo].[Handshake] ADD  DEFAULT ('9999-12-31T00:00:00.0000000') FOR [InactiveDate]
GO

