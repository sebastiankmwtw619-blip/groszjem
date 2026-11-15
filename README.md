# Grosz.jem

Bary mleczne i tanie obiady w Polsce według województw. Aplikacja webowa (PWA), którą można zainstalować na iPhonie i Androidzie.

**Adres:** https://sebastiankmwtw619-blip.github.io/groszjem/

## Instalacja na telefonie

- **Android (Chrome):** otwórz adres i dotknij **Zainstaluj** na górze listy albo w menu ⋮ wybierz **Zainstaluj aplikację**.
- **iPhone (Safari):** otwórz adres, dotknij **Udostępnij**, potem **Do ekranu początkowego**.

## Dane

- `places.json` – 31 lokali znalezionych w źródłach internetowych 15.11.2026, ze źródłem przy każdym. Ceny tylko tam, gdzie podaje je źródło. Mogą być nieaktualne.
- Ceny i lokale zgłaszane w aplikacji domyślnie zapisują się **tylko na danym telefonie** (tryb lokalny).

## Wspólna baza (opcjonalnie)

Żeby zgłoszenia widzieli wszyscy:

1. Załóż darmowe konto na https://supabase.com i utwórz projekt.
2. W **SQL Editor** uruchom plik `supabase.sql`.
3. W **Project Settings → API** skopiuj *Project URL* i klucz *anon public* do `config.js`.
4. Opublikuj zmianę (commit + push). Aplikacja sama przełączy się na wspólną bazę.

## Pliki

| Plik | Co robi |
| --- | --- |
| `index.html` | Cała aplikacja |
| `places.json` | Lista lokali |
| `config.js` | Ustawienia wspólnej bazy |
| `manifest.webmanifest`, `icons/` | Instalacja jako aplikacja |
| `sw.js` | Działanie bez internetu |
| `supabase.sql` | Schemat wspólnej bazy |
| `make_icons.py` | Generuje ikony |

## Moderacja

Panel: https://sebastiankmwtw619-blip.github.io/groszjem/admin.html (logowanie linkiem e-mail, tylko adresy z tabeli `moderators`).

- **Zgłoszenia lokali:** zatwierdź (znika oznaczenie „niezweryfikowany”), odrzuć (znika z aplikacji) albo usuń.
- **Ceny:** ukryj, przywróć albo usuń.
- Reguły bazy są w `supabase-moderation.sql`. Nowego moderatora dodasz w Supabase SQL Editor:
  `insert into moderators (email) values ('adres@przyklad.pl');`
