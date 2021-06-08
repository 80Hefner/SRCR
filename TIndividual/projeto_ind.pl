:- op( 900,xfy,'::' ).
:- use_module(library(lists)).

:- include('pontos_recolha.pl').
:- include('arcos.pl').

% -------------------------- Predicados das Aulas -------------------------- %

nao( Questao ) :-
    Questao, !, fail.
nao( _ ).

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

comprimento(S,N) :- length(S,N).

estaVazia(L,V) :- comprimento(L,V),nao(V>0).

imprime([]).
imprime([X|T]) :- write(X), nl, imprime(T).

getLocalTipo(Local,Tipo) :- pontos_recolha(_, _, Local, Tipo, _, _).
getArco(Origem,Destino,Dist) :- arco(Origem,Destino,Dist).

totalLixo([],0).
totalLixo([X|T],Tx):- totalLixo(T,Ty), Tx is X + Ty.

adjacente(Origem, Destino, Custo) :- getArco(Origem, Destino, Custo).
adjacente(Origem, Destino, Custo) :- getArco(Destino, Origem, Custo).

minimo(L, (A,B)) :-
    select((A,B), L, R),
    \+ ( member((A1,B1), R), B1 < B ).

maximo(L, (A,B)) :-
    select((A,B), L, R),
    \+ ( member((A1,B1), R), B1 > B ).
             


% -------------------------- Projeto -------------------------- %

inicial('R do Alecrim').

final('Av 24 de Julho').

% -------------------------- Procura não informada -------------------------- %


% -------------------------- DFS (número de arcos) -------------------------- %

% Devolve um caminho através de uma procura em profundidade.
resolveProcuraProfundidade([Nodo|Caminho]):-
    inicial(Nodo),
    procuraProfundidade(Nodo,[Nodo],Caminho).

procuraProfundidade(Nodo,_,[]):-
    final(Nodo).

procuraProfundidade(Nodo,Historico,[ProxNodo|Caminho]):-
    adjacente(Nodo,ProxNodo,_),
    nao(membro(ProxNodo,Historico)),
    procuraProfundidade(ProxNodo,[ProxNodo|Historico],Caminho).

% Devolve todos os caminhos possíveis através de uma DFS.
resolveProcuraProfundidadeTodos(L):-
    findall((S,C),(resolveProcuraProfundidade(S),comprimento(S,C)),L).

% Devolve o caminho com o maior número de arcos através de uma DFS.
melhorSolucaoProcuraProfundidadeMaximo(Nodo,Caminho,NArcos):-
    findall((S,C),(resolveProcuraProfundidade(S),comprimento(S,C)),L), maximo(L,(Caminho,NArcos)).

% Devolve o caminho com o menor número de arcos através de uma DFS.
melhorSolucaoProcuraProfundidade(Nodo,Caminho,NArcos):-
    findall((S,C),(resolveProcuraProfundidade(S),comprimento(S,C)),L), minimo(L,(Caminho,NArcos)).

% Devolve um caminho através de uma DFS, tendo em conta um tipo de lixo.
resolveProcuraProfundidadeTipo([Nodo|Caminho], Tipo):-
    inicial(Nodo),
    procuraProfundidadeTipo(Nodo,[Nodo],Caminho, Tipo).

procuraProfundidadeTipo(Nodo,_,[], Tipo):-
    final(Nodo).

procuraProfundidadeTipo(Nodo,Historico,[ProxNodo|Caminho], Tipo):-
    getLocalTipo(ProxNodo, Tipo),
    adjacente(Nodo,ProxNodo,_),
    nao(membro(ProxNodo,Historico)),
    procuraProfundidadeTipo(ProxNodo,[ProxNodo|Historico],Caminho, Tipo).

% Devolve todos os caminhos possíveis através de uma DFS, tendo em conta um tipo de lixo.
resolveProcuraProfundidadeTAll(L,T):-
    findall((S,C),(resolveProcuraProfundidadeTipo(S,T),comprimento(S,C)),L).

% Devolve o caminho com o maior número de arcos através de uma DFS, tendo em conta um tipo de lixo.
melhorSolucaoProcuraProfundidadeTMaximo(Nodo,Caminho,NArcos,Tipo):-
    findall((S,C),(resolveProcuraProfundidadeTipo(S,T),comprimento(S,C)),L), maximo(L,(Caminho,NArcos)).


