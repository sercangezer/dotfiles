# 🔍 ff — Hızlı Dosya & Klasör Arama Aracı

`zoxide` deneyimini tüm sistemdeki dosya ve klasörlere taşıyan, `plocate` + `fzf` + `bat` tabanlı hızlı ve interaktif terminal arama aracı.

## ✨ Özellikler

* **Anlık Tüm Disk Araması:** Bulunduğun dizinden bağımsız olarak `plocate` indeksi üzerinden milisaniyeler içinde arama yapar.
* **Akıllı Önizleme:** Klasörlerin içeriğini listeler, metin/kod dosyalarını `bat` ile renklendirir, binary dosyalar (`.xls`, `.pdf` vb.) için tip, boyut ve tarih bilgisini gösterir.
* **Tek Tuşla Aksiyonlar:** Bulduğun dosyayı doğrudan Nautilus'ta seçili olarak açabilir, varsayılan uygulamasıyla başlatabilir veya yolunu panoya kopyalayabilirsin.
* **Kabuk Bağımsız:** `/usr/local/bin/ff` olarak kurulur; Bash, Zsh ve Fish üzerinde ek ayar gerektirmez.

## 🖥️ Desteklenen Sistemler

* **Fedora** (`dnf`)
* **Ubuntu / Debian** (`apt`)

*(Gerekli bağımlılıklar — `plocate`, `fzf`, `bat`, `file`, `wl-clipboard`, `xclip` — kurulum scripti tarafından otomatik yüklenir.)*

## 🚀 Kurulum

### Tek Satırda Kurulum (Önerilen)

```bash
curl -fsSL [https://raw.githubusercontent.com/](https://raw.githubusercontent.com/)<KULLANICI_ADIN>/<REPO_ADIN>/main/install.sh | bash