# 📊 Haftalık Konsolide Satış Raporu (SQL)

Bu proje, yerel ve uzak sunucularda (Linked Server) bulunan mağaza veritabanlarından anlık satış verilerini çeken, bunları ülke bazında gruplayan ve okunabilir bir formatta sunan bir T-SQL scriptidir.

## 🚀 Özellikler

* **Çoklu Kaynak:** Türkiye (Yerel), Ülke1 ve Ülke2 (Linked Server) veritabanlarından veriyi tek merkezde toplar.
* **Otomatik Hesaplama:** İadeleri, satır/alt iskontoları düşerek **Net Satış** rakamını hesaplar.
* **Haftalık Filtre:** Otomatik olarak içinde bulunulan haftanın başından (Pazartesi) anlık zamana kadar olan veriyi getirir.
* **Formatlama:** Para birimlerini (TL ve €) otomatik ekler, veri olmayan günleri "SATIS YOK" olarak etiketler.
* **Pivot Yapı:** Tarihleri satıra, ülkeleri sütuna çevirerek özet tablo oluşturur.

## 🛠 Gereksinimler

Bu scriptin hatasız çalışması için SQL Server ortamında aşağıdaki tanımlamaların yapılmış olması gerekir:

1.  **Linked Server Tanımları:**
    * `GeniusULKE1`
    * `GeniusULKE2`
2.  **Veritabanı Yapısı:**
    * Hedef sunucularda `GENIUS3` veritabanı ve `TRANSACTION_HEADER` tablosu erişilebilir olmalıdır.
3.  **SQL Sürümü:**
    * `FORMAT` fonksiyonu kullanıldığı için SQL Server 2012 veya üzeri gereklidir.

## ⚙️ Hesaplama Mantığı

Satış verileri çekilirken aşağıdaki formül kullanılır:

text
Net Ciro = (İşlem Yönü * (Brüt Tutar - (Satır İskonto + Genel İskonto)))


⚙️ Sorgu Mantığı
Sorgu 3 ana aşamadan oluşur:

1. Veri Birleştirme (UNION ALL)
Her üç kaynaktan aşağıdaki formül ile Net Satış hesaplanır:


NetSatış = (Yön * (Brüt Tutar - (Satır İskonto + Genel İskonto)))
Yön: PTYPE 2 ise (İade) -1, değilse +1

2. Pivot İşlemi
Alt alta gelen veriler (Satırlar), ülke isimlerine göre yan yana sütunlara (Columns) dönüştürülür.

Kaynak: ANASORGU

Hedef Sütunlar: [TÜRKİYE], [ULKE1], [ULKE2]

3. Çıktı Formatlama
Sonuç tablosu #SatisRaporu adında geçici bir tabloya (Temp Table) yazılır. Para birimleri eklenir:
text
Türkiye -> TL

Ülke 1 -> TL

Ülke 2 (Eu zone) -> €

⚠️ Önemli Notlar
Tarih Formatı: Tarihler dd.mm.yyyy (Convert 104) formatında gelir.

Dil Ayarları: FORMAT fonksiyonu tr-TR kültürünü kullanır. Sunucu dil ayarlarından bağımsız olarak Türkçe formatlama yapar.

Geçici Tablo: Script her çalıştığında DROP TABLE komutu ile önceki #SatisRaporu tablosunu siler ve yeniden oluşturur.

💻 Kurulum ve Çalıştırma
SQL Server Management Studio (SSMS) uygulamasını açın.

Yeni bir sorgu penceresi (New Query) oluşturun.

Kodları yapıştırın ve F5 tuşuna basarak çalıştırın.

Sonuçları görmek için scriptin en altına şu satırı ekleyebilirsiniz:

sql
SELECT * FROM #SatisRaporu