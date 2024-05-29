return function (class)
   class.options.binding = "print"
   class.options.papersize = 1000 / 300 .. "in x " .. 1600 / 300 .. "in"
end
