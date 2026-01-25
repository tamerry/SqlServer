-- Eğer tablo daha önce varsa hata vermemesi için önce siliyoruz 
IF OBJECT_ID('dbo.TestUrunleri', 'U') IS NOT NULL
DROP TABLE dbo.TestUrunleri;
GO

-- Tabloyu oluşturuyoruz
CREATE TABLE dbo.TestUrunleri (
    UrunID INT IDENTITY(1,1) PRIMARY KEY, -- Otomatik artan numara
    UrunAdi NVARCHAR(100) NOT NULL,       -- Metin (String) işlemleri için
    Kategori NVARCHAR(50),                -- IN operatörü için ideal
    BirimFiyat DECIMAL(10, 2) NOT NULL,   -- Aritmetik ve karşılaştırma için
    StokAdedi INT NOT NULL,               -- Modulo (%) ve aritmetik için
    SonSatisTarihi DATETIME NULL,         -- Tarih ve IS NULL testi için (Boş olabilir)
    Aciklama NVARCHAR(255) NULL           -- LIKE ve NULL testi için
);
GO

-- Test verilerini ekliyoruz
INSERT INTO TestUrunleri (UrunAdi, Kategori, BirimFiyat, StokAdedi, SonSatisTarihi, Aciklama)
VALUES
('Laptop X1 Pro', 'Elektronik', 25000.00, 15, '2023-10-25', 'Yüksek performanslı iş bilgisayarı.'),
('Kablosuz Mouse M50', 'Elektronik', 450.50, 102, GETDATE(), 'Ergonomik tasarım.'),
('Gaming Klavye RGB', 'Elektronik', 1200.00, 8, '2023-11-01', NULL), -- Açıklama NULL
('4K Monitör 27 inç', 'Elektronik', 8500.00, 0, '2023-09-15', 'Stokta yok, teşhir ürünü.'), -- Stok 0
('Deri Ceket (L)', 'Giyim', 3500.00, 20, NULL, 'Hakiki deri, kışlık.'), -- Hiç satılmamış (Tarih NULL)
('Kot Pantolon Mavi', 'Giyim', 890.90, 55, '2023-10-05', 'Rahat kesim.'),
('Spor Ayakkabı Run', 'Spor', 2100.00, 13, '2023-11-10', 'Koşu için ideal.'),
('Yoga Matı', 'Spor', 350.00, 4, NULL, NULL); -- Hem tarih hem açıklama NULL

-- Verilerin doğru yüklendiğini kontrol edelim
SELECT * FROM TestUrunleri;
GO