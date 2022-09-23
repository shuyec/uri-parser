870084 Hu Stefano Yecheng

## **Osservazioni:**
- Il programma fa utilizzo di "defstruct", quindi la costruzione di funzioni
   come "uri-scheme", "uri-userinfo"...etc è superflua perché vengono create
   automaticamente.
- Nel caso in cui lo scheme sia zos, allora il path è obbligatorio perché
  "deve avere almeno un carattere".

## **Main function:**

``` lisp
uri-parse (uristring)
```

1. Converte la stringa in lista e sostituisce gli spazi con "%20".
2. Controlla la presenza dello scheme.
3. Controlla la presenza del special scheme.
4. Se la lista è vuota, allora ritorna NIL.
5. Se lo scheme è "mailto", allora genera l'uri-structure con scheme,
   userinfo, host se presente e port di default a 80.
6. Se lo scheme è "news", allora genera l'uri-structure con scheme, host e
   port di default a 80.
7. Se lo scheme è "tel" o "fax", allora genera l'uri-structure con scheme,
   userinfo e port di default a 80.
8. Se bss è 0, allora controlla la presenza dell'authorithy, userinfo,
   fragment, query, path, port e host. Successivamente controlla la loro
   grammatica tramite le funzioni di check e genera tutte le stringhe dei
   componenti a partire dalle liste.


## **Secondary functions:**

``` lisp
defstruct uri
```
Definisce la uri-structure.
<br/><br/>
``` lisp
generate-uri (lscheme luserinfo lhost lport lpath lquery lfragment)
```
Genera le stringhe di tutti i componenti a partire dalle liste.
<br/><br/>
``` lisp
copy-to-end (lst end)
```
Copia la lista dall'inizio fino all'indice "end - 1".
<br/><br/>
``` lisp
sublst (lst start &optional (end (length lst)))
```
Copia la lista "lst" dall'indice "start" fino all'indice opzionale "end -1".
- Se "end" non è specificato, allora "lst" è copiato da "start" fino alla
  fine.
<br/><br/>
``` lisp
split (lst index)
```
Divide la lista "lst" in 2 parti tenendo l'index come punto di divisione.
<br/><br/>
``` lisp
search-element (lst element)
```
Cerca "element" all'interno di "lst" e, se presente, restituisce il suo indice.
<br/><br/>
``` lisp
split-on-element (lst element)
```
Divide la lista in 2 parti tenendo "element" come punto di divisione.
La prima lista contiene gli elementi dall'inizio fino all'elemento non
compreso.
La seconda lista contiene gli elementi dall'elemento compreso fino alla fine.
<br/><br/>
``` lisp
list-to-string (lst)
```
Converte la lista "lst" in una stringa se "lst" non è null.
<br/><br/>
``` lisp
equal-last (lst el)
```
Controlla se "el" è l'ultimo elemento della lista.
<br/><br/>
``` lisp
substi (el1 el2 lst)
```
Sostituisce "el1" al posto di "el2" nella lista "lst".
<br/><br/>
``` lisp
memb (el lst)
```
Controlla se "el" è un elemento della lista "lst".
<br/><br/>
``` lisp
scheme-presence (lst)
```
Controlla se scheme è presente nella lista.
- Se è presente, allora definisce la booleana "boolscheme" a 1 e restituisce
  una lista contenente lo scheme e il resto.
- Se non è presente, ritorna un errore.
<br/><br/>
``` lisp
authority-presence (lst)
```
Controlla se l'authorithy è presente.
- Se è presente, ritorna la "boolauth" uguale a 1 e una lista con "//" rimosso.
- Se non è presente, allora viene ritornata la stessa lista di partenza.
<br/><br/>
``` lisp
userinfo-presence (lst boolauth)
```
Controlla se userinfo è presente.
- Se è presente, allora ritorna una lista contenente lo userinfo e il resto.
- Se non è presente, allora ritorna la lista (NIL lst).
<br/><br/>
``` lisp
host-presence (lst boolauth)
```
Controlla se l'host è presente.
- Se c'è l'authorithy ma non c'è l'host, allora ritorna errore.
- Se c'è l'authorithy e c'è l'host, allora ritorna una lista con l'host.
- Se non c'è l'authorithy, allora ritorna NIL.
<br/><br/>
``` lisp
port-presence (lst)
```
Controlla se la port è presente.
- Se non c'è, allora è 80.
- Se c'è, allora è il numero specificato.
- Se c'è solo il : senza la port, allora ritorna error.
<br/><br/>
``` lisp
path-presence (lst lquery lfragment boolauth)
```
Controlla se il path è presente.
- Se è presente, allora ritorna una lista contenente il path e il resto.
- Se non è presente, allora ritorna la lista (NIL lst).
<br/><br/>
``` lisp
query-presence (lst)
```
Controlla se la query è presente.
- Se è presente, allora ritorna una lista contenente la query e il resto.
- Se non è presente, allora ritorna la lista (NIL lst).
<br/><br/>
``` lisp
fragment-presence (lst)
```
Controlla se il fragment è presente.
- Se è presente, allora ritorna una lista contenente il fragment e il resto.
- Se non è presente, allora ritorna la lista (NIL lst).
<br/><br/>
``` lisp
special-scheme-presence (lscheme boolscheme)
```
Controlla se lo scheme è uno special scheme.
- Se sè ed è "mailto" o "news" o "tel" o "fax", allora definisce "boolsscheme"
  e "bss" a 1.
