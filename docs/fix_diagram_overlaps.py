from __future__ import annotations

import math
import shutil
import zipfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DOCX = ROOT / "docs" / "Shahid_Umer_And_Musharaf_Tours_Travel_Thesis_ExpeditionExact_v3.docx"
OUTPUT_DOCX = ROOT / "docs" / "Shahid_Umer_And_Musharaf_Tours_Travel_Thesis_ExpeditionExact_v4.docx"
OUTPUT_DIR = ROOT / "docs" / "generated_diagrams_simple_exact_clean"

CANVAS_W = 1700
CANVAS_H = 980
BG = "white"
FG = "black"


def load_font(size: int, bold: bool = False):
    candidates = []
    if bold:
        candidates.extend(
            [
                r"C:\Windows\Fonts\timesbd.ttf",
                r"C:\Windows\Fonts\arialbd.ttf",
                r"C:\Windows\Fonts\calibrib.ttf",
            ]
        )
    else:
        candidates.extend(
            [
                r"C:\Windows\Fonts\times.ttf",
                r"C:\Windows\Fonts\arial.ttf",
                r"C:\Windows\Fonts\calibri.ttf",
            ]
        )

    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


TITLE_FONT = load_font(32, bold=True)
BOX_TITLE_FONT = load_font(26, bold=True)
BODY_FONT = load_font(22, bold=False)
SMALL_FONT = load_font(20, bold=False)