% -------------------------- DFS (distâncias) -------------------------- %

% Devolve um caminho e o respetivo custo através de uma DFS.
resolveProcuraProfundidadeCusto([Nodo|Caminho],Custo):-
    inicial(Nodo),
    procuraProfundidadeCusto(Nodo,[Nodo],Caminho,Custo).

procuraProfundidadeCusto(Nodo,_,[],0):-
    final(Nodo).

procuraProfundidadeCusto(Nodo,Historico,[ProxNodo|Caminho],Custo):-
    adjacente(Nodo,ProxNodo,CustoArco),
    nao(membro(ProxNodo,Historico)),
    procuraProfundidadeCusto(ProxNodo,[ProxNodo|Historico],Caminho,AuxCusto),
    Custo is CustoArco+AuxCusto.

% Devolve todos os caminhos e respetivos custos através de uma DFS.
resolveProcuraProfundidadeCustoTodos(L):-
    findall((S,C),(resolveProcuraProfundidadeCusto(S,C)),L).

% Devolve o caminho com menor custo e o respetivo custo através de uma DFS.
melhorSolucaoProcuraProfundidadeCusto(Nodo,Caminho,Custo):-
    findall((S,C),(resolveProcuraProfundidadeCusto(S,C)),L),minimo(L,(Caminho,Custo)).

% Devolve um caminho e o respetivo custo através de uma DFS, tendo em conta um tipo de lixo.
resolveProcuraProfundidadeCustoTipo([Nodo|Caminho],Custo, Tipo):-
    inicial(Nodo),
    procuraProfundidadeCustoTipo(Nodo,[Nodo],Caminho,Custo,Tipo).

procuraProfundidadeCustoTipo(Nodo,_,[],0,Tipo):-
    final(Nodo).

procuraProfundidadeCustoTipo(Nodo,Historico,[ProxNodo|Caminho],Custo,Tipo):-
    getLocalTipo(ProxNodo,Tipo),
    adjacente(Nodo,ProxNodo,CustoArco),
    nao(membro(ProxNodo,Historico)),
    procuraProfundidadeCustoTipo(ProxNodo,[ProxNodo|Historico],Caminho,CustoAux,Tipo),
    Custo is CustoArco+CustoAux.

% Devolve todos os caminhos e respetivos custos através de uma DFS, tendo em conta um tipo de lixo.
resolveProcuraProfundidadeCustoTipoTodos(L,T):-
    findall((S,C),(resolveProcuraProfundidadeCustoTipo(S,C,T)),L).


% -------------------------- DFS (produtividade) -------------------------- %

resolveProcuraProfundidadeProdutividade([Nodo|Caminho], Custo):-
    inicial(Nodo),
    procuraProfundidadeProdutividade(Nodo,[Nodo], Caminho, Custo).

procuraProfundidadeProdutividade(Nodo, _, [], 0):-
    final(Nodo).

procuraProfundidadeProdutividade(Nodo, Historico, [ProxNodo|Caminho], Custo):-
    adjacente(Nodo, ProxNodo,_),
    calculaProdutividade(ProxNodo, CustoArco),
    nao(membro(ProxNodo, Historico)),
    procuraProfundidadeProdutividade(ProxNodo, [ProxNodo|Historico], Caminho, AuxCusto),
    Custo is CustoArco + AuxCusto.

calculaProdutividade(Nodo,Total) :- findall(C,pontos_recolha(_,_,Nodo,_,C,_),R),totalLixo(R,Total).

melhorSolucaoMaxLixo(Nodo,Cam,Custo):- findall((Ca,Cus), (resolveProcuraProfundidadeProdutividade(Ca,Cus)), L),maximo(L,(Cam,Custo)).


% -------------------------- BFS (número de arcos) -------------------------- %

% Devolve um caminho através de uma BFS.
resolveLarguraPrimeiro(Nodo,Solucao):-
    inicial(Nodo),
    larguraPrimeiro([[Nodo]],Solucao).

larguraPrimeiro([[Nodo|Caminho]|_],[Nodo|Caminho]):-
    final(Nodo).

larguraPrimeiro([Caminho|Caminhos],Solucao):-
    extend(Caminho,Novos),
    append(Caminhos,Novos,AuxCaminhos),
    larguraPrimeiro(AuxCaminhos,Solucao).

