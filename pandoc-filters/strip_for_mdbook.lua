local function remove_attr (element)
  if element.attr then
    element.attr = pandoc.Attr()
    return element
  end
end

-- c.f. pandoc-filters/withoutheadinglinks.lua
Header = function (element)
  if element.level >= 2 then
    element = remove_attr(element)
  end
  return pandoc.walk_block(element, {
    -- c.f. pandoc-filters/epubclean.lua
    Note = function (_)
      return {}
    end,
    Link = function (element_)
      return element_.content
    end
  })
end

Inline = remove_attr
Block = remove_attr
