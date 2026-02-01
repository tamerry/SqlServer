-- Tablo varsa temizle
IF OBJECT_ID('dbo.DimPerakendeTarih', 'U') IS NOT NULL 
    DROP TABLE dbo.DimPerakendeTarih;
GO

-- 1. Tablo Yapısı
CREATE TABLE dbo.DimPerakendeTarih (
    TarihKey INT PRIMARY KEY,              -- 20231029 (Join için)
    Tarih DATE NOT NULL,
    
    -- Standart Takvim (Gregorian)
    StandartYil INT,
    StandartAy INT,
    
    -- Perakende (Retail) Takvimi
    PerakendeYil INT,                      -- Mali Yıl (FY)
    PerakendeAy INT,                       -- 1-12
    PerakendeAyAdi NVARCHAR(20),           -- Dönem 1, Dönem 2...
    PerakendeHafta INT,                    -- 1-53
    PerakendeCeyrek INT,                   -- 1-4
    PerakendeYilinGunu INT,                -- 1-371
    
    -- Dönem Bilgileri
    PerakendeHaftaBaslangic DATE,          -- O haftanın Pazar günü
    PerakendeHaftaBitis DATE               -- O haftanın Cumartesi günü
);
GO

-- 2. Veri Üretimi ve Hesaplama Mantığı
DECLARE @BaslangicYili INT = 2019; -- Hesaplama güvenliği için 1 yıl geri
DECLARE @BitisYili INT = 2041;     -- Hesaplama güvenliği için 1 yıl ileri

-- A. Mali Yıl Başlangıçlarını Bul (Ocak 31'e en yakın Cumartesi'den sonraki Pazar)
;WITH Yillar AS (
    SELECT @BaslangicYili AS Yil
    UNION ALL
    SELECT Yil + 1 FROM Yillar WHERE Yil < @BitisYili
),
MaliYilSinirlari AS (
    SELECT 
        Yil AS MaliYil,
        -- Kural: Mali yıl, Ocak ayının son Cumartesi gününü takip eden Pazar başlar.
        -- Pratik formül: O yılın Ocak 31'ine en yakın Cumartesi'yi bulup 1 gün ekle (Pazar).
        DATEADD(DAY, 1, 
            DATEADD(DAY, 
                CASE 
                    WHEN DATEPART(DW, DATEFROMPARTS(Yil, 1, 31)) < 4 THEN -DATEPART(DW, DATEFROMPARTS(Yil, 1, 31)) -- Haftanın başındaysa geriye git
                    ELSE 7 - DATEPART(DW, DATEFROMPARTS(Yil, 1, 31)) -- Haftanın sonundaysa ileri git (veya o gün)
                END, 
                DATEFROMPARTS(Yil, 1, 31)
            )
        ) AS BaslangicTarihi
    FROM Yillar
),
-- B. Günleri Üret ve Mali Yıl ile Eşleştir
Gunler AS (
    SELECT 
        MS.MaliYil,
        DATEADD(DAY, t.rn - 1, MS.BaslangicTarihi) AS Tarih,
        t.rn AS YilinGunu
    FROM MaliYilSinirlari MS
    CROSS APPLY (
        -- Bir sonraki yılın başlangıcını bulup gün farkını alıyoruz
        SELECT DATEDIFF(DAY, MS.BaslangicTarihi, LEAD(MS.BaslangicTarihi) OVER(ORDER BY MS.MaliYil)) AS GunSayisi
        FROM MaliYilSinirlari SubMS 
        WHERE SubMS.MaliYil = MS.MaliYil OR SubMS.MaliYil = MS.MaliYil + 1
    ) YilBilgisi
    CROSS APPLY (
        -- O yıl kaç gün ise o kadar sayı üret (364 veya 371)
        SELECT TOP (ISNULL(YilBilgisi.GunSayisi, 364)) ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rn
        FROM sys.all_objects a CROSS JOIN sys.all_objects b -- Yeterli sayı üretmek için
    ) t
    WHERE YilBilgisi.GunSayisi IS NOT NULL -- Son satırı temizle
),
-- C. 4-5-4 Mantığını Uygula
PerakendeHesap AS (
    SELECT
        MaliYil AS PerakendeYil,
        Tarih,
        YilinGunu,
        -- Hafta Sayısı: (YılınGunu - 1) / 7 + 1
        ((YilinGunu - 1) / 7) + 1 AS PerakendeHafta,
        
        -- Ay Hesaplama (4-5-4 Kuralı)
        -- Q1: 4-5-4 (Wk 1-13)
        -- Q2: 4-5-4 (Wk 14-26)
        -- Q3: 4-5-4 (Wk 27-39)
        -- Q4: 4-5-4 (Wk 40-52) + 53. Hafta varsa 12. aya eklenir
        CASE 
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 1 AND 4 THEN 1
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 5 AND 9 THEN 2
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 10 AND 13 THEN 3
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 14 AND 17 THEN 4
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 18 AND 22 THEN 5
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 23 AND 26 THEN 6
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 27 AND 30 THEN 7
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 31 AND 35 THEN 8
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 36 AND 39 THEN 9
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 40 AND 43 THEN 10
            WHEN ((YilinGunu - 1) / 7) + 1 BETWEEN 44 AND 48 THEN 11
            ELSE 12 -- Kalanlar (49-52 veya 53) 12. Ay
        END AS PerakendeAy
    FROM Gunler
)
-- D. Sonucu Tabloya Bas
INSERT INTO dbo.DimPerakendeTarih
SELECT
    CAST(FORMAT(Tarih, 'yyyyMMdd') AS INT) AS TarihKey,
    Tarih,
    YEAR(Tarih) AS StandartYil,
    MONTH(Tarih) AS StandartAy,
    PerakendeYil,
    PerakendeAy,
    'Dönem ' + CAST(PerakendeAy AS NVARCHAR(2)) AS PerakendeAyAdi,
    PerakendeHafta,
    CASE 
        WHEN PerakendeAy BETWEEN 1 AND 3 THEN 1
        WHEN PerakendeAy BETWEEN 4 AND 6 THEN 2
        WHEN PerakendeAy BETWEEN 7 AND 9 THEN 3
        ELSE 4 
    END AS PerakendeCeyrek,
    YilinGunu AS PerakendeYilinGunu,
    -- Haftanın Başlangıcı (Pazar)