extend([Nodo|Caminho],Novos):-
    findall([Novo,Nodo|Caminho],
        (adjacente(Nodo,Novo,_), nao(membro(Novo,[Nodo|Caminho]))),
        Novos).

% Devolve todos os caminhos possíveis através de uma BFS.
resolveLarguraPrimeiroTodos(L):-
    findall((S,C),(resolveLarguraPrimeiro(N,S),comprimento(S,C)),L).

% Devolve o caminho com o menor número de arcos através de uma BFS.
melhorSolucaoLarguraPrimeiro(Nodo,Caminho,NArcos):-
    findall((S,C),(resolveLarguraPrimeiro(N,S),comprimento(S,C)),L), minimo(L,(Caminho,NArcos)).

% -------------------------- BFS (distâncias) -------------------------- %
 
% Devolve um caminho e o respetivo custo através de uma BFS.
resolveLarguraPrimeiroCusto(Solucao, Custo) :-
    inicial(No),
    larguraPrimeiro([[No]],Sol),
    reverse(Sol,Solucao),
    custoTotal(Solucao, Custo). 

custoTotal([],0).
custoTotal([No],0).
custoTotal([No1,No2|Caminho],Custo) :-
    adjacente(No1,No2,CustoArco),
    custoTotal([No2|Caminho],CustoResto),
    Custo is CustoArco + CustoResto.

% Devolve todos os caminhos possíveis e os respetivos custos através de uma BFS.
resolveLarguraPrimeiroCustoTodos(L):- findall((S,C),(resolveLarguraPrimeiroCusto(S,C)),L).

% Devolve o melhor caminho e o respetivo custo através de uma BFS.
melhorSolucaoLarguraPrimeiroCusto(Nodo,Caminho,Custo):-
    findall((S,C),(resolveLarguraPrimeiroCusto(S,C)),L),minimo(L,(Caminho,Custo)).


% -------------------------- Limitada em Profundidade (número de arcos) -------------------------- %

% Devolve um caminho através de uma Busca Iterativa Limitada em Profundidade.
resolveLimitadeEmProfundidade(Solucao,L) :-
    inicial(Nodo),
    limitadaEmProfundidade([],Nodo,SolucaoAux,L),
    reverse(SolucaoAux,Solucao).

limitadaEmProfundidade(Caminho,Nodo,[Nodo|Caminho],_) :-
    final(Nodo),!.

limitadaEmProfundidade(Caminho,Nodo,S,L) :-
    L > 0,
    adjacente(Nodo,ProxNodo,_),
    nao(membro(ProxNodo,Caminho)),
    L1 is L - 1,
    limitadaEmProfundidade([Nodo|Caminho],ProxNodo,S,L1).

% Devolve todos os caminhos possíveis através de uma Busca Iterativa Limitada em Profundidade.
resolveLimitadeEmProfundidadeTodos(L,Size):- 
    findall((S,C),(resolveLimitadeEmProfundidade(S,Size),comprimento(S,C)), L).

% Devolve o caminho com o menor número de arcos através de uma Busca Iterativa Limitada em Profundidade.
melhorSolucaoLimitadeEmProfundidade(Nodo,Caminho,NArcos,Size):-
    findall((S,C),(resolveLimitadeEmProfundidade(S,Size),comprimento(S,C)),L), minimo(L,(Caminho,NArcos)).

% Devolve um caminho através de uma Busca Iterativa Limitada em Profundidade, tendo em conta um tipo de lixo.
resolveLimitadeEmProfundidadeTipo(Solucao,L,Tipo) :-
    inicial(Nodo),
    limitadaEmProfundidadeTipo([],Nodo,SolucaoAux,L,Tipo),
    reverse(SolucaoAux,Solucao).

limitadaEmProfundidadeTipo(Caminho,Nodo,[Nodo|Caminho],_,Tipo) :-
    final(Nodo),!.

limitadaEmProfundidadeTipo(Caminho,Nodo,S,L,Tipo) :-
    getLocalTipo(ProxNodo,Tipo),
    L > 0,
    adjacente(Nodo,ProxNodo,_),
    nao(membro(ProxNodo,Caminho)),
    L1 is L - 1,
    limitadaEmProfundidadeTipo([Nodo|Caminho],ProxNodo,S,L1,Tipo).

