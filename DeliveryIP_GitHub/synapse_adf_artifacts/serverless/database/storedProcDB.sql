/****** Object:  Database [StoredProcDB]    Script Date: 5/19/2023 3:10:38 PM ******/
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'StoredProcDB')
  BEGIN
    CREATE DATABASE [StoredProcDB]
  END
GO

ALTER DATABASE [StoredProcDB] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [StoredProcDB] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [StoredProcDB] SET ARITHABORT OFF 
GO

ALTER DATABASE [StoredProcDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [StoredProcDB] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [StoredProcDB] SET QUOTED_IDENTIFIER OFF 
GO

