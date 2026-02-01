# MSSQL Takvim ve Tarih Boyut Tablosu (2020-2040) 📅

Bu proje, SQL Server (MSSQL) veritabanları için **2020 ile 2040** yılları arasını kapsayan, Türkçe yerelleştirmesi yapılmış, performans odaklı bir **Tarih Boyut Tablosu (Date Dimension)** oluşturur.

Özellikle Veri Ambarı (Data Warehouse), İş Zekası (BI) projeleri ve Power BI raporlama süreçlerinde `JOIN` işlemleri ve zaman serisi analizleri için tasarlanmıştır.

## 🚀 Özellikler

* **Geniş Aralık:** 2020'den 2040'a kadar tüm günleri içerir (Yaklaşık 7.600+ satır).
* **Türkçe Yerelleştirme:** Ay ve Gün isimleri Türkçe olarak oluşturulur (`tr-TR`).
* **Performans Odaklı:** `JOIN` işlemleri için `INT` tipinde `TarihKey` (Örn: `20231029`) içerir.
* **Türkiye Standartları:** Haftanın başlangıcı **Pazartesi** olarak ayarlanmıştır.
* **Hafta Sonu İşaretleyicisi:** Raporlarda hafta içi/hafta sonu ayrımı yapmak için hazır `BIT` kolonu bulunur.
* **Recursive CTE:** Döngü (Cursor veya While) kullanmadan, set-based yaklaşım ile milisaniyeler içinde tabloyu oluşturur.

## 📋 Tablo Yapısı (Schema)

Oluşturulan `DimTarih` tablosunun yapısı aşağıdaki gibidir:
```plaintext
| Kolon Adı | Veri Tipi | Açıklama | Örnek Veri |
| :--- | :--- | :--- | :--- |
| `TarihKey` | `INT` | YYYYMMDD formatında birincil anahtar | `20231029` |
| `Tarih` | `DATE` | Standart tarih formatı | `2023-10-29` |
| `Yil` | `INT` | Yıl bilgisi | `2023` |
| `Ay` | `INT` | Ay numarası (1-12) | `10` |
| `AyAdi` | `NVARCHAR` | Tam ay adı (Türkçe) | `Ekim` |
| `Gun` | `INT` | Ayın günü | `29` |
| `GunAdi` | `NVARCHAR` | Gün adı (Türkçe) | `Pazar` |
| `YilinGunu` | `INT` | Yılın kaçıncı günü (1-366) | `302` |
| `HaftaninGunu`| `INT` | Haftanın kaçıncı günü (Pzt=1) | `7` |
| `YilinHaftasi`| `INT` | Yılın kaçıncı haftası (ISO) | `43` |
| `Ceyrek` | `INT` | Yıl çeyreği (1-4) | `4` |
| `CeyrekAdi` | `VARCHAR` | Çeyrek etiketi | `Q4` |
| `HaftaSonuMu` | `BIT` | Hafta sonu kontrolü (1=Evet, 0=Hayır)| `1` |
```
## ⚙️ Kurulum ve Kullanım

1.  Repo içerisindeki `.sql` dosyasını indirin veya kopyalayın.
2.  SQL Server Management Studio (SSMS) üzerinde scripti çalıştırın.
3.  Script, veritabanınızda `dbo.DimTarih` tablosunu otomatik olarak oluşturacak ve dolduracaktır.

### Örnek Sorgu

Tablo oluşturulduktan sonra satışları hafta sonuna göre analiz etmek için şöyle bir sorgu yazabilirsiniz:

```sql
SELECT 
    T.Yil,
    T.AyAdi,
    CASE WHEN T.HaftaSonuMu = 1 THEN 'Hafta Sonu' ELSE 'Hafta İçi' END AS Donem,
    SUM(S.TotalDue) AS ToplamSatis
FROM Sales.SalesOrderHeader S
INNER JOIN dbo.DimTarih T ON CAST(FORMAT(S.OrderDate, 'yyyyMMdd') AS INT) = T.TarihKey
GROUP BY T.Yil, T.AyAdi, T.HaftaSonuMu
ORDER BY T.Yil, T.AyAdi;
```