open Core.Std

(***
    Apply f to f of f x, etc, for a total of n applications of f.
    Basically, Haskell's iterate function.
***)
let recurse f x n =
    List.fold_left ~init:(f x)
                    ~f:(fun acc _idx -> f acc)
                    (List.range 0 (pred n))
