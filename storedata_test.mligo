type parameter = bytes

type storage = bytes

let main (arg : parameter * storage) : operation list * storage =
  begin
    let (p,storage) = arg in
    (([] : operation list), p)
  end
