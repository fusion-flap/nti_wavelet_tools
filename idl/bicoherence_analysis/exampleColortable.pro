;https://www.harrisgeospatial.com/docs/TVLCT_Procedure.html
;http://www.idlcoyote.com/color_tips/create_colortable.html
PRO EXAMPLEcolortable
  pg_initgraph
  steps = 100
  scaleFactor = FINDGEN(steps) / (steps - 1)

  ; Do first 100 colors (yellow to blue).

  ; Red vector: 255 -> 0
  redVector = 255 + (0 - 255) * scaleFactor

  ; Green vector: 255 -> 0
  greenVector = 255 + (0 - 255) * scaleFactor

  ; Blue vector: 0 -> 255
  blueVector = 0 + (255 - 0) * scaleFactor

  ; Do second 100 colors (blue to red).

  ; Red vector: 0 -> 255
  redVector = [redVector, 0 + (255 - 0) * scaleFactor]

  ; Green vector: 0 -> 0
  greenVector = [greenVector, REPLICATE(0, steps)]

  ; Blue vector: 255 -> 0
  blueVector = [blueVector, 255 + (0 - 255) * scaleFactor]
  TVLCT, redVector, greenVector, blueVector

  image = FINDGEN(200) # REPLICATE(1, 40)
  WINDOW, XSIZE=200, YSIZE=40
  TV, BYTE(image)
END
