type receive_parameter = (nat ticket)

type parameter =
  | Pickup of receive_parameter

type storage =
  [@layout:comb]
  {
   tacos : (bytes, address) big_map;
   ticketer_address : address;
   base_timestamp : timestamp;
  }

let main (arg : parameter * storage) : operation list * storage =
  begin
    assert (Tezos.amount = 0mutez);
    let (p,storage) = arg in
    let {tacos = tacos;ticketer_address = ticketer_address;base_timestamp = base_timestamp} = storage in
    ( match p with
      | Pickup ticket -> begin
        let ((addy,(content,amt)), ticket) = Tezos.read_ticket ticket in
        assert(addy = ticketer_address);
        assert(amt = 1n);
        let ts_int = Tezos.now - base_timestamp in
        let int_bytes = Bytes.pack ts_int in
        let sha = Crypto.sha256 int_bytes in
        let (_,tacos) = Big_map.get_and_update sha (Some Tezos.source : address option) tacos in
        (([] : operation list), {tacos = tacos;ticketer_address = ticketer_address;base_timestamp = base_timestamp})
      end
    )
  end
