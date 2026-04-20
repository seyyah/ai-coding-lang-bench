# MiniLibrary v3 Walkthrough

Bu belge, **v2** ve **v3** sürümleri arasındaki temel farkları ve v3'ün nasıl test edildiğini belgelemek için oluşturulmuştur.

## v2 ve v3 Arasındaki Farklar

MiniLibrary v3 (Spesifikasyon 2.1) ile kütüphane otomasyonuna "kullanıcı takibi ve kara liste (blacklist)" mantığı getirilmiştir. 

Önceki sürüm (v2) ile kıyaslandığında aşağıdaki temel değişiklikler bulunmaktadır:

### 1. Yeni Veri Dosyaları
- **`borrowers.dat`**: Kullanıcıların zamanında iade etmedikleri kitap sayılarını (gecikmeleri) tutar. Formatı: `<kullanici_adi>|<gecikme_sayisi>`
- **`blacklist.dat`**: Kara listeye alınan kullanıcıları tutar. İçerisinde sadece kullanıcı adları yer alır.

### 2. Gecikme ve Kara Liste Mantığı (Late Return & Blacklist)
- `borrow` (ödünç alma): Kitap ödünç alınırken `blacklist.dat` dosyası kontrol edilir. Kullanıcı kara listedeyse kitabın ödünç verilmesi reddedilir.
- `return` (iade etme): 
  - Kitap iade edildiğinde kontrol gerçekleştirilir: İade süresi 14 günü aşmışsa (Bugün > `due_date`), kullanıcının gecikme sayısı (`borrowers.dat`) 1 artırılır.
  - Eğer kullanıcının gecikme sayısı **3 veya daha fazlaysa**, kullanıcı `blacklist.dat` dosyasına eklenerek kara listeye alınır.

### 3. Yeni Komutlar
- **`minilibrary blacklist`**: Kara listeye alınmış kişileri listeler.
- **`minilibrary listborrowers`**: Sistemde gecikme kaydı bulunan kullanıcıları ve gecikme sayılarını listeler.

## Kurulum ve Test (v3)
v3 sürümünün bütünlüğü `test_v3.sh` üzerinden sağlanır:
1. Kurulum için `./test_v3.sh` veya `bash test_v3.sh` komutu kullanılabilir.
2. Test betiği, sistemin önceki durumlarda (`.minilibrary`'nin varlığı), kitap ekleme-alma, başarılı iade ve özellikle **3 gecikme sonrası kara liste mekanizmasını** test etmek için sahte bir tarih (30 gün öncesi) ile kayıtları manipüle ederek uç senaryoları simüle eder.
3. Kara liste çalışan fonksiyonlar: `borrow` kontrolü başarılıysa "PASS: blacklisted user blocked from borrowing" yanıtını döner.

## Github Entegrasyonu Bilgisi
v2 - v3 farklarını kendi reponuzda yayımlama ve `seyyah/whichlanguage` reposuna PR atma işlemlerini gerçekleştirebilmek için gerekli erişim (bağlantılar, GitHub token bilgisi/`gh` cli veya repo url'si) şu anki ortamımızda bulunmamaktadır. Eğer bu işlemleri terminalden yapmamızı isterseniz GitHub yetkilerinizin ayarlandığından emin olup gerekli repolarınızın linklerini (ya da PR atılacak spesifik repoyu) yönlendirmelisiniz.
