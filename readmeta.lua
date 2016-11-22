local yaml = require("yaml")
yaml.configure({ load_nulls_as_nil = true })

return {
	load = function(filename)
		return yaml.loadpath(filename)
	end
}
