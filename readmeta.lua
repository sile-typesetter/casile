local yaml = require("yaml")
yaml.configure({
	load_nulls_as_nil = true,
	load_numeric_scalars = false,
})

return {
	load = function (filename)
		return yaml.loadpath(filename)
	end
}
