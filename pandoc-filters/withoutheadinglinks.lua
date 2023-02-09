-- Don't allow links in headings (notably drops auto verse links)
Header = function (element)
  return pandoc.walk_block(element, {
    Link = function (element_)
      return element_.content
    end
  })
end
