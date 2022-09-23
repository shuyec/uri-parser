% 870084 Hu Stefano Yecheng

uri_parse(URIString, URI) :-
    string_to_atom(URIString, Atoms0),
    space_replace(Atoms0, Atoms1),
    atom_chars(Atoms1, LA0),
    scheme_presence(LA0, BoolScheme, LScheme, LSchemeLow, LA1),

    special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS),
    mailto_presence(LSchemeLow, LA1, BoolSScheme, LUserinfo, LHost),
    news_presence(LSchemeLow, LA1, BoolSScheme, LHost),
    tel_fax_presence(LSchemeLow, LA1, BoolSScheme, LUserinfo),

    authority_presence(LA1, BoolAuth, BSS, LA2),
    userinfo_presence(LA2, BoolAuth, BSS, LUserinfo, LA3),
    fragment_presence(LA3, BSS, LFragment, LA4),
    query_presence(LA4, BSS, LQuery, LA5),
    path_presence(LA5, LQuery, LFragment, BoolAuth, BSS, LPath, LA6),
    port_presence(LA6, LPort, LA7),
    host_presence(LA7, BoolAuth, BSS, LHost),

    scheme_check(LScheme),
    userinfo_check(LUserinfo),
    host_check(LHost),
    port_check(LPort),
    path_check(LPath, LSchemeLow),
    path_zos_check(LPath, LSchemeLow),
    query_check(LQuery),
    fragment_check(LFragment),

    generate_atom(LScheme, Scheme),
    generate_atom(LUserinfo, Userinfo),
    generate_atom(LHost, Host),
    generate_port(LPort, Port),
    generate_atom(LPath, Path),
    generate_atom(LQuery, Query),
    generate_atom(LFragment, Fragment),

    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).


uri(_Scheme, _Userinfo, _Host, _Port, _Path, _Query, _Fragment).

% useful predicates to control lists

not_member(_, []) :- !.
not_member(X, [H | T]) :- X \= H, not_member(X, T).

split_on_element(List, El, Left, Right) :-
    append(Left, [El | Rest], List),
    Right = [El | Rest].

remove_n(List, N, Result) :-
    length(Prefix, N),
    append(Prefix, Result, List).

% replacing spaces with '%20'

space_replace(Atom, Result) :-
    atomic_list_concat(LAtoms, ' ', Atom),
    atomic_list_concat(LAtoms, '%20', Result).

% checking if the URI parts are present or not

scheme_presence(List, BoolScheme, _LScheme, _, _Rest) :-
    not_member(':', List),
    BoolScheme is 0,
    !,
    fail.
scheme_presence(List, BoolScheme, LScheme, LSchemeLow, Rest) :-
    member(':', List),
    BoolScheme is 1,
    split_on_element(List, ':', LScheme, Right),
    LScheme \= [],
    atomic_list_concat(LScheme, Acc1),
    downcase_atom(Acc1, Acc2),
    atom_chars(Acc2, LSchemeLow),
    remove_n(Right, 1, Rest).

authority_presence(_, _, BSS, _) :-
    BSS = 1,
    !.
authority_presence(List, BoolAuth, _,Rest) :-
    nth0(0, List, '/'),
    nth0(1, List, '/'),
    BoolAuth is 1,
    remove_n(List, 2, Rest),
    !.
authority_presence(List, BoolAuth, _, Rest) :-
    BoolAuth is 0,
    Rest = List.

userinfo_presence(_, _, BSS, _, _) :-
    BSS = 1,
    !.
userinfo_presence(List, BoolAuth, _, Userinfo, Rest) :-
    BoolAuth = 0,
    Userinfo = [],
    Rest = List,
    !.
userinfo_presence(List, BoolAuth, _, Userinfo, Rest) :-
    BoolAuth = 1,
    not_member('@', List),
    Userinfo = [],
    Rest = List.
userinfo_presence(List, BoolAuth, _, Userinfo, Rest) :-
    BoolAuth = 1,
    member('@', List),
    split_on_element(List, '@', Userinfo, Right),
    Userinfo \= [],
    remove_n(Right, 1, Rest).

host_presence(_, _, BSS, _) :-
    BSS = 1,
    !.
host_presence(_List, BoolAuth, _, Host) :-
    BoolAuth = 0,
    Host = [],
    !.
host_presence(List, BoolAuth, _, Host) :-
    BoolAuth = 1,
    List \= [],
    Host = List.

