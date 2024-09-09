function DeepCopy(Src)
  local Dest = {}
  if type(Src) ~= "table" then return Src end
  for Key, Val in pairs(Src) do
    
    Key = type(Key) == "table" and DeepCopy(Key) or Key    
    Val = type(Val) == "table" and DeepCopy(Val) or Val
    Dest[Key] = Val
  end
  return Dest
end
