#!/usr/bin/env lua

-- Remove footnotes from headers to pass epub validation for Play Books
Header = function (element)
  return pandoc.walk_block(element, {
      Note = function (element)
        return {}
      end
    })
end
