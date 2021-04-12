type send_parameter = nat

type st = 8 sapling_state 
type tr = 8 sapling_transaction

type parameter =
  | Receive of tr

type storage =
  [@layout:comb]
  {
   secrets : (nat, tr) big_map;
   current_id : nat;
   state : st;
  }

let main (arg : parameter * storage) : operation list * storage =
  begin
    assert (Tezos.amount = 0mutez);
    let (p,storage) = arg in
    let {secrets = secrets; current_id = current_id; state = state} = storage in
    ( match p with
      | Receive trr -> begin

        let x :st = Tezos.sapling_empty_state in
        let result : (int * st) = 
        ( match Tezos.sapling_verify_update trr x with  
          | Some r -> r
          | None -> (failwith "failed" : int * st)
        ) in

        let (bal,_) :(int * st) = result in

        let (_, _) = (
          if bal < 0 && bal > 1000
            then (failwith "failed" : tr option * (nat, tr) big_map)
        else
          Big_map.get_and_update current_id (Some trr) secrets
        ) in

        (([] : operation list), {secrets = secrets; current_id = current_id + 1n; state = state})
        end
(*       | Apply id -> begin

        let x :st = Tezos.sapling_empty_state in
        let result : (int * st) = ( match Tezos.sapling_verify_update id x with  
          | Some r -> r
          | None -> (failwith "failed" : int * st)
        ) in
        (([] : operation list), {secrets = secrets; current_id = current_id; state = state})
      end *)
    )
  end
