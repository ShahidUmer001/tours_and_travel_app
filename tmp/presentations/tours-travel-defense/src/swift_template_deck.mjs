import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const { Presentation, PresentationFile } = await import("@oai/artifact-tool");

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const WORKSPACE = path.resolve(__dirname, "..");
const OUTPUT_DIR = path.join(WORKSPACE, "output");
const SCRATCH_DIR = path.join(WORKSPACE, "scratch");
const PREVIEW_DIR = path.join(SCRATCH_DIR, "template-previews");
const PPTX_PREVIEW_DIR = path.join(SCRATCH_DIR, "template-pptx-previews");
const LAYOUT_DIR = path.join(SCRATCH_DIR, "template-layouts");
const THESIS_ASSETS = path.join(SCRATCH_DIR, "assets");
const TEMPLATE_ASSETS = path.join(SCRATCH_DIR, "swift-template-assets");

const W = 960;
const H = 540;

const COLORS = {
  white: "FFFFFF",
  green: "1F7A3E",
  ink: "1E293B",
  slate: "64748B",
  gray: "AAAAAA",
  lightGray: "D8DEE6",
  paleGray: "F8FAFC",
  dark: "1F2937",
  pass: "16A34A",
  paleGreen: "E9F7EE",
  paleBlue: "EAF1FB",
  paleAmber: "FFF6E2",
};

const FONTS = {
  sans: "Calibri",
  sansBold: "Calibri",
};

function asset(name) {
  return path.join(THESIS_ASSETS, name);
}

function templateAsset(name) {
  return path.join(TEMPLATE_ASSETS, name);
}

function solid(color) {
  return { type: "solid", color };
}

function addShape(slide, opts) {
  return slide.shapes.add({
    geometry: opts.geometry || "rect",
    name: opts.name,
    position: {
      left: opts.x,
      top: opts.y,
      width: opts.w,
      height: opts.h,
      rotation: opts.rotation || 0,
    },
    fill: opts.fill,
    line: opts.line,
    borderRadius: opts.borderRadius,
  });
}

function addText(slide, opts) {
  const shape = addShape(slide, {
    geometry: opts.geometry || "rect",
    name: opts.name,
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    rotation: opts.rotation || 0,
    fill: opts.fill || { type: "none" },
    line: opts.line || { width: 0 },
  });
  shape.text.style = {
    fontSize: opts.fontSize || 14,
    color: opts.color || COLORS.ink,
    typeface: opts.font || FONTS.sans,
    bold: Boolean(opts.bold),
    italic: Boolean(opts.italic),
    alignment: opts.align || "left",
    verticalAlignment: opts.valign || "top",
    wrap: opts.wrap !== false,
    insets: opts.insets || { left: 0, right: 0, top: 0, bottom: 0 },
  };
  shape.text = opts.text;
  return shape;
}

function addImage(slide, opts) {
  const image = slide.images.add({
    path: opts.path,
    alt: opts.alt || "",
    position: { left: opts.x, top: opts.y, width: opts.w, height: opts.h },
    fit: opts.fit || "contain",
  });
  if (opts.geometry) image.geometry = opts.geometry;
  if (opts.name) image.name = opts.name;
  return image;
}

function addLogo(slide, titleSlide = false) {
  if (titleSlide) {
    addImage(slide, {
      path: templateAsset("image1.png"),
      alt: "Abasyn University logo",
      x: 24,
      y: 14.4,
      w: 153.6,
      h: 72,
      fit: "contain",
    });
  } else {
    addImage(slide, {
      path: templateAsset("image1.png"),
      alt: "Abasyn University logo",
      x: 19.2,
      y: 9.6,
      w: 134.4,
      h: 62.4,
      fit: "contain",
    });
  }
}

function addFooter(slide, slideNo) {
  addText(slide, {
    x: 240,
    y: 513.6,
    w: 480,
    h: 19.2,
    text: "AUIC – CS/SE - FYP Presentation",
    fontSize: 9,
    color: COLORS.gray,
    align: "center",
    valign: "middle",
  });
  addText(slide, {
    x: 892.8,
    y: 513.6,
    w: 48,
    h: 19.2,
    text: String(slideNo),
    fontSize: 9,
    color: COLORS.gray,
    align: "right",
    valign: "middle",
  });
}

