--4 8 24
--8 8 24
--by yyonce

--a function dump data.

local put = table.insert
local format = string.format
local rep = string.rep

local function ondump(o,opar,r,add,added,deep,par,meta,cache) --onpublic
  local loaded = package.loaded
  put(r,"{")
  for k,v in pairs(o) do
    local dot --false
    local index = tostring(k)
    local _k = index or "nil" --nonnil
    --k
    if true then
      local n = rep(" ",add)
      if k == _G then
        put(r,format('\r\n%s[_G] = ',n))
       else
        local t = type(k)
        if t == "string" then
          put(r,format('\r\n%s[%q] = ',n,k))
          dot = true --true
          goto v
        end
        if t == "table" then
          local mt = getmetatable(k)
          if mt and mt.__tostring then
            put(r,format('\r\n%s[%q] = ',n,index))
            goto v
          end
        end
        put(r,format('\r\n%s[%s] = ',n,index))
        if k == v then
          put(r,index)
          put(r," ;")
          goto c
        end
      end
    end ::v::
    --v
    if true then
      if v == _G then
        put(r,"_G ;")
       else
        local t = type(v)
        if t == "table" then
          local mt = getmetatable(v)
          local mtto = mt and mt.__tostring
          if deep ~= nil and (deep == "_G" or deep == _k) then --can deep
            if mtto and meta then
              put(r,format("%q",tostring(v)))
              goto c
            end
            --cache
            local parent = par and par..(dot and "." or "/").._k or error("no par",2)
            if not mtto then --need stable cache key
              local _v = tostring(v) --nonnil
              local cached = cache[_v]
              if cached == nil then --no cache
                cache[_v] = parent
               else
                --cached
                put(r,cached)
                put(r," ;")
                goto c
              end
            end
            --can deep
            if v == loaded then --handle
              ondump(v,o,r,add+added,added,nil,parent,meta,cache)
             else
              ondump(v,o,r,add+added,added,"_G",parent,meta,cache)
            end
           else
            --no deep
            if mtto then
              put(r,format("%q ;",tostring(v)))
             else
              put(r,tostring(v))
              put(r," ;")
            end
          end
         elseif t == "string" then
          put(r,format("%q ;",v))
         else
          put(r,tostring(v))
          put(r," ;")
        end
      end
    end ::c:: --continue
  end
  put(r,format("\r\n%s} ;",rep(" ",add-added)))
end

local function _dump(o,r,add,added,deep,par,concat,meta) --can dump table
  if meta then
    local mt = getmetatable(o)
    if mt and mt.__tostring then
      put(r,o == _G and "_G ;" or format("%q ;",tostring(o)))
      return concat and table.concat(r) or nil
    end
  end
  ondump(o,nil,r,add,added,deep,par or "index",meta,{})
  return concat and table.concat(r) or nil
end

local function dump(o,deep)
  if o == nil then
    return "nil ;" end
  local t = type(o)
  if t == "table" then
    return _dump(o,{},2,4,deep,nil,true,true)
   elseif t == "string" then
    return format("%q ;",o)
   else return tostring(o).." ;"
  end
end

if true then
  print(dump(nil)) --nil ;
  print(dump(true)) --true ;
  print(dump(1.120)) --1.12 ;
  print(dump("Lua")) --"Lua" ;
  print(dump(dump))
  print(dump(this))
  print(dump(coroutine.running()))
  print(dump(_G))
  print(dump(_G,"package"))
  print(dump(_G,"_G"))
end

local function r(o) return dump(o,"_G") end

return r
