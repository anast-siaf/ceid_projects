%dilosi synartisewn dynamic

:-dynamic arxiki_katastasi/1.
:-dynamic katastasi/2.
:-dynamic metakinisi/3.
:-dynamic print_state_a/5.
:-dynamic print_state_b/5.
:-dynamic print_state_c/5.

:-dynamic updisk/3.
:-dynamic check/3.
:-dynamic move/3.

%Eisagwgiko mhnyma pou typonei to programma
:-
	write('------Welcome--------------'),nl,
	write('------Hanoi Towers---------'),nl,
	write('Vasikes odhgies: '),nl,
	write('Arxika oloi oi diskoi vriskontai se ena passalo'),nl,
	write('----------------------------'),nl,
	write('1)Metakinisi diskou: ?-move(A,B,C). '),nl,
	write('\t opou A=diskos pros metakinisi,'),nl,
	write('\t opou B=passalos pou vrisketai o diskos'),nl,
	write('\t opou C=passalos pou tha metakinithei'),nl,
	write('2)Periorismoi:'),nl,
	write('-Mporei na metakinithei mono o teleftaios diskos'),nl,
	write('-Megalyteros diskos den mporei na mpei panw apo mikrotero'),nl,nl,nl,
	write('!!Orise prota tin arxiki katastasi!!'),nl,
	write('------------------------------'),nl.

%katastasi(passalos,diskos)
arxiki_katastasi:-
retractall(katastasi(_,_)),
write('Poios passalos thes na einai o arxikos? '),nl,
read(X),
assert(katastasi(X,5)),
assert(katastasi(X,4)),
assert(katastasi(X,3)),
assert(katastasi(X,2)),
assert(katastasi(X,1)),
print_state_a,print_state_b,print_state_c.


%metakinisi me periorismous
move(N,X,Y):- updisk(N,X,Y),check(N,X,Y),metakinisi(N,X,Y).




%metakiniseis
metakinisi(N,X,Y):-
	write('Metakinise ton disko '), write(N),
	write(' apo ton passalo '), write(X), write(' '),
	write('ston '), write(Y),nl,
	retract(katastasi(X,N)),
	assert(katastasi(Y,N)),print_state_a,
	print_state_b,print_state_c,nl,win.



%ektyposi katastasewn
%print_state:- print_state_a,print_state_b,print_state_c,nl.

print_state_a:-
	findall(X,katastasi(a,X),Passalosa),
	write('passalos A: '),write(Passalosa),nl.

print_state_b:-
	findall(Y,katastasi(b,Y),Passalosb),
	write('passalos B: '), write(Passalosb),nl.

print_state_c:-
	findall(Z,katastasi(c,Z),Passalosc),
	write('passalos C: '), write(Passalosc),nl.

%synthiki nikis
win:- (katastasi(K,1),katastasi(L,2),
      katastasi(M,3),katastasi(N,3),
      katastasi(O,4),katastasi(P,5),
      K==L,L==M,M==N,N==O,O==P,
      write('----MPRAVO KERDISES!---'),nl);nl.




%\\\\\---------Periorismoi----------/////
%1.den mporei megalyteros diskos na mpei panw apo mikrotero
%kata analogia tou metakinisi(N,X,Y)

check(N,X,Y):- (katastasi(Y,M),katastasi(X,N),
	N>M->write('Lathos kinisi'),nl,!,fail);true.

%2.mono o panw diskos mporei na metakinithei

updisk(N,X,Y):- (katastasi(X,N),katastasi(X,M),
	N>M->write('Den mporei na metakinithei o diskos '),
	write(N),write(' ston passalo '), write(Y),
	write(' giati den einai o panw diskos'),nl,!,fail);
        true.



