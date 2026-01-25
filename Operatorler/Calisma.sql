
SELECT 
    UrunAdi,
    BirimFiyat,
    BirimFiyat * 1.20 AS KdvliFiyat,    -- Çarpma
    StokAdedi - 1 AS SatisSonrasiStok, -- Çıkarma
    StokAdedi + 1 AS SatisSonrasiStok, -- Toplama
    StokAdedi / 2 AS SatisSonrasiStok,  -- Bölme
    StokAdedi % 2 AS SatisSonrasiStok -- Bölümden Kalan

FROM TestUrunleri;


SELECT * FROM TestUrunleri
WHERE BirimFiyat > 2000 
AND (Kategori = 'Elektronik' OR Kategori = 'Spor');
-- Alternatif olarak IN kullanımı: AND Kategori IN ('Elektronik', 'Spor');

SELECT * FROM TestUrunleri
WHERE Aciklama IS NULL; -- Açıklama sütunu boş olan kayıtlar

SELECT * FROM TestUrunleri
WHERE Aciklama IS NOT NULL; -- Açıklama sütunu dolu olan kayıtlar

SELECT * FROM TestUrunleri
WHERE UrunAdi LIKE '%Pro%'; -- UrunAdi içinde 'Pro' geçen kayıtlar  
-- Diğer LIKE örnekleri:
-- WHERE UrunAdi LIKE 'Laptop%'  -- 'Laptop' ile başlayanlar    
-- WHERE UrunAdi LIKE '%27 inç' -- '27 inç' ile bitenler
-- WHERE UrunAdi LIKE '_at%'    -- İkinci harfi 'a' olanlar (örneğin 'Kat', 'Mat' gibi)


SELECT * FROM TestUrunleri
WHERE StokAdedi % 2 = 0; -- StokAdedi çift olan kayıtlar

SELECT * FROM TestUrunleri
WHERE SonSatisTarihi < '2023-10-01'; -- 1 Ekim 2023'ten önce satılan ürünler

SELECT * FROM TestUrunleri
WHERE SonSatisTarihi IS NULL; -- Hiç satılmamış ürünler (Tarih NULL)

SELECT * FROM TestUrunleri
WHERE StokAdedi BETWEEN 10 AND 50; -- StokAdedi 10 ile 50 arasında olan kayıtlar

SELECT * FROM TestUrunleri
WHERE Kategori IN ('Giyim', 'Spor'); -- Kategori 'Giyim' veya 'Spor' olan kayıtlar  

SELECT * FROM TestUrunleri
WHERE BirimFiyat + 1000 < 5000; -- BirimFiyat'a 1000 eklenince 5000'den az olan kayıtlar    


SELECT 
    UrunAdi,
    Kategori,
    UrunAdi + '  ' + Kategori AS UrunVeKategori

FROM TestUrunleri;  -- Metin birleştirme (Concatenation)

--ansi_nulls özelliği açık ise metin birleştirme işlemi NULL değer içeriyorsa sonuç da NULL olur.
--SET ANSI_NULLS OFF; -- Bu komut ANSI NULL davranışını kapatır 

SELECT 
    UrunAdi,
    Kategori,
    ISNULL(Aciklama, 'Açıklama yok') AS AciklamaBilgisi
FROM TestUrunleri;  -- ISNULL ile NULL değer yerine varsayılan metin ekleme

    
--ANSI Concatenation
SET ANSI_NULLS OFF;     
SET ANSI_NULLS OFF;     
SELECT 
    UrunAdi,
    Kategori,
    UrunAdi   ||   ISNULL(Kategori, 'Kategori Yok') AS UrunVeKategori 
    FROM TestUrunleri
