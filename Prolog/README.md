870084 Hu Stefano Yecheng

## **Main predicate:**  
**uri_parse/2**
``` prolog
uri_parse(URIString, URI)
```
1. Converte la stringa in un atomo.
2. Sostituisce gli spazi vuoti con "%20".
3. Converte l'atomo in una lista di caratteri.
4. Controlla la presenza dello scheme e genera il resto della lista.
5. Controlla la presenza di uno special scheme e restituisce le varie booleane.
6. Controlla la presenza dello special scheme "mailto" e restituisce le liste
   dei suoi componenti se lo scheme corrisponde.
7. Controlla la presenza dello special scheme "news" e restituisce la lista
   del suo componente se lo scheme corrisponde.
8. Controlla la presenza dello special scheme "tel" o "fax" e restituisce la
   lista del suo componente se lo scheme corrisponde.
9. Controlla la presenza dell'authorithy e genera il resto della lista.
10. Controlla la presenza dell'userinfo e genera il resto della lista.
11. Controlla la presenza del fragment e genera il resto della lista.
12. Controlla la presenza della query e genera il resto della lista.
13. Controlla la presenza del path e genera il resto della lista.
14. Controlla la presenza del port e genera il resto della lista.
15. Controlla la presenza dell'host.
16. Controlla la grammatica dello scheme.
17. Controlla la grammatica dell'userinfo.
18. Controlla la grammatica dell'host.
19. Controlla la grammatica del port.
20. Controlla la grammatica del path.
21. Controlla la grammatica del zos-path.
22. Controlla la grammatica della query.
23. Controlla la grammatica del fragment.
24. Genera tutti gli atomi dei componenti della struttura a partire dalle
    liste. L'unica eccezione è la port che viene convertita in numero.
25. Unifica con il predicato uri/7 restituendo i vari componenti.
<br/><br/>

## **Secondary predicates:**

**uri/7**
``` prolog
uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment)
```
Struttura dell'uri con i suoi componenti.
<br/><br/>

**not_member/2**
``` prolog
not_member(X, List)
```
Controlla se l'elemento "X" appartiene alla lista "List". Restituisce true se
non appartiene e false se appartiene.
<br/><br/>

**split_on_element/4**
``` prolog
split_on_element(List, El, Left, Right)
```
Divide la lista in 2 parti considerando "El" come il punto di divisione.
"Left" va dall'inizio a prima dell'elemento "El".
"Right" va dall'elemento "El" compreso alla fine.
<br/><br/>

**remove_n/3**
``` prolog
remove_n(List, N, Result)
```
Rimuove n elementi dalla lista e ritorna il risultato in "Result".
<br/><br/>

**space_replace/2**
``` prolog
space_replace(Atom, Result)
```
Sostituisce tutti gli spazi all'interno dell'atomo con "%20".
<br/><br/>

**scheme_presence/5**
``` prolog
scheme_presence(List, BoolScheme, LScheme, LSchemeLow, Rest)
```
Controlla la presenza dello scheme. Se non è presente, allora ritorna false.
BoolScheme = booleana per la presenza dello scheme. 1 se presente e 0 se no.
LScheme = lista contenente i vari caratteri dello scheme.
LSchemeLow = LScheme convertito in lowercase.
Rest = lista con caratteri rimanenti.
<br/><br/>

**authorithy_presence/4**
``` prolog
authority_presence(List, BoolAuth, BSS, Rest)
```
Controlla la presenza dell'authorithy in "List".
BoolAuth = booleana per la presenza dell'authorithy. 1 se presente e 0 se no.
BSS = booleana per la presenza di uno special scheme che non sia "zos".
Rest = lista con caratteri rimanenti.
<br/><br/>

**userinfo_presence/5**
``` prolog
userinfo_presence(List, BoolAuth, BSS, Userinfo, Rest)
```
Controlla la presenza di userinfo se c'è l'authorithy.
Userinfo = lista contenente lo userinfo se presente.
	   Userinfo = [] se non presente.
Rest = lista con caratteri rimanenti.
<br/><br/>

**host_presence/4**
``` prolog
host_presence(List, BoolAuth, BSS, Host)
```
Controlla la presenza dell'host all'interno di "List".
Host = lista contentente i caratteri di host se presente.
       Host = [] se non presente.
       uri_parse fallisce se c'è l'authorithy, ma non c'è l'host.
<br/><br/>

**port_presence/3**
``` prolog
port_presence(List, Port, Rest)
```
Controlla se è presente la port.
Port = lista contenente i caratteri della port se presente.
       Port = 80 se non è specificata la port.
Rest = lista con caratteri rimanenti.
<br/><br/>

**path_presence/7**
``` prolog
path_presence(List, LQuery, LFragment, BoolAuth, BSS, Path, Rest)
```
Controlla se path è presente nella lista "List".
Path = lista contenente i caratteri di path se è presente. 
       Path = [] se non è presente.
       Il programma fallisce se LQuery o LFragment non sono vuoti,
       ma manca lo "/" di divisione tra authorithy e loro.
Rest = lista con caratteri rimanenti.
<br/><br/>

**query_presence/4**
``` prolog
query_presence(List, BSS, Query, Rest)
```
Controlla se query è presente nella lista "List".
Query = lista contenente i caratteri della query se presente.
      	Query = [] se non presente.
Rest = lista con caratteri rimanenti.
<br/><br/>

