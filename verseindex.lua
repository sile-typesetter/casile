local href = SILE.Commands["href"]

SILE.registerCommand("href", function (options, content)
  SILE.call("markverse", options, content)
  return href(options, content)
end)

SILE.registerCommand("markverse", function (options, content)
  SU.dump(options, content)
  SILE.call("info", {
    category = "tov",
    value = {
      label = content
    }
  })
end)

SILE.registerCommand("verseindex", function (options, content)
end)
