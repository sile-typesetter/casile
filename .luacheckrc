std = "lua54+sile"

max_line_length = false

include_files = {
   "**/*.lua",
   "**/*.lua.in",
   "*.rockspec",
   ".busted",
   ".luacheckrc",
}

exclude_files = {
   "casile-*",
   "lua_modules",
   "lua-libraries",
   ".lua",
   ".luarocks",
   ".install",
}

files["spec"] = {
   std = "+busted",
}

files["pandoc-filters"] = {
   globals = {
      "Block",
      "Header",
      "Inline",
      "Link",
      "Note",
      "Pandoc",
      "pandoc",
   },
   ignore = { "4.2" },
}