% Devolve todos os caminhos possíveis através de uma Busca Iterativa Limitada em Profundidade, tendo em conta um tipo de lixo.
resolveLimitadeEmProfundidadeTodosTipo(L,Size,Tipo):- 
    findall((S,C),(resolveLimitadeEmProfundidadeTipo(S,Size,Tipo),comprimento(S,C)), L).


% -------------------------- Limitada em Profundidade (distâncias) -------------------------- %

% Devolve um caminho e o respetivo custo através de uma Busca Iterativa Limitada em Profundidade.
resolveLimitadeEmProfundidadeCusto(Solucao,L,Custo) :-
    inicial(Nodo),
    limitadaEmProfundidadeCusto([],Nodo,AuxSolucao,L,Custo),
    reverse(AuxSolucao,Solucao).

limitadaEmProfundidadeCusto(Caminho,Nodo,[Nodo|Caminho],L,0) :-
    final(Nodo),!.

limitadaEmProfundidadeCusto(Caminho,Nodo,S,L,Custo) :-
    L > 0,
    adjacente(Nodo,ProxNodo,CustoArco),
    nao(membro(ProxNodo,Caminho)),
    L1 is L - 1,
    limitadaEmProfundidadeCusto([Nodo|Caminho],ProxNodo,S,L1,AuxCusto),
    Custo is CustoArco + AuxCusto.

% Devolve todos os caminhos possíveis e os respetivos custos através de uma Busca Iterativa Limitada em Profundidade.
resolveLimitadeEmProfundidadeCustoTodos(L,Size):-
    findall((S,C,Cost),(resolveLimitadeEmProfundidadeCusto(S,Size,Cost)),L).

% Devolve o caminho com o menor custo e o respetivo custo através de uma Busca Iterativa Limitada em Profundidade.
melhorSolucaoLimitadeEmProfundidadeCusto(Nodo,Caminho,Custo,Size):-
    findall((S,C),(resolveLimitadeEmProfundidadeCusto(S,Size,C)),L),minimo(L,(Caminho,Custo)).

% Devolve um caminho e o respetivo custo através de uma Busca Iterativa Limitada em Profundidade, tendo em conta um tipo de lixo.
resolveLimitadeEmProfundidadeCustoTipo(Solucao,L,Custo,Tipo) :-
    inicial(Nodo),
    limitadaEmProfundidadeCustoTipo([],Nodo,AuxSolucao,L,Custo,Tipo),
    reverse(AuxSolucao,Solucao).

limitadaEmProfundidadeCustoTipo(Caminho,Nodo,[Nodo|Caminho],L,0,Tipo) :-
    final(Nodo),!.

limitadaEmProfundidadeCustoTipo(Caminho,Nodo,S,L,Custo,Tipo):-
    getLocalTipo(ProxNodo,Tipo),
    L > 0,
    adjacente(Nodo,ProxNodo,CustoArco),
    nao(membro(ProxNodo,Caminho)),
    L1 is L - 1,
    limitadaEmProfundidadeCustoTipo([Nodo|Caminho],ProxNodo,S,L1,AuxCusto,Tipo),
    Custo is CustoArco + AuxCusto.

% Devolve todos os caminhos possíveis e os respetivos custos através de uma Busca Iterativa Limitada em Profundidade, tendo em conta um tipo de lixo.
resolveLimitadeEmProfundidadeCustoTipoTodos(L,Size,Tipo):-
    findall((S,C,Cost),(resolveLimitadeEmProfundidadeCustoTipo(S,Size,Cost,Tipo)),L).




% -------------------------- Procura informada -------------------------- %

% -------------------------- Gulosa -------------------------- %

% Devolve um caminho através de uma procura Gulosa.
resolveGulosa(Nodo,Caminho/Custo):-
    estimativa(Nodo,Estimativa),
    gulosa([[Nodo]/0/Estimativa],CaminhoInverso/Custo/_),
    reverse(CaminhoInverso,Caminho).

gulosa(Caminhos,Caminho):-
    melhorGulosa(Caminhos,Caminho),
    Caminho = [Nodo|_]/_/_,final(Nodo).

