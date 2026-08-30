import AppKit

guard CommandLine.arguments.count == 3 else {
  fputs("Uso: swift compose_feature_graphic.swift entrada.png saida.png\n", stderr)
  exit(64)
}

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])

guard let source = NSImage(contentsOf: input),
      let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: 1024,
        pixelsHigh: 500,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0
      ),
      let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
  fputs("Não foi possível preparar a composição.\n", stderr)
  exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics

let canvas = NSRect(x: 0, y: 0, width: 1024, height: 500)
source.draw(in: canvas, from: .zero, operation: .copy, fraction: 1)

let overlay = NSGradient(colorsAndLocations:
  (NSColor(calibratedWhite: 0, alpha: 0.62), 0),
  (NSColor(calibratedWhite: 0, alpha: 0.42), 0.46),
  (NSColor(calibratedWhite: 0, alpha: 0), 0.72)
)
overlay?.draw(in: canvas, angle: 0)

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .left

let brandAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: 64, weight: .bold),
  .foregroundColor: NSColor(calibratedRed: 0.82, green: 0.88, blue: 0.81, alpha: 1),
  .kern: 1.5,
  .paragraphStyle: paragraph,
]

let sloganAttributes: [NSAttributedString.Key: Any] = [
  .font: NSFont.systemFont(ofSize: 28, weight: .medium),
  .foregroundColor: NSColor(calibratedRed: 0.72, green: 0.80, blue: 0.73, alpha: 1),
  .kern: 0.2,
  .paragraphStyle: paragraph,
]

NSString(string: "Aevum").draw(
  in: NSRect(x: 72, y: 244, width: 430, height: 82),
  withAttributes: brandAttributes
)
NSString(string: "Evolua no seu tempo").draw(
  in: NSRect(x: 74, y: 200, width: 430, height: 44),
  withAttributes: sloganAttributes
)

graphics.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let data = bitmap.representation(using: .png, properties: [:]) else {
  fputs("Não foi possível gerar o PNG.\n", stderr)
  exit(1)
}

try data.write(to: output, options: .atomic)
