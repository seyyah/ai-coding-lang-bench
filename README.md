# mini-grades

Komut satırı tabanlı öğrenci not yönetim sistemi.  
Veriler `grades.txt` dosyasında saklanır.

---

## Kullanım

```
python mini-grades-v2.py <komut> [argümanlar]
```

## Komutlar

| Komut | Açıklama |
|-------|----------|
| `init` | `grades.txt` dosyasını oluşturur |
| `ogrenci-ekle <isim>` | Yeni öğrenci ekler |
| `not-gir <id> <not>` | Öğrenciye not ekler (0-100) |
| `listele` | Tüm öğrencileri listeler |
| `ara <kelime>` | İsme göre öğrenci arar (büyük/küçük harf duyarsız) |
| `ortalama <id>` | Öğrencinin not ortalamasını hesaplar |
| `not-listele <id>` | Öğrencinin tüm notlarını listeler |

## Örnek

```
python mini-grades-v2.py init
python mini-grades-v2.py ogrenci-ekle "Ali Veli"
python mini-grades-v2.py not-gir 1 85
python mini-grades-v2.py not-gir 1 90
python mini-grades-v2.py ara "Ali"
python mini-grades-v2.py ortalama 1
python mini-grades-v2.py not-listele 1
python mini-grades-v2.py listele
```

---

## Sürüm Geçmişi

### v0
- `init`, `ogrenci-ekle`, `not-gir` komutları eklendi
- Temel dosya okuma/yazma ve ID yönetimi

### v1
- `listele` komutu eklendi (`while` döngüsü ile satır satır okuma)
- Bilinmeyen komut hatası eklendi
- SPEC v1 olarak güncellendi

### v2
- `ara` komutu eklendi: isim araması (`for` döngüsü + string `in` operatörü)
- `ortalama` komutu eklendi: `for` döngüsü ile not toplama ve ortalama hesabı
- `not-listele` komutu eklendi: belirli öğrencinin notlarını `for` ile listeler
- SPEC v2 olarak güncellendi

---

## Veri Formatı

```
STUDENT|1|Ali Veli
GRADE|1|85
GRADE|1|90
```

---

Geliştirici: Davud Kılıç — 251478023
