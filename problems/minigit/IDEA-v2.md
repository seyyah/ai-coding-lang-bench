# MiniGit v2 — Geriye Dönüş, Fark Görmek, Index Müdahalesi

*v1'in yazma-ağırlıklı çekirdeğini; `checkout`, `reset`, `diff`, `rm`, `show` komutları ve sertleştirilmiş `status` formatıyla geçmişi okuyan ve index'i manipüle edebilen tam-döngülü bir VCS'e dönüştüren uzantı katmanı.*

> Bu belge `IDEA-v1.md`'yi genişletir. v1'in tezi, problem çerçevesi ve teknik kontratı aynen geçerlidir; burada yalnız **v2 deltası** tanımlanır. v2 implementasyonu v1'in tüm davranışlarını korumalı ve `bash test-v2.sh`'i tam geçmelidir.

---

## 1. Tez (Thesis)

v1, Git'in yazma tarafını (hash, blob, commit, HEAD) kurdu. Ama bir VCS yalnız yazmakla değil, **geriye gitmek, iki anlık fotoğrafı kıyaslamak ve index'e müdahale edebilmek** ile bir araçtır.

**MiniGit v2; aynı deterministik kontratı koruyarak tarihe dokunma yetkisini kullanıcıya veren beş yeni komut (`checkout`, `reset`, `diff`, `rm`, `show`) ve bilinçli bir format sertleştirmesi (`status`) ile sistemin döngüsünü kapatır.**

---

## 2. Problem

v1'de bir "ufak hata"nın dönüşü yok — yanlış commit atıldı, index yanlış dosyayla doldu, eski bir state'e bakmak isteniyor: elde hiçbir araç yok. v1 "bu codex tek-yön bir pipeline kurabiliyor mu?"yu ölçtü; v2 daha zor bir soruyu sorar:

**Aynı codex, zaten yazdığı dosyaları birebir geri okuyup, state'i tutarlı biçimde geriye alabiliyor mu?**

Bu ikinci kısım daha sert çünkü:

* Kendi ürettiği commit formatını literal olarak geri parse edebilmelidir (**parser ↔ producer simetrisi**).
* `checkout` working directory'ye yazar — yani dış duruma dokunur, geri alınamaz.
* `reset` working directory'ye dokunmaz ama HEAD ve index'i değiştirir — sadece iç duruma dokunur.
* İkisinin farkını codex ayırt edebiliyor mu? Bu, gerçek bir Git mental modelinin LLM ağırlıklarında ne kadar yerleşik olduğunu ölçer.

---

## 3. Nasıl Çalışır (How It Works)

### Temel İçgörü 1 — Parse ↔ Produce Simetrisi
v2 komutlarının tamamı, v1'in yazdığı commit dosyasını okumaya dayanır. v1'de commit formatı tutarsız üretilmişse v2'nin `checkout`/`diff`/`show`'u çöker. Bu, LLM'in kendi ürettiği formata sadık kalma disiplinini test eder.

### Temel İçgörü 2 — Working Directory vs Repository State Ayrımı
İki yakın-görünümlü ama farklı komut:
* `checkout <hash>` → working directory'yi commit snapshot'ına **yazar**, HEAD'i günceller, index'i temizler.
* `reset <hash>` → yalnız HEAD + index'i değiştirir; working directory'ye **DOKUNMAZ**.

Bu ince ayrım v2'nin en sık kaçırılan detayıdır ve gerçek Git mental modelinin litmus testidir.

### Temel İçgörü 3 — Bilinçli Breaking Change: status Formatı
v1'in `status` çıktısı "staged dosyaları listele"ydi (serbest). v2 bunu birebir sabitler:

```
Staged files:
<file1>
<file2>
```

Boş ise:
```
Staged files:
(none)
```

Bu bir **breaking change**'tir. v1'den v2'ye geçişte status kodu yeniden yazılmalıdır. Bu, codex'in "önceki implementasyonu oku, bozulmayı tespit et, sertleşmiş formata geçiş yap" kapasitesini ölçer — gerçek yazılım evriminin mikro bir sahnesi.

### Temel İçgörü 4 — Ek Hata Sözleşmesi
Tüm yeni commit-referanslı komutlar (`checkout`, `reset`, `diff`, `show`) geçersiz commit için aynı tek mesajı kullanır: `Invalid commit` (exit 1). Homojenlik, codex'in hata yolunu tekrar tekrar yazmasını engeller.

### 3.x Teknik Kontrat — v2 Deltası

**Yeni komutlar:**

