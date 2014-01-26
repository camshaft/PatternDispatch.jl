module TestDAG

using PatternDispatch: Ops, DAGs
using PatternDispatch.Common: emit!, calc!

primary_eq(x, y) = primary_rep(x) === primary_rep(y)


g = DAG()
args = calc!(g, Arg())
x = calc!(g, TupleRef(1), args)
y = calc!(g, TupleRef(2), args)
@assert calc!(g, TupleRef(1), args) === x
@assert !primary_eq(x, y)

emit!(g, EgalGuard(), x, y)
@assert primary_eq(x, y)


g = DAG()
t = calc!(g, Arg())
n = 5
args = [calc!(g, TupleRef(k)) for k=1:n]
for k=1:n, l=1:n
    @assert primary_eq(args[k], args[l]) == (k == l)
end

emit!(g, EgalGuard(), args[1], args[2])
emit!(g, EgalGuard(), args[3], args[4])
for k=1:n, l=1:n
    @assert primary_eq(args[k], args[l]) == (((k-1)&~1)==((l-1)&~1))
end

emit!(g, EgalGuard(), args[1], args[4])
for k=1:n, l=1:n
    @assert primary_eq(args[k], args[l]) == ((k<=4)==(l<=4))
end


g = DAG()
t = calc!(g, Arg())
emit!(g, TypeGuard(Matrix), t)
emit!(g, TypeGuard(Array{Int}), t)
@assert TGof(g, t) == Matrix{Int}


g = DAG()
t = calc!(g, Arg())
x, y = calc!(g, TupleRef(1), t), calc!(g, TupleRef(2), t)
emit!(g, TypeGuard(Matrix),     x)
emit!(g, TypeGuard(Array{Int}), y)
@assert TGof(g, x) == Matrix
@assert TGof(g, y) == Array{Int}
emit!(g, EgalGuard(), x, y)
@assert TGof(g, x) == Matrix{Int}


end
