
-- 1. ADIM: VERiLERi GEÇiCi TABLOYA HAZIRLAMA
IF OBJECT_ID('tempdb..#SatisRaporu') IS NOT NULL DROP TABLE #SatisRaporu;


-- 1. ADIM: VERiLERi GEÇiCi TABLOYA HAZIRLAMA
IF OBJECT_ID('tempdb..#SatisRaporu') IS NOT NULL DROP TABLE #SatisRaporu;
-- Geçici tabloyu oluştur ve verileri ekle
SELECT * INTO #SatisRaporu FROM (
    SELECT 
        TARiH,
        ISNULL(FORMAT([TÜRKiYE], 'N2', 'tr-TR') + ' TL', 'SATIS YOK') AS TR,
        ISNULL(FORMAT([ULKE1], 'N2', 'tr-TR') + ' TL', 'SATIS YOK') AS ULKE1,
        ISNULL(FORMAT([ULKE2], 'N2', 'tr-TR') + ' €', 'SATIS YOK') AS KSV
    FROM (
        SELECT * FROM (
            -- TÜRKiYE
            SELECT 'TÜRKiYE' AS 'ULKE', CONVERT(VARCHAR(10), T.TRANS_DATE, 104) 'TARiH',               
                   SUM(CASE WHEN PTYPE <> 2 THEN 1 ELSE -1 END * (GROSS_TOTAL-(DISCOUNT_ON_LINES+DISCOUNT_ON_TOTAL))) 'NETSATIS' 
            FROM GENIUS3.TRANSACTION_HEADER T 
            WHERE TRANS_DATE >= DATEADD(ww, DATEDIFF(ww, 0, GETDATE()), 0) AND STATUS = 0 
            GROUP BY T.TRANS_DATE 
            UNION ALL
            -- ULKE1
            SELECT 'ULKE1' AS 'ULKE', CONVERT(VARCHAR(10), T.TRANS_DATE, 104) 'TARiH',               
                   SUM(CASE WHEN PTYPE <> 2 THEN 1 ELSE -1 END * (GROSS_TOTAL-(DISCOUNT_ON_LINES+DISCOUNT_ON_TOTAL))) 'NETSATIS' 
            FROM GeniusULKE1.GENIUS3.TRANSACTION_HEADER T 
            WHERE TRANS_DATE >= DATEADD(ww, DATEDIFF(ww, 0, GETDATE()), 0) AND STATUS = 0 
            GROUP BY T.TRANS_DATE
            UNION ALL
            -- ULKE2
            SELECT 'KOSOVA' AS 'ULKE', CONVERT(VARCHAR(10), T.TRANS_DATE, 104) 'TARiH',             
                   SUM(CASE WHEN PTYPE <> 2 THEN 1 ELSE -1 END * (GROSS_TOTAL-(DISCOUNT_ON_LINES+DISCOUNT_ON_TOTAL))) 'NETSATIS' 
            FROM GeniusULKE2.GENIUS3.TRANSACTION_HEADER T 
            WHERE TRANS_DATE >= DATEADD(ww, DATEDIFF(ww, 0, GETDATE()), 0) AND STATUS = 0 
            GROUP BY T.TRANS_DATE
        ) as ANASORGU
        PIVOT
        (
            SUM(NETSATIS)
            FOR ULKE IN ([TÜRKiYE], [ULKE1], [ULKE2])
        ) AS PIVOTTABLO
    ) AS SonucTablosu
) AS TempData;

select * from #SatisRaporu