def new_canvas(title: str):
    image = Image.new("RGB", (CANVAS_W, CANVAS_H), BG)
    draw = ImageDraw.Draw(image)
    draw.text((CANVAS_W // 2, 36), title, fill=FG, font=TITLE_FONT, anchor="mm")
    draw.line([(60, 70), (CANVAS_W - 60, 70)], fill=FG, width=2)
    return image, draw


def text_width(draw: ImageDraw.ImageDraw, text: str, font) -> int:
    left, _, right, _ = draw.textbbox((0, 0), text, font=font)
    return right - left


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font, max_width: int) -> list[str]:
    words = text.split()
    if not words:
        return [""]

    lines: list[str] = []
    current = words[0]
    for word in words[1:]:
        test = f"{current} {word}"
        if text_width(draw, test, font) <= max_width:
            current = test
        else:
            lines.append(current)
            current = word
    lines.append(current)
    return lines


def draw_multiline_centered(
    draw: ImageDraw.ImageDraw,
    text: str,
    box: tuple[int, int, int, int],
    font,
    line_gap: int = 6,
):
    x1, y1, x2, y2 = box
    lines = wrap_text(draw, text, font, x2 - x1 - 20)
    line_heights = []
    for line in lines:
        _, top, _, bottom = draw.textbbox((0, 0), line, font=font)
        line_heights.append(bottom - top)
    total_h = sum(line_heights) + max(0, len(lines) - 1) * line_gap
    current_y = y1 + ((y2 - y1 - total_h) // 2)
    for line, height in zip(lines, line_heights):
        draw.text(((x1 + x2) // 2, current_y + height // 2), line, fill=FG, font=font, anchor="mm")
        current_y += height + line_gap


def draw_box(
    draw: ImageDraw.ImageDraw,
    rect: tuple[int, int, int, int],
    title: str,
    body: list[str] | None = None,
    radius: int = 18,
):
    x1, y1, x2, y2 = rect
    draw.rounded_rectangle(rect, radius=radius, outline=FG, width=3)
    title_h = 40
    divider_y = y1 + 44
    draw.line([(x1, divider_y), (x2, divider_y)], fill=FG, width=2)
    draw.text(((x1 + x2) // 2, y1 + title_h // 2 + 2), title, fill=FG, font=BOX_TITLE_FONT, anchor="mm")

    if body:
        body_lines: list[str] = []
        for item in body:
            body_lines.extend(wrap_text(draw, item, BODY_FONT, x2 - x1 - 28))
        current_y = divider_y + 18
        for line in body_lines:
            draw.text((x1 + 16, current_y), line, fill=FG, font=BODY_FONT)
            current_y += 28


def draw_simple_box(
    draw: ImageDraw.ImageDraw,
    rect: tuple[int, int, int, int],
    lines: list[str],
    radius: int = 18,
):
    draw.rounded_rectangle(rect, radius=radius, outline=FG, width=3)
    x1, y1, x2, y2 = rect
    body_lines: list[str] = []
    for line in lines:
        body_lines.extend(wrap_text(draw, line, BODY_FONT, x2 - x1 - 26))
    total_h = len(body_lines) * 28
    start_y = y1 + ((y2 - y1 - total_h) // 2)
    for line in body_lines:
        draw.text(((x1 + x2) // 2, start_y + 12), line, fill=FG, font=BODY_FONT, anchor="mm")
        start_y += 28


def draw_database(
    draw: ImageDraw.ImageDraw,
    rect: tuple[int, int, int, int],
    title: str,
    body: list[str] | None = None,
):
    x1, y1, x2, y2 = rect
    ellipse_h = 22
    draw.ellipse((x1, y1, x2, y1 + ellipse_h), outline=FG, width=3)
    draw.line([(x1, y1 + ellipse_h // 2), (x1, y2 - ellipse_h // 2)], fill=FG, width=3)
    draw.line([(x2, y1 + ellipse_h // 2), (x2, y2 - ellipse_h // 2)], fill=FG, width=3)
    draw.arc((x1, y2 - ellipse_h, x2, y2), start=0, end=180, fill=FG, width=3)
    draw.line([(x1, y1 + ellipse_h // 2), (x2, y1 + ellipse_h // 2)], fill=FG, width=3)
    draw.text(((x1 + x2) // 2, y1 + 44), title, fill=FG, font=BOX_TITLE_FONT, anchor="mm")
    if body:
        current_y = y1 + 76
        for line in body:
            for wrapped in wrap_text(draw, line, BODY_FONT, x2 - x1 - 24):
                draw.text(((x1 + x2) // 2, current_y), wrapped, fill=FG, font=BODY_FONT, anchor="mm")
                current_y += 26


def draw_actor(draw: ImageDraw.ImageDraw, center: tuple[int, int], label: str):
    x, y = center
    draw.ellipse((x - 18, y - 70, x + 18, y - 34), outline=FG, width=3)
    draw.line([(x, y - 34), (x, y + 24)], fill=FG, width=3)
    draw.line([(x - 34, y - 8), (x + 34, y - 8)], fill=FG, width=3)
    draw.line([(x, y + 24), (x - 26, y + 62)], fill=FG, width=3)
    draw.line([(x, y + 24), (x + 26, y + 62)], fill=FG, width=3)
    draw.text((x, y + 92), label, fill=FG, font=BODY_FONT, anchor="mm")


def draw_oval_label(draw: ImageDraw.ImageDraw, rect: tuple[int, int, int, int], label: str):
    draw.ellipse(rect, outline=FG, width=3)
    draw_multiline_centered(draw, label, rect, BODY_FONT)


def draw_diamond(draw: ImageDraw.ImageDraw, rect: tuple[int, int, int, int], label: str):
    x1, y1, x2, y2 = rect
    cx = (x1 + x2) // 2
    cy = (y1 + y2) // 2
    points = [(cx, y1), (x2, cy), (cx, y2), (x1, cy)]
    draw.polygon(points, outline=FG, fill=BG, width=3)
    draw_multiline_centered(draw, label, rect, SMALL_FONT)


def arrow(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], width: int = 3, head: int = 14):
    draw.line(points, fill=FG, width=width)
    if len(points) < 2:
        return
    (x1, y1), (x2, y2) = points[-2], points[-1]
    angle = math.atan2(y2 - y1, x2 - x1)
    left = (
        x2 - head * math.cos(angle) + head * 0.55 * math.sin(angle),
        y2 - head * math.sin(angle) - head * 0.55 * math.cos(angle),
    )
    right = (
        x2 - head * math.cos(angle) - head * 0.55 * math.sin(angle),
        y2 - head * math.sin(angle) + head * 0.55 * math.cos(angle),
    )
    draw.polygon([(x2, y2), left, right], fill=FG)


def label_text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str):
    draw.text(xy, text, fill=FG, font=SMALL_FONT)


def box_center(rect):
    x1, y1, x2, y2 = rect
    return (x1 + x2) // 2, (y1 + y2) // 2


def top_center(rect):
    x1, y1, x2, _ = rect
    return (x1 + x2) // 2, y1


def bottom_center(rect):
    x1, _, x2, y2 = rect
    return (x1 + x2) // 2, y2


def left_center(rect):
    x1, y1, _, y2 = rect
    return x1, (y1 + y2) // 2


def right_center(rect):
    _, y1, x2, y2 = rect
    return x2, (y1 + y2) // 2


def top_at(rect, dx: int = 0):
    x, y = top_center(rect)
    return x + dx, y


def bottom_at(rect, dx: int = 0):
    x, y = bottom_center(rect)
    return x + dx, y


def left_at(rect, dy: int = 0):
    x, y = left_center(rect)
    return x, y + dy


def right_at(rect, dy: int = 0):
    x, y = right_center(rect)
    return x, y + dy


def diagram_01(path: Path):
    image, draw = new_canvas("System Architecture Diagram")

    ui1 = (80, 120, 470, 290)
    ui2 = (650, 120, 1080, 290)
    ui3 = (1210, 120, 1620, 290)
    svc1 = (90, 390, 410, 535)
    svc2 = (500, 390, 820, 535)
    svc3 = (910, 390, 1230, 535)
    svc4 = (1310, 390, 1620, 535)
    store1 = (60, 690, 310, 840)
    store2 = (370, 690, 620, 840)
    store3 = (680, 690, 940, 840)
    store4 = (990, 690, 1250, 840)
    store5 = (1300, 690, 1560, 840)

    draw_box(draw, ui1, "Auth Screens", ["SplashScreen", "LoginScreen", "SignupScreen"])
    draw_box(draw, ui2, "Core Travel Screens", ["HomeScreen", "DestinationScreen", "TourBookingScreen", "PaymentScreen"])
    draw_box(draw, ui3, "Utility Screens", ["ProfileScreen", "BookingHistoryScreen", "MapScreen", "MyListingsScreen"])
    draw_box(draw, svc1, "LocalAuthService", ["Hybrid auth flow", "Firebase or local login"])
    draw_box(draw, svc2, "DatabaseService", ["destinations", "hotels", "transport sample data"])
    draw_box(draw, svc3, "BookingService", ["createBooking", "getUserBookings", "updateBookingStatus"])
    draw_box(draw, svc4, "UserListingsService", ["user hotels", "user cars", "owner listings"])
    draw_database(draw, store1, "Firebase Auth", ["email login", "social login"])
    draw_database(draw, store2, "SharedPreferences", ["local_users_v1", "local_current_email_v1"])
    draw_database(draw, store3, "Cloud Firestore", ["users", "destinations", "hotels"])
    draw_database(draw, store4, "Cloud Firestore", ["bookings", "transport"])
    draw_database(draw, store5, "SharedPreferences", ["user_hotels_v1", "user_cars_v1"])

    arrow(draw, [bottom_center(ui1), (bottom_center(ui1)[0], 350), top_center(svc1)])
    arrow(draw, [bottom_at(ui2, -80), (780, 345), (660, 345), top_at(svc2, 0)])
    arrow(draw, [bottom_at(ui2, 80), (950, 345), (1070, 345), top_at(svc3, 0)])
    arrow(draw, [bottom_center(ui3), (bottom_center(ui3)[0], 350), top_center(svc4)])
    arrow(draw, [right_at(svc2, -18), (865, 430), left_at(svc3, -18)])
    arrow(draw, [right_at(svc3, 18), (1275, 500), left_at(svc4, 18)])
    arrow(draw, [bottom_at(svc1, -70), (180, 615), (180, 665), top_center(store1)])
    arrow(draw, [bottom_at(svc1, 70), (320, 615), (495, 615), top_center(store2)])
    arrow(draw, [bottom_center(svc2), (bottom_center(svc2)[0], 665), top_center(store3)])
    arrow(draw, [bottom_center(svc3), (bottom_center(svc3)[0], 665), top_center(store4)])
    arrow(draw, [bottom_center(svc4), (bottom_center(svc4)[0], 650), top_center(store5)])

    image.save(path)


def diagram_02(path: Path):
    image, draw = new_canvas("Use Case Diagram")

    boundary = (320, 120, 1380, 850)
    draw.rounded_rectangle(boundary, radius=26, outline=FG, width=3)
    draw.text((850, 145), "Tours & Travel Mobile Application", fill=FG, font=BOX_TITLE_FONT, anchor="mm")

    draw_actor(draw, (150, 360), "Traveler")
    draw_actor(draw, (1540, 300), "Listing Owner")
    draw_actor(draw, (1540, 620), "Admin")

    cases = {
        "login": (430, 220, 690, 300, "Sign Up / Login"),
        "explore": (760, 220, 1020, 300, "Explore Destinations"),
        "tour": (1090, 220, 1320, 300, "Book Tour Package"),
        "hotel": (430, 380, 690, 460, "Book Hotel"),
        "car": (760, 380, 1020, 460, "Book Car"),
        "payment": (1090, 380, 1320, 460, "Make Payment"),
        "history": (430, 560, 690, 640, "View Booking History"),
        "profile": (760, 560, 1020, 640, "Manage Profile"),
        "listings": (1090, 560, 1320, 640, "Manage My Listings"),
        "add_hotel": (900, 720, 1180, 800, "Add Hotel Listing"),
        "add_car": (1190, 720, 1340, 800, "Add Car Listing"),
        "admin_ops": (470, 720, 780, 800, "Manage Users / Bookings"),
    }

    for _, (x1, y1, x2, y2, label) in cases.items():
        draw_oval_label(draw, (x1, y1, x2, y2), label)

    traveler = (184, 360)
    owner = (1506, 300)
    admin = (1506, 620)
    for key in ["login", "explore", "tour", "hotel", "car", "payment", "history", "profile"]:
        x1, y1, x2, y2, _ = cases[key]
        arrow(draw, [traveler, (x1, (y1 + y2) // 2)])
    for key in ["listings", "add_hotel", "add_car"]:
        x1, y1, x2, y2, _ = cases[key]
        arrow(draw, [owner, (x2, (y1 + y2) // 2)])
    x1, y1, x2, y2, _ = cases["admin_ops"]
    arrow(draw, [admin, (x2, (y1 + y2) // 2)])

    image.save(path)


def diagram_03(path: Path):
    image, draw = new_canvas("Data Flow Diagram Level 0")

    user = (80, 290, 300, 430)
    app = (570, 250, 1130, 470)
    firebase = (1360, 180, 1600, 330)
    local = (1360, 390, 1600, 540)
    maps = (1360, 600, 1600, 750)

    draw_box(draw, user, "Traveler", ["login", "search", "booking requests"])
    draw_box(draw, app, "Tours & Travel Mobile App", ["authentication", "destination browsing", "hotel and car booking", "profile and listings"])
    draw_database(draw, firebase, "Firebase", ["Auth", "Firestore", "Storage"])
    draw_database(draw, local, "Local Storage", ["SharedPreferences", "offline session"])
    draw_database(draw, maps, "External Services", ["Google Maps", "internet content"])

    arrow(draw, [right_center(user), left_center(app)])
    label_text(draw, (350, 335), "user input")
    arrow(draw, [right_center(app), left_center(firebase)])
    label_text(draw, (1165, 235), "cloud data")
    arrow(draw, [right_center(app), left_center(local)])
    label_text(draw, (1165, 445), "saved session")
    arrow(draw, [right_center(app), left_center(maps)])
    label_text(draw, (1165, 655), "map access")

    arrow(draw, [left_center(app), (300, left_center(app)[1])])
    label_text(draw, (355, 390), "screens and results")

    image.save(path)


def diagram_04(path: Path):
    image, draw = new_canvas("Data Flow Diagram Level 1")

    ext_user = (60, 330, 250, 460)
    p1 = (320, 140, 620, 290)
    p2 = (700, 140, 1000, 290)
    p3 = (1080, 140, 1380, 290)
    p4 = (450, 430, 770, 580)
    p5 = (930, 430, 1250, 580)
    d1 = (250, 700, 500, 850)
    d2 = (560, 700, 830, 850)
    d3 = (900, 700, 1170, 850)
    d4 = (1230, 700, 1550, 850)

    draw_box(draw, ext_user, "Traveler", ["searches", "books", "updates profile"])
    draw_box(draw, p1, "Authentication Module", ["SplashScreen", "LoginScreen", "SignupScreen"])
    draw_box(draw, p2, "Travel Browsing Module", ["HomeScreen", "DestinationScreen", "Hotel and car search"])
    draw_box(draw, p3, "Booking Module", ["TourBookingScreen", "TransportSelectionScreen", "PaymentScreen"])
    draw_box(draw, p4, "Profile and History Module", ["ProfileScreen", "BookingHistoryScreen"])
    draw_box(draw, p5, "Listings Module", ["MyListingsScreen", "AddHotelScreen", "AddCarScreen"])
    draw_database(draw, d1, "Users Store", ["users collection", "local_users_v1"])
    draw_database(draw, d2, "Travel Store", ["destinations", "hotels", "transport"])
    draw_database(draw, d3, "Bookings Store", ["bookings"])
    draw_database(draw, d4, "Local Listings Store", ["user_hotels_v1", "user_cars_v1"])

    arrow(draw, [right_at(ext_user, -30), (285, 365), (285, 215), left_center(p1)])
    arrow(draw, [right_at(ext_user, -5), (305, 390), (305, 215), left_center(p2)])
    arrow(draw, [right_at(ext_user, 20), (325, 415), left_center(p4)])
    arrow(draw, [right_at(ext_user, 45), (345, 440), (345, 505), left_center(p5)])
    arrow(draw, [bottom_center(p1), (bottom_center(p1)[0], 660), top_center(d1)])
    arrow(draw, [bottom_center(p2), (bottom_center(p2)[0], 660), top_center(d2)])
    arrow(draw, [bottom_center(p3), (bottom_center(p3)[0], 660), top_center(d3)])
    arrow(draw, [bottom_center(p5), (bottom_center(p5)[0], 660), top_center(d4)])
    arrow(draw, [right_center(p2), left_center(p3)])
    arrow(draw, [bottom_center(p4), (bottom_center(p4)[0], 620), (1090, 620), bottom_center(p5)])

    image.save(path)


def diagram_05(path: Path):
    image, draw = new_canvas("Activity Diagram - Login")

    start = (835, 110, 865, 140)
    splash = (640, 170, 1060, 250)
    check_onboard = (700, 290, 1000, 380)
    onboarding = (180, 300, 520, 380)
    login = (650, 430, 1050, 510)
    validate = (710, 550, 990, 640)
    firebase_ready = (710, 690, 990, 780)
    firebase_auth = (1100, 675, 1510, 755)
    local_auth = (180, 675, 590, 755)
    success = (710, 820, 990, 910)
    home = (1090, 825, 1510, 905)
    error = (180, 825, 590, 905)

    draw.ellipse(start, outline=FG, width=3)
    draw_simple_box(draw, splash, ["Open SplashScreen"])
    draw_diamond(draw, check_onboard, "Onboarding seen?")
    draw_simple_box(draw, onboarding, ["Show onboarding", "set onboarding_seen"])
    draw_simple_box(draw, login, ["Open LoginScreen", "Enter email and password"])
    draw_diamond(draw, validate, "Fields valid?")
    draw_diamond(draw, firebase_ready, "Firebase ready?")
    draw_simple_box(draw, firebase_auth, ["FirebaseAuth signIn", "load user profile"])
    draw_simple_box(draw, local_auth, ["check local_users_v1", "load local session"])
    draw_diamond(draw, success, "Login success?")
    draw_simple_box(draw, home, ["Open HomeScreen"])
    draw_simple_box(draw, error, ["Show error", "stay on LoginScreen"])

    arrow(draw, [(850, 140), (850, 170)])
    arrow(draw, [bottom_center(splash), top_center(check_onboard)])
    arrow(draw, [left_center(check_onboard), (560, left_center(check_onboard)[1]), right_center(onboarding)])
    label_text(draw, (555, 308), "No")
    arrow(draw, [bottom_center(onboarding), (350, 430), left_center(login)])
    arrow(draw, [bottom_center(check_onboard), top_center(login)])
    label_text(draw, (1010, 318), "Yes")
    arrow(draw, [bottom_center(login), top_center(validate)])
    arrow(draw, [bottom_center(validate), top_center(firebase_ready)])
    label_text(draw, (1000, 566), "Yes")
    arrow(draw, [right_center(firebase_ready), (1060, right_center(firebase_ready)[1]), left_center(firebase_auth)])
    label_text(draw, (1005, 705), "Yes")
    arrow(draw, [left_center(firebase_ready), (620, left_center(firebase_ready)[1]), right_center(local_auth)])
    label_text(draw, (610, 705), "No")
    arrow(draw, [bottom_center(firebase_auth), (1305, 800), right_center(success)])
    arrow(draw, [bottom_center(local_auth), (385, 800), left_center(success)])
    arrow(draw, [right_center(success), (1060, right_center(success)[1]), left_center(home)])
    label_text(draw, (1005, 836), "Yes")
    arrow(draw, [left_center(success), (620, left_center(success)[1]), right_center(error)])
    label_text(draw, (610, 836), "No")

    image.save(path)


def diagram_06(path: Path):
    image, draw = new_canvas("Activity Diagram - Tour Booking")

    start = (835, 95, 865, 125)
    a1 = (610, 150, 1090, 225)
    a2 = (610, 260, 1090, 335)
    a3 = (610, 370, 1090, 445)
    a4 = (610, 480, 1090, 555)
    a5 = (610, 590, 1090, 665)
    a6 = (610, 700, 1090, 775)
    a7 = (610, 810, 1090, 885)

    draw.ellipse(start, outline=FG, width=3)
    draw_simple_box(draw, a1, ["Open HomeScreen and select destination"])
    draw_simple_box(draw, a2, ["Open DestinationScreen and view package details"])
    draw_simple_box(draw, a3, ["Open TourBookingScreen and enter travelers"])
    draw_simple_box(draw, a4, ["Choose hotel in MultiCityHotelScreen or HotelSelectionScreen"])
    draw_simple_box(draw, a5, ["Choose transport in TransportSelectionScreen"])
    draw_simple_box(draw, a6, ["Pay in PaymentScreen and call BookingService"])
    draw_simple_box(draw, a7, ["Show BookingSuccessScreen and save booking history"])

    arrow(draw, [(850, 125), (850, 150)])
    for upper, lower in [(a1, a2), (a2, a3), (a3, a4), (a4, a5), (a5, a6), (a6, a7)]:
        arrow(draw, [bottom_center(upper), top_center(lower)])

    image.save(path)


def diagram_07(path: Path):
    image, draw = new_canvas("Sequence Diagram - Authentication")

    participants = [
        ("User", 160),
        ("LoginScreen", 500),
        ("LocalAuthService", 860),
        ("FirebaseAuth / Local Store", 1260),
    ]

    top_y = 110
    for label, x in participants:
        draw_simple_box(draw, (x - 110, top_y, x + 110, top_y + 60), [label], radius=14)
        draw.line([(x, top_y + 60), (x, 875)], fill=FG, width=2)

    messages = [
        (160, 500, 200, "enter email and password"),
        (500, 860, 280, "signIn(email, password)"),
        (860, 1260, 370, "use Firebase if ready, else local users"),
        (1260, 860, 500, "status + user data"),
        (860, 500, 610, "success or error"),
        (500, 160, 720, "open HomeScreen or show message"),
    ]

    for x1, x2, y, text in messages:
        arrow(draw, [(x1, y), (x2, y)])
        label_text(draw, (min(x1, x2) + 16, y - 24), text)

    image.save(path)


def diagram_08(path: Path):
    image, draw = new_canvas("Sequence Diagram - Payment and Confirmation")

    participants = [
        ("User", 130),
        ("TourBookingScreen", 430),
        ("PaymentScreen", 760),
        ("BookingService", 1080),
        ("Firestore bookings", 1410),
    ]

    top_y = 110
    for label, x in participants:
        draw_simple_box(draw, (x - 120, top_y, x + 120, top_y + 60), [label], radius=14)
        draw.line([(x, top_y + 60), (x, 885)], fill=FG, width=2)

    messages = [
        (130, 430, 210, "confirm package details"),
        (430, 760, 300, "open PaymentScreen"),
        (130, 760, 390, "enter card or wallet data"),
        (760, 1080, 490, "create booking request"),
        (1080, 1410, 580, "save booking document"),
        (1410, 1080, 670, "save success"),
        (1080, 760, 760, "return confirmation"),
        (760, 130, 850, "show BookingSuccessScreen"),
    ]

    for x1, x2, y, text in messages:
        arrow(draw, [(x1, y), (x2, y)])
        label_text(draw, (min(x1, x2) + 14, y - 24), text)

    image.save(path)


def diagram_09(path: Path):
    image, draw = new_canvas("Class Diagram")

    c1 = (50, 120, 350, 300)
    c2 = (430, 120, 730, 300)
    c3 = (810, 120, 1110, 300)
    c4 = (1190, 120, 1490, 300)
    c5 = (430, 470, 770, 670)
    c6 = (840, 470, 1180, 670)
    c7 = (1240, 470, 1600, 670)

    draw_box(draw, c1, "Destination", ["id", "name", "location", "price", "duration"])
    draw_box(draw, c2, "Hotel", ["id", "destinationId", "pricePerNight", "amenities"])
    draw_box(draw, c3, "TourPackage", ["id", "name", "duration", "price"])
    draw_box(draw, c4, "Car", ["id", "name", "type", "pricePerKm", "capacity"])
    draw_box(draw, c5, "Booking", ["id", "userId", "destinationId", "status", "bookingDate"])
    draw_box(draw, c6, "BookingService", ["createBooking()", "getUserBookings()", "updateBookingStatus()"])
    draw_box(draw, c7, "UserListingsService", ["addHotel()", "addCar()", "persist local listings"])

    arrow(draw, [bottom_center(c1), (470, 470)])
    arrow(draw, [bottom_center(c2), (560, 470)])
    arrow(draw, [bottom_center(c3), (650, 470)])
    arrow(draw, [bottom_center(c4), (740, 470)])
    arrow(draw, [right_center(c5), left_center(c6)])
    arrow(draw, [right_center(c6), left_center(c7)])

    image.save(path)


def diagram_10(path: Path):
    image, draw = new_canvas("Firestore and Local Storage Schema Diagram")

    s1 = (80, 150, 420, 300)
    s2 = (80, 470, 420, 660)
    d0 = (560, 130, 1010, 320)
    d1 = (1180, 120, 1550, 250)
    d2 = (1180, 280, 1550, 410)
    d3 = (1180, 440, 1550, 570)
    d4 = (1180, 600, 1550, 730)
    d5 = (1180, 760, 1550, 890)
    local_store = (560, 560, 1010, 810)

    draw_box(draw, s1, "LocalAuthService", ["users collection", "local_users_v1", "local_current_email_v1"])
    draw_box(draw, s2, "Booking and Listings", ["BookingService", "UserListingsService", "sample data and local listings"])
    draw_database(draw, d0, "Cloud Firestore", ["central project database"])
    draw_database(draw, d1, "users", ["uid", "email", "fullName", "provider"])
    draw_database(draw, d2, "destinations", ["name", "location", "price", "highlights"])
    draw_database(draw, d3, "hotels", ["destinationId", "location", "pricePerNight"])
    draw_database(draw, d4, "bookings", ["userId", "status", "bookingDate"])
    draw_database(draw, d5, "transport", ["fromLocation", "toLocation", "price"])
    draw_database(draw, local_store, "SharedPreferences", ["local_users_v1", "local_current_email_v1", "user_hotels_v1", "user_cars_v1"])

    arrow(draw, [right_at(s1, -20), (520, 205), left_at(d0, -35)])
    arrow(draw, [right_at(s2, -10), (500, 565), (500, 275), left_at(d0, 40)])
    arrow(draw, [right_at(s1, 35), (500, 335), (500, 640), left_at(local_store, -20)])
    arrow(draw, [right_center(s2), (500, right_center(s2)[1]), left_at(local_store, 35)])
    arrow(draw, [right_at(d0, -55), left_center(d1)])
    arrow(draw, [right_at(d0, -20), left_center(d2)])
    arrow(draw, [right_at(d0, 15), left_center(d3)])
    arrow(draw, [right_at(d0, 50), left_center(d4)])
    arrow(draw, [right_at(d0, 85), left_center(d5)])

    image.save(path)


def diagram_11(path: Path):
    image, draw = new_canvas("Navigation Structure Diagram")

    n1 = (650, 100, 1050, 170)
    n2 = (250, 240, 560, 320)
    n3 = (1140, 240, 1450, 320)
    n4 = (40, 420, 250, 500)
    n5 = (300, 420, 540, 500)
    n6 = (585, 420, 825, 500)
    n7 = (860, 420, 1100, 500)
    n8 = (1135, 420, 1375, 500)
    n12 = (1410, 420, 1655, 500)
    n9 = (40, 620, 250, 700)
    n13 = (300, 610, 540, 710)
    n10 = (585, 620, 825, 700)
    n11 = (860, 620, 1100, 700)
    n15 = (1410, 610, 1655, 710)
    n14 = (860, 825, 1100, 905)

    draw_simple_box(draw, n1, ["SplashScreen"])
    draw_simple_box(draw, n2, ["LoginScreen", "SignupScreen", "ForgotPasswordScreen"])
    draw_simple_box(draw, n3, ["HomeScreen"])
    draw_simple_box(draw, n4, ["DestinationScreen"])
    draw_simple_box(draw, n5, ["AllPakistanHotelBookingScreen"])
    draw_simple_box(draw, n6, ["CityToCityCarBookingScreen"])
    draw_simple_box(draw, n7, ["BookingHistoryScreen"])
    draw_simple_box(draw, n8, ["ProfileScreen"])
    draw_simple_box(draw, n9, ["TourBookingScreen"])
    draw_simple_box(draw, n10, ["TransportSelectionScreen"])
    draw_simple_box(draw, n11, ["PaymentScreen"])
    draw_simple_box(draw, n12, ["MyListingsScreen"])
    draw_simple_box(draw, n13, ["MultiCityHotelScreen", "HotelSelectionScreen"])
    draw_simple_box(draw, n14, ["BookingSuccessScreen"])
    draw_simple_box(draw, n15, ["AddHotelScreen", "AddCarScreen", "MapScreen"])

    splash_split_y = 205
    arrow(draw, [bottom_center(n1), (bottom_center(n1)[0], splash_split_y)])
    draw.line([(405, splash_split_y), (1295, splash_split_y)], fill=FG, width=3)
    arrow(draw, [(405, splash_split_y), top_center(n2)])
    arrow(draw, [(1295, splash_split_y), top_center(n3)])

    home_split_y = 365
    arrow(draw, [bottom_center(n3), (bottom_center(n3)[0], home_split_y)])
    draw.line([(145, home_split_y), (1530, home_split_y)], fill=FG, width=3)
    for child in [n4, n5, n6, n7, n8, n12]:
        x = box_center(child)[0]
        arrow(draw, [(x, home_split_y), top_center(child)])
    arrow(draw, [bottom_center(n4), top_center(n9)])
    arrow(draw, [bottom_center(n5), top_center(n13)])
    arrow(draw, [right_center(n9), left_center(n10)])
    arrow(draw, [right_center(n13), left_center(n11)])
    arrow(draw, [bottom_center(n6), top_center(n11)])
    arrow(draw, [bottom_center(n11), top_center(n14)])
    arrow(draw, [bottom_center(n12), top_center(n15)])

    image.save(path)


def diagram_12(path: Path):
    image, draw = new_canvas("Deployment Diagram")

    dev = (80, 170, 430, 380)
    device = (620, 150, 1090, 420)
    firebase = (1270, 140, 1600, 390)
    local_store = (670, 560, 1040, 790)
    external = (1240, 560, 1600, 790)

    draw_box(draw, dev, "Developer Machine", ["Android Studio", "Flutter SDK", "Dart codebase"])
    draw_box(draw, device, "Android App Runtime", ["Flutter app on phone or emulator", "HomeScreen, booking screens, profile and maps"])
    draw_database(draw, firebase, "Firebase Platform", ["Firebase Auth", "Cloud Firestore", "Firebase Storage"])
    draw_database(draw, local_store, "Device Local Storage", ["SharedPreferences", "session data", "user listings"])
    draw_database(draw, external, "External Services", ["Google Maps", "internet images", "remote APIs if available"])

    arrow(draw, [right_center(dev), left_center(device)])
    label_text(draw, (465, 255), "build and run")
    arrow(draw, [right_center(device), left_center(firebase)])
    label_text(draw, (1115, 255), "cloud sync")
    arrow(draw, [bottom_center(device), top_center(local_store)])
    label_text(draw, (760, 470), "local save")
    arrow(draw, [bottom_center(firebase), (1435, 470), top_center(external)])
    arrow(draw, [right_center(device), (1160, right_center(device)[1]), (1160, box_center(external)[1]), left_center(external)])
    label_text(draw, (1175, 660), "maps and online content")

    image.save(path)


def replace_doc_media(diagrams: list[Path]):
    shutil.copyfile(SOURCE_DOCX, OUTPUT_DOCX)
    with zipfile.ZipFile(OUTPUT_DOCX, "r") as source_zip:
        file_map = {name: source_zip.read(name) for name in source_zip.namelist()}

    for idx, diagram_path in enumerate(diagrams, start=2):
        media_name = f"word/media/image{idx}.png"
        file_map[media_name] = diagram_path.read_bytes()

    with zipfile.ZipFile(OUTPUT_DOCX, "w") as out_zip:
        for name, data in file_map.items():
            out_zip.writestr(name, data)


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    builders = [
        diagram_01,
        diagram_02,
        diagram_03,
        diagram_04,
        diagram_05,
        diagram_06,
        diagram_07,
        diagram_08,
        diagram_09,
        diagram_10,
        diagram_11,
        diagram_12,
    ]

    generated: list[Path] = []
    for idx, builder in enumerate(builders, start=1):
        output_path = OUTPUT_DIR / f"diagram_{idx:02d}.png"
        builder(output_path)
        generated.append(output_path)

    replace_doc_media(generated)
    print(f"Created: {OUTPUT_DOCX}")


if __name__ == "__main__":
    main()