- Se sè ma è zos, allora  definisce "boolsscheme" a 1 e "bss" a 0.
- Se no, allora definisce "boolsscheme" e "bss" a 0.
<br/><br/>
``` lisp
mailto-presence (lscheme lst boolsscheme)
```
Controlla se lo special scheme è "mailto".
- Se sè, allora ritorna una lista contenente lo userinfo e l'host.
- Se non c'è lo special scheme o è diverso da "mailto", allora ritorna NIL.
<br/><br/>
``` lisp
news-presence (lscheme lst boolsscheme)
```
Controlla se lo special scheme è "news".
- Se sè, allora ritorna una lista contenente l'host.
- Se non c'è lo special scheme o è diverso da "news", allora ritorna NIL.
<br/><br/>
``` lisp
tel-fax-presence (lscheme lst boolsscheme)
```
Controlla se lo special scheme è "tel" o "fax".
- Se sè, allora ritorna una lista contenente lo userinfo.
- Se non c'è lo special scheme o è diverso da "tel" e "fax", allora
  ritorna NIL.
<br/><br/>
``` lisp
path-zos-check (lscheme lpath)
```
Controlla la grammatica del zos-path se lo scheme è "zos".
Il path ci deve essere per forza se lo scheme è "zos", quindi il programma
fallisce se "lpath" è null.
<br/><br/>
``` lisp
id44-check (lst)
```
Controlla la grammatica dell'id44 utilizzando id44-2-check e se la lunghezza
è al massimo 44.
<br/><br/>
``` lisp
id44-2-check (lst)
```
Funzione secondaria per il controllo della grammatica del zos-path. Controlla
solo se i caratteri sono leciti.
<br/><br/>
``` lisp
id8-check (lst)
```
Controlla la grammatica di id8.
<br/><br/>
``` lisp
scheme-check (lst)
```
Controlla la grammatica dello scheme utilizzando la funzione "id-check".
<br/><br/>
``` lisp
userinfo-check (lst)
```
Controlla la grammatica dell'userinfo utilizzando la funzione "id-check".
<br/><br/>
``` lisp
host-check (lst)
```
Controlla la grammatica dell'host utilizzando le funzioni ip-check (per
controllare se è un IP valido) e id-host-check.
<br/><br/>
``` lisp
port-check (lst)
```
Controlla la grammatica della port utilizzando digit-check.
<br/><br/>
``` lisp
path-check (lscheme lst)
```
Controlla la grammatica del path-check se lo scheme non è "zos".
Utilizza la funzione id-check.
<br/><br/>
``` lisp
query-check (lst)
```
Controlla la grammatica della query.
<br/><br/>
``` lisp
fragment-check (lst)
```
Controlla la grammatica del fragment.
<br/><br/>
``` lisp
id-check (lst)
```
Controlla la grammatica di un identificatore.
<br/><br/>
``` lisp
id-host-check (lst)
```
Controlla la grammatica di un identificatore-host.
<br/><br/>
``` lisp
digit-check (lst)
```
Controlla se la lista contiene solo digit.
<br/><br/>
``` lisp
three-digits-check (lst)
```
Controlla se "lst" contiene 3 digits e se il loro numero corrispondente è
compreso tra 0 e 255.
<br/><br/>
``` lisp
ip-check (lst)
```
Controlla se la lunghezza di "lst" è 11. Se sè, allora controlla la grammatica
dell'indirizzo-IP utilizzando "ip-sub-check".
<br/><br/>
``` lisp
ip-sub-check (lst)
```
Controlla la grammatica di un indirizzo-IP.
<br/><br/>
``` lisp
uri-display (uri-structure &optional (stream t))
```
Stampa la uri-structure. E' possibile definire uno stream opzionale.
