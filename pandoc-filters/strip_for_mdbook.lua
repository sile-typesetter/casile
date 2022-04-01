function remove_attr (element)
  if element.attr then
    element.attr = pandoc.Attr()
    return element
  end
end

-- c.f. pandoc-filters/withoutheadinglinks.lua
Header = function (element)
  element = remove_attr(element)
  return pandoc.walk_block(element, {
      -- c.f. pandoc-filters/epubclean.lua
      Note = function (_)
        return {}
      end,
      Link = function (element)
        return element.content
      end
    })
end

Inline = remove_attr
Block = remove_attr
