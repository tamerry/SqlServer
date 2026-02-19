-- 1. Değişkenleri tanımlayalım
DECLARE @StoreDesc NVARCHAR(255) = 'KAYIT BULUNAMADI';
DECLARE @CmdOutput TABLE (OutputLine NVARCHAR(MAX));
DECLARE @WmiRaw NVARCHAR(MAX);
DECLARE @Serial NVARCHAR(100) = 'HATA', @Model NVARCHAR(100) = 'HATA', @Brand NVARCHAR(100) = 'HATA';
DECLARE @Cmd NVARCHAR(4000);

-- 2. Mağaza açıklamasını Genius3 veritabanından çekelim (Try/Catch ile hata kontrolü)
BEGIN TRY
    SELECT TOP 1 @StoreDesc = DESCRIPTION 
    FROM Genius3.GENIUS3.STORE 
    WHERE ID IN (SELECT TOP(1) FK_STORE FROM Genius3.GENIUS3.TRANSACTION_HEADER);
END TRY
BEGIN CATCH
    SET @StoreDesc = 'SORGU HATASI';
END CATCH

-- 3. xp_cmdshell özelliğini aktif edelim
EXEC sp_configure 'show advanced options', 1; 
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'xp_cmdshell', 1; 
RECONFIGURE WITH OVERRIDE;

-- 4. PowerShell komutunu hazırlayıp çalıştıralım ve sonucu tabloya alalım
SET @Cmd = 'powershell.exe -NoProfile -Command "Get-WmiObject Win32_ComputerSystemProduct | ForEach-Object { Write-Output ([string]$_.IdentifyingNumber + [char]64 + [string]$_.Name + [char]64 + [string]$_.Vendor) }"';

INSERT INTO @CmdOutput (OutputLine)
EXEC xp_cmdshell @Cmd;

-- 5. xp_cmdshell özelliğini güvenlik için tekrar kapatalım
EXEC sp_configure 'xp_cmdshell', 0; 
RECONFIGURE WITH OVERRIDE;
EXEC sp_configure 'show advanced options', 0; 
RECONFIGURE WITH OVERRIDE;

-- 6. Dönen sonucu yakalayalım (İçinde @ işareti olan satırı buluyoruz)
SELECT TOP 1 @WmiRaw = OutputLine 
FROM @CmdOutput 
WHERE OutputLine LIKE '%@%@%';

-- 7. Yakalanan veriyi (Serial@Model@Brand) XML yöntemiyle parçalayalım
IF @WmiRaw IS NOT NULL
BEGIN
    DECLARE @xml XML = CAST('<x>' + REPLACE(@WmiRaw, '@', '</x><x>') + '</x>' AS XML);
    
    SELECT 
        @Serial = @xml.value('/x[1]', 'NVARCHAR(100)'),
        @Model  = @xml.value('/x[2]', 'NVARCHAR(100)'),
        @Brand  = @xml.value('/x[3]', 'NVARCHAR(100)');
END

-- 8. Sonuçları tek bir tablo çıktısı olarak gösterelim
SELECT 
    @@SERVERNAME AS [Sunucu (IP/İsim)],
    @StoreDesc AS [Mağaza Açıklaması],
    LTRIM(RTRIM(@Serial)) AS [Seri No],
    LTRIM(RTRIM(@Model)) AS [Model],
    LTRIM(RTRIM(@Brand)) AS [Marka];