| Komut | Davranış | Çıktı / Hata |
|---|---|---|
| `minigit diff <c1> <c2>` | İki commit'in `files:` listelerini blob hash'e göre karşılaştırır. Blob içeriğine bakmaz. | Her fark için: `Added: <file>`, `Removed: <file>`, `Modified: <file>`. Commit yok: `Invalid commit` (exit 1) |
| `minigit checkout <hash>` | Commit'i okur; her dosyayı `objects/<blob_hash>`'tan çalışma dizinine yazar; HEAD'i `<hash>`'e günceller; index'i temizler. | Başarı: `Checked out <hash>`. Commit yok: `Invalid commit` (exit 1) |
| `minigit reset <hash>` | HEAD'i `<hash>`'e günceller; index'i temizler; working directory dosyalarına **dokunmaz**. | Başarı: `Reset to <hash>`. Commit yok: `Invalid commit` (exit 1) |
| `minigit rm <file>` | Dosyayı index'ten kaldırır. Working directory dosyasını silmez. | Index'te değilse: `File not in index` (exit 1) |
| `minigit show <hash>` | Commit bilgilerini biçimli dökümler (aşağıdaki format). | Commit yok: `Invalid commit` (exit 1) |

**`show` çıktı formatı** (birebir, iki-boşluk indent, dosya isimleri leksikografik sıralı):

```
commit <commit_hash>
Date: <timestamp>
Message: <message>
Files:
  <filename> <blobhash>
  <filename> <blobhash>
```

**Değişen komut — `status` (v1 → v2):**

v1'de serbest olan çıktı artık birebir. Dolu index için:
```
Staged files:
<file1>
<file2>
```

Boş index için:
```
Staged files:
(none)
```

**Invariant'lar (sık kaçırılan):**

* `checkout` working directory'ye yazar **+** HEAD/index'i günceller.
* `reset` yalnız HEAD + index'i günceller; working directory'ye **DOKUNMAZ**.
* `diff` iki commit'in `files:` bölümlerini karşılaştırır, blob içeriğini karşılaştırmaz — aynı dosya farklı blob hash'lere sahipse `Modified`.
* `rm` yalnız index'i düzeltir; working directory'den dosya silmez.
* Commit yok hatası tek string: `Invalid commit`. Varyasyon yok.

**Test süiti:** `bash test-v2.sh` — v1 testlerinin üzerine v2 deltası eklenir. Hepsi geçmeli.

---

## 4. Ne Yapmaz (What It Does Not Do)

* **Branch eklemez:** HEAD hâlâ tek. `checkout` önceki bir commit'e gider ama ayrı bir "branch head" tutmaz.
* **Merge eklemez:** İki ayrı geçmişi birleştirmek v2 kapsamı dışında.
* **Diff blob içeriğine bakmaz:** Yalnız commit'lerin `files:` bölümlerini kıyaslar; satır-bazlı diff yoktur.
* **`checkout` kirli working directory'yi korumaz:** Sessizce üzerine yazar. Gerçek Git'teki "uncommitted changes would be overwritten" koruması yoktur.
* **`rm` working directory dosyasını silmez:** Yalnız index'ten kaldırır.

---

## 5. Neden Şimdi (Why Now)

* **Yazma ↔ okuma simetrisi araştırma sorusu:** Codex'ler yazma ağırlıklı problemlerde iyidir; kendi çıktılarını literal geri okuma tutarlılığı daha az test edilmiştir. v2 bunu sorgular.
* **Breaking change'li iteratif spec disiplini:** `status` formatı değişiyor — bu, codex'in "önceki implementasyonu oku, uyumsuz bir yerde kırılmadan yeniden yaz" kapasitesini ölçer. Gerçek yazılım geliştirmeye yakın bir sinyal.
* **v2 uzantı prompt'u kısadır:** "IDEA-v2.md'yi oku ve mevcut kodu genişlet" — codex'in anayasayı delta olarak uygulayıp uygulayamadığını görmek için bilinçli minimal girdi.

---

## 6. Kim Fayda Sağlar (Who Benefits)

* **Multi-turn codex değerlendirmesi yapanlar:** v1→v2 zinciri, tek promptluk değerlendirmelerin ötesine geçer.
* **Format tutarlılığı test edenler:** Codex'in kendi ürettiği serileştirme formatına sadakatini ölçmek isteyenler.
* **Spec evolution benchmark tasarımcıları:** Bir spec'in yeni versiyonu gelince mevcut implementasyonun ne kadarının bozulduğunu ölçen metodolojinin referans problemi.
* **Mental model araştırmacıları:** `checkout` vs `reset` ayrımı gibi Git iç modelinin LLM ağırlıklarında ne kadar yerleşik olduğunu merak edenler.

---

## 7. Özet (Summary)

MiniGit v2; v1'in yazan-çekirdeğine geri-dönme (`checkout`, `reset`), fark-okuma (`diff`, `show`) ve index-temizleme (`rm`) yetilerini ekler; bir yandan `status` formatını sertleştirerek bilinçli bir breaking change uygular. Ana araştırma sorusu: bir codex, yazdığı formata geri dönüp onu tutarlı parse edebiliyor mu, ve `checkout` (working dir dokunur) ile `reset` (yalnız iç durum) gibi ince davranış farklarını uygulayabiliyor mu? v1'in 13 testine v2 testleri eklenir ve hepsi geçmelidir.
