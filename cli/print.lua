local function print(text)
    io.stderr:write(tostring(text) .. "\n")
end

return print
