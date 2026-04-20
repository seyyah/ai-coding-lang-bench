# Mini To-Do List Project - V2

Bu proje, Programlamaya Giriş II dersi kapsamında geliştirilen, komut satırı üzerinden çalışan bir görev yönetim uygulamasıdır.

## V1 Görevleri (V1 Tasks)
[cite_start]V1 aşamasında projenin temel iskeleti oluşturulmuş ve şu özellikler eklenmiştir: [cite: 786]
* [cite_start]**Temel Komutlar:** `init` ve `add` komutları işlevsel hale getirildi. [cite: 781]
* **Döngü Kullanımı:** `while` döngüsü kullanılarak dosyadan satır satır okuma yapıldı.
* **Durum Güncelleme:** `done` komutu ile görevlerin durumu "PENDING"den "DONE"a çekildi.

## V2 Görevleri (V2 Tasks)
[cite_start]V2 aşamasında Ders 4'te öğrenilen String metotları ve biçimlendirme teknikleri projeye dahil edilmiştir: [cite: 842, 847]
1. [cite_start]**Gelişmiş Arama (`search`):** String içinde arama metotları kullanılarak görevler arasında filtreleme yapılması sağlandı. [cite: 558-560]
2. [cite_start]**Girdi Doğrulaması:** `isalpha()` ve `strip()` metotları ile boş veya sadece sayıdan oluşan hatalı görev girişleri engellendi. [cite: 22-29]
3. [cite_start]**Tablo Görünümü:** `list` komutu çıktısı, string biçimlendirme operatörleri (`:^`, `:<`) ile düzenli bir tablo formatına getirildi. [cite: 66-74]

## V1 ve V2 Arasındaki Farklar (V1 vs V2 Comparison)
[cite_start]Projenin V2 sürümü, V1 sürümüne göre hem teknik hem de kullanıcı deneyimi açısından şu farkları içerir: [cite: 792, 849]

| Özellik | V1 Sürümü | V2 Sürümü (Güncel) |
| :--- | :--- | :--- |
| **Girdi Kontrolü** | Kontrol yok, her metin ekleniyordu. | [cite_start]`isalpha()` ile sadece geçerli metinler kabul ediliyor. [cite: 28-29] |
| **Görsel Çıktı** | Düz metin (raw text) formatı. | [cite_start]Hizalanmış tablo formatı (`format()` metodu). [cite: 53-56] |
| **Arama** | Özellik bulunmuyordu. | [cite_start]Kelime bazlı arama (`search`) özelliği eklendi. [cite: 558-560] |
| **Veri Yapısı** | Temel ayraç kullanımı. | [cite_start]Biçimlendirilmiş ve doğrulanmış veri girişi. [cite: 100-108] |
