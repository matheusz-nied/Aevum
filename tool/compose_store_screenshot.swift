import AppKit

guard CommandLine.arguments.count == 4 else {
  fputs("Uso: compose_store_screenshot entrada.png saida.png titulo\n", stderr)
  exit(64)
}

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
let title = CommandLine.arguments[3]

guard let screenshot = NSImage(contentsOf: input),
      let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: 1080,
        pixelsHigh: 1920,
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
  fputs("Não foi possível preparar a screenshot.\n", stderr)
  exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics

let canvas = NSRect(x: 0, y: 0, width: 1080, height: 1920)
NSGradient(colors: [
  NSColor(calibratedRed: 0.015, green: 0.045, blue: 0.032, alpha: 1),
  NSColor(calibratedRed: 0.045, green: 0.105, blue: 0.073, alpha: 1),
  NSColor(calibratedRed: 0.018, green: 0.055, blue: 0.038, alpha: 1),
])?.draw(in: canvas, angle: 90)

let ringColor = NSColor(calibratedRed: 0.66, green: 0.76, blue: 0.66, alpha: 0.09)
for inset in [0.0, 32.0, 68.0, 108.0] {
  let ring = NSBezierPath(ovalIn: NSRect(x: 730 + inset / 2, y: 1660 + inset / 2, width: 300 - inset, height: 220 - inset))
  ring.lineWidth = 3
  ringColor.setStroke()
  ring.stroke()
}

let eyebrow = NSMutableParagraphStyle()
eyebrow.alignment = .left
NSString(string: "AEVUM  •  FOCO E HÁBITOS").draw(
  in: NSRect(x: 74, y: 1848, width: 820, height: 36),
  withAttributes: [
    .font: NSFont.systemFont(ofSize: 19, weight: .semibold),
    .foregroundColor: NSColor(calibratedRed: 0.68, green: 0.77, blue: 0.68, alpha: 1),
    .kern: 2.1,
    .paragraphStyle: eyebrow,
  ]
)

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .left
paragraph.lineBreakMode = .byWordWrapping
paragraph.lineSpacing = 2
NSString(string: title).draw(
  in: NSRect(x: 72, y: 1550, width: 936, height: 205),
  withAttributes: [
    .font: NSFont.systemFont(ofSize: title.count > 28 ? 40 : 46, weight: .bold),
    .foregroundColor: NSColor(calibratedWhite: 0.95, alpha: 1),
    .kern: -0.4,
    .paragraphStyle: paragraph,
  ]
)

let frame = NSRect(x: 110, y: 42, width: 860, height: 1529)
let shadowPath = NSBezierPath(roundedRect: frame.insetBy(dx: -2, dy: -2), xRadius: 42, yRadius: 42)
NSColor(calibratedWhite: 0, alpha: 0.42).setFill()
shadowPath.fill()

NSGraphicsContext.saveGraphicsState()
NSBezierPath(roundedRect: frame, xRadius: 38, yRadius: 38).addClip()
screenshot.draw(in: frame, from: .zero, operation: .copy, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

let border = NSBezierPath(roundedRect: frame, xRadius: 38, yRadius: 38)
border.lineWidth = 2
NSColor(calibratedWhite: 1, alpha: 0.16).setStroke()
border.stroke()

graphics.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let data = bitmap.representation(using: .png, properties: [:]) else {
  fputs("Não foi possível gerar o PNG.\n", stderr)
  exit(1)
}
try data.write(to: output, options: .atomic)