port_presence(List, Port, Rest) :-
    not_member(':' , List),
    Port = ['80'],
    Rest = List,
    !.
port_presence(List, Port, Rest) :-
    member(':', List),
    split_on_element(List, ':', Rest, Right),
    remove_n(Right, 1, Port),
    Port \= [].

path_presence(_, _, _, _, BSS, _, _) :-
    BSS = 1,
    !.
path_presence(List, LQuery, LFragment, BoolAuth, _, Path, Rest) :-
    BoolAuth = 1,
    not_member('/', List),
    LQuery = [],
    LFragment = [],
    Path = [],
    Rest = List,
    !.
path_presence(List, LQuery, _, BoolAuth, _, _, _) :-
    BoolAuth = 1,
    not_member('/', List),
    LQuery \= [],
    !,
    fail.
path_presence(List, _, LFragment, BoolAuth, _, _, _) :-
    BoolAuth = 1,
    not_member('/', List),
    LFragment \= [],
    !,
    fail.
path_presence(List, _, _, BoolAuth, _, Path, Rest) :-
    BoolAuth = 1,
    member('/', List),
    split_on_element(List, '/', Rest, Right),
    remove_n(Right, 1, Path),
    !.
path_presence(List, LQuery, LFragment, BoolAuth, _, _, _) :-
    BoolAuth = 0,
    not_member('/', List),
    LQuery = [],
    LFragment = [],
    List \= [],
    !,
    fail.
path_presence(List, LQuery, _, BoolAuth, _, _, _) :-
    BoolAuth = 0,
    List = [],
    LQuery \= [],
    !,
    fail.
path_presence(List, _, LFragment, BoolAuth, _, _, _) :-
    BoolAuth = 0,
    List = [],
    LFragment \= [],
    !,
    fail.
path_presence(List, _, _, BoolAuth, _, Path, Rest) :-
    BoolAuth = 0,
    List = [],
    Rest = [],
    Path = [],
    !.
path_presence([H | _], _, _, BoolAuth, _, _, _) :-
    BoolAuth = 0,
    H \= '/',
    !,
    fail.
path_presence([H | T], _, _, BoolAuth, _, Path, Rest) :-
    BoolAuth = 0,
    H = '/',
    remove_n([H | T], 1, Path),
    Rest = [].

query_presence(_, BSS, _, _) :-
    BSS = 1,
    !.
query_presence(List, _, Query, Rest) :-
    not_member('?', List),
    Query = [],
    Rest = List,
    !.
query_presence(List, _, Query, Rest) :-
    member('?', List),
    split_on_element(List, '?', Left, Right),
    remove_n(Right, 1, Query),
    Query \= [],
    Rest = Left.

fragment_presence(_, BSS, _, _) :-
    BSS = 1,
    !.
fragment_presence(List, _, Fragment, Rest) :-
    not_member('#', List),
    Fragment = [],
    Rest = List,
    !.
fragment_presence(List, _, Fragment, Rest) :-
    member('#', List),
    split_on_element(List, '#', Left, Right),
    remove_n(Right, 1, Fragment),
    Fragment \= [],
    Rest = Left.

% controlling if there is a special scheme

