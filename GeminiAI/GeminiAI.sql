CREATE OR ALTER PROCEDURE sp_AnalyzeTableDataWithAI
    @MyQuery NVARCHAR(MAX) -- Analiz edilecek VERİLERİ getiren sorgu
AS
BEGIN
    SET NOCOUNT ON;

    -- UYARI: Kendi API anahtarınızı buraya yazın!
    DECLARE @ApiKey VARCHAR(100) = '';
    DECLARE @DataAsJson NVARCHAR(MAX);
    DECLARE @Base64Prompt VARCHAR(MAX);
    DECLARE @cmd VARCHAR(8000);

    -- 1. Verileri JSON formatına çevir
    DECLARE @JsonExec NVARCHAR(MAX) = N'SET @json = (SELECT TOP 5 * FROM (' + @MyQuery + ') AS Sub FOR JSON PATH)';
    EXEC sp_executesql @JsonExec, N'@json NVARCHAR(MAX) OUTPUT', @json = @DataAsJson OUTPUT;

    IF @DataAsJson IS NULL OR @DataAsJson = ''
    BEGIN
        PRINT 'HATA: Sorgu veri dondurmedi.';
        RETURN;
    END

    -- 2. Prompt Hazırla
    DECLARE @FullPrompt NVARCHAR(MAX) = 'Sana gelen bu JSON verilerini analiz et, anormallikleri ve trendleri Turkce raporla: ' + @DataAsJson;
    
    -- 3. Base64 Çevrimi
    SET @Base64Prompt = (
        SELECT CAST(@FullPrompt AS VARBINARY(MAX)) 
        FOR XML PATH(''), BINARY BASE64
    );

    -- Boşlukları temizle
    SET @Base64Prompt = REPLACE(REPLACE(@Base64Prompt, CHAR(10), ''), CHAR(13), '');

    -- GÜVENLİK 
    IF LEN(@Base64Prompt) > 7200
    BEGIN
        PRINT 'HATA: Veri cok buyuk! Kapasite asildi (' + CAST(LEN(@Base64Prompt) AS VARCHAR) + ' karakter). Lutfen sorgunuzda daha az sutun secin.';
        RETURN;
    END

    -- 4. PowerShell Komutu
    SET @cmd = 'powershell.exe -Command "' +
        '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ' +
        '$encoded = ''' + @Base64Prompt + '''; ' +
        '$decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded)); ' +
        '$body = @{ contents = @(@{ parts = @(@{ text = $decoded }) }) } | ConvertTo-Json -Compress -Depth 10; ' +
        '$uri = ''https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + @ApiKey + '''; ' +
        '$res = Invoke-RestMethod -Uri $uri -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -ContentType ''application/json; charset=utf-8''; ' +
        '$res.candidates[0].content.parts[0].text"'

    -- 5. Tablo oluştur ve çalıştır
    IF OBJECT_ID('tempdb..#GeminiTemp') IS NOT NULL DROP TABLE #GeminiTemp;
    CREATE TABLE #GeminiTemp (ID INT IDENTITY(1,1), LineText NVARCHAR(MAX));

    INSERT INTO #GeminiTemp (LineText)
    EXEC xp_cmdshell @cmd;

    -- 6. Sonucu Göster )
    BEGIN
        DECLARE @i INT = 1;
        DECLARE @max INT = (SELECT MAX(ID) FROM #GeminiTemp);
        DECLARE @line NVARCHAR(MAX);

        PRINT '==================================================';
        PRINT '         AI VERİ ANALİZ RAPORU                 ';
        PRINT '==================================================';

        
        WHILE @i <= @max
        BEGIN
            SELECT @line = LineText FROM #GeminiTemp WHERE ID = @i;
            
            IF @line IS NOT NULL 
                PRINT @line;
            
            SET @i = @i + 1;
        END
        
        PRINT '==================================================';
    END
    ELSE
    BEGIN
        PRINT 'HATA: Veri akisi saglanamadi. İnternet veya bağlantı sorunu olabilir.';
    END

    DROP TABLE #GeminiTemp;
END
GO

EXEC sp_AnalyzeTableDataWithAI 'SELECT * FROM [HumanResources].[vEmployee]';