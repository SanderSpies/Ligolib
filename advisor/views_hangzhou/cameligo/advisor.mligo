type advisorAlgo = (int -> bool)

type advisorStorage = {
    indiceAddress : address;
    algorithm : advisorAlgo;
    result : bool;
}

type advisorEntrypoints = ChangeAlgorithm of advisorAlgo | ExecuteAlgorithm of unit

type advisorFullReturn = operation list * advisorStorage

let missing_entrypoint_sendvalue : string = "the targeted contract has not entrypoint sendValue"

let change(p, s : advisorAlgo * advisorStorage) : advisorFullReturn = 
    (([] : operation list), { s with algorithm = p})

let executeAlgorithm(s : advisorStorage) : advisorFullReturn =
    let indiceValOpt : int option = Tezos.call_view "indice_value" unit s.indiceAddress in
    let indiceVal : int = match indiceValOpt with
    | None -> (failwith("unknown indice value") : int)
    | Some (v) -> v
    in
    (([] : operation list), { s with result = s.algorithm indiceVal })

let advisorMain(ep, store : advisorEntrypoints * advisorStorage) : advisorFullReturn = 
    let ret : advisorFullReturn = match ep with
    | ChangeAlgorithm(p) -> change(p, store)
    | ExecuteAlgorithm(_p) -> executeAlgorithm(store) 
    in 
    ret
