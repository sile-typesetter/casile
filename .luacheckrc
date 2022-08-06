std = "lua54"
include_files = {
  "**/*.lua",
  "*.rockspec",
  ".busted",
  ".luacheckrc"
}
exclude_files = {
  "casile-*",
  "lua_modules",
  "lua-libraries",
  ".lua",
  ".luarocks",
  ".install"
}
files["spec"] = {
  std = "+busted"
}
files["pandoc-filters"] = {
  globals = {
    "Block",
    "Header",
    "Inline",
    "Link",
    "Note",
    "Pandoc",
    "pandoc"
  },
  ignore = { "4.2" }
}
globals = {
  "SILE",
  "SU",
  "luautf8",
  "pl",
  "fluent",
  "CASILE"
}
max_line_length = false
