local firstheading

findfirstheading = {
	Header = function (element)
		if not firstheading then
			firstheading = element.identifier
		end
	end
}

Pandoc = function (element)
	pandoc.walk_block(pandoc.Div(element.blocks), findfirstheading)
	print(firstheading)
	os.exit(firstheading and 0 or 1)
end
