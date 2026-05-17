from __future__ import annotations

import math
from pathlib import Path
from typing import Iterable, Sequence

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "AppStoreAssets" / "Screenshots"


COLORS = {
    "bg": (246, 249, 250),
    "ink": (27, 31, 36),
    "muted": (92, 103, 112),
    "subtle": (227, 235, 238),
    "card": (255, 255, 255),
    "teal": (10, 143, 162),
    "teal_dark": (24, 104, 93),
    "blue": (31, 102, 198),
    "green": (34, 139, 90),
    "amber": (181, 126, 29),
    "orange": (205, 92, 42),
    "red": (176, 25, 45),
    "shadow": (207, 217, 221),
}


def font(size: int, weight: str = "regular") -> ImageFont.FreeTypeFont:
    candidates = {
        "regular": [
            "C:/Windows/Fonts/segoeui.ttf",
            "C:/Windows/Fonts/arial.ttf",
        ],
        "semibold": [
            "C:/Windows/Fonts/seguisb.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
        ],
        "bold": [
            "C:/Windows/Fonts/segoeuib.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
        ],
    }
    for path in candidates.get(weight, candidates["regular"]):
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font_obj: ImageFont.ImageFont, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        test = word if not current else f"{current} {word}"
        if draw.textbbox((0, 0), test, font=font_obj)[2] <= max_width:
            current = test
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def draw_text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    font_obj: ImageFont.ImageFont,
    fill: tuple[int, int, int] = COLORS["ink"],
    max_width: int | None = None,
    line_gap: int = 8,
) -> int:
    x, y = xy
    lines = text.split("\n")
    final_lines: list[str] = []
    for line in lines:
        if max_width:
            final_lines.extend(wrap_text(draw, line, font_obj, max_width))
        else:
            final_lines.append(line)

    for line in final_lines:
        draw.text((x, y), line, font=font_obj, fill=fill)
        bbox = draw.textbbox((x, y), line, font=font_obj)
        y = bbox[3] + line_gap
    return y


def rounded(draw: ImageDraw.ImageDraw, rect: tuple[int, int, int, int], radius: int, fill, outline=None, width: int = 1):
    draw.rounded_rectangle(rect, radius=radius, fill=fill, outline=outline, width=width)


def shadow_card(draw: ImageDraw.ImageDraw, rect: tuple[int, int, int, int], radius: int, fill=COLORS["card"]):
    x1, y1, x2, y2 = rect
    rounded(draw, (x1 + 6, y1 + 8, x2 + 6, y2 + 8), radius, COLORS["shadow"])
    rounded(draw, rect, radius, fill)


