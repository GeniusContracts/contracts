type receive_parameter = nat ticket contract

type parameter =
  | BuyTaco of receive_parameter
  | FreeTaco of receive_parameter

type storage =
  [@layout:comb]
  {admin : address;
   current_id : nat;
   current_price : tez;
   }

let main (arg : parameter * storage) : operation list * storage =
  begin
    let (p,storage) = arg in
    let {admin = admin; current_id = current_id; current_price = current_price} = storage in
    ( match p with
      | BuyTaco buy_dest -> begin
        assert (Tezos.amount = current_price);
        let ticket = Tezos.create_ticket current_id 1n in
        let op = Tezos.transaction ticket 0mutez buy_dest in
        ([op], {admin = admin; current_id = current_id + 1n; current_price = current_price + 1mutez})
      end
      | FreeTaco free_dest -> begin
        assert (Tezos.sender = admin);
        assert (Tezos.amount = 0mutez);
        let ticket = Tezos.create_ticket current_id 1n in 
        let op = Tezos.transaction ticket 0mutez free_dest in
        ([op], {admin = admin; current_id = current_id + 1n; current_price = current_price})
      end
    )
  end
