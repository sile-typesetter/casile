std = "lua53"
include_files = {
  "**/*.lua",
  "*.rockspec",
  ".busted",
  ".luacheckrc"
}
exclude_files = {
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
		"Link",
		"Header",
		"Note",
		"Pandoc",
		"pandoc"
	},
	ignore = { "4.2" }
}
globals = {
	"CASILE",
  "SILE",
  "SU",
  "std",
  "pl",
  "SYSTEM_SILE_PATH",
  "SHARED_LIB_EXT",
  "ProFi"
}
max_line_length = false
