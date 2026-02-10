CREATE PROCEDURE sp_AutoAudit_Olustur
    @HedefTablo NVARCHAR(100),
    @AnahtarKolon NVARCHAR(50) = 'ID'
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @TriggerAdi NVARCHAR(100) = 'trg_Audit_' + @HedefTablo;

    -- Eski trigger varsa temizle
    SET @SQL = 'IF OBJECT_ID(''' + @TriggerAdi + ''', ''TR'') IS NOT NULL DROP TRIGGER ' + @TriggerAdi + ';';
    EXEC sp_executesql @SQL;

    -- Dinamik Trigger Kodu
    SET @SQL = '
    CREATE TRIGGER ' + @TriggerAdi + '
    ON ' + @HedefTablo + '
    AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Islem CHAR(3);

        -- İşlem tipini belirle
        IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
            SET @Islem = ''UPD'';
        ELSE IF EXISTS (SELECT * FROM INSERTED)
            SET @Islem = ''INS'';
        ELSE
            SET @Islem = ''DEL'';


	--Insert Ediliyor
        INSERT INTO AuditLog (TabloAdi, IslemTipi, IslemYapan, HostName, EskiVeri, YeniVeri)
        SELECT 
            ''' + @HedefTablo + ''',
            @Islem,
            SYSTEM_USER,
            HOST_NAME(),             (SELECT * FROM DELETED FOR JSON AUTO),
            (SELECT * FROM INSERTED FOR JSON AUTO);
    END;';

    PRINT 'Trigger oluşturuluyor: ' + @TriggerAdi;
    EXEC sp_executesql @SQL;
END;