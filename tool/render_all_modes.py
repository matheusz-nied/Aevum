import zlib, struct, math, os

def load_rgba(path):
    with open(path, 'rb') as f:
        data = f.read()
    idx = 8
    idat = []
    w, h = 0, 0
    colort = 6
    while idx < len(data):
        length, = struct.unpack('>I', data[idx:idx+4])
        ctype = data[idx+4:idx+8]
        chunk = data[idx+8:idx+8+length]
        if ctype == b'IHDR':
            w, h, bitd, colort, comp, filt, inter = struct.unpack('>IIBBBBB', chunk)
        elif ctype == b'IDAT':
            idat.append(chunk)
        elif ctype == b'IEND':
            break
        idx += 12 + length
    raw = zlib.decompress(b''.join(idat))
    
    src_bpp = 3 if colort == 2 else 4
    src_stride = w * src_bpp
    
    # Target is always 4 bpp RGBA
    img = bytearray(w * h * 4)
    src_idx = 0
    dst_idx = 0
    prev_row = bytearray(src_stride)
    
    for y in range(h):
        filter_type = raw[src_idx]
        src_idx += 1
        row = bytearray(raw[src_idx:src_idx+src_stride])
        src_idx += src_stride
        
        if filter_type == 1:
            for x in range(src_bpp, src_stride):
                row[x] = (row[x] + row[x - src_bpp]) & 0xff
        elif filter_type == 2:
            for x in range(src_stride):
                row[x] = (row[x] + prev_row[x]) & 0xff
        elif filter_type == 3:
            for x in range(src_stride):
                left = row[x - src_bpp] if x >= src_bpp else 0
                row[x] = (row[x] + ((left + prev_row[x]) >> 1)) & 0xff
        elif filter_type == 4:
            for x in range(src_stride):
                a = row[x - src_bpp] if x >= src_bpp else 0
                b = prev_row[x]
                c = prev_row[x - src_bpp] if x >= src_bpp else 0
                p = a + b - c
                pa = abs(p - a)
                pb = abs(p - b)
                pc = abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                row[x] = (row[x] + pr) & 0xff
                
        prev_row = row
        
        # Convert to RGBA
        if src_bpp == 3:
            for px in range(w):
                img[dst_idx + px*4] = row[px*3]
                img[dst_idx + px*4 + 1] = row[px*3 + 1]
                img[dst_idx + px*4 + 2] = row[px*3 + 2]
                img[dst_idx + px*4 + 3] = 255
        else:
            img[dst_idx : dst_idx + w*4] = row
            
        dst_idx += w * 4
        
    return w, h, img

def save_rgba_png(path, w, h, rgba_bytes):
    raw_scanlines = bytearray()
    stride = w * 4
    for y in range(h):
        raw_scanlines.append(0)
        start = y * stride
        raw_scanlines.extend(rgba_bytes[start:start+stride])
    compressed = zlib.compress(raw_scanlines, 6)
    def make_chunk(ctype, data):
        length = struct.pack('>I', len(data))
        crc = struct.pack('>I', zlib.crc32(ctype + data) & 0xffffffff)
        return length + ctype + data + crc
    ihdr_data = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(make_chunk(b'IHDR', ihdr_data))
        f.write(make_chunk(b'IDAT', compressed))
        f.write(make_chunk(b'IEND', b''))

