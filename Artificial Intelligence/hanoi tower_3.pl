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
	write('-Megalyteros diskos den mporei na mpei panw apo mikrotero'),nl,nl,
	write('~~~Grapse lysi. kai to provlima tha lythei~~~'),nl,
	write('------------------------------'),nl.

lysi:-
	arxiki_katastasi(a),nl,
	move(1,a,c),
	move(2,a,b),
	move(1,c,b),
	move(3,a,c),
	move(1,b,a),
	move(2,b,c),
	move(1,a,c),
	move(4,a,b),
	move(1,c,a),
	move(2,c,b),
	move(1,a,b),
	move(3,c,a),
	move(1,b,a),
	move(2,b,c),
	move(1,a,c),
	move(3,a,b),
	move(1,c,a),
	move(2,c,b),
	move(1,a,b),
	move(5,a,c),
	move(1,b,c),
	move(2,b,a),
	move(1,c,a),
	move(3,b,c),
	move(1,a,c),
	move(2,a,b),
	move(1,c,b),
	move(3,c,a),
	move(1,b,c),
	move(2,b,a),
	move(1,c,a),
	move(4,b,c),
	move(1,a,c),
	move(2,a,b),
	move(1,c,b),
	move(3,a,c),
	move(1,b,a),
	move(2,b,c),
	move(1,a,c).


%katastasi(passalos,diskos)
arxiki_katastasi(X):-
retractall(katastasi(_,_)),
write('Arxika oi disoi vriskontai ston passalo '),
write(X),nl,
assert(katastasi(X,5)),
assert(katastasi(X,4)),
assert(katastasi(X,3)),
assert(katastasi(X,2)),
assert(katastasi(X,1)),
print_state_a,print_state_b,print_state_c.



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
win:-( katastasi(K,1),katastasi(L,2),
      katastasi(M,3),katastasi(N,3),
      katastasi(O,4),katastasi(P,5),
      K==L,L==M,M==N,N==O,O==P,
      write('----MPRAVO KERDISES!---'),nl);nl.




%\\\\\---------Periorismoi----------/////
%1.den mporei megalyteros diskos na mpei panw apo mikrotero
%  kata analogia tou metakinisi(N,X,Y)

check(N,X,Y):- (katastasi(Y,M),katastasi(X,N),
	N>M->write('Lathos kinisi'),
		nl,!,fail);true.

%2.mono o panw diskos mporei na metakinithei

updisk(N,X,Y):- (katastasi(X,N),katastasi(X,M),
	N>M->write('Den mporei na metakinithei o diskos '),
	write(N),write(' ston passalo '), write(Y),
	write(' giati den einai o panw diskos'),nl,!,fail);
        true.



