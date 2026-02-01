## 🛒 Perakende Takvimi (Retail Calendar 4-5-4)

Standart takvime ek olarak, proje **NRF 4-5-4 Perakende Takvimi** oluşturan bir script daha içerir. Bu yapı, perakende sektöründe "Yıldan Yıla (YoY)" karşılaştırmaların doğru yapılabilmesi için kritiktir.

### Neden 4-5-4?
* Her yıl ve her hafta aynı gün (Pazar) başlar.
* Her çeyrek tam olarak 13 haftadan oluşur (4 hafta - 5 hafta - 4 hafta).
* Bayram ve kampanya dönemlerinin (Örn: Black Friday) her yıl haftanın aynı gününe denk gelmesini sağlar.
* **53. Hafta Yönetimi:** Yaklaşık her 5-6 yılda bir gelen "Artık Hafta" otomatik olarak 12. aya eklenir.

### Perakende Tablo Yapısı (`DimPerakendeTarih`)
```plaintext
| Kolon | Açıklama |
| :--- | :--- |
| `PerakendeYil` | Mali Yıl (Fiscal Year). Genellikle Şubat ayında başlar. |
| `PerakendeAy` | 1-12 arası dönem numarası. |
| `PerakendeHafta` | 1-52 (veya 53) arası hafta numarası. |
| `PerakendeCeyrek`| 1-4 arası çeyrek bilgisi. |
| `HaftaBaslangic` | O haftanın Pazar günü tarihi. |

```