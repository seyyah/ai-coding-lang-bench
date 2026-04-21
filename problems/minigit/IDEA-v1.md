# MiniGit — İçerik-Adresli Mikro Sürüm Kontrolü

*Git'in temel döngüsünü (içerik-adresli depolama + doğrusal commit zinciri) dış bağımlılık olmadan, deterministik bir bayt-düzeyi kontratla yeniden üreten minimal sürüm kontrol aracı.*

> Bu belge IDEA standardını takip etmektedir. Tek satır kod yazılmadan önce MiniGit'in ne olduğunu, yazılım mimarisini ve neden `which-language` benchmark'ının referans problemlerinden biri olduğunu açıklar. Karpathy'nin autoresearch ve LLM-wiki felsefesiyle uyumludur.

---

## 1. Tez (Thesis)

Git; çoğu yazılım mühendisi için günlük kullandığı ama içini bilmediği bir "büyülü kutu"dur. Onu demistifiye etmenin en hızlı yolu dokümantasyon okumak değil, **çekirdek döngüyü kendi elleriyle yeniden inşa etmektir**: dosyayı hash'le, blob olarak sakla, commit dosyasıyla zincire bağla, HEAD'i güncelle.

**MiniGit; bir LLM codex'inin standart kütüphane dışında hiçbir araca dayanmadan, deterministik bir hash algoritması ve 5 komut ile Git'in özündeki versiyonlama soyutlamasını ~200 satırda üretebilmesini ölçen, çalıştırılabilir bir spesifikasyondur.**

---

## 2. Problem

Benchmark'ın araştırma sorusu şudur: bir codex × dil kombinasyonu, *hafif CRUD*'un ötesinde, birkaç invariantın eş zamanlı tutulmasını gerektiren bir sistem ne kadar iyi üretebilir?

MiniGit bu soruya üç stres ekseni getirir:

* **Deterministik bayt-düzeyi kontrat:** `MiniHash` (FNV-1a varyantı) çıktısı, üretilen kodun harf harf doğru olmasını zorunlu kılar. "Yaklaşık doğru" kabul edilmez.
* **Durum tutarlılığı:** `.minigit/HEAD`, `.minigit/index`, `objects/`, `commits/` arasındaki ilişki tek bir komut hatasında çöker — LLM'in soyutlamayı tutarlı tutma disiplinini ölçer.
* **Dil ekosistemi farklılığı:** 64-bit unsigned integer aritmetiği ve bayt bazlı I/O her dilde aynı kolaylıkta değildir. Python'da `int` sınırsız, Go'da `uint64` overflow davranışı farklı, JavaScript'te `BigInt` gerekir, Haskell'de `Data.Word` devreye girer. Aynı problem farklı dillerde farklı tuzaklar sunar.

---

## 3. Nasıl Çalışır (How It Works)

### Temel İçgörü 1 — Tek Depo Dizini, Tek Ağaç
Tüm repo durumu `.minigit/` altındadır. Komutlar çalıştırıldıkları dizine göredir. Network, remote, branch gibi kavramlar v1 kapsamında **yoktur**; basitlik hedeftir, zaaf değil.

### Temel İçgörü 2 — İçerik-Adresli Depolama (Content-Addressed Storage)
Bir dosya eklenirken içeriği üzerinde MiniHash hesaplanır; blob `objects/<hash>` olarak saklanır. İki dosya aynı içeriğe sahipse aynı bloba işaret eder — bu, Git'in "deduplikasyon bedava" özelliğinin minimal uygulamasıdır ve test-10'da doğrulanır.

### Temel İçgörü 3 — Doğrusal Commit Zinciri
Her commit; `parent`, `timestamp`, `message` ve `files` satırlarından oluşan bir düz metin dosyasıdır. Commit hash'i, commit dosyasının tüm içeriği üzerinde MiniHash çalıştırılarak üretilir (yani commit hash'i de içerik-adreslidir). `HEAD` yalnız bu zincirin son halkasını tutar.

