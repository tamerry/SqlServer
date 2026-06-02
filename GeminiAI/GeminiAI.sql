-- ==============================================================================
-- 1. ADIM: GÜVENLİK AYARLARINI OTOMATİK AÇ
-- ==============================================================================
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

-- ==============================================================================
-- 2. ADIM: VERİ TOPLAMA VE YAPAY ZEKA ANALİZİ
-- ==============================================================================
USE [Genius3];
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Rapor ana tablosunu oluştur
IF OBJECT_ID('tempdb..#Genius3Report') IS NOT NULL DROP TABLE #Genius3Report;
CREATE TABLE #Genius3Report (
    [ReportID]       INT IDENTITY(1,1),
    [SiraNo]         INT,
    [Kategori]       NVARCHAR(100),
    [Analiz_Metriği] NVARCHAR(255),
    [Durum_Değeri]   NVARCHAR(MAX)
);

-- --- [1. SUNUCU BİLGİSİ] ---
INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT 1, 'SUNUCU BILGISI', 'SQL Sürüm Bilgisi', LEFT(@@VERSION, CHARINDEX('(', @@VERSION) - 2) + ' ' + CAST(SERVERPROPERTY('Edition') AS NVARCHAR(50));

INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT 1, 'SUNUCU BILGISI', 'Son Başlangıç Zamanı', CONVERT(VARCHAR, login_time, 120)
FROM sys.dm_exec_sessions WHERE session_id = 1;

-- --- [2. VERİTABANI BOYUTU] ---
INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT 2, 'VERITABANI BOYUTU', 'Genius3 Toplam Boyut', CAST(SUM(CAST(size AS BIGINT) * 8 / 1024) AS NVARCHAR(50)) + ' MB (~' + CAST(CAST(CAST(SUM(CAST(size AS BIGINT) * 8 / 1024) AS FLOAT) / 1024 AS DECIMAL(10,2)) AS NVARCHAR(50)) + ' GB)'
FROM sys.master_files WHERE database_id = DB_ID('Genius3');

-- --- [3. DISK DURUMU] ---
IF OBJECT_ID('tempdb..#DiskTemp') IS NOT NULL DROP TABLE #DiskTemp;
CREATE TABLE #DiskTemp (Drive CHAR(1), FreeMB INT);
BEGIN TRY
    INSERT INTO #DiskTemp EXEC master..xp_fixeddrives;
    INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
    SELECT 3, 'DISK DURUMU', 'Sürücü ' + Drive + ':\', CAST(CAST(CAST(FreeMB AS FLOAT) / 1024 AS DECIMAL(10,2)) AS NVARCHAR(50)) + ' GB Boş Alan' FROM #DiskTemp;
END TRY BEGIN CATCH 
    INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri]) VALUES (3, 'DISK DURUMU', 'Hata', 'Disk bilgileri alınamadı.'); 
END CATCH;
IF OBJECT_ID('tempdb..#DiskTemp') IS NOT NULL DROP TABLE #DiskTemp;