function addPageTitle(slide, title, slideNo, subtitle) {
  addLogo(slide, false);
  addText(slide, {
    x: 172.8,
    y: 20,
    w: 614.4,
    h: 42,
    text: title,
    fontSize: 32,
    color: COLORS.green,
    bold: true,
    align: "center",
    valign: "middle",
  });
  if (subtitle) {
    addText(slide, {
      x: 28.8,
      y: 72,
      w: 902.4,
      h: 24,
      text: subtitle,
      fontSize: 13,
      color: COLORS.ink,
      bold: true,
      align: "center",
    });
  }
  addFooter(slide, slideNo);
}

function addBulletList(slide, opts) {
  let y = opts.y;
  for (const item of opts.items) {
    addText(slide, {
      x: opts.x,
      y,
      w: 22,
      h: opts.lineHeight || 22,
      text: "•",
      fontSize: opts.bulletSize || 14,
      color: opts.bulletColor || COLORS.ink,
      bold: true,
      align: "center",
    });
    addText(slide, {
      x: opts.x + 28,
      y,
      w: opts.w - 28,
      h: item.h || opts.itemHeight || 54,
      text: item.text || item,
      fontSize: item.fontSize || opts.fontSize || 14,
      color: item.color || opts.color || COLORS.ink,
      bold: Boolean(item.bold),
      italic: Boolean(item.italic),
    });
    y += item.gap || opts.gap || 42;
  }
}

function drawTable(slide, cfg) {
  const rows = cfg.rows.length + 1;
  const totalWidth = cfg.widths.reduce((sum, v) => sum + v, 0);
  let y = cfg.y;

  let x = cfg.x;
  for (let c = 0; c < cfg.headers.length; c += 1) {
    addShape(slide, {
      x,
      y,
      w: cfg.widths[c],
      h: cfg.headerHeight,
      fill: solid(cfg.headerFill || COLORS.dark),
      line: { width: 1, fill: COLORS.white },
    });
    addText(slide, {
      x: x + 8,
      y: y + 6,
      w: cfg.widths[c] - 16,
      h: cfg.headerHeight - 12,
      text: cfg.headers[c],
      fontSize: cfg.headerFontSize || 12,
      color: COLORS.white,
      bold: true,
      valign: "middle",
    });
    x += cfg.widths[c];
  }

  y += cfg.headerHeight;
  for (let r = 0; r < cfg.rows.length; r += 1) {
    const row = cfg.rows[r];
    x = cfg.x;
    const rowHeight = (cfg.rowHeights && cfg.rowHeights[r]) || cfg.rowHeight || 48;
    for (let c = 0; c < row.length; c += 1) {
      addShape(slide, {
        x,
        y,
        w: cfg.widths[c],
        h: rowHeight,
        fill: solid(COLORS.white),
        line: { width: 1, fill: COLORS.lightGray },
      });
      const cell = typeof row[c] === "string" ? { text: row[c] } : row[c];
      addText(slide, {
        x: x + 8,
        y: y + 6,
        w: cfg.widths[c] - 16,
        h: rowHeight - 12,
        text: cell.text,
        fontSize: cell.fontSize || cfg.fontSize || 12,
        color: cell.color || COLORS.ink,
        bold: Boolean(cell.bold),
        italic: Boolean(cell.italic),
        valign: "middle",
      });
      x += cfg.widths[c];
    }
    y += rowHeight;
  }

  return {
    x: cfg.x,
    y: cfg.y,
    w: totalWidth,
    h: cfg.headerHeight + cfg.rows.reduce((sum, _, idx) => sum + ((cfg.rowHeights && cfg.rowHeights[idx]) || cfg.rowHeight || 48), 0),
  };
}

function addCaption(slide, text, slideNo) {
  addText(slide, {
    x: 144,
    y: 465.6,
    w: 672,
    h: 24,
    text,
    fontSize: 10,
    color: COLORS.gray,
    italic: true,
    align: "center",
  });
  addFooter(slide, slideNo);
}

