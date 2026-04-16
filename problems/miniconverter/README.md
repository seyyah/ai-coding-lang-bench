Proje Gelişim Geçmişi
V1 Geliştirme Süreci (v0 → v1)
V1 Somut Görev Listesi:

Harf Duyarlılığı: Kullanıcıdan gelen birim girdilerini (KM, m, Cm vb.) otomatik olarak küçük harfe çevirerek hataları engelle.

Sayısal Hassasiyet: Tüm hesaplama sonuçlarını virgülden sonra tam 2 ondalık basamağa yuvarla.

Hata Yönetimi: Desteklenmeyen birim girişlerinde, kullanıcıya hangi birimlerin geçerli olduğunu belirten net bir mesaj döndür.

v0 → v1 Temel Değişiklikler:

Esneklik: V0'daki katı küçük harf zorunluluğu kaldırılarak kullanıcı dostu bir yapıya geçildi.

Okunabilirlik: Karmaşık ondalık sayılar yerine standart bir çıktı formatı benimsendi.

V2 Geliştirme Süreci (v1 → v2)
V2 Somut Görev Listesi:

Sayısal Doğrulama: Kullanıcının girdiği değerin bir sayı olup olmadığını denetle; geçersiz girişlerde "Error: <value> is not a valid number." mesajını döndür.

Komut Denetimi: Tanımlanmayan komutlar için "Unknown command: <command>" uyarısını ekle.

Veri Tutarlılığı: Çıktılar ve history.dat kayıtlarının her zaman 2 ondalık basamak ve "2026-04-16" formatıyla tutulmasını sağla.

v1 → v2 Temel Değişiklikler:

Dayanıklılık: Sayısal olmayan veri girişlerinde programın çökmesi engellenerek yazılım stabilitesi artırıldı.

Geri Bildirim: Hatalı değerler ve komutlar için spesifik hata mesajları eklenerek CLI etkileşimi profesyonelleştirildi.