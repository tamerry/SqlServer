-- Eğer tablo daha önce varsa sil
IF OBJECT_ID('dbo.DimTarih', 'U') IS NOT NULL 
    DROP TABLE dbo.DimTarih;
GO

-- 1. Tabloyu Oluştur
CREATE TABLE dbo.DimTarih (
    TarihKey INT PRIMARY KEY,           -- Örn: 20230101 (Join işlemleri için hızlı)
    Tarih DATE NOT NULL,                -- Örn: 2023-01-01
    Yil INT NOT NULL,                   -- 2023
    Ay INT NOT NULL,                    -- 1
    AyAdi NVARCHAR(20) NOT NULL,        -- Ocak
    Gun INT NOT NULL,                   -- 1
    GunAdi NVARCHAR(20) NOT NULL,       -- Pazar
    YilinGunu INT NOT NULL,             -- 1 (1-366 arası)
    HaftaninGunu INT NOT NULL,          -- 1-7 arası (Pazartesi=1 kabul edilerek)
    YilinHaftasi INT NOT NULL,          -- 1-53
    Ceyrek INT NOT NULL,                -- 1, 2, 3, 4
    CeyrekAdi VARCHAR(10) NOT NULL,     -- Q1, Q2...
    HaftaSonuMu BIT NOT NULL            -- 1: Hafta Sonu, 0: Hafta İçi
);
GO

-- 2. Verileri Oluştur ve Ekle
-- Haftanın başlangıcını Pazartesi (1) olarak ayarla (Türkiye standardı için)
SET DATEFIRST 1; 

DECLARE @BaslangicTarihi DATE = '2020-01-01';
DECLARE @BitisTarihi DATE = '2040-12-31';

-- CTE ile tarih aralığını üret
WITH TarihSiniri AS (
    SELECT @BaslangicTarihi AS Tarih
    UNION ALL
    SELECT DATEADD(DAY, 1, Tarih)
    FROM TarihSiniri
    WHERE Tarih < @BitisTarihi
)
INSERT INTO dbo.DimTarih
SELECT 
    -- TarihKey (YYYYMMDD formatında integer)
    CAST(FORMAT(Tarih, 'yyyyMMdd') AS INT) AS TarihKey,
    
    -- Tarih
    Tarih,
    
    -- Yıl
    YEAR(Tarih) AS Yil,
    
    -- Ay
    MONTH(Tarih) AS Ay,
    
    -- Ay Adı (Türkçe - FORMAT fonksiyonu kültüre duyarlıdır)
    FORMAT(Tarih, 'MMMM', 'tr-TR') AS AyAdi,
    
    -- Gün
    DAY(Tarih) AS Gun,
    
    -- Gün Adı (Türkçe)
    FORMAT(Tarih, 'dddd', 'tr-TR') AS GunAdi,
    
    -- Yılın Günü
    DATEPART(DY, Tarih) AS YilinGunu,
    
    -- Haftanın Günü (SET DATEFIRST 1 ayarı sayesinde Pazartesi=1 olur)
    DATEPART(DW, Tarih) AS HaftaninGunu,
    
    -- Yılın Haftası (ISO haftası için ISO_WEEK kullanılabilir, burada standart WEEK kullanıldı)
    DATEPART(ISO_WEEK, Tarih) AS YilinHaftasi,
    
    -- Çeyrek
    DATEPART(QUARTER, Tarih) AS Ceyrek,
    
    -- Çeyrek Adı
    'Q' + CAST(DATEPART(QUARTER, Tarih) AS VARCHAR(1)) AS CeyrekAdi,
    
    -- Hafta Sonu Mu? (Cumartesi=6, Pazar=7 ise 1, değilse 0)
    CASE 
        WHEN DATEPART(DW, Tarih) IN (6, 7) THEN 1 
        ELSE 0 
    END AS HaftaSonuMu

FROM TarihSiniri
OPTION (MAXRECURSION 0); -- Sınırsız döngüye izin ver (7000+ gün olduğu için gerekli)

GO

-- 3. Sonucu Kontrol Et
SELECT TOP 10 * FROM dbo.DimTarih ORDER BY Tarih;