### Temel İçgörü 4 — Bayt-Seviyesi Determinizm
Dosya isimleri leksikografik sıralanır, ekstra boşluk yoktur, debug çıktısı yazılmaz. Her komut çıktısı test süitinde string düzeyinde karşılaştırılır. LLM üretimini "yaklaşık olarak doğru" kabul etmeyen bu sertlik, codex değerlendirmesi için kritiktir — halüsinasyonu anında açığa çıkarır.

### 3.x Teknik Kontrat (Implementation Contract)

Test süitinin birebir geçebilmesi için aşağıdaki kontrat aynen uygulanmalıdır. Çıktı string'leri İngilizcedir ve testler bu string'leri literal olarak arar.

**Yürütülebilir adı:** `minigit` — derlenmiş dillerde `Makefile` veya `build.sh`, yorumlanan dillerde doğru shebang ile `./minigit` olarak çalıştırılabilir.

**Kısıtlamalar:**
- Harici kütüphane **yasak**, yalnızca standart kütüphane serbest.
- Kalıcı depolama yalnızca yerel dosya sistemi.
- Kripto kütüphanesi **yasak** (MiniHash'in kendisi gereklidir).

**Depo yapısı (`init` sonrası):**

```
.minigit/
    objects/       # blob depolama
    commits/       # commit dosyaları
    index          # staged dosya isimleri, satır başına bir tane
    HEAD           # son commit hash'i ya da boş
```

**MiniHash algoritması (ZORUNLU):**

- Girdi: ham bayt dizisi
- Çıktı: 16 karakter küçük harf hex
- Başlangıç: `h = 1469598103934665603` (64-bit unsigned)
- Her bayt `b` için:
  - `h = h XOR b`
  - `h = (h * 1099511628211) mod 2^64`
- Sonuç: 64-bit değerin 16 karakter sıfır-doldurmalı küçük harf hex gösterimi.
- Bu SHA **değildir**. FNV-1a varyantıdır. Kriptografik iddiası yoktur.

**Komutlar:**

| Komut | Davranış | Çıktı / Hata |
|---|---|---|
| `minigit init` | `.minigit/` yapısını kurar | Zaten varsa: `Repository already initialized` (exit 0) |
| `minigit add <file>` | Dosyayı hash'ler, blob yazar, index'e ekler (zaten eklenmişse tekrar etmez) | Dosya yok: `File not found` (exit 1) |
| `minigit commit -m "<msg>"` | Index'ten commit üretir, HEAD'i günceller, index'i temizler | Boş index: `Nothing to commit` (exit 1). Başarı: `Committed <commit_hash>` |
| `minigit log` | HEAD'den başlayıp parent zincirini gezer (en yeniden en eskiye) | Commit yok: `No commits`. Aksi halde her commit için üç satır (aşağıda) |
| `minigit status` | Staged dosyaları listeler (satır başına bir tane) | Boş index: `Nothing staged` |

**`log` çıktı formatı** (her commit için birebir):
```
commit <hash>
Date: <timestamp>
Message: <message>
```

**Commit dosyası formatı** (birebir, `.minigit/commits/<commit_hash>`):
```
parent: <parent_hash or NONE>
timestamp: <unix_epoch_integer>
message: <message>
files:
<filename> <blobhash>
<filename> <blobhash>
```

- Dosya isimleri leksikografik sıralı
- `parent` = HEAD'de hash varsa o hash, yoksa tam olarak `NONE` (büyük harf)
- `timestamp` = unix epoch tam sayısı
- Commit hash = commit dosyasının tüm içeriği üzerinde MiniHash

**Determinizm kuralları:**
- Dosya isimleri sıralı
- Ekstra boşluk/satır yok
- Debug çıktısı yazılmaz
- Tam string eşleşme zorunlu

**Test süiti:** `bash test-v1.sh` — 13 test. Hepsi geçmeli.

---

## 4. Ne Yapmaz (What It Does Not Do)

* **Branch'leme yoktur:** Tek doğrusal tarih, tek HEAD.
* **Merge, rebase, cherry-pick yoktur:** v1'in hiçbir komutu ağaç topolojisini değiştirmez.
* **Diff, checkout, reset, rm, show yoktur:** Bunlar v2'de eklenir (`IDEA-v2.md`).
* **Uzaktan operasyon (clone/push/pull) yoktur:** Yerel dosya sistemi dışı hedef yok.
* **SHA veya kriptografik hash yoktur:** MiniHash açıkça FNV-1a varyantıdır.
* **Etkileşimli arayüz yoktur:** Komut tek seferde çalışır, stdin'den beklemez.
* **"Kirli working directory" koruması yoktur:** v1 yalnız yazar, geri dönüş senaryosu v2'ye aittir.

---

## 5. Neden Şimdi (Why Now)

* **Karpathy'nin autoresearch çağı:** LLM'lerin kod üretip kendi çıktısını test süitinde doğruladığı döngüler artık benchmark standardı. MiniGit; bir codex'in "idea-to-working-system" kapasitesini gerçek bir sistemin küçültülmüş versiyonu üzerinde ölçen reprodüksiyonlu referans.
* **Dil-bağımsız kıyaslama ihtiyacı:** Aynı problemin 15 dilde üretilip karşılaştırılması, bir dilin ekosisteminin LLM için ne kadar "doğal" olduğunu ampirik olarak ortaya koyar.
* **Framing araştırma sorusu:** Aynı problem iki framing altında (SPEC kuralcı teknik metni vs IDEA anayasası) aynı codex'e verildiğinde pass rate / LOC / maliyet farkı, Karpathy'nin LLM-wiki tezinin bu repoda ampirik testini oluşturur. `problems/minigit/SPEC-v1.txt` ve `problems/minigit/IDEA-v1.md` aynı kontratı iki farklı framing'le taşır.

---

## 6. Kim Fayda Sağlar (Who Benefits)

* **Codex değerlendiricileri:** Bir modelin küçük-ama-bütünsel bir sistem üretme kapasitesini, hafif CRUD'u aşan tek referans problem üzerinde ölçenler.
* **Dil ekosistemi araştırmacıları:** Aynı deterministik kontratın farklı dillerde ne kadar satır koda maloluyor, hangi dillerde halüsinasyon oranı yüksek, hangilerinde düşük — bunu görmek isteyenler.
* **Framing araştırmacıları:** SPEC (imperative teknik metin) ile IDEA (vizyon + teknik kontrat) arasında LLM kod üretim kalitesi farkını ölçen deneyciler.
* **Yazılım eğitimcileri:** Git'in iç yapısını ~200 satırlık çalışan bir referansla anlatmak isteyenler.
* **`which-language` benchmark'ının kendisi:** Diğer problemlerin karmaşıklık eksenine göre kalibrasyonu MiniGit referans alınarak yapılabilir.

---

## 7. Özet (Summary)

MiniGit; içerik-adresli depolama, doğrusal commit zinciri ve bayt-düzeyi deterministik bir hash algoritmasıyla Git'in çekirdek döngüsünü yeniden kuran, ~200 satırlık bir mikro sürüm kontrol aracıdır. Harici kütüphane yasaktır; çıktılar string düzeyinde testlenir; aynı problem farklı dillerde farklı ekosistem tuzakları ortaya çıkarır. `which-language` benchmark'ında MiniGit, bir codex × dil çiftinin "idea-to-working-system" kapasitesini, hafif CRUD probleminin üzerindeki bir karmaşıklık eşiğinde ölçen referans testtir. v1 yazan-çekirdeği kurar; v2 geçmişe dönme, farkları görme ve index müdahalesi gibi "okuyan/geri dönen" operasyonları ekler (bkz. `IDEA-v2.md`).
