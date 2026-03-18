--[[
A simple function to print tables or to write tables into files.
Great for debugging but also for data storage.
When writing into files the 'return' keyword will be added automatically,
so the tables can be loaded with 'dofile()' into a variable.
The basic datatypes table, string, number, boolean and nil are supported.
The tables can be nested and have number and string indices.
This function has no protection when writing files without proper permissions and
when datatypes other then the supported ones are used.
--]]

-- t = table
-- f = filename [optional]
-- n = table name  [optional]
function printTable(t, f, n)

   local function printTableHelper(obj, cnt)

      local cnt = cnt or 0

      if type(obj) == "table" then

         io.write("\n", string.rep("\t", cnt), "{\n")
         cnt = cnt + 1

         for k,v in pairs(obj) do

            if type(k) == "string" then
               io.write(string.rep("\t",cnt), '["'..k..'"]', ' = ')
            end

            if type(k) == "number" then
               io.write(string.rep("\t",cnt), "["..k.."]", " = ")
            end

            printTableHelper(v, cnt)
            io.write(",\n")
         end

         cnt = cnt-1
         io.write(string.rep("\t", cnt), "}")

      elseif type(obj) == "string" then
         io.write(string.format("%q", obj))

      else
         io.write(tostring(obj))
      end 
   end

   if f == nil then
      printTableHelper(t)
   else
      io.output(f)
      io.write((n and n.." = ") or "return")
      printTableHelper(t)
      io.output(io.stdout)
   end
end
