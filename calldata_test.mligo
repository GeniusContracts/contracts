type parameter = bytes

type storage = unit

let main (arg : parameter * storage) : operation list * storage =
  begin
    let (_,storage) = arg in
    (([] : operation list), storage)
  end