class Canvas:
    def __init__(self, w, h, base_rgba=None):
        self.w = w
        self.h = h
        if base_rgba:
            self.buf = bytearray(base_rgba)
        else:
            self.buf = bytearray(w * h * 4)

    def set_pixel(self, x, y, r, g, b, a=255):
        if 0 <= x < self.w and 0 <= y < self.h:
            r = min(255, max(0, int(r)))
            g = min(255, max(0, int(g)))
            b = min(255, max(0, int(b)))
            a = min(255, max(0, int(a)))
            idx = (y * self.w + x) * 4
            if a >= 255:
                self.buf[idx] = r
                self.buf[idx+1] = g
                self.buf[idx+2] = b
                self.buf[idx+3] = 255
            elif a > 0:
                alpha = a / 255.0
                inv = 1.0 - alpha
                self.buf[idx] = int(r * alpha + self.buf[idx] * inv)
                self.buf[idx+1] = int(g * alpha + self.buf[idx+1] * inv)
                self.buf[idx+2] = int(b * alpha + self.buf[idx+2] * inv)
                self.buf[idx+3] = 255

    def get_pixel(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            idx = (y * self.w + x) * 4
            return (self.buf[idx], self.buf[idx+1], self.buf[idx+2], self.buf[idx+3])
        return (0, 0, 0, 0)

    def draw_circle_fill(self, cx, cy, radius, r, g, b, a=255):
        min_x = max(0, int(cx - radius - 2))
        max_x = min(self.w - 1, int(cx + radius + 2))
        min_y = max(0, int(cy - radius - 2))
        max_y = min(self.h - 1, int(cy + radius + 2))

        for y in range(min_y, max_y + 1):
            dy = y - cy
            for x in range(min_x, max_x + 1):
                dx = x - cx
                dist = math.hypot(dx, dy)
                if dist <= radius:
                    edge = radius - dist
                    sub_a = a * min(1.0, max(0.0, edge + 0.5))
                    self.set_pixel(x, y, r, g, b, int(sub_a))

    def draw_circle_stroke(self, cx, cy, radius, r, g, b, a=255, stroke_width=2.0):
        r_min = radius - stroke_width / 2.0
        r_max = radius + stroke_width / 2.0
        min_x = max(0, int(cx - r_max - 2))
        max_x = min(self.w - 1, int(cx + r_max + 2))
        min_y = max(0, int(cy - r_max - 2))
        max_y = min(self.h - 1, int(cy + r_max + 2))

        for y in range(min_y, max_y + 1):
            dy = y - cy
            for x in range(min_x, max_x + 1):
                dx = x - cx
                dist = math.hypot(dx, dy)
                if r_min <= dist <= r_max:
                    edge = min(dist - r_min, r_max - dist)
                    sub_a = a * min(1.0, max(0.0, edge + 0.5))
                    self.set_pixel(x, y, r, g, b, int(sub_a))

    def draw_arc(self, cx, cy, radius, start_angle, sweep_angle, r, g, b, a=255, stroke_width=4.0):
        r_min = radius - stroke_width / 2.0
        r_max = radius + stroke_width / 2.0
        min_x = max(0, int(cx - r_max - 2))
        max_x = min(self.w - 1, int(cx + r_max + 2))
        min_y = max(0, int(cy - r_max - 2))
        max_y = min(self.h - 1, int(cy + r_max + 2))

        for y in range(min_y, max_y + 1):
            dy = y - cy
            for x in range(min_x, max_x + 1):
                dx = x - cx
                dist = math.hypot(dx, dy)
                if r_min <= dist <= r_max:
                    ang = math.atan2(dy, dx)
                    diff = (ang - start_angle) % (2 * math.pi)
                    if diff <= sweep_angle:
                        edge = min(dist - r_min, r_max - dist)
                        sub_a = a * min(1.0, max(0.0, edge + 0.5))
                        self.set_pixel(x, y, r, g, b, int(sub_a))

    def draw_radial_glow(self, cx, cy, radius, r, g, b, peak_a=100):
        min_x = max(0, int(cx - radius))
        max_x = min(self.w - 1, int(cx + radius))
        min_y = max(0, int(cy - radius))
        max_y = min(self.h - 1, int(cy + radius))

        for y in range(min_y, max_y + 1):
            dy = y - cy
            for x in range(min_x, max_x + 1):
                dx = x - cx
                dist = math.hypot(dx, dy)
                if dist < radius:
                    t = 1.0 - (dist / radius)
                    alpha = int(peak_a * (t * t))
                    self.set_pixel(x, y, r, g, b, alpha)

    def draw_line(self, x0, y0, x1, y1, r, g, b, a=255, stroke_width=2.0):
        dx = x1 - x0
        dy = y1 - y0
        length = math.hypot(dx, dy)
        if length == 0: return
        steps = int(length * 2)
        for i in range(steps + 1):
            t = i / steps
            px = x0 + dx * t
            py = y0 + dy * t
            self.draw_circle_fill(px, py, stroke_width / 2.0, r, g, b, a)

    def draw_rounded_rect(self, rx, ry, rw, rh, rad, r, g, b, a=255, stroke_width=0, fill_r=None, fill_g=None, fill_b=None, fill_a=None):
        min_x = max(0, int(rx - 2))
        max_x = min(self.w - 1, int(rx + rw + 2))
        min_y = max(0, int(ry - 2))
        max_y = min(self.h - 1, int(ry + rh + 2))

        for y in range(min_y, max_y + 1):
            for x in range(min_x, max_x + 1):
                dx = max(rx + rad - x, 0, x - (rx + rw - rad))
                dy = max(ry + rad - y, 0, y - (ry + rh - rad))
                dist = math.hypot(dx, dy)
                if dist <= rad:
                    if fill_a is not None and fill_a > 0:
                        edge = rad - dist
                        sub_a = fill_a * min(1.0, max(0.0, edge + 0.5))
                        self.set_pixel(x, y, fill_r, fill_g, fill_b, int(sub_a))
                    if stroke_width > 0:
                        r_min = rad - stroke_width
                        if r_min <= dist <= rad:
                            edge = min(dist - r_min, rad - dist)
                            sub_a = a * min(1.0, max(0.0, edge + 0.5))
                            self.set_pixel(x, y, r, g, b, int(sub_a))

# Load reference raw screenshots
w, h, base_img = load_rgba('docs/screenshots/raw/03-timer-modes.png')
w, h, focus_img = load_rgba('docs/screenshots/raw/04-focus-free.png')

TAB_CENTERS = [298, 422, 548, 672, 798]

def build_base_canvas(active_tab_index):
    c = Canvas(w, h, base_img)
    
    # 1. Seamless radial inpainting in dial area (cx=540, cy=960)
    cx, cy = 540, 960
    erase_radius = 420.0
    for y in range(int(cy - erase_radius), int(cy + erase_radius + 1)):
        dy = y - cy
        for x in range(int(cx - erase_radius), int(cx + erase_radius + 1)):
            dx = x - cx
            dist = math.hypot(dx, dy)
            if dist <= erase_radius:
                t = (y - 340) / (1580 - 340)
                bg_r = int(14 * (1 - t) + 8 * t)
                bg_g = int(32 * (1 - t) + 16 * t)
                bg_b = int(22 * (1 - t) + 12 * t)
                blend = min(1.0, max(0.0, (erase_radius - dist) / 60.0))
                if blend > 0:
                    c.set_pixel(x, y, bg_r, bg_g, bg_b, int(255 * blend))

    # 2. Reset mode selector bar
    for y in range(238, 322):
        for x in range(240, 356):
            idx = (y * w + x) * 4
            c.buf[idx:idx+4] = focus_img[idx:idx+4]
    
    # Highlight active tab
    target_cx = TAB_CENTERS[active_tab_index]
    pill_w = 104
    pill_h = 76
    pill_rx = target_cx - pill_w // 2
    pill_ry = 280 - pill_h // 2
    c.draw_rounded_rect(pill_rx, pill_ry, pill_w, pill_h, 38, 143, 172, 149, 110, stroke_width=2, fill_r=42, fill_g=68, fill_b=54, fill_a=180)
    
    # Brighten active icon pixels
    for y in range(280 - 24, 280 + 25):
        for x in range(target_cx - 24, target_cx + 25):
            r, g, b, a = c.get_pixel(x, y)
            if g > 110 or r > 100 or b > 100:
                c.set_pixel(x, y, min(255, r + 70), min(255, g + 85), min(255, b + 70), 255)
                
    return c

# 1. MANDALA FLOW (Mode 2)
def generate_mandala_flow():
    c = build_base_canvas(1)
    cx, cy = 540, 930
    
    c.draw_radial_glow(cx, cy, 460, 82, 137, 109, peak_a=85)
    c.draw_radial_glow(cx, cy, 280, 143, 172, 149, peak_a=110)
    
    c.draw_circle_stroke(cx, cy, 330, 255, 255, 255, a=22, stroke_width=4.0)
    c.draw_arc(cx, cy, 330, -math.pi/2, math.pi * 1.5, 143, 172, 149, a=230, stroke_width=6.0)
    
    c.draw_circle_stroke(cx, cy, 290, 82, 137, 109, a=70, stroke_width=1.5)
    c.draw_circle_stroke(cx, cy, 255, 196, 215, 199, a=110, stroke_width=2.0)
    c.draw_circle_stroke(cx, cy, 180, 143, 172, 149, a=90, stroke_width=1.8)
    c.draw_circle_stroke(cx, cy, 110, 82, 137, 109, a=80, stroke_width=1.5)
    
    R = 210.0
    for i in range(8):
        ang = i * math.pi / 4.0
        pcx = cx + R * 0.5 * math.cos(ang)
        pcy = cy + R * 0.5 * math.sin(ang)
        c.draw_circle_stroke(pcx, pcy, R * 0.5, 196, 215, 199, a=150, stroke_width=2.5)
        
        pcx2 = cx + R * 0.85 * math.cos(ang + math.pi/8.0)
        pcy2 = cy + R * 0.85 * math.sin(ang + math.pi/8.0)
        c.draw_circle_stroke(pcx2, pcy2, R * 0.42, 143, 172, 149, a=95, stroke_width=1.8)
        
        vx = cx + R * math.cos(ang)
        vy = cy + R * math.sin(ang)
        c.draw_circle_fill(vx, vy, 7, 240, 253, 248, a=240)
        c.draw_circle_fill(vx, vy, 16, 143, 172, 149, a=90)
        c.draw_circle_fill(vx, vy, 28, 82, 137, 109, a=45)
        
        c.draw_line(cx, cy, cx + 290 * math.cos(ang), cy + 290 * math.sin(ang), 143, 172, 149, a=45, stroke_width=1.2)
        c.draw_line(cx, cy, cx + 290 * math.cos(ang + math.pi/8.0), cy + 290 * math.sin(ang + math.pi/8.0), 82, 137, 109, a=30, stroke_width=1.0)
    
    c.draw_circle_fill(cx, cy, 76, 22, 42, 32, a=235)
    c.draw_circle_stroke(cx, cy, 76, 143, 172, 149, a=200, stroke_width=3.0)
    c.draw_radial_glow(cx, cy, 110, 82, 137, 109, peak_a=110)
    
    c.draw_rounded_rect(cx - 24, cy - 28, 14, 56, 4, 143, 172, 149, 255, fill_r=143, fill_g=172, fill_b=149, fill_a=255)
    c.draw_rounded_rect(cx + 10, cy - 28, 14, 56, 4, 143, 172, 149, 255, fill_r=143, fill_g=172, fill_b=149, fill_a=255)
    
    save_rgba_png('docs/screenshots/raw/03-mandala-flow.png', w, h, c.buf)
    print("Saved docs/screenshots/raw/03-mandala-flow.png")

# 2. INSPIRACIONAL (Mode 3)
def generate_inspirational():
    c = build_base_canvas(2)
    cx, cy = 540, 930
    
    c.draw_radial_glow(cx, cy, 440, 143, 172, 149, peak_a=55)
    
    c.draw_circle_stroke(cx, cy, 330, 255, 255, 255, a=22, stroke_width=4.0)
    c.draw_arc(cx, cy, 330, -math.pi/2, math.pi * 1.35, 143, 172, 149, a=220, stroke_width=6.0)
    
    c.draw_circle_fill(cx, cy, 290, 20, 36, 28, a=220)
    c.draw_circle_stroke(cx, cy, 290, 186, 201, 181, a=90, stroke_width=2.5)
    c.draw_circle_stroke(cx, cy, 288, 255, 255, 255, a=35, stroke_width=1.0)
    c.draw_radial_glow(cx, cy, 200, 143, 172, 149, peak_a=60)
    
    sy = cy - 170
    c.draw_line(cx, sy - 24, cx, sy + 24, 196, 215, 199, a=240, stroke_width=2.5)
    c.draw_line(cx - 24, sy, cx + 24, sy, 196, 215, 199, a=240, stroke_width=2.5)
    c.draw_circle_fill(cx, sy, 5, 255, 255, 255, a=255)
    c.draw_circle_fill(cx, sy, 14, 143, 172, 149, a=100)
    
    c.draw_line(cx - 60, cy - 40, cx + 60, cy - 40, 143, 172, 149, a=120, stroke_width=1.5)
    
    def draw_digit(dx, dy, digit, scale=1.0):
        seg_w = int(28 * scale)
        seg_h = int(52 * scale)
        th = max(3, int(6.5 * scale))
        patterns = {
            '0': (1,1,1,1,1,1,0),
            '1': (0,1,1,0,0,0,0),
            '2': (1,1,0,1,1,0,1),
            '3': (1,1,1,1,0,0,1),
            '4': (0,1,1,0,0,1,1),
            '5': (1,0,1,1,0,1,1),
            '6': (1,0,1,1,1,1,1),
            '7': (1,1,1,0,0,0,0),
            '8': (1,1,1,1,1,1,1),
            '9': (1,1,1,1,0,1,1),
            ':': 'colon'
        }
        if digit == ':':
            c.draw_circle_fill(dx, dy + seg_h // 2 - 14, 6, 245, 253, 248, a=245)
            c.draw_circle_fill(dx, dy + seg_h // 2 + 14, 6, 245, 253, 248, a=245)
            return
        p = patterns[str(digit)]
        col = (250, 253, 248)
        if p[0]: c.draw_line(dx - seg_w//2, dy, dx + seg_w//2, dy, col[0], col[1], col[2], a=250, stroke_width=th)
        if p[1]: c.draw_line(dx + seg_w//2, dy, dx + seg_w//2, dy + seg_h//2, col[0], col[1], col[2], a=250, stroke_width=th)
        if p[2]: c.draw_line(dx + seg_w//2, dy + seg_h//2, dx + seg_w//2, dy + seg_h, col[0], col[1], col[2], a=250, stroke_width=th)
        if p[3]: c.draw_line(dx - seg_w//2, dy + seg_h, dx + seg_w//2, dy + seg_h, col[0], col[1], col[2], a=250, stroke_width=th)
        if p[4]: c.draw_line(dx - seg_w//2, dy + seg_h//2, dx - seg_w//2, dy + seg_h, col[0], col[1], col[2], a=250, stroke_width=th)
        if p[5]: c.draw_line(dx - seg_w//2, dy, dx - seg_w//2, dy + seg_h//2, col[0], col[1], col[2], a=250, stroke_width=th)
        if p[6]: c.draw_line(dx - seg_w//2, dy + seg_h//2, dx + seg_w//2, dy + seg_h//2, col[0], col[1], col[2], a=250, stroke_width=th)

    ty = cy + 5
    draw_digit(cx - 130, ty, 2, 1.5)
    draw_digit(cx - 65, ty, 4, 1.5)
    draw_digit(cx, ty, ':', 1.5)
    draw_digit(cx + 65, ty, 3, 1.5)
    draw_digit(cx + 130, ty, 8, 1.5)
    
    c.draw_circle_fill(cx - 50, cy + 140, 4, 143, 172, 149, a=200)
    c.draw_circle_fill(cx + 50, cy + 140, 4, 143, 172, 149, a=200)
    c.draw_line(cx - 40, cy + 140, cx + 40, cy + 140, 143, 172, 149, a=180, stroke_width=2.0)
    
    save_rgba_png('docs/screenshots/raw/03-inspirational.png', w, h, c.buf)
    print("Saved docs/screenshots/raw/03-inspirational.png")

# 3. ORBE LÍQUIDO (Mode 5)
def generate_liquid_orb():
    c = build_base_canvas(4) # Tab index 4 = Liquid Orb
    cx, cy = 540, 930
    
    c.draw_circle_fill(cx - 110, 410, 7, 143, 172, 149, a=255)
    c.draw_radial_glow(cx - 110, 410, 22, 143, 172, 149, peak_a=180)
    
    c.draw_radial_glow(cx, cy, 480, 70, 140, 105, peak_a=90)
    c.draw_radial_glow(cx, cy, 320, 120, 190, 150, peak_a=110)
    
    orb_w, orb_h, orb_raw = load_rgba('docs/screenshots/raw/orb_temp2.png')
    
    target_radius = 265
    
    for y in range(int(cy - target_radius), int(cy + target_radius + 1)):
        dy = (y - cy) / float(target_radius)
        src_y = int((dy * 0.5 + 0.5) * orb_h)
        if not (0 <= src_y < orb_h): continue
        
        for x in range(int(cx - target_radius), int(cx + target_radius + 1)):
            dx = (x - cx) / float(target_radius)
            dist2 = dx*dx + dy*dy
            if dist2 <= 1.0:
                dist = math.sqrt(dist2)
                src_x = int((dx * 0.5 + 0.5) * orb_w)
                if not (0 <= src_x < orb_w): continue
                
                s_idx = (src_y * orb_w + src_x) * 4
                sr, sg, sb, sa = orb_raw[s_idx], orb_raw[s_idx+1], orb_raw[s_idx+2], orb_raw[s_idx+3]
                
                # Transform blue glass towards deep emerald / sage green palette
                tint_r = int(sr * 0.35 + sg * 0.25)
                tint_g = int(sg * 0.88 + sb * 0.45)
                tint_b = int(sb * 0.42 + sg * 0.35)
                
                edge_fade = min(1.0, (1.0 - dist) / 0.04)
                final_a = int(sa * edge_fade)
                
                c.set_pixel(x, y, tint_r, tint_g, tint_b, final_a)

    c.draw_circle_stroke(cx, cy, target_radius, 196, 215, 199, a=150, stroke_width=2.5)
    c.draw_circle_stroke(cx, cy, target_radius - 4, 255, 255, 255, a=45, stroke_width=1.5)
    
    c.draw_circle_fill(cx, cy, 64, 20, 38, 28, a=230)
    c.draw_circle_stroke(cx, cy, 64, 143, 172, 149, a=190, stroke_width=2.5)
    c.draw_radial_glow(cx, cy, 95, 82, 137, 109, peak_a=95)
    
    c.draw_rounded_rect(cx - 20, cy - 24, 12, 48, 3, 143, 172, 149, 255, fill_r=143, fill_g=172, fill_b=149, fill_a=255)
    c.draw_rounded_rect(cx + 8, cy - 24, 12, 48, 3, 143, 172, 149, 255, fill_r=143, fill_g=172, fill_b=149, fill_a=255)
    
    save_rgba_png('docs/screenshots/raw/05-liquid-orb.png', w, h, c.buf)
    print("Saved docs/screenshots/raw/05-liquid-orb.png")

if __name__ == '__main__':
    generate_mandala_flow()
    generate_inspirational()
    generate_liquid_orb()
