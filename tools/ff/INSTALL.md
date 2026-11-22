# 🔍 ff — Hızlı Dosya & Klasör Arama Aracı

`zoxide` deneyimini tüm sistemdeki dosya ve klasörlere taşıyan, `plocate` + `fzf` + `bat` tabanlı hızlı ve interaktif terminal arama aracı.

## ✨ Özellikler

* **Anlık Tüm Disk Araması:** Bulunduğun dizinden bağımsız olarak `plocate` indeksi üzerinden milisaniyeler içinde arama yapar.
* **Akıllı Önizleme:** Klasörlerin içeriğini listeler, metin/kod dosyalarını `bat` ile renklendirir, binary dosyalar (`.xls`, `.pdf` vb.) için tip, boyut ve tarih bilgisini gösterir.
* **Masaüstü & Sunucu (Headless) Uyumlu:** Kurulum ve çalışma anında ortamı otomatik algılar. Sunucularda X11/Wayland gibi gereksiz GUI paketlerini kurmaz; sadece CLI araçlarını yükler.
* **Kabuk Bağımsız:** `/usr/local/bin/ff` olarak kurulur; Bash, Zsh ve Fish üzerinde ek ayar gerektirmez.

## 🖥️ Desteklenen Sistemler

* **Fedora** (`dnf`)
* **Ubuntu / Debian** (`apt`)

*(Gerekli bağımlılıklar — `plocate`, `fzf`, `bat`, `file` ve yalnızca masaüstü ortamlarında `wl-clipboard`, `xclip` — kurulum scripti tarafından otomatik yüklenir.)*

## 🚀 Kurulum

### Tek Satırda Kurulum (Önerilen)

```bash
curl -fsSL https://raw.githubusercontent.com/sercangezer/dotfiles/refs/heads/main/tools/ff/ff-install.sh | bash
```

### Manuel Kurulum

```bash
git clone https://github.com/sercangezer/dotfiles.git
cd dotfiles/tools/ff
chmod +x ff-install.sh
./ff-install.sh
```

## 🛠️ Kullanım

Terminalde herhangi bir dizindeyken aramak istediğin kelimeyi yaz:

```bash
ff rapor
```

Parametre vermeden tüm indekste interaktif arama başlatmak için:

```bash
ff
```

### Kısayollar

| Kısayol        | Masaüstü Modu                                         | Sunucu (SSH / Headless) Modu                   |
| :------------- | :---------------------------------------------------- | :--------------------------------------------- |
| **`Enter`**    | Seçili öğeyi **Nautilus** içinde (seçili halde) açar. | Seçili öğenin tam yolunu terminale yazdırır.   |
| **`Ctrl + E`** | Dosyayı `$EDITOR` (varsayılan `vim`) ile açar.        | Dosyayı `$EDITOR` (varsayılan `vim`) ile açar. |
| **`Ctrl + O`** | Dosyayı varsayılan uygulamasıyla (`xdg-open`) açar.   | —                                              |
| **`Ctrl + Y`** | Tam yolu panoya kopyalar (Wayland & X11 uyumlu).      | —                                              |
| **`Ctrl + /`** | Alt önizleme panelini gizler veya gösterir.           | Alt önizleme panelini gizler veya gösterir.    |
| **`Esc`**      | İşlem yapmadan çıkar.                                 | İşlem yapmadan çıkar.                          |

## 🔄 İndeksi Manuel Güncelleme

`plocate` veritabanı sistem tarafından arka planda periyodik olarak güncellenir. Yeni oluşturduğun bir dosyanın anında görünmesi için indeksi elle tetikleyebilirsin:

```bash
sudo updatedb
```

## 🗑️ Kaldırma

Tek satırda kaldırmak için (`plocate`, `fzf`, `bat` gibi sistem paketlerine dokunmaz, yalnızca `/usr/local/bin/ff` dosyasını siler):

```bash
curl -fsSL https://raw.githubusercontent.com/sercangezer/dotfiles/refs/heads/main/tools/ff/ff-install.sh | bash -s -- --uninstall
```

Veya yerel script üzerinden:

```bash
./ff-install.sh --uninstall
```