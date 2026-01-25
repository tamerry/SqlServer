# SQL Server Operatörleri ve Sorgu Mantığı 🚀

![SQL Server](https://img.shields.io/badge/SQL%20Server-2025%2B-blue)
![YouTube](https://img.shields.io/badge/YouTube-Video%20Ders-red)
![License](https://img.shields.io/badge/License-MIT-green)

Bu depo, ** @TamerYavuzz ** YouTube kanalında yayınlanan **"SQL Server Operatörleri"** eğitim videosunun kaynak kodlarını, örnek veritabanı senaryolarını ve ders notlarını içerir.

## 📺 Eğitim Videosu
Projeyi uygulamalı olarak izlemek için:  

[![Video Başlığı](https://img.youtube.com/vi/05qpFmt-4wk/0.jpg)](https://www.youtube.com/watch?v=05qpFmt-4wk)  
  
  
*(Yukarıdaki görsele tıklayarak videoya gidebilirsiniz)*
---

## 📚 İçerik
Bu projede aşağıdaki konular işlenmiştir:
1.  **Aritmetik Operatörler:** `+`, `-`, `*`, `/` ve Modulo `%`
2.  **Karşılaştırma Operatörleri:** `=`, `<>`, `>`, `<`, `>=`, `<=`
3.  **Mantıksal Operatörler:** `AND`, `OR`, `LIKE`, `BETWEEN`, `IN`
4.  **NULL Yönetimi:** `IS NULL` vs `= NULL` hatası
5.  **SQL Server 2025 Yenilikleri:** `||` (Concat), Regex ve Vektör işlemleri

---

## 🛠️ Kurulum ve Test Verisi

Aşağıdaki T-SQL kodunu SQL Server Management Studio (SSMS) üzerinde çalıştırarak eğitimde kullanılan tabloyu ve verileri oluşturabilirsiniz.

```sql
-- Tablo Oluşturma
IF OBJECT_ID('dbo.TestUrunleri', 'U') IS NOT NULL
DROP TABLE dbo.TestUrunleri;
GO

CREATE TABLE dbo.TestUrunleri (
    UrunID INT IDENTITY(1,1) PRIMARY KEY,
    UrunAdi NVARCHAR(100) NOT NULL,
    Kategori NVARCHAR(50),
    BirimFiyat DECIMAL(10, 2) NOT NULL,
    StokAdedi INT NOT NULL,
    SonSatisTarihi DATETIME NULL,
    Aciklama NVARCHAR(255) NULL
);
GO

-- Örnek Verileri Ekleme
INSERT INTO TestUrunleri (UrunAdi, Kategori, BirimFiyat, StokAdedi, SonSatisTarihi, Aciklama)
VALUES
('Laptop X1 Pro', 'Elektronik', 25000.00, 15, '2023-10-25', 'Yüksek performanslı iş bilgisayarı.'),
('Kablosuz Mouse M50', 'Elektronik', 450.50, 102, GETDATE(), 'Ergonomik tasarım.'),
('Gaming Klavye RGB', 'Elektronik', 1200.00, 8, '2023-11-01', NULL),
('4K Monitör 27 inç', 'Elektronik', 8500.00, 0, '2023-09-15', 'Stokta yok.'),
('Deri Ceket (L)', 'Giyim', 3500.00, 20, NULL, 'Hakiki deri.'),
('Kot Pantolon Mavi', 'Giyim', 890.90, 55, '2023-10-05', 'Rahat kesim.'),
('Spor Ayakkabı Run', 'Spor', 2100.00, 13, '2023-11-10', 'Koşu için ideal.'),
('Yoga Matı', 'Spor', 350.00, 4, NULL, NULL);