import AppKit

guard CommandLine.arguments.count == 3 else {
  fputs("Uso: compose_adaptive_foreground entrada.png saida.png\n", stderr)
  exit(64)
}

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])

guard let mark = NSImage(contentsOf: input),
      let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: 432,
        pixelsHigh: 432,
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
  fputs("Não foi possível preparar a camada adaptativa.\n", stderr)
  exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: 432, height: 432).fill()
mark.draw(
  in: NSRect(x: 72, y: 72, width: 288, height: 288),
  from: .zero,
  operation: .sourceOver,
  fraction: 1
)
graphics.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let data = bitmap.representation(using: .png, properties: [:]) else {
  fputs("Não foi possível gerar o PNG.\n", stderr)
  exit(1)
}
try data.write(to: output, options: .atomic)