function addScreenWithCaption(slide, opts) {
  addImage(slide, {
    path: opts.path,
    alt: opts.alt,
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    fit: "contain",
  });
  addText(slide, {
    x: opts.x - 14,
    y: opts.y + opts.h + 12,
    w: opts.w + 28,
    h: 20,
    text: opts.title,
    fontSize: 13,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
  addText(slide, {
    x: opts.x - 14,
    y: opts.y + opts.h + 34,
    w: opts.w + 28,
    h: 18,
    text: opts.subtitle,
    fontSize: 10,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
}

function buildDeck() {
  const pres = Presentation.create({ slideSize: { width: W, height: H } });
  buildTitleSlide(pres.slides.add());
  buildIntroduction(pres.slides.add(), 2);
  buildLiteratureReview(pres.slides.add(), 3);
  buildProblemStatement(pres.slides.add(), 4);
  buildMethodology(pres.slides.add(), 5);
  buildMethodologyCont(pres.slides.add(), 6);
  buildSystemDesign(pres.slides.add(), 7);
  buildSystemDesignCont(pres.slides.add(), 8);
  buildAppScreensOne(pres.slides.add(), 9);
  buildAppScreensTwo(pres.slides.add(), 10);
  buildAppScreensThree(pres.slides.add(), 11);
  buildResultsTable(pres.slides.add(), 12);
  buildResultsCont(pres.slides.add(), 13);
  buildChallenges(pres.slides.add(), 14);
  buildFutureWork(pres.slides.add(), 15);
  buildConclusion(pres.slides.add(), 16);
  buildReferences(pres.slides.add(), 17);
  buildQuestionSlide(pres.slides.add(), 18);
  return pres;
}

function buildTitleSlide(slide) {
  addLogo(slide, true);
  addText(slide, {
    x: 720,
    y: 9.6,
    w: 220.8,
    h: 86.4,
    text: "FYP Defense\nPresentation",
    fontSize: 14,
    color: COLORS.ink,
    bold: true,
    align: "center",
    valign: "middle",
  });
  addText(slide, {
    x: 48,
    y: 126,
    w: 864,
    h: 108,
    text: "Tours & Travel",
    fontSize: 56,
    color: COLORS.green,
    bold: true,
    align: "center",
    valign: "middle",
  });
  addText(slide, {
    x: 48,
    y: 182,
    w: 864,
    h: 62,
    text: "Mobile Application",
    fontSize: 40,
    color: COLORS.green,
    bold: true,
    align: "center",
    valign: "middle",
  });
  addText(slide, {
    x: 48,
    y: 232,
    w: 864,
    h: 34,
    text: "A Smart Tourism Management & Booking Platform",
    fontSize: 18,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
  addText(slide, {
    x: 144,
    y: 292.8,
    w: 672,
    h: 86.4,
    text: "Shahid Umer\t\tAUIC-22SG-BSCS-6732\nMusharaf\t\tAUIC-22SG-BSCS-7029",
    fontSize: 15,
    color: COLORS.ink,
    align: "center",
    valign: "middle",
  });
  addText(slide, {
    x: 96,
    y: 441.6,
    w: 768,
    h: 43.2,
    text: "Supervisor:   Dr. Amjad Khan",
    fontSize: 16,
    color: COLORS.green,
    bold: true,
    align: "center",
    valign: "middle",
  });
}

function buildIntroduction(slide, no) {
  addPageTitle(slide, "Introduction", no);
  addBulletList(slide, {
    x: 62,
    y: 118,
    w: 806,
    fontSize: 14,
    gap: 56,
    items: [
      {
        text: "Tours & Travel is a Flutter-based mobile application designed to unify destination discovery, hotel booking, transport planning, maps, and traveler support in one platform.",
        h: 52,
      },
      {
        text: "The project targets Pakistan’s domestic tourism context, where users still depend on scattered sources for places, hotels, payments, and travel coordination.",
        h: 52,
      },
      {
        text: "Core objective: build a modular academic prototype that demonstrates authentication, bookings, maps, profile management, booking history, and user-created listings.",
        h: 52,
      },
      {
        text: "The system uses Flutter for the mobile interface and Firebase-backed services with local fallback support for stable final-year demonstration.",
        h: 52,
      },
    ],
  });
}

function buildLiteratureReview(slide, no) {
  addPageTitle(slide, "Literature Review", no);
  drawTable(slide, {
    x: 50,
    y: 110,
    widths: [130, 205, 180, 345],
    headerHeight: 30,
    rowHeight: 62,
    fontSize: 10,
    headers: ["App / System", "It Gives", "Gap", "Our App Gives"],
    rows: [
      [
        { text: "Booking.com", bold: true },
        "Hotels, stays, flights, car rentals, and guest reviews.",
        "Strong booking app, but not one local tourism flow for our project scope.",
        "We give destination browsing, hotel booking flow, maps, profile, and booking history in one app.",
      ],
      [
        { text: "Agoda", bold: true },
        "Hotels, homes, flights, transport, and activities.",
        "Good travel deals app, but not focused on one local tourism workflow.",
        "We give local destination details, booking support, maps, and user account features in one system.",
      ],
      [
        { text: "Expedia", bold: true },
        "Stays, flights, cars, packages, and things to do.",
        "Strong global travel bundles, but not tailored to our local academic use case.",
        "We combine destination exploration, hotel flow, profile, and booking history in one app.",
      ],
      [
        { text: "Trip.com", bold: true },
        "Hotels, flights, trains, attractions, and travel deals.",
        "Strong international app, but it does not match our single local tourism demo flow.",
        "We give maps, local destinations, hotel booking support, profile, and booking history together.",
      ],
    ],
  });

  addText(slide, {
    x: 64,
    y: 436,
    w: 832,
    h: 32,
    text: "Summary: existing apps provide strong global booking services, while our app combines local destination discovery, hotel flow, maps, profile, and booking history in one academic mobile app.",
    fontSize: 10,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
}

function buildProblemStatement(slide, no) {
  addPageTitle(slide, "Problem Statement", no);
  addText(slide, {
    x: 95,
    y: 116,
    w: 770,
    h: 72,
    text: "Pakistan’s tourism planning process is still fragmented and semi-manual. Users discover destinations on one platform, research hotels somewhere else, arrange transport separately, and confirm details through calls or messages.",
    fontSize: 14,
    color: COLORS.ink,
  });
  addText(slide, {
    x: 95,
    y: 194,
    w: 770,
    h: 72,
    text: "There is no single user-friendly mobile application that lets travelers move smoothly from exploration to booking confirmation while also supporting maps, profile data, booking history, and service listings.",
    fontSize: 14,
    color: COLORS.ink,
  });
  addText(slide, {
    x: 95,
    y: 272,
    w: 770,
    h: 72,
    text: "This creates repeated data entry, weak cost visibility, inconsistent communication, and lower trust for both users and service providers. The project addresses that gap through one integrated tourism app prototype.",
    fontSize: 14,
    color: COLORS.ink,
  });
}

function buildMethodology(slide, no) {
  addPageTitle(slide, "Methodology", no, "Academic software engineering approach — requirement-driven, modular, and iterative");
  const headers = [
    { x: 24, y: 124.8, title: "Requirement Engineering" },
    { x: 489.6, y: 124.8, title: "Core Feature Modules" },
    { x: 24, y: 316.8, title: "Data & Service Layer" },
    { x: 489.6, y: 316.8, title: "Testing & Validation" },
  ];
  for (const h of headers) {
    addShape(slide, {
      x: h.x,
      y: h.y,
      w: 441.6,
      h: 36.48,
      fill: solid(COLORS.dark),
      line: { width: 0 },
    });
    addText(slide, {
      x: h.x + 19,
      y: h.y + 8,
      w: 400,
      h: 20,
      text: h.title,
      fontSize: 12,
      color: COLORS.white,
      bold: true,
    });
  }

  addBulletList(slide, {
    x: 38.4,
    y: 205,
    w: 412.8,
    fontSize: 12,
    gap: 25,
    items: [
      "Stakeholder identification and requirement analysis",
      "Functional / non-functional requirements definition",
      "Feasibility study, risk assessment, and traceability planning",
    ],
  });
  addBulletList(slide, {
    x: 504,
    y: 205,
    w: 412.8,
    fontSize: 12,
    gap: 25,
    items: [
      "Authentication, destination discovery, and booking workflow design",
      "Hotel search, car rental, payment simulation, and map support",
      "Profile management, booking history, and user listing modules",
    ],
  });
  addBulletList(slide, {
    x: 38.4,
    y: 396,
    w: 412.8,
    fontSize: 12,
    gap: 25,
    items: [
      "Service-oriented separation of screens, models, and storage logic",
      "Firebase Auth, Firestore, Storage, Shared Preferences, and in-memory fallback",
      "Reusable validators, constants, theme utilities, and navigation helpers",
    ],
  });
  addBulletList(slide, {
    x: 504,
    y: 396,
    w: 412.8,
    fontSize: 12,
    gap: 25,
    items: [
      "Manual and integration testing across major user flows",
      "Positive / negative case validation for forms, bookings, and routing",
      "Honest reporting of defects, limitations, and production gaps",
    ],
  });
}

function buildMethodologyCont(slide, no) {
  addPageTitle(slide, "Methodology (Cont..)", no);
  addText(slide, {
    x: 28.8,
    y: 84.48,
    w: 520,
    h: 24,
    text: "Development Tools & Practices",
    fontSize: 12,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
  addText(slide, {
    x: 585.6,
    y: 84.48,
    w: 355.2,
    h: 24,
    text: "Technology Stack",
    fontSize: 12,
    color: COLORS.green,
    bold: true,
    align: "center",
  });

  drawTable(slide, {
    x: 24,
    y: 124.8,
    widths: [120, 404],
    headerHeight: 26,
    rowHeight: 46,
    fontSize: 11,
    headers: ["Category", "Tool / Practice"],
    rows: [
      ["IDE", "Visual Studio Code / Android Studio"],
      ["Framework", "Flutter with Dart"],
      ["Cloud services", "Firebase Auth, Cloud Firestore, Firebase Storage"],
      ["Local support", "Shared Preferences + in-memory booking store"],
      ["Maps & location", "Google Maps Flutter and Geolocator"],
      ["Testing", "Manual and integration flow testing"],
    ],
  });

  const techBoxes = [
    { x: 580.8, y: 132.48, text: "Flutter" },
    { x: 763.2, y: 132.48, text: "Dart" },
    { x: 580.8, y: 238.08, text: "Firebase" },
    { x: 763.2, y: 238.08, text: "Firestore" },
    { x: 580.8, y: 343.68, text: "Maps API" },
    { x: 763.2, y: 343.68, text: "Shared Prefs" },
  ];
  for (const box of techBoxes) {
    addShape(slide, {
      x: box.x,
      y: box.y,
      w: 163.2,
      h: 84.48,
      fill: solid(COLORS.paleGray),
      line: { width: 1, fill: COLORS.lightGray },
    });
    addText(slide, {
      x: box.x,
      y: box.y + 25,
      w: 163.2,
      h: 30,
      text: box.text,
      fontSize: 14,
      color: COLORS.green,
      bold: true,
      align: "center",
      valign: "middle",
    });
  }
}

function buildSystemDesign(slide, no) {
  addPageTitle(slide, "System Design", no);
  addImage(slide, {
    path: asset("p27_img1.png"),
    alt: "System architecture diagram",
    x: 198.6,
    y: 104,
    w: 562.8,
    h: 330,
    fit: "contain",
  });
  addCaption(slide, "Proposed System Architecture Diagram", no);
}

function buildSystemDesignCont(slide, no) {
  addPageTitle(slide, "System Design (Cont..)", no);
  addImage(slide, {
    path: asset("p29_img2.png"),
    alt: "Use case diagram",
    x: 260,
    y: 104,
    w: 420,
    h: 330,
    fit: "contain",
  });
  addCaption(slide, "Use Case Diagram", no);
}

function buildAppScreensOne(slide, no) {
  addPageTitle(slide, "App Screens", no);
  addText(slide, {
    x: 28.8,
    y: 67.2,
    w: 902.4,
    h: 20,
    text: "Mobile App — Authentication & Discovery Interface",
    fontSize: 11,
    color: COLORS.green,
    bold: true,
    align: "center",
  });
  addScreenWithCaption(slide, {
    path: asset("p38_img1.jpg"),
    alt: "Login screen",
    x: 110,
    y: 108,
    w: 160,
    h: 345,
    title: "Login Screen",
    subtitle: "User authentication entry",
  });
  addScreenWithCaption(slide, {
    path: asset("p40_img1.jpg"),
    alt: "Home screen",
    x: 390,
    y: 108,
    w: 150,
    h: 345,
    title: "Home / Discovery Screen",
    subtitle: "Browse destinations and services",
  });
  addScreenWithCaption(slide, {
    path: asset("p43_img1.jpg"),
    alt: "Destination detail screen",
    x: 620,
    y: 108,
    w: 170,
    h: 345,
    title: "Destination Detail Screen",
    subtitle: "Highlights, gallery, and booking CTA",
  });
  addFooter(slide, no);
}

function buildAppScreensTwo(slide, no) {
  addPageTitle(slide, "App Screens (Cont..)", no);
  addText(slide, {
    x: 28.8,
    y: 67.2,
    w: 902.4,
    h: 20,
    text: "Mobile App — Booking, Selection, and Confirmation",
    fontSize: 11,
    color: COLORS.green,
    bold: true,
    align: "center",
  });
  addScreenWithCaption(slide, {
    path: asset("p44_img2.jpg"),
    alt: "Hotel selection screen",
    x: 95,
    y: 108,
    w: 165,
    h: 345,
    title: "Hotel Selection Screen",
    subtitle: "User chooses hotel and room type",
  });
  addScreenWithCaption(slide, {
    path: asset("p51_img1.jpg"),
    alt: "Payment screen",
    x: 380,
    y: 108,
    w: 165,
    h: 345,
    title: "Payment Screen",
    subtitle: "Simulated payment interface",
  });
  addScreenWithCaption(slide, {
    path: asset("p52_img1.jpg"),
    alt: "Booking confirmation screen",
    x: 665,
    y: 108,
    w: 165,
    h: 345,
    title: "Booking Confirmation",
    subtitle: "Success state after confirmation",
  });
  addFooter(slide, no);
}

function buildAppScreensThree(slide, no) {
  addPageTitle(slide, "App Screens (Cont..)", no);
  addText(slide, {
    x: 28.8,
    y: 75.36,
    w: 902.4,
    h: 20,
    text: "Booking History, Profile, and Maps",
    fontSize: 11,
    color: COLORS.green,
    bold: true,
    align: "center",
  });
  addImage(slide, {
    path: asset("p53_img1.jpg"),
    alt: "Booking history screen",
    x: 70,
    y: 116,
    w: 210,
    h: 300,
    fit: "contain",
  });
  addText(slide, {
    x: 24,
    y: 434.88,
    w: 283.2,
    h: 24,
    text: "Booking History Screen",
    fontSize: 12,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
  addText(slide, {
    x: 24,
    y: 458.88,
    w: 283.2,
    h: 19.2,
    text: "Confirmed trips visible to the user",
    fontSize: 10,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
  addImage(slide, {
    path: asset("p55_img1.jpg"),
    alt: "Profile screen",
    x: 360,
    y: 116,
    w: 210,
    h: 300,
    fit: "contain",
  });
  addText(slide, {
    x: 336,
    y: 434.88,
    w: 258,
    h: 24,
    text: "Profile Management Screen",
    fontSize: 12,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
  addText(slide, {
    x: 336,
    y: 458.88,
    w: 258,
    h: 19.2,
    text: "User details, counts, and quick actions",
    fontSize: 10,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
  addImage(slide, {
    path: asset("p57_img1.jpg"),
    alt: "Map screen",
    x: 650,
    y: 116,
    w: 210,
    h: 300,
    fit: "contain",
  });
  addText(slide, {
    x: 624,
    y: 434.88,
    w: 262,
    h: 24,
    text: "Tourist Map Screen",
    fontSize: 12,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
  addText(slide, {
    x: 624,
    y: 458.88,
    w: 262,
    h: 19.2,
    text: "Location markers and map-based support",
    fontSize: 10,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
  addFooter(slide, no);
}

function buildResultsTable(slide, no) {
  addPageTitle(slide, "Results and Analysis", no);
  addText(slide, {
    x: 38.4,
    y: 81.6,
    w: 902.4,
    h: 24,
    text: "Functional Testing — Core User Flows Validated",
    fontSize: 13,
    color: COLORS.ink,
    bold: true,
  });
  drawTable(slide, {
    x: 19.2,
    y: 116.5,
    widths: [160, 160, 475, 139],
    headerHeight: 34,
    rowHeight: 50,
    fontSize: 11,
    headers: ["Test Case ID", "Module", "Description", "Status"],
    rows: [
      ["TC-01", "Authentication", "User registers / logs in successfully", { text: "PASS", color: COLORS.pass, bold: true }],
      ["TC-02", "Validation", "Invalid email or password shows appropriate feedback", { text: "PASS", color: COLORS.pass, bold: true }],
      ["TC-03", "Booking", "Destination and hotel selection flow completes correctly", { text: "PASS", color: COLORS.pass, bold: true }],
      ["TC-04", "Payment", "Simulated payment moves to booking success state", { text: "PASS", color: COLORS.pass, bold: true }],
      ["TC-05", "History", "Confirmed booking appears in booking history", { text: "PASS", color: COLORS.pass, bold: true }],
      ["TC-06", "Maps / Listings", "Map loads and local listings remain accessible", { text: "PASS", color: COLORS.pass, bold: true }],
    ],
  });
}

function buildResultsCont(slide, no) {
  addPageTitle(slide, "Results and Analysis (Cont..)", no);
  addText(slide, {
    x: 319.09,
    y: 78.72,
    w: 360.22,
    h: 24,
    text: "Prototype Readiness & Cloud Data View",
    fontSize: 13,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
  addImage(slide, {
    path: asset("p32_img1.jpg"),
    alt: "Firestore schema diagram",
    x: 45.8,
    y: 120,
    w: 380,
    h: 245,
    fit: "contain",
  });
  addImage(slide, {
    path: asset("p61_img1.jpg"),
    alt: "Firestore console screenshot",
    x: 489.6,
    y: 120,
    w: 422.4,
    h: 283.2,
    fit: "contain",
  });
  addText(slide, {
    x: 60,
    y: 408,
    w: 852,
    h: 50,
    text: "The prototype demonstrates structured Firestore collections, initialized cloud data, and a maintainable service-driven design that can be extended beyond the current academic scope.",
    fontSize: 12,
    color: COLORS.ink,
    align: "center",
  });
  addText(slide, {
    x: 60,
    y: 450,
    w: 852,
    h: 38,
    text: "Key outcome: the app is not just visually complete; it also has coherent architecture, reusable modules, and a practical path toward full deployment.",
    fontSize: 11,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
  addFooter(slide, no);
}

function buildChallenges(slide, no) {
  addPageTitle(slide, "Challenges", no);
  addBulletList(slide, {
    x: 95.7,
    y: 90.6,
    w: 768.5,
    fontSize: 14,
    gap: 84,
    items: [
      "Simulated payments instead of a live payment gateway mean the booking flow is demonstration-ready but not yet transaction-ready.",
      "Automated testing coverage is still limited, so validation is stronger for manual user flows than for long-term regression control.",
      "Some booking states and user-created listings currently rely on local or session-based persistence instead of complete cloud synchronization.",
    ],
  });
}

function buildFutureWork(slide, no) {
  addPageTitle(slide, "Future Work", no);
  addBulletList(slide, {
    x: 96.6,
    y: 109.9,
    w: 752.2,
    fontSize: 14,
    gap: 40,
    items: [
      "Integrate a real payment gateway for production-grade booking confirmation.",
      "Add recommendation, search enhancement, ratings, and review features for better traveler decision support.",
      "Extend cloud storage to every booking category and build an admin dashboard with stronger moderation controls.",
      "Introduce push notifications, stronger security rules, and broader automated unit / integration tests.",
      "Move from a robust academic prototype toward a deployable tourism platform for Pakistan.",
    ],
  });
}

function buildConclusion(slide, no) {
  addPageTitle(slide, "Conclusion", no);
  addBulletList(slide, {
    x: 90.1,
    y: 129.3,
    w: 759.4,
    fontSize: 14,
    gap: 54,
    items: [
      "The project successfully demonstrates that one modular Flutter application can combine destination discovery, hotel booking, car rental, maps, profile management, and booking history in one tourism workflow.",
      "It applies requirement engineering, layered architecture, reusable UI, Firebase-backed services, and structured testing in a real final-year software project.",
      "The prototype is academically valuable today and also leaves a credible path toward future commercial and research-oriented enhancement.",
    ],
  });
}

function buildReferences(slide, no) {
  addPageTitle(slide, "References", no);
  const refs = [
    "[1] Google, \"Flutter documentation,\" https://docs.flutter.dev/.",
    "[2] Google, \"Firebase documentation,\" https://firebase.google.com/docs.",
    "[3] Google for Developers, \"Google Maps Platform documentation,\" https://developers.google.com/maps/documentation.",
    "[4] Material Design 3 guidelines, https://m3.material.io/.",
    "[5] Dart documentation, \"Dart language tour,\" https://dart.dev/guides/language/language-tour.",
    "[6] Geolocator package documentation, https://pub.dev/packages/geolocator.",
    "[7] Cloud Firestore package documentation, https://pub.dev/packages/cloud_firestore.",
  ];
  let y = 88.32;
  for (let i = 0; i < refs.length; i += 1) {
    addText(slide, {
      x: 33.6,
      y,
      w: 892.8,
      h: 38,
      text: refs[i],
      fontSize: 13,
      color: COLORS.ink,
    });
    y += 46;
  }
}

function buildQuestionSlide(slide, no) {
  addLogo(slide, false);
  addText(slide, {
    x: 48,
    y: 221.55,
    w: 864,
    h: 81.6,
    text: "Question & Suggestions",
    fontSize: 42,
    color: COLORS.green,
    bold: true,
    align: "center",
    valign: "middle",
  });
  addShape(slide, {
    x: 240,
    y: 322.57,
    w: 480,
    h: 2,
    fill: solid(COLORS.green),
    line: { width: 0 },
  });
  addText(slide, {
    x: 48,
    y: 436.8,
    w: 864,
    h: 28.8,
    text: "Abasyn University Islamabad Campus  |  Department of Computer Science  |  2022 – 2026",
    fontSize: 11,
    color: "BBBBBB",
    align: "center",
  });
  addFooter(slide, no);
}

async function hydrateLocalImages(presentation) {
  const pending = presentation.getPendingImageHydrationRequests();
  if (!pending.length) return;
  const hydrated = [];
  for (const request of pending) {
    const filePath = path.isAbsolute(request.uri)
      ? request.uri
      : path.resolve(WORKSPACE, request.uri);
    const data = await fs.readFile(filePath);
    hydrated.push({
      assetId: request.assetId,
      contentType: request.contentType,
      data,
    });
  }
  presentation.hydrateImageAssets(hydrated);
}

async function blobToBuffer(blobLike) {
  if (blobLike && blobLike.data) return Buffer.from(blobLike.data);
  if (blobLike && typeof blobLike.arrayBuffer === "function") {
    return Buffer.from(await blobLike.arrayBuffer());
  }
  if (blobLike && typeof blobLike.bytes === "function") {
    return Buffer.from(await blobLike.bytes());
  }
  throw new Error("Unsupported blob payload.");
}

async function exportDeck(presentation) {
  await fs.mkdir(OUTPUT_DIR, { recursive: true });
  await fs.mkdir(PREVIEW_DIR, { recursive: true });
  await fs.mkdir(LAYOUT_DIR, { recursive: true });

  const pptxBlob = await PresentationFile.exportPptx(presentation);
  await fs.writeFile(path.join(OUTPUT_DIR, "output.pptx"), await blobToBuffer(pptxBlob));

  for (let i = 0; i < presentation.slides.items.length; i += 1) {
    const slide = presentation.slides.items[i];
    const number = String(i + 1).padStart(2, "0");
    const png = await presentation.export({ format: "png", slide });
    await fs.writeFile(path.join(PREVIEW_DIR, `slide-${number}.png`), await blobToBuffer(png));
    const layout = await presentation.export({ format: "layout", slide });
    await fs.writeFile(path.join(LAYOUT_DIR, `slide-${number}.layout.json`), await blobToBuffer(layout));
  }
}

async function main() {
  const pres = buildDeck();
  await hydrateLocalImages(pres);
  await exportDeck(pres);
  console.log(JSON.stringify({
    slides: pres.slides.items.length,
    pptx: path.join(OUTPUT_DIR, "output.pptx"),
    previews: PREVIEW_DIR,
    layouts: LAYOUT_DIR,
  }, null, 2));
}

await main();
