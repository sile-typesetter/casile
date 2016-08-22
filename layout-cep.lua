local book=SILE.require("classes/book");
book:defineMaster({
  id="right", firstContentFrame="content", frames={
    content={ left="20mm", right="100%pw-10mm", top="20mm", bottom="100%ph-15mm" },
    runningHead= {left="left(content)", right="right(content)", top="top(content)-10mm", bottom="top(content)-2mm" },
    footnotes={ left="20mm", right="100%pw-12.5mm", top="0", height="0" },
  }
})
book:defineMaster({ id="left", firstContentFrame="content", frames={} })
book:loadPackage("twoside", { oddPageMaster="right", evenPageMaster="left" });
book:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id="right" })

SILE.registerCommand("imprint:font", function(options, content)
  SILE.call("font", { family="Libertinus Serif", size="7pt", language="und" }, content)
end)