def badge(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, color, scale: float = 1.0):
    x, y = xy
    f = font(int(22 * scale), "bold")
    pad_x = int(18 * scale)
    pad_y = int(8 * scale)
    bbox = draw.textbbox((0, 0), text, font=f)
    w = bbox[2] - bbox[0] + pad_x * 2
    h = bbox[3] - bbox[1] + pad_y * 2
    rounded(draw, (x, y, x + w, y + h), h // 2, color)
    draw.text((x + pad_x, y + pad_y - 2), text, font=f, fill=(255, 255, 255))
    return x + w, y + h


def top_bar(draw: ImageDraw.ImageDraw, width: int, y: int, margin: int, scale: float, active: str):
    title_f = font(int(32 * scale), "bold")
    tab_f = font(int(20 * scale), "semibold")
    draw.text((margin, y), "PropertyScan IQ", font=title_f, fill=COLORS["ink"])
    tabs = ["Dashboard", "Reports", "Settings"]
    x = width - margin - int(520 * scale)
    for tab in tabs:
        color = COLORS["teal"] if tab == active else COLORS["muted"]
        draw.text((x, y + int(10 * scale)), tab, font=tab_f, fill=color)
        if tab == active:
            bbox = draw.textbbox((x, y + int(10 * scale)), tab, font=tab_f)
            draw.rounded_rectangle((bbox[0], bbox[3] + 8, bbox[2], bbox[3] + 12), radius=2, fill=COLORS["teal"])
        x += int(160 * scale)


def hero(draw: ImageDraw.ImageDraw, margin: int, y: int, title: str, subtitle: str, scale: float, width: int) -> int:
    y = draw_text(draw, (margin, y), title, font(int(48 * scale), "bold"), max_width=width - margin * 2, line_gap=int(8 * scale))
    y = draw_text(draw, (margin, y + int(8 * scale)), subtitle, font(int(24 * scale)), COLORS["muted"], max_width=width - margin * 2, line_gap=int(10 * scale))
    return y + int(32 * scale)


def stat_card(draw, rect, label, value, color, scale):
    shadow_card(draw, rect, int(18 * scale))
    x1, y1, x2, _ = rect
    draw.ellipse((x1 + int(28 * scale), y1 + int(26 * scale), x1 + int(68 * scale), y1 + int(66 * scale)), fill=color)
    draw_text(draw, (x1 + int(28 * scale), y1 + int(82 * scale)), value, font(int(44 * scale), "bold"), max_width=x2 - x1 - int(56 * scale))
    draw_text(draw, (x1 + int(28 * scale), y1 + int(138 * scale)), label, font(int(22 * scale), "semibold"), COLORS["muted"], max_width=x2 - x1 - int(56 * scale))


def property_card(draw, rect, name, address, meta, scale):
    shadow_card(draw, rect, int(18 * scale))
    x1, y1, x2, _ = rect
    draw.rounded_rectangle((x1 + int(26 * scale), y1 + int(28 * scale), x1 + int(78 * scale), y1 + int(80 * scale)), radius=int(12 * scale), fill=(224, 247, 250))
    draw_text(draw, (x1 + int(96 * scale), y1 + int(25 * scale)), name, font(int(25 * scale), "bold"), max_width=x2 - x1 - int(140 * scale))
    draw_text(draw, (x1 + int(96 * scale), y1 + int(60 * scale)), address, font(int(20 * scale)), COLORS["muted"], max_width=x2 - x1 - int(140 * scale))
    draw_text(draw, (x1 + int(26 * scale), y1 + int(112 * scale)), meta, font(int(18 * scale), "semibold"), COLORS["teal"], max_width=x2 - x1 - int(52 * scale))


def issue_card(draw, rect, title, body, severity, category, color, scale):
    shadow_card(draw, rect, int(18 * scale))
    x1, y1, x2, _ = rect
    draw_text(draw, (x1 + int(26 * scale), y1 + int(22 * scale)), title, font(int(25 * scale), "bold"), max_width=x2 - x1 - int(210 * scale))
    badge(draw, (x2 - int(170 * scale), y1 + int(22 * scale)), severity, color, scale)
    draw_text(draw, (x1 + int(26 * scale), y1 + int(62 * scale)), category, font(int(18 * scale), "semibold"), COLORS["teal"], max_width=x2 - x1 - int(52 * scale))
    draw_text(draw, (x1 + int(26 * scale), y1 + int(100 * scale)), body, font(int(20 * scale)), COLORS["muted"], max_width=x2 - x1 - int(52 * scale), line_gap=int(7 * scale))


def phone_canvas() -> tuple[Image.Image, ImageDraw.ImageDraw, int, int, int, float]:
    size = (1284, 2778)
    image = Image.new("RGB", size, COLORS["bg"])
    draw = ImageDraw.Draw(image)
    return image, draw, size[0], size[1], 72, 1.0


def ipad_canvas() -> tuple[Image.Image, ImageDraw.ImageDraw, int, int, int, float]:
    size = (2048, 2732)
    image = Image.new("RGB", size, COLORS["bg"])
    draw = ImageDraw.Draw(image)
    return image, draw, size[0], size[1], 120, 1.12


def draw_dashboard(draw, width, height, margin, scale, title_suffix=""):
    top_bar(draw, width, int(78 * scale), margin, scale, "Dashboard")
    y = hero(
        draw,
        margin,
        int(190 * scale),
        "Inspection command center",
        "Create properties, scan rooms, approve findings, and export client-ready reports.",
        scale,
        width,
    )
    button_h = int(86 * scale)
    rounded(draw, (margin, y, width - margin, y + button_h), int(18 * scale), COLORS["teal"])
    draw_text(draw, (margin + int(32 * scale), y + int(24 * scale)), "New Inspection", font(int(28 * scale), "bold"), (255, 255, 255))
    y += button_h + int(34 * scale)

    gap = int(24 * scale)
    cols = 2
    card_w = (width - margin * 2 - gap) // cols
    card_h = int(190 * scale)
    stats = [
        ("Inspections", "18", COLORS["teal"]),
        ("Open issues", "42", COLORS["amber"]),
        ("Urgent", "3", COLORS["red"]),
        ("Reports", "11", COLORS["green"]),
    ]
    for i, (label, value, color) in enumerate(stats):
        col = i % 2
        row = i // 2
        x = margin + col * (card_w + gap)
        yy = y + row * (card_h + gap)
        stat_card(draw, (x, yy, x + card_w, yy + card_h), label, value, color, scale)
    y += 2 * card_h + gap + int(42 * scale)

    draw_text(draw, (margin, y), "Recent Properties", font(int(30 * scale), "bold"))
    y += int(54 * scale)
    property_card(draw, (margin, y, width - margin, y + int(172 * scale)), "Riverside Flat", "24 Riverside Walk, Bristol", "Flat   •   4 inspections   •   2 reports", scale)
    y += int(196 * scale)
    property_card(draw, (margin, y, width - margin, y + int(172 * scale)), "Maple House", "18 Maple Road, Bath", "House   •   Maintenance check today", scale)


def draw_builder(draw, width, height, margin, scale):
    top_bar(draw, width, int(78 * scale), margin, scale, "Dashboard")
    y = hero(draw, margin, int(190 * scale), "Build inspections fast", "Pick a property, choose the inspection type, then add every room or area to scan.", scale, width)
    shadow_card(draw, (margin, y, width - margin, y + int(238 * scale)), int(18 * scale))
    draw_text(draw, (margin + int(30 * scale), y + int(28 * scale)), "Inspection type", font(int(24 * scale), "bold"))
    types = ["Move-in", "Move-out", "Maintenance", "Contractor"]
    x = margin + int(30 * scale)
    yy = y + int(88 * scale)
    for i, t in enumerate(types):
        fill = COLORS["teal"] if i == 2 else COLORS["subtle"]
        txt = (255, 255, 255) if i == 2 else COLORS["ink"]
        w = int((width - margin * 2 - int(90 * scale)) / 2)
        xx = x + (i % 2) * (w + int(30 * scale))
        yyy = yy + (i // 2) * int(62 * scale)
        rounded(draw, (xx, yyy, xx + w, yyy + int(48 * scale)), int(24 * scale), fill)
        draw_text(draw, (xx + int(20 * scale), yyy + int(8 * scale)), t, font(int(19 * scale), "semibold"), txt)
    y += int(278 * scale)

    draw_text(draw, (margin, y), "Rooms and areas", font(int(30 * scale), "bold"))
    y += int(56 * scale)
    rooms = ["Kitchen", "Bathroom", "Bedroom", "Living room", "Exterior", "Roofline", "Garden", "Utility", "Hallway"]
    card_w = (width - margin * 2 - int(24 * scale)) // 2
    card_h = int(78 * scale)
    for i, room in enumerate(rooms):
        x = margin + (i % 2) * (card_w + int(24 * scale))
        yy = y + (i // 2) * (card_h + int(18 * scale))
        selected = i in [0, 1, 2, 3, 4]
        rounded(draw, (x, yy, x + card_w, yy + card_h), int(16 * scale), (226, 247, 249) if selected else COLORS["card"], outline=(190, 222, 226))
        draw_text(draw, (x + int(24 * scale), yy + int(23 * scale)), room, font(int(22 * scale), "semibold"), COLORS["ink"])
        if selected:
            draw.ellipse((x + card_w - int(48 * scale), yy + int(22 * scale), x + card_w - int(22 * scale), yy + int(48 * scale)), fill=COLORS["teal"])


def draw_room_scan(draw, width, height, margin, scale):
    top_bar(draw, width, int(78 * scale), margin, scale, "Dashboard")
    y = hero(draw, margin, int(190 * scale), "Scan visible issues", "Add photos and notes for each room, then review cautious AI suggestions before approval.", scale, width)
    photo_h = int(330 * scale)
    shadow_card(draw, (margin, y, width - margin, y + photo_h), int(18 * scale))
    draw_text(draw, (margin + int(30 * scale), y + int(28 * scale)), "Bathroom photo evidence", font(int(26 * scale), "bold"))
    tile_y = y + int(88 * scale)
    tile_w = (width - margin * 2 - int(90 * scale)) // 3
    for i, color in enumerate([(218, 229, 229), (196, 216, 213), (226, 219, 208)]):
        x = margin + int(30 * scale) + i * (tile_w + int(15 * scale))
        rounded(draw, (x, tile_y, x + tile_w, tile_y + int(190 * scale)), int(14 * scale), color)
        draw.rectangle((x, tile_y + int(115 * scale), x + tile_w, tile_y + int(190 * scale)), fill=tuple(max(0, c - 24) for c in color))
    y += photo_h + int(34 * scale)
    rounded(draw, (margin, y, width - margin, y + int(86 * scale)), int(18 * scale), COLORS["teal"])
    draw_text(draw, (margin + int(32 * scale), y + int(24 * scale)), "AI scan room photos", font(int(28 * scale), "bold"), (255, 255, 255))
    y += int(126 * scale)
    draw_text(draw, (margin, y), "Detected issue cards", font(int(30 * scale), "bold"))
    y += int(54 * scale)
    issue_card(draw, (margin, y, width - margin, y + int(230 * scale)), "Possible moisture staining", "Visible marks may indicate damp or mould staining. Verify before relying on the report.", "High", "Damp/mould", COLORS["orange"], scale)
    y += int(258 * scale)
    issue_card(draw, (margin, y, width - margin, y + int(230 * scale)), "Ventilation concern", "Possible visible sign of poor airflow around the ceiling edge. Recommend professional review if persistent.", "Medium", "Safety hazard", COLORS["amber"], scale)


def draw_report(draw, width, height, margin, scale):
    top_bar(draw, width, int(78 * scale), margin, scale, "Reports")
    y = hero(draw, margin, int(190 * scale), "Professional PDF reports", "Turn approved findings, room notes, photo evidence, and priority actions into a polished export.", scale, width)
    shadow_card(draw, (margin, y, width - margin, height - int(190 * scale)), int(18 * scale))
    inner = margin + int(34 * scale)
    yy = y + int(34 * scale)
    draw_text(draw, (inner, yy), "Riverside Flat Inspection Report", font(int(34 * scale), "bold"), max_width=width - margin * 2 - int(68 * scale))
    yy += int(76 * scale)
    draw_text(draw, (inner, yy), "Property overview", font(int(25 * scale), "bold"))
    yy += int(44 * scale)
    draw_text(draw, (inner, yy), "24 Riverside Walk, Bristol\nMove-out inspection • 5 rooms • Generated today", font(int(21 * scale)), COLORS["muted"], max_width=width - margin * 2 - int(68 * scale))
    yy += int(118 * scale)
    draw_text(draw, (inner, yy), "Severity breakdown", font(int(25 * scale), "bold"))
    yy += int(54 * scale)
    x = inner
    for label, value, color in [("Low", "4", COLORS["green"]), ("Medium", "6", COLORS["amber"]), ("High", "2", COLORS["orange"]), ("Urgent", "0", COLORS["red"])]:
        rounded(draw, (x, yy, x + int(170 * scale), yy + int(112 * scale)), int(14 * scale), COLORS["bg"])
        badge(draw, (x + int(18 * scale), yy + int(16 * scale)), label, color, scale * 0.78)
        draw_text(draw, (x + int(64 * scale), yy + int(64 * scale)), value, font(int(28 * scale), "bold"))
        x += int(188 * scale)
    yy += int(158 * scale)
    draw_text(draw, (inner, yy), "Recommended next actions", font(int(25 * scale), "bold"))
    yy += int(50 * scale)
    actions = [
        "Review bathroom staining and ventilation.",
        "Record kitchen flooring wear for tenancy evidence.",
        "Schedule contractor follow-up for exterior gutter concern.",
    ]
    for action in actions:
        rounded(draw, (inner, yy, width - margin - int(34 * scale), yy + int(74 * scale)), int(12 * scale), COLORS["bg"])
        draw_text(draw, (inner + int(22 * scale), yy + int(20 * scale)), action, font(int(20 * scale)), COLORS["ink"], max_width=width - margin * 2 - int(112 * scale))
        yy += int(90 * scale)
    rounded(draw, (margin + int(34 * scale), height - int(310 * scale), width - margin - int(34 * scale), height - int(230 * scale)), int(18 * scale), COLORS["teal"])
    draw_text(draw, (margin + int(66 * scale), height - int(288 * scale)), "Export PDF", font(int(26 * scale), "bold"), (255, 255, 255))


def draw_paywall(draw, width, height, margin, scale):
    top_bar(draw, width, int(78 * scale), margin, scale, "Settings")
    y = hero(draw, margin, int(190 * scale), "Upgrade inspection workflows", "Unlock unlimited inspections, PDF exports, custom branding, and business reporting tools.", scale, width)
    plans = [
        ("Free", "2 inspections/mo", ["10 photo scans", "Basic report export", "PropertyScan IQ footer"], COLORS["muted"]),
        ("Pro", "GBP 19.99/mo", ["Unlimited inspections", "More AI scans", "PDF exports", "Custom logo"], COLORS["teal"]),
        ("Business", "GBP 49.99/mo", ["Unlimited reports", "White-label branding", "Contractor action lists", "Team-ready structure"], COLORS["blue"]),
    ]
    card_h = int(360 * scale)
    for name, price, features, color in plans:
        shadow_card(draw, (margin, y, width - margin, y + card_h), int(18 * scale))
        draw_text(draw, (margin + int(30 * scale), y + int(28 * scale)), name, font(int(32 * scale), "bold"))
        draw_text(draw, (width - margin - int(320 * scale), y + int(34 * scale)), price, font(int(24 * scale), "bold"), color)
        yy = y + int(100 * scale)
        for feature in features:
            draw.ellipse((margin + int(34 * scale), yy + int(8 * scale), margin + int(54 * scale), yy + int(28 * scale)), fill=color)
            draw_text(draw, (margin + int(72 * scale), yy), feature, font(int(22 * scale)), COLORS["ink"], max_width=width - margin * 2 - int(120 * scale))
            yy += int(48 * scale)
        y += card_h + int(28 * scale)


def save_screen(name: str, draw_fn, canvas_fn):
    image, draw, width, height, margin, scale = canvas_fn()
    draw_fn(draw, width, height, margin, scale)
    folder = OUT / ("iPhone-6.5-1284x2778" if width == 1284 else "iPad-12.9-2048x2732")
    folder.mkdir(parents=True, exist_ok=True)
    path = folder / name
    image.save(path, "PNG", optimize=True)
    return path


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    screens = [
        ("01-dashboard.png", draw_dashboard),
        ("02-inspection-builder.png", draw_builder),
        ("03-room-scan-ai-findings.png", draw_room_scan),
        ("04-pdf-report-export.png", draw_report),
        ("05-subscriptions-settings.png", draw_paywall),
    ]
    written = []
    for filename, fn in screens:
        written.append(save_screen(filename, fn, phone_canvas))
        written.append(save_screen(filename, fn, ipad_canvas))

    readme = OUT / "README.md"
    readme.write_text(
        "# App Store Screenshots\n\n"
        "Generated upload-ready screenshots for App Store Connect.\n\n"
        "## iPhone\n\n"
        "- Folder: `iPhone-6.5-1284x2778`\n"
        "- Size: 1284 x 2778 PNG\n\n"
        "## iPad\n\n"
        "- Folder: `iPad-12.9-2048x2732`\n"
        "- Size: 2048 x 2732 PNG\n\n"
        "Use the first three screenshots to show dashboard, inspection creation, and AI issue review. "
        "The remaining screenshots show PDF export and subscriptions/settings.\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(written)} screenshots to {OUT}")
    for path in written:
        print(path)


if __name__ == "__main__":
    main()
