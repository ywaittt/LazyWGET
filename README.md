# LazyWGET (lwget)

LazyWGET este un script shell care descarcă **lenes (lazy)** documente HTML. Spre deosebire de `wget -r`, nu descarcă automat întreg arborele de pagini dintr-un singur apel. În schimb, tratează linkurile HTML ca **promisiuni (pending)** care sunt evaluate doar când rulezi din nou `lwget` pe unul dintre acele URL-uri.

## Cerință (interpretare)
- Scriptul folosește `wget` **nerecursiv** pentru a descărca **un singur fișier HTML** per apel.
- Scriptul **parsează** fișierul HTML descărcat și extrage linkuri către alte resurse HTML.
- Linkurile găsite sunt tratate ca **promisiuni**: sunt memorate ca `pending`, dar nu sunt descărcate imediat.
- Evaluarea promisiunilor se face doar când un apel ulterior `lwget <URL>` forțează descărcarea acelui URL.

## Cum funcționează (lazy)
La un apel:
```
    lwget <URL>
```


Scriptul:
1. Verifică dacă URL-ul este accesibil folosind `wget --spider`.
2. Descarcă documentul HTML indicat (un singur fișier) cu `wget` și îl salvează local.
3. Actualizează fișierele de stare:
   - dacă URL-ul era în `pending`, îl elimină din `pending` și îl marchează ca `downloaded`
   - dacă URL-ul era deja în `downloaded`, nu îl adaugă din nou
4. Parsează fișierul HTML local și adaugă în `pending` linkurile HTML găsite (fără duplicate).

Important: un singur apel descarcă doar pagina cerută. Linkurile descoperite devin doar `pending`.

## Cerințe
- Linux cu:
  - `bash`
  - `wget`
  - `grep` (GNU grep recomandat)
  - `sed`

## Rulare

### 1) Permisiuni
```bash
chmod +x LazyWGET.sh
```
### 2) Executie
```
./LazyWGET.sh <URL> [download_dir]
```
  - <URL>: URL către un document HTML (http/https)
  - [download_dir] (opțional): directorul în care se salvează fișierele (implicit downloads)

### 3) Exemplu
```
    ./LazyWGET.sh "https://example.com/index.html"
    ./LazyWGET.sh "https://example.com/index.html" "my_downloads"
```

## Output și stare persistentă

În directorul de download (implicit ```downloads/```), scriptul:
  - salvează HTML-ul descărcat ca fișier local (numele este derivat din ultima parte a URL-ului; dacă URL-ul se termină cu /, se folosește index.html)
  - creează un director de stare:
```
downloads/.lwget/
    pending.txt
    downloaded.txt
```
### Fisierele de stare
  - ```pending.txt```:  URL-uri descoperite in HTML, dar inca nedescarcate.
  - ```downloaded.txt```: URL-uri care au fost deja descărcate

## Exemplu de scenariu

Presupunem:
  - A conține linkuri către B și C
  - B conține link către D

1. Rulezi:
```
./LazyWGET.sh "<A_URL>"
```
Rezultat:
  - B este descărcat
  - B este eliminat din pending.txt și apare în downloaded.txt
  - D este adăugat în pending.txt

## Note despre parsare și limitări

Pentru simplitate și viteză de implementare:

  - scriptul extrage linkuri din atribute href="..." (format cu ghilimele duble)
  - sunt luate în considerare doar linkuri absolute care încep cu http/https
  - linkurile relative (de exemplu href="/page.html" sau href="page.html") nu sunt urmărite în această versiune
  - src (imagini/JS) nu este tratat ca „resursă HTML” în această versiune

Notă: URL-urile sunt tratate ca string-uri. Pentru rezultate previzibile, rulează lwget folosind aceeași formă a URL-ului (de exemplu cu sau fără / final) ca în lista pending.

## Resetare rapidă

Dacă vrei să pornești de la zero:
  - șterge directorul de download sau doar starea:
```
rm -rf downloads/.lwget
```

sau folosește un alt ```download_dir``` la rulare.