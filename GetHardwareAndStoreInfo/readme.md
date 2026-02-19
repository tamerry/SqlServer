# 🚀 T-SQL Donanım ve Mağaza Bilgisi Çekme Betiği

Bu T-SQL betiği, üzerinde çalıştığı SQL Server sunucusunun donanım bilgilerini (Seri Numarası, Model, Marka) ve `Genius3` veritabanından mağaza açıklamasını tek bir sorgu sonucu olarak döndürür. İşletim sistemi seviyesindeki donanım bilgilerini alabilmek için geçici olarak `xp_cmdshell` özelliğini kullanır ve PowerShell üzerinden WMI sorgusu çalıştırır.

## 🌟 Özellikler

* **Yerleşik PowerShell Kullanımı:** `xp_cmdshell` üzerinden WMI (`Win32_ComputerSystemProduct`) sorgusu atarak işletim sistemi seviyesinde fiziksel veya sanal donanım bilgilerini çeker.
* **Akıllı Metin Parçalama (XML Yöntemi):** PowerShell'den dönen ve `@` karakteri ile ayrılmış olan string veriyi (örn: `SeriNo@Model@Marka`), T-SQL'in güçlü XML yeteneklerini kullanarak performanslı bir şekilde sütunlara ayırır.
* **Geçici Yetkilendirme:** Güvenlik risklerini en aza indirmek amacıyla `xp_cmdshell` özelliği sadece komutun çalıştırılacağı anlık sürede açık kalır, işlem biter bitmez otomatik olarak tekrar kapatılır.
* **Hata Toleransı (Try/Catch):** `Genius3` veritabanında ilgili tablo veya kayıt bulunamazsa betik çökmez; "SORGU HATASI" veya "KAYIT BULUNAMADI" mesajı vererek donanım bilgilerini getirmeye devam eder.

## 📋 Gereksinimler

* **Yetki:** Betiği çalıştıran kullanıcının `sp_configure` ayarlarını değiştirebilmesi ve `xp_cmdshell` çalıştırabilmesi için `sysadmin` rolüne (örn: `sa` kullanıcısı) sahip olması gerekir.
* **Veritabanı:** Mağaza bilgisinin tam ve doğru gelebilmesi için sunucuda `Genius3` adlı bir veritabanı bulunmalıdır (Yoksa donanım bilgileri yine de gelir, mağaza kısmı hata verir).

## 🛠️ Kullanım

1. Kodu SQL Server Management Studio (SSMS) veya Azure Data Studio gibi bir arayüzde **New Query** (Yeni Sorgu) penceresine yapıştırın.
2. `F5` tuşuna basarak veya **Execute** (Çalıştır) butonuna tıklayarak betiği çalıştırın.
3. Sonuç (Results) sekmesinde şu formatta tek bir satır dönecektir:
   * `Sunucu (IP/İsim)` | `Mağaza Açıklaması` | `Seri No` | `Model` | `Marka`

## ⚠️ Güvenlik ve Uyarılar

* **`xp_cmdshell` Riski:** Bu betik işletim sistemi seviyesinde komut çalıştırma yetkisi gerektirir. Betik, işlemi bitirdikten sonra yetkiyi geri alsa da, `xp_cmdshell` özelliğinin üretim (production) ortamlarında kullanımı güvenlik politikalarına (örneğin şirket güvenlik duvarları veya antivirüs kuralları) takılabilir.
* **Sınırlı Veritabanı Değişimi:** Betik spesifik olarak `Genius3.GENIUS3.STORE` tablosuna hard-coded olarak bağlanmaktadır. Farklı bir veritabanı yapısında kullanmak isterseniz `BEGIN TRY` bloğundaki `SELECT` sorgusunu güncellemeniz gerekir.

## 🤝 Katkıda Bulunma

Geliştirmelere açıktır. Özellikle WMI sorgusuna eklenecek yeni parametreler (RAM, CPU, Disk bilgisi vb.) için Pull Request gönderebilirsiniz.

## 📝 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır. Serbestçe kullanılabilir ve değiştirilebilir.