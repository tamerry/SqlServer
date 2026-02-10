# MSSQL Auto Audit Generator 🔍

Bu proje, Microsoft SQL Server veritabanlarında tablolar üzerindeki veri değişikliklerini (**INSERT, UPDATE, DELETE**) takip etmek için gereken karmaşık denetim (audit) altyapısını **otomatize eden** bir çözümdür.

Tek tek her tablo için tetikleyici (trigger) yazmak yerine, bu proje sayesinde tek bir komutla istediğiniz tabloyu denetim altına alabilirsiniz.

## 🚀 Özellikler

* **Tam Otomasyon:** Hedef tablo için gerekli olan trigger yapısını otomatik olarak oluşturur ve sisteme kaydeder.
* **Detaylı Takip:** İşlemi **Kim** yaptı? **Ne Zaman** yaptı? **Hangi Bilgisayardan** (Hostname) bağlandı?
* **Modern JSON Yapısı:** Eski ve Yeni verileri **JSON** formatında saklar. Bu sayede tablo yapısı değişse (yeni kolon eklense) bile denetim sistemi bozulmadan çalışmaya devam eder.
* **Esnek:** Ekleme, Güncelleme ve Silme işlemlerini tek bir merkezden yönetir.
* **Minimum Kaynak Tüketimi:** Karmaşık ilişkisel tablolar yerine metin tabanlı (JSON) loglama yaparak veritabanı şemasını kirletmez.

## 🛠 Kurulum

Projenin kurulumu oldukça basittir:

1.  Repodaki kurulum dosyasını (`setup.sql` veya benzeri) indirin.
2.  Dosyayı SQL Server Management Studio (SSMS) veya tercih ettiğiniz bir editör ile veritabanınızda çalıştırın.
3.  Bu işlem, logların tutulacağı ana tabloyu ve otomasyonu sağlayan prosedürü veritabanınıza kuracaktır.

## 📖 Kullanım

Kurulum tamamlandıktan sonra sistemi kullanmak için aşağıdaki adımları izleyin:

1.  Veritabanınızda oluşturulan **Otomatik Trigger Oluşturucu Prosedürü** bulun.
2.  Bu prosedürü, takip etmek istediğiniz **Tablo Adı** ve o tablonun **Birincil Anahtar (Primary Key)** kolonunu parametre olarak vererek çalıştırın.
3.  Sistem, ilgili tablo için özel bir tetikleyiciyi (Trigger) anında oluşturacaktır.

Artık o tabloda yapılan her işlem (silme, güncelleme veya ekleme) otomatik olarak log tablosuna kaydedilecektir.

## 📊 Logları İnceleme

Tüm denetim kayıtları, kurulum sırasında oluşturulan **Log Tablosunda** toplanır.

* **Veri Formatı:** Değişiklik öncesi ve sonrası veriler JSON formatında saklanır.
* **Sorgulama:** Standart veritabanı sorguları ile log tablosunu listeleyebilir, veritabanınızın JSON okuma fonksiyonlarını kullanarak detaylı analizler (Örn: Sadece fiyatı değişen ürünleri bulmak gibi) yapabilirsiniz.

## ⚙️ Çalışma Mantığı

Sistemin arka plandaki akışı şöyledir:

```mermaid
graph TD
    A[Kullanıcı / Uygulama] -->|DELETE veya UPDATE Komutu| B(SQL Server Motoru)
    B --> C{Trigger Var mı?}
    C -- Evet --> D[Trigger Tetiklenir]
    
    
    subgraph "Trigger İçindeki İşlemler"
    D --> E[Sanal Tabloları Oku: DELETED & INSERTED]
    E --> F[Veriyi JSON Formatına Çevir]
    F --> G[Kullanıcı ve Bilgisayar Bilgisini Al]
    end
    
    G --> H[(AuditLog Tablosuna Kaydet)]
    H --> I{Mail Atılacak mı?}
    I -- Evet --> J[Yöneticiye E-Posta Gönder]
    I -- Hayır --> K[İşlemi Bitir]