**fragment_presence/4**
``` prolog
fragment_presence(List, BSS, Fragment, Rest)
```
Controlla se il fragment è presente all'interno della lista "List".
Fragment = lista contenente i caratteri del fragment se è presente.
	   Fragment = [] se non è presente.
Rest = lista con caratteri rimanenti.
<br/><br/>

**special_scheme_presence/4**
``` prolog
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS)
```
Controlla se lo scheme è uno special scheme.
BoolSScheme = booleana per la presenza di uno special scheme.
BSS = booleana per la presenza di "mailto" o "news" o "tel" o "fax".
<br/><br/>

**mailto_presence/5**
``` prolog
mailto_presence(LSchemeLow, List, BoolSScheme, LUserinfo, LHost)
```
Controlla se lo scheme è "mailto".
Se lo è, allora genera le liste LUSerinfo e LHost.
LUserinfo = lista contenente i caratteri dello userinfo.
LHost = lista contenente i caratteri dell'host.
<br/><br/>

**mailto_check/3**
``` prolog
mailto_check(LMail, LUserinfo, LHost)
```
Controlla se è presente solo lo userinfo o anche l'host.
<br/><br/>

**news_presence/4**
``` prolog
news_presence(LSchemeLow, List, BoolSScheme, LHost)
```
Controlla se lo scheme è "news".
Se lo è, allora genera la lista "LHost" contenente l'host.
<br/><br/>

**tel_fax_presence/4**
``` prolog
tel_fax_presence(LSchemeLow, List, BoolSScheme, LUserinfo)
```
Controlla se lo scheme è "tel" o "fax".
Se lo è, allora genera la lista "LUserinfo" contenente lo userinfo.
<br/><br/>

**scheme_check/1**
``` prolog
scheme_check(LScheme)
```
Controlla la grammatica dello scheme tramite la DCG per l'identificatore.
<br/><br/>

**userinfo_check/1**
``` prolog
userinfo_check(LUserinfo)
```
Controlla la grammatica dell'userinfo tramite la DCG per l'identificatore.
<br/><br/>

**port_check/1**
``` prolog
port_check(LPort)
```
Controlla la grammatica del port tramite la DCG per i digits.
<br/><br/>

**query_check/1**
``` prolog
query_check(LQuery)
```
Controlla la grammatica della query tramite la DCG "query".
<br/><br/>

**fragment_check/1**
``` prolog
fragment_check(LFragment)
```
Controlla la grammatica del fragment tramite la DCG "fragment".
<br/><br/>

**path_zos_check/2**
``` prolog
path_zos_check(LPath, LSchemeLow)
```
Controlla la grammatica del "zos-path" se lo scheme è "zos".
Tramite DCG vengono controllati l'id44 e l'id8 se presente.
Il path deve per forza esserci se lo scheme è "zos".
<br/><br/>

**path_check/2**
``` prolog
path_check(LPath, LSchemeLow)
```
Controlla la grammatica del path se lo scheme non è "zos".
I controlli vengono fatti tramite le DCG per l'identificatore.
<br/><br/>

**host_check/1**
``` prolog
host_check(LHost)
```
Controlla la grammatica dell'host tramite le DCG per l'indirizzo-IP e le DCG
per l'identificatore-host.
<br/><br/>

**generate_atom/2**
``` prolog
generate_atom(List, Result)
```
Genera un atom da una lista se essa non è vuota.
<br/><br/>

**generate_port/2**
``` prolog
generate_port(LPort, Port)
```
Genera la port (numero) da una lista se essa non è vuota.
<br/><br/>

**uri_display/1**
``` prolog
uri_display(URI)
```
URI corrisponde al risultato di un uri_parse.
Stampa URI.
<br/><br/>

**uri_display/2**
``` prolog
uri_display(URI, Stream)
```
URI corrisponde al risultato di un uri_parse.
Scrive URI sullo Stream che deve essere aperto in precedenza tramite un open.
Inoltre, bisogna chiudere lo stream dopo aver utilizzato uri_display.
<br/><br/>

## **DCG:**

**digit/1**
``` prolog
digit(NAtom)
```
DCG per il controllo delle cifre.
<br/><br/>

``` prolog
ip_address
```
DCG per definire la grammatica di un indirizzo-IP.
<br/><br/>

**three_digits/3**
``` prolog
three_digits(N1, N2, N3)
```
DCG per il controllo dei 4 numeri a 3 cifre componenti l'indirizzo-IP.
Controllo tramite la DCG dei digits e se il numero è compreso tra 0 e 255.
<br/><br/>

**id/1**
``` prolog
id(List)
```
DCG per definire la grammatica dell'identificatore.
<br/><br/>

**id_host/1**
``` prolog
id_host(List)
```
DCG per definire la grammatica dell'identificatore-host.
<br/><br/>

**port/1**
``` prolog
port(List)
```
DCG per definire la grammatica del port.
<br/><br/>

**query/1**
``` prolog
query(List)
```
DCG per definire la grammatica della query.
<br/><br/>

**fragment/1**
``` prolog
fragment(List)
```
DCG per definire la grammatica del fragment.
<br/><br/>

**id44/2**
``` prolog
id44(List, N)
```
DCG per definire la grammatica dell'id44.
N è il contatore dei caratteri che devono essere al massimo 44.
<br/><br/>

**id8/2**
``` prolog
id8(List, N)
```
DCG per definire la grammatica dell'id8.
N è il contatore dei caratteri che devono essere al massimo 8.