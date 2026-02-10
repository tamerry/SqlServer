CREATE TABLE AuditLog (
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TabloAdi NVARCHAR(100),
    IslemTipi CHAR(3), -- INS (Ekleme), UPD (Güncelleme), DEL (Silme)
    IslemYapan NVARCHAR(100),
    HostName NVARCHAR(100),
    IslemTarihi DATETIME DEFAULT GETDATE(),
    EskiVeri NVARCHAR(MAX), -- JSON Olarak saklanacak
    YeniVeri NVARCHAR(MAX)  -- JSON Olarak saklanacak
);