-- --- [4. INDEX FRAGMENTASYONU] ---
INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT TOP 5 4, 'PERFORMANS - INDEX BOZULMALARI', 'Tablo: ' + ISNULL(OBJECT_NAME(i.object_id), '') + ' | İndeks: ' + ISNULL(i.name, ''), '% ' + CAST(CAST(ips.avg_fragmentation_in_percent AS DECIMAL(10,2)) AS NVARCHAR(50)) + ' Bozulma Oranı'
FROM sys.dm_db_index_physical_stats(DB_ID('Genius3'), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 20 AND ips.page_count > 1000 
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- --- [5. EKSİK INDEX ÖNERİLERİ] ---
INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT TOP 3 5, 'PERFORMANS - EKSIK INDEXLER', 'Tablo: ' + REPLACE(REPLACE(ISNULL(mid.statement, ''), '[Genius3].', ''), '[GENIUS3].', ''), '% ' + CAST(CAST(migs.avg_user_impact AS DECIMAL(10,2)) AS NVARCHAR(50)) + ' Tahmini Performans Artışı'
FROM sys.dm_db_missing_index_groups AS mig
INNER JOIN sys.dm_db_missing_index_group_stats AS migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid ON mid.index_handle = mig.index_handle
WHERE mid.database_id = DB_ID('Genius3')
ORDER BY migs.avg_user_impact DESC;

-- --- [6. HATA LOGLARI] ---
IF OBJECT_ID('tempdb..#ErrorLogTemp') IS NOT NULL DROP TABLE #ErrorLogTemp;
CREATE TABLE #ErrorLogTemp (LogDate DATETIME, ProcessInfo NVARCHAR(50), LogText NVARCHAR(4000));
BEGIN TRY
    INSERT INTO #ErrorLogTemp EXEC master..xp_readerrorlog 0, 1, N'Error';
    INSERT INTO #ErrorLogTemp EXEC master..xp_readerrorlog 0, 1, N'Failed';
    
    INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
    SELECT TOP 2 6, 'SISTEM LOGU (SON HATALAR)', 'Zaman: ' + CONVERT(VARCHAR, LogDate, 120), REPLACE(LEFT(LogText, 120), '   ', ' ')
    FROM #ErrorLogTemp ORDER BY LogDate DESC;
END TRY BEGIN CATCH 
    INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri]) VALUES (6, 'SISTEM LOGU (SON HATALAR)', 'Erişim Hatası', 'Loglar okunamadı.'); 
END CATCH;
IF OBJECT_ID('tempdb..#ErrorLogTemp') IS NOT NULL DROP TABLE #ErrorLogTemp;

-- --- [7. YAPAY ZEKA ENTEGRASYONU (ÇİFT FAZLI)] ---
DECLARE @ApiKey VARCHAR(100) = ''; --Gemini Api keyi 
DECLARE @DataAsJson NVARCHAR(MAX) = (SELECT * FROM #Genius3Report FOR JSON PATH);
DECLARE @Base64Prompt VARCHAR(MAX);
DECLARE @cmd VARCHAR(8000);

-- Temp AI tablosu
IF OBJECT_ID('tempdb..#GeminiTemp') IS NOT NULL DROP TABLE #GeminiTemp;
CREATE TABLE #GeminiTemp (ID INT IDENTITY(1,1), LineText NVARCHAR(MAX));

-- FAZ A: PERFORMANS TAVSİYELERİ
DECLARE @PromptTavsiye NVARCHAR(MAX) = 'Sana gelen bu SQL Server durum verilerini analiz et. Donanim yetersizlikleri, limitsel riskler ve performans basliklari altinda COK KISA ve NET maddeler halinde aksiyon onerileri sun (Turkce): ' + @DataAsJson;
SET @Base64Prompt = (SELECT CAST(@PromptTavsiye AS VARBINARY(MAX)) FOR XML PATH(''), BINARY BASE64);
SET @Base64Prompt = REPLACE(REPLACE(@Base64Prompt, CHAR(10), ''), CHAR(13), '');

SET @cmd = 'powershell.exe -Command "' +
    '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ' +
    '$encoded = ''' + @Base64Prompt + '''; ' +
    '$decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded)); ' +
    '$body = @{ contents = @(@{ parts = @(@{ text = $decoded }) }) } | ConvertTo-Json -Compress -Depth 10; ' +
    '$uri = ''https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + @ApiKey + '''; ' +
    '$res = Invoke-RestMethod -Uri $uri -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType ''application/json; charset=utf-8''; ' +
    '$res.candidates[0].content.parts[0].text"'

INSERT INTO #GeminiTemp (LineText) EXEC xp_cmdshell @cmd;

INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT 7, 'AI PERFORMANS TAVSIYELERI', '', LTRIM(RTRIM(LineText))
FROM #GeminiTemp WHERE LineText IS NOT NULL AND LTRIM(RTRIM(LineText)) <> '';

-- FAZ B: DÜZELTME SORGULARI (SCRIPT)
TRUNCATE TABLE #GeminiTemp;

DECLARE @PromptSorgu NVARCHAR(MAX) = 'Sana gelen SQL Server durum verilerindeki INDEX BOZULMALARI ve EKSIK INDEXLERI cozmek icin calistirilmasi gereken GERCEK, TAM ve calismaya hazir T-SQL duzeltme sorgularini (ALTER INDEX REBUILD ve CREATE INDEX scriptlerini) yaz. Sadece SQL kod bloklari ve cok kisa basliklar olsun: ' + @DataAsJson;
SET @Base64Prompt = (SELECT CAST(@PromptSorgu AS VARBINARY(MAX)) FOR XML PATH(''), BINARY BASE64);
SET @Base64Prompt = REPLACE(REPLACE(@Base64Prompt, CHAR(10), ''), CHAR(13), '');

SET @cmd = 'powershell.exe -Command "' +
    '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ' +
    '$encoded = ''' + @Base64Prompt + '''; ' +
    '$decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded)); ' +
    '$body = @{ contents = @(@{ parts = @(@{ text = $decoded }) }) } | ConvertTo-Json -Compress -Depth 10; ' +
    '$uri = ''https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + @ApiKey + '''; ' +
    '$res = Invoke-RestMethod -Uri $uri -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType ''application/json; charset=utf-8''; ' +
    '$res.candidates[0].content.parts[0].text"'

INSERT INTO #GeminiTemp (LineText) EXEC xp_cmdshell @cmd;

INSERT INTO #Genius3Report ([SiraNo], [Kategori], [Analiz_Metriği], [Durum_Değeri])
SELECT 8, 'AI PERFORMANS DUZELTME SORGULARI (READY TO RUN)', '', LTRIM(RTRIM(LineText))
FROM #GeminiTemp WHERE LineText IS NOT NULL AND LTRIM(RTRIM(LineText)) <> '';

-- ==============================================================================
-- 3. ADIM: SİSTEMİ TEKRAR GÜVENLİ HALE GETİR (Ayar Yazıları Yukarıda Kalır)
-- ==============================================================================
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;

-- ==============================================================================
-- 4. ADIM: KUSURSUZ METİN RAPORUNU MESSAGES EKRANINA BAS
-- ==============================================================================
PRINT ''; 
PRINT '';
PRINT '================================================================================';
PRINT '                    GENIUS3 SAĞLIK VE YAPAY ZEKA RAPORU                         ';
PRINT '================================================================================';

DECLARE @Kat NVARCHAR(100), @Metrik NVARCHAR(255), @Deger NVARCHAR(MAX);
DECLARE @CurrentCategory NVARCHAR(100) = '';

-- SiraNo ve hemen ardından eklenme sırasına (ReportID) göre sıralayarak kaymaları önlüyoruz
DECLARE ReportCursor CURSOR FOR 
SELECT [Kategori], [Analiz_Metriği], [Durum_Değeri] 
FROM #Genius3Report 
ORDER BY [SiraNo], [ReportID];

OPEN ReportCursor;
FETCH NEXT FROM ReportCursor INTO @Kat, @Metrik, @Deger;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @CurrentCategory <> @Kat
    BEGIN
        PRINT '';
        PRINT '>>> [ ' + @Kat + ' ]';
        PRINT '--------------------------------------------------------------------------------';
        SET @CurrentCategory = @Kat;
    END

    -- Yapay zeka çıktısı olan alanlar düz metin, sistem metrikleri hizalı basılır
    IF @Kat IN ('AI PERFORMANS TAVSIYELERI', 'AI PERFORMANS DUZELTME SORGULARI (READY TO RUN)')
    BEGIN
        PRINT '   ' + @Deger; 
    END
    ELSE
    BEGIN
        PRINT '   • ' + LEFT(@Metrik + SPACE(40), 40) + ' : ' + @Deger;
    END

    FETCH NEXT FROM ReportCursor INTO @Kat, @Metrik, @Deger;
END

CLOSE ReportCursor;
DEALLOCATE ReportCursor;

PRINT '';
PRINT '================================================================================';
PRINT '                             RAPORUN SONU                                       ';
PRINT '================================================================================';

-- Son temizlik
DROP TABLE #Genius3Report;
IF OBJECT_ID('tempdb..#GeminiTemp') IS NOT NULL DROP TABLE #GeminiTemp;
GO