special_scheme_presence(_LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 0,
    BoolSScheme is 0,
    BSS is 0,
    !.
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 1,
    LSchemeLow \= [m, a, i, l, t, o],
    LSchemeLow \= [n, e, w, s],
    LSchemeLow \= [t, e, l],
    LSchemeLow \= [f, a, x],
    LSchemeLow \= [z, o, s],
    BoolSScheme is 0,
    BSS is 0,
    !.
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 1,
    LSchemeLow = [m, a, i, l, t, o],
    BoolSScheme is 1,
    BSS is 1.
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 1,
    LSchemeLow = [n, e, w, s],
    BoolSScheme is 1,
    BSS is 1.
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 1,
    LSchemeLow = [t, e, l],
    BoolSScheme is 1,
    BSS is 1.
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 1,
    LSchemeLow = [f, a, x],
    BoolSScheme is 1,
    BSS is 1.
special_scheme_presence(LSchemeLow, BoolScheme, BoolSScheme, BSS) :-
    BoolScheme = 1,
    LSchemeLow = [z, o, s],
    BoolSScheme is 1,
    BSS is 0.


% if there is a special scheme, then check which one it is

mailto_presence(_LSchemeLow, _List, BoolSScheme, _LUserinfo, _LHost) :-
    BoolSScheme = 0,
    !.
mailto_presence(LSchemeLow, _List, BoolSScheme, _LUserinfo, _LHost) :-
    BoolSScheme = 1,
    LSchemeLow \= [m, a, i, l, t, o],
    !.
mailto_presence(LSchemeLow, List, BoolSScheme, LUserinfo, LHost) :-
    BoolSScheme = 1,
    LSchemeLow = [m, a, i, l, t, o],
    mailto_check(List, LUserinfo, LHost).
mailto_check(LMail, LUserinfo, LHost) :-
    not_member('@', LMail),
    LUserinfo = LMail,
    LHost = [],
    !.
mailto_check(LMail, LUserinfo, LHost) :-
    member('@', LMail),
    split_on_element(LMail, '@', LUserinfo, Right),
    LUserinfo \= [],
    remove_n(Right, 1, LHost),
    LHost \= [].

news_presence(_LSchemeLow, _List, BoolSScheme, _LHost) :-
    BoolSScheme = 0,
    !.
news_presence(LSchemeLow, _List, BoolSScheme, _LHost) :-
    BoolSScheme = 1,
    LSchemeLow \= [n, e, w, s],
    !.
news_presence(LSchemeLow, List, BoolSScheme, LHost) :-
    BoolSScheme = 1,
    LSchemeLow = [n, e, w, s],
    LHost = List.

tel_fax_presence(_LSchemeLow, _List, BoolSScheme, _LUserinfo) :-
    BoolSScheme = 0,
    !.
tel_fax_presence(LSchemeLow, _List, BoolSScheme, _LUserinfo) :-
    BoolSScheme = 1,
    LSchemeLow \= [t, e, l],
    LSchemeLow \= [f, a, x],
    !.
tel_fax_presence(LSchemeLow, List, BoolSScheme, LUserinfo) :-
    BoolSScheme = 1,
    LSchemeLow = [t, e, l],
    LUserinfo = List,
    !.
tel_fax_presence(LSchemeLow, List, BoolSScheme, LUserinfo) :-
    BoolSScheme = 1,
    LSchemeLow = [f, a, x],
    LUserinfo = List.


% predicates for grammar checking

scheme_check(LScheme) :-
    phrase(id(LScheme), LScheme).
userinfo_check(LUserinfo) :-
    phrase(id(LUserinfo), LUserinfo).
port_check(LPort) :-
    phrase(port(LPort), LPort).
query_check(LQuery) :-
    phrase(query(LQuery), LQuery).
fragment_check(LFragment) :-
    phrase(fragment(LFragment), LFragment).

path_zos_check(_, LSchemeLow) :-
    LSchemeLow \= [z, o, s],
    !.
path_zos_check(LPath, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    LPath = [],
    !,
    fail.
path_zos_check(LPath, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    member('(', LPath),
    not_member(')', LPath),
    !,
    fail.
path_zos_check(LPath, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    not_member('(', LPath) ,
    member(')', LPath),
    !,
    fail.
path_zos_check(LPath, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    LPath = [],
    !.
path_zos_check(LPath, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    not_member('(', LPath),
    not_member(')', LPath),
    phrase(id44(LPath, 0), LPath).
path_zos_check(LPath, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    member('(', LPath),
    member(')', LPath),
    split_on_element(LPath, '(', Id44, Right),
    remove_n(Right, 1, Rest),
    split_on_element(Rest, ')', Id8, _),
    Id8 \= [],
    phrase(id44(Id44, 0), Id44),
    phrase(id8(Id8, 0), Id8).

path_check(_, LSchemeLow) :-
    LSchemeLow = [z, o, s],
    !.
path_check([], _) :- !.
path_check([H | T], _) :-
    H = '/',
    T \= [],
    !,
    fail.
path_check(LPath, _) :-
    not_member('/', LPath),
    phrase(id(LPath), LPath).
path_check(LPath, _) :-
    last(LPath, '/'),
    !,
    fail.
path_check(LPath, _) :-
    member('/', LPath),
    split_on_element(LPath, '/', Left, Right),
    phrase(id(Left), Left),
    remove_n(Right, 1, Rest),
    path_check(Rest, _).

host_check([]) :- !.
host_check(LHost) :-
    last(LHost, '.'),
    !,
    fail.
host_check(LHost) :-
    phrase(ip_address, LHost),
    !.
host_check([H | _]) :-
    H = '.',
    !,
    fail.
host_check(LHost) :-
    not_member('.', LHost),
    phrase(id_host(LHost), LHost).
host_check(LHost) :-
    member('.', LHost),
    split_on_element(LHost, '.', Left, Right),
    phrase(id_host(Left), Left),
    remove_n(Right, 1, Rest),
    host_check(Rest).

% DCG for normal URI

digit(NAtom) --> [NAtom], { atom_number(NAtom, N), number(N) }.
ip_address -->
    three_digits(_N1, _N2, _N3),
    ['.'],
    three_digits(_N4, _N5, _N6),
    ['.'],
    three_digits(_N7, _N8, _N9),
    ['.'],
    three_digits(_N10, _N11, _N12).
three_digits(N1, N2, N3) -->
    digit(N1), digit(N2), digit(N3),
    { atomic_list_concat([N1, N2, N3], NAtom),
      atom_number(NAtom, Number),
      Number >= 0,
      Number =< 255 }.

id([]) --> [], !.
id([H | T]) -->
    [H],
    { H \= '/', H \= '?', H \= '#', H \= '@', H \= ':' },
    id(T).

id_host([]) --> [], !.
id_host([H | T]) -->
    [H],
    id_host([H | T]).
id_host([H | T]) -->
    [H],
    { H \= '.', H \= '/', H \= '?', H \= '#', H \= '@', H \= ':' },
    id_host(T).

port([]) --> [], !.
port([H | T]) --> digit(H), port(T).

query([]) --> [], !.
query([H | T]) --> [H], { H \= '#' }, query(T).

fragment([]) --> [], !.
fragment([H | T]) --> [H], fragment(T).

% DCG for zos

id44([], N) -->
    [],
    { N =< 44 },
    !.
id44([X], _) -->
    [X],
    { X = '.', !, fail }.
id44([H | T], N) -->
    [H],
    { N = 0, char_type(H, alpha), M is N + 1 },
    id44(T, M).
id44([H | T], N) -->
    [H],
    { N > 0, N =< 44, H = '.', M is N + 1 },
    id44(T, M).
id44([H | T], N) -->
    [H],
    { N > 0, N =< 44, char_type(H, alnum), M is N + 1 },
    id44(T, M).

id8([], N) -->
    [],
    { N =< 8 },
    !.
id8([H | T], N) -->
    [H],
    { N = 0, char_type(H, alpha), M is N + 1 },
    id8(T, M).
id8([H | T], N) -->
    [H],
    { N > 0, N =< 8, char_type(H, alnum), M is N + 1 },
    id8(T, M).

% conversion from list to atom

generate_atom([], Result) :-
    Result = [],
    !.
generate_atom(List, Result) :-
    atomic_list_concat(List, Result).

generate_port([], Result) :-
    Result = [],
    !.
generate_port(LPort, Port) :-
    generate_atom(LPort, APort),
    atom_number(APort, Port).

% predicates for writing

uri_display(URI) :-
    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment),
    write('Scheme:\t\t'),
    write(Scheme),
    write('\n'),
    write('Userinfo:\t'),
    write(Userinfo),
    write('\n'),
    write('Host:\t\t'),
    write(Host),
    write('\n'),
    write('Port:\t\t'),
    write(Port),
    write('\n'),
    write('Path:\t\t'),
    write(Path),
    write('\n'),
    write('Query:\t\t'),
    write(Query),
    write('\n'),
    write('Fragment:\t'),
    write(Fragment),
    write('\n\n').

uri_display(URI, Stream) :-
    URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment),
    write(Stream, 'Scheme:\t\t'),
    write(Stream, Scheme),
    write(Stream, '\n'),
    write(Stream, 'Userinfo:\t'),
    write(Stream, Userinfo),
    write(Stream, '\n'),
    write(Stream, 'Host:\t\t'),
    write(Stream, Host),
    write(Stream, '\n'),
    write(Stream, 'Port:\t\t'),
    write(Stream, Port),
    write(Stream, '\n'),
    write(Stream, 'Path:\t\t'),
    write(Stream, Path),
    write(Stream, '\n'),
    write(Stream, 'Query:\t\t'),
    write(Stream, Query),
    write(Stream, '\n'),
    write(Stream, 'Fragment:\t'),
    write(Stream, Fragment),
    write(Stream, '\n\n').
