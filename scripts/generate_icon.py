#!/usr/bin/env python3
"""
Generates modern macOS Big Sur-style AppIcon for Cleany.
Uses PIL to create a 1024x1024 master icon and exports an .iconset, then compiles with iconutil.
"""

import os
import subprocess
import math
from PIL import Image, ImageDraw, ImageFilter

def create_master_icon(size=1024):
    # Create RGBA canvas
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    # Outer margin for standard macOS squircle (824x824 inside 1024x1024)
    inset = int(size * 0.09765625) # ~100px
    rect_box = [inset, inset, size - inset, size - inset]
    radius = int(size * 0.2246)    # ~230px standard Apple continuous corner radius
    
    # Create mask for rounded squircle
    mask = Image.new("L", (size, size), 0)
    draw_mask = ImageDraw.Draw(mask)
    draw_mask.rounded_rectangle(rect_box, radius=radius, fill=255)
    
    # Create drop shadow for squircle
    shadow_mask = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_shadow = ImageDraw.Draw(shadow_mask)
    shadow_box = [inset, inset + int(size * 0.02), size - inset, size - inset + int(size * 0.02)]
    draw_shadow.rounded_rectangle(shadow_box, radius=radius, fill=(0, 0, 0, 110))
    shadow_blurred = shadow_mask.filter(ImageFilter.GaussianBlur(radius=int(size * 0.035)))
    img.paste(shadow_blurred, (0, 0), shadow_blurred)

    # Base gradient inside squircle: modern deep indigo / electric teal & cyan
    gradient = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    g_draw = ImageDraw.Draw(gradient)
    
    # Render diagonal gradient
    top_color = (24, 28, 48)      # Deep midnight space
    mid_color = (30, 48, 88)      # Rich slate blue
    accent_teal = (14, 165, 233)  # Vibrant cyan
    accent_mint = (52, 211, 153)  # Clean mint green
    
    for y in range(size):
        ratio_y = y / float(size)
        r = int(top_color[0] * (1 - ratio_y) + mid_color[0] * ratio_y)
        g = int(top_color[1] * (1 - ratio_y) + mid_color[1] * ratio_y)
        b = int(top_color[2] * (1 - ratio_y) + mid_color[2] * ratio_y)
        g_draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
        
    # Glow ring in center
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    g_glow = ImageDraw.Draw(glow)
    cx, cy = size // 2, size // 2
    r_max = int(size * 0.36)
    
    for r in range(r_max, 0, -2):
        factor = 1.0 - (r / float(r_max))
        alpha = int(90 * (factor ** 1.8))
        g_glow.ellipse([cx - r, cy - r + 30, cx + r, cy + r + 30], fill=(14, 165, 233, alpha))
        
    # Composite squircle background
    squircle = Image.alpha_composite(gradient, glow)
    
    # Internal icon graphics: Sleek Sparkle / Geometric Star & Cleaning Wand
    fg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)
    
    # Draw central dynamic Sparkle / 4-point Diamond Star (Cleanliness & Privacy)
    star_center_x = cx
    star_center_y = cy - 20
    star_outer_r = int(size * 0.22)
    star_inner_r = int(size * 0.055)
    
    points = []
    for i in range(8):
        angle = i * (math.pi / 4.0)
        r = star_outer_r if (i % 2 == 0) else star_inner_r
        # Make cardinal points prominent
        px = star_center_x + r * math.sin(angle)
        py = star_center_y - r * math.cos(angle)
        points.append((px, py))
        
    fg_draw.polygon(points, fill=(255, 255, 255, 240))
    
    # Draw secondary satellite sparkle
    s2_x, s2_y = cx + int(size * 0.18), cy - int(size * 0.16)
    s2_outer = int(size * 0.08)
    s2_inner = int(size * 0.02)
    p2 = []
    for i in range(8):
        angle = i * (math.pi / 4.0)
        r = s2_outer if (i % 2 == 0) else s2_inner
        px = s2_x + r * math.sin(angle)
        py = s2_y - r * math.cos(angle)
        p2.append((px, py))
    fg_draw.polygon(p2, fill=(52, 211, 153, 230))
    
    # Draw tertiary satellite sparkle
    s3_x, s3_y = cx - int(size * 0.19), cy + int(size * 0.14)
    s3_outer = int(size * 0.06)
    s3_inner = int(size * 0.015)
    p3 = []
    for i in range(8):
        angle = i * (math.pi / 4.0)
        r = s3_outer if (i % 2 == 0) else s3_inner
        px = s3_x + r * math.sin(angle)
        py = s3_y - r * math.cos(angle)
        p3.append((px, py))
    fg_draw.polygon(p3, fill=(14, 165, 233, 220))
    
    # Subtle shield arc at the bottom (indicating local privacy & protection)
    arc_box = [cx - int(size * 0.24), cy - int(size * 0.05), cx + int(size * 0.24), cy + int(size * 0.32)]
    fg_draw.arc(arc_box, start=30, end=150, fill=(255, 255, 255, 120), width=int(size * 0.012))
    
    # Merge fg with squircle
    squircle = Image.alpha_composite(squircle, fg)
    
    # Subtle glass highlight at the top border of squircle
    highlight = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    h_draw = ImageDraw.Draw(highlight)
    h_draw.rounded_rectangle(rect_box, radius=radius, outline=(255, 255, 255, 45), width=int(size * 0.005))
    squircle = Image.alpha_composite(squircle, highlight)

    # Paste squircle using the mask
    img.paste(squircle, (0, 0), mask)
    
    return img

def main():
    os.makedirs("Resources", exist_ok=True)
    iconset_dir = "Resources/Cleany.iconset"
    os.makedirs(iconset_dir, exist_ok=True)
    
    master = create_master_icon(1024)
    master.save("Resources/icon_1024.png", "PNG")
    print("Master icon created: Resources/icon_1024.png")
    
    sizes = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
    ]
    
    for filename, s in sizes:
        resized = master.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(os.path.join(iconset_dir, filename), "PNG")
        
    icns_path = "Resources/AppIcon.icns"
    cmd = ["iconutil", "-c", "icns", iconset_dir, "-o", icns_path]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        print(f"Successfully generated macOS icon: {icns_path}")
    else:
        print(f"iconutil failed: {res.stderr}")

if __name__ == "__main__":
    main()
