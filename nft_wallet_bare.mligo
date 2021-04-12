type send_parameter =
  [@layout:comb]
  {destination : nat ticket contract;
   ticket_id : nat}

type receive_parameter = (nat ticket)

type parameter =
  | Receive of receive_parameter
  | Send of send_parameter

type storage =
  [@layout:comb]
  {admin : address;
   tickets : (nat, nat ticket) big_map;
   current_id : nat;
   }

let main (arg : parameter * storage) : operation list * storage =
  begin
    assert (Tezos.amount = 0mutez);
    let (p,storage) = arg in
    let {admin = admin ; tickets = tickets; current_id = current_id} = storage in
    ( match p with
      | Receive ticket -> begin
        let ((_,(_,_)), ticket) = Tezos.read_ticket ticket in
        let (_,tickets) = Big_map.get_and_update current_id (Some ticket) tickets in
        (([] : operation list), {admin = admin; tickets = tickets; current_id = current_id + 1n})
        end
      | Send send -> begin
        assert (Tezos.sender = admin);
        let (ticket, tickets) = Big_map.get_and_update send.ticket_id (None : nat ticket option) tickets in
        ( match ticket with
          | None -> (failwith "no tickets" : operation list * storage)
          | Some ticket ->
              let op = Tezos.transaction ticket 0mutez send.destination in
              ([op], {admin = admin; tickets = tickets; current_id = current_id})
        )
      end
    )
  end