gulosa(Caminhos,SolucaoCaminho):-
    melhorGulosa(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expandeGulosa(MelhorCaminho,ExpCaminhos),
    append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
    gulosa(NovoCaminhos,SolucaoCaminho).

melhorGulosa([Caminho],Caminho):- !.

melhorGulosa([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos],MelhorCaminho):-
	Est1 =< Est2, !,
	melhorGulosa([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).

melhorGulosa([_|Caminhos],MelhorCaminho):- 
	melhorGulosa(Caminhos,MelhorCaminho).

expandeGulosa(Caminho,Caminhos):-
	findall(NovoCaminho,adjacenteGulosa(Caminho,NovoCaminho),Caminhos).

adjacenteGulosa([Nodo|Caminho]/Custo/_,[ProxNodo,Nodo|Caminho]/NovoCusto/Est):-
	adjacente(Nodo,ProxNodo,CustoPasso),
    nao(membro(ProxNodo,Caminho)),
	NovoCusto is Custo+CustoPasso,
	estimativa(ProxNodo,Est).

estimativa(Nodo,Est):-
    distance(Nodo,Est).

distance(Origem,Dist):-
    pontos_recolha(Lat1,Lon1,Origem,_,_,_),
    final(Destino),
    pontos_recolha(Lat2,Lon2,Destino,_,_,_),
    P is 0.017453292519943295,
    A is (0.5 - cos((Lat2 - Lat1) * P) / 2 + cos(Lat1 * P) * cos(Lat2 * P) * (1 - cos((Lon2 - Lon1) * P)) / 2),
    Dist is (12742 * asin(sqrt(A))).

seleciona(E,[E|Xs],Xs).
seleciona(E,[X|Xs],[X|Ys]):- 
    seleciona(E,Xs,Ys).

% Devolve um caminho através de uma procura Gulosa, tendo em conta um tipo de lixo.
resolveGulosaTipo(Nodo,Caminho/Custo,Tipo):-
    estimativa(Nodo,Estimativa),
    gulosaTipo([[Nodo]/0/Estimativa],CaminhoInverso/Custo/_,Tipo),
    reverse(CaminhoInverso,Caminho).

gulosaTipo(Caminhos,Caminho,Tipo):-
    melhorGulosa(Caminhos,Caminho),
    Caminho = [Nodo|_]/_/_,final(Nodo).

gulosaTipo(Caminhos,SolucaoCaminho,Tipo):-
    melhorGulosa(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expandeGulosaTipo(MelhorCaminho,ExpCaminhos,Tipo),
    append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
    gulosaTipo(NovoCaminhos,SolucaoCaminho,Tipo).

expandeGulosaTipo(Caminho,Caminhos,Tipo):-
	findall(NovoCaminho,adjacenteGulosaTipo(Caminho,NovoCaminho,Tipo),Caminhos).

adjacenteGulosaTipo([Nodo|Caminho]/Custo/_,[ProxNodo,Nodo|Caminho]/NovoCusto/Est,Tipo):-
    getLocalTipo(NodoProx,Tipo),
	adjacente(Nodo,ProxNodo,PassoCusto),
    nao(membro(ProxNodo,Caminho)),
	NovoCusto is Custo+PassoCusto,
	estimativa(ProxNodo,Est).


% -------------------------- A* (A estrela) -------------------------- %

% Devolve um caminho através de uma procura A estrela.
resolveAEstrela(Caminho/Custo):-
    inicial(Nodo),
    pontos_recolha(_,_,Nodo,_,Cap,_),
    aEstrela([[Nodo]/0/pontos_recolha], CaminhoInverso/Custo/_),
    reverse(CaminhoInverso, Caminho).

aEstrela(Caminhos, Caminho):-
    melhorAEstrela(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_,
    final(Nodo).

aEstrela(Caminhos, SolucaoCaminho):-
    melhorAEstrela(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expandeAEstrela(MelhorCaminho, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aEstrela(NovoCaminhos, SolucaoCaminho).

melhorAEstrela([Caminho],Caminho):- !.

melhorAEstrela([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho):-
    Custo1 + Est1 =< Custo2 + Est2, !,
    melhorAEstrela([Caminho1/Custo1/Est1|Caminhos],MelhorCaminho).
    
melhorAEstrela([_|Caminhos],MelhorCaminho):- 
    melhorAEstrela(Caminhos,MelhorCaminho).
    
expandeAEstrela(Caminho,Caminhos):-
    findall(NovoCaminho,adjacenteGulosa(Caminho,NovoCaminho),Caminhos).
