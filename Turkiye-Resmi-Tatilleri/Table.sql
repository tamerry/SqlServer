IF OBJECT_ID('TurkiyeTakvim', 'U') IS NOT NULL DROP TABLE TurkiyeTakvim;

CREATE TABLE TurkiyeTakvim (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Tarih DATE NOT NULL,
    EtkinlikAdi NVARCHAR(150) NOT NULL,
    Kategori NVARCHAR(50), -- 'Resmi Tatil', 'Dini Tatil', 'Okul'
    Aciklama NVARCHAR(250)
);

CREATE INDEX IX_Tarih_Yil ON TurkiyeTakvim(Tarih);
GO

-- A. SABİT RESMİ TATİLLER (2020-2030)
DECLARE @Yil INT = 2020;
WHILE @Yil <= 2030
BEGIN
    INSERT INTO TurkiyeTakvim (Tarih, EtkinlikAdi, Kategori, Aciklama) VALUES
    (CAST(CAST(@Yil AS VARCHAR) + '-01-01' AS DATE), 'Yılbaşı', 'Resmi Tatil', 'Yılın ilk günü'),
    (CAST(CAST(@Yil AS VARCHAR) + '-04-23' AS DATE), 'Ulusal Egemenlik ve Çocuk Bayramı', 'Resmi Tatil', '23 Nisan'),
    (CAST(CAST(@Yil AS VARCHAR) + '-05-01' AS DATE), 'Emek ve Dayanışma Günü', 'Resmi Tatil', '1 Mayıs'),
    (CAST(CAST(@Yil AS VARCHAR) + '-05-19' AS DATE), 'Atatürk''ü Anma, Gençlik ve Spor Bayramı', 'Resmi Tatil', '19 Mayıs'),
    (CAST(CAST(@Yil AS VARCHAR) + '-07-15' AS DATE), 'Demokrasi ve Milli Birlik Günü', 'Resmi Tatil', '15 Temmuz'),
    (CAST(CAST(@Yil AS VARCHAR) + '-08-30' AS DATE), 'Zafer Bayramı', 'Resmi Tatil', '30 Ağustos'),
    (CAST(CAST(@Yil AS VARCHAR) + '-10-29' AS DATE), 'Cumhuriyet Bayramı', 'Resmi Tatil', '29 Ekim');
    SET @Yil = @Yil + 1;
END;

-- B. DEĞİŞKEN DİNİ BAYRAMLAR (Ramazan ve Kurban Bayramı 1. Günleri)
-- Not: Dini bayramlar 3-4 gün sürer, burada başlangıç tarihleri baz alınmıştır.
INSERT INTO TurkiyeTakvim (Tarih, EtkinlikAdi, Kategori) VALUES
('2020-05-24', 'Ramazan Bayramı', 'Dini Tatil'), ('2020-07-31', 'Kurban Bayramı', 'Dini Tatil'),
('2021-05-13', 'Ramazan Bayramı', 'Dini Tatil'), ('2021-07-20', 'Kurban Bayramı', 'Dini Tatil'),
('2022-05-02', 'Ramazan Bayramı', 'Dini Tatil'), ('2022-07-09', 'Kurban Bayramı', 'Dini Tatil'),
('2023-04-21', 'Ramazan Bayramı', 'Dini Tatil'), ('2023-06-28', 'Kurban Bayramı', 'Dini Tatil'),
('2024-04-10', 'Ramazan Bayramı', 'Dini Tatil'), ('2024-06-16', 'Kurban Bayramı', 'Dini Tatil'),
('2025-03-30', 'Ramazan Bayramı', 'Dini Tatil'), ('2025-06-06', 'Kurban Bayramı', 'Dini Tatil'),
('2026-03-20', 'Ramazan Bayramı', 'Dini Tatil'), ('2026-05-27', 'Kurban Bayramı', 'Dini Tatil'),
('2027-03-09', 'Ramazan Bayramı', 'Dini Tatil'), ('2027-05-16', 'Kurban Bayramı', 'Dini Tatil'),
('2028-02-26', 'Ramazan Bayramı', 'Dini Tatil'), ('2028-05-04', 'Kurban Bayramı', 'Dini Tatil'),
('2029-02-14', 'Ramazan Bayramı', 'Dini Tatil'), ('2029-04-23', 'Kurban Bayramı', 'Dini Tatil'),
('2030-02-04', 'Ramazan Bayramı', 'Dini Tatil'), ('2030-04-12', 'Kurban Bayramı', 'Dini Tatil');

-- C. OKUL TAKVİMİ (Tahmini Dönemler)
INSERT INTO TurkiyeTakvim (Tarih, EtkinlikAdi, Kategori) VALUES
('2025-09-08', 'Okulların Açılışı', 'Okul'), ('2026-01-19', 'Sömestr Başlangıcı', 'Okul'),
('2026-06-19', 'Okulların Kapanışı', 'Okul'), ('2026-09-14', 'Okulların Açılışı', 'Okul'),
('2027-01-22', 'Sömestr Başlangıcı', 'Okul'), ('2027-06-18', 'Okulların Kapanışı', 'Okul');
-- (Bu liste 2030'a kadar benzer mantıkla uzatılabilir)