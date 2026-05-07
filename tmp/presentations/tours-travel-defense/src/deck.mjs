import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const { Presentation, PresentationFile } = await import("@oai/artifact-tool");

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const WORKSPACE = path.resolve(__dirname, "..");
const OUTPUT_DIR = path.join(WORKSPACE, "output");
const SCRATCH_DIR = path.join(WORKSPACE, "scratch");
const PREVIEW_DIR = path.join(SCRATCH_DIR, "previews");
const LAYOUT_DIR = path.join(SCRATCH_DIR, "layouts");
const ASSET_DIR = path.join(SCRATCH_DIR, "assets");

const SLIDE_WIDTH = 1920;
const SLIDE_HEIGHT = 1080;

const COLORS = {
  navy: "0F2743",
  navyDeep: "0A1C33",
  blue: "1E63C4",
  teal: "0FA5A6",
  tealSoft: "DDF4F4",
  skySoft: "E8F0FB",
  gold: "F1B756",
  sand: "F7E9CF",
  cream: "FBF8F2",
  offWhite: "F7F7F4",
  white: "FFFFFF",
  ink: "12243B",
  slate: "52657A",
  line: "D8E1EA",
  green: "1D9B57",
  greenSoft: "E6F5EE",
  amber: "D68B00",
  amberSoft: "FFF1D4",
  roseSoft: "FBE6E1",
  red: "C85C46",
};

const FONTS = {
  display: "Cambria",
  body: "Calibri",
};

function solid(color) {
  return { type: "solid", color };
}

function gradient(angleDeg, stops) {
  return {
    type: "gradient",
    gradientKind: "linear",
    angleDeg,
    stops,
  };
}

function asset(name) {
  return path.join(ASSET_DIR, name);
}

function addShape(slide, opts) {
  const shape = slide.shapes.add({
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
  return shape;
}

function addText(slide, opts) {
  const shape = slide.shapes.add({
    geometry: opts.geometry || "rect",
    name: opts.name,
    position: {
      left: opts.x,
      top: opts.y,
      width: opts.w,
      height: opts.h,
      rotation: opts.rotation || 0,
    },
    fill: opts.fill || { type: "none" },
    line: opts.line || { width: 0 },
  });
  shape.text.style = {
    fontSize: opts.fontSize || 24,
    color: opts.color || COLORS.ink,
    typeface: opts.font || FONTS.body,
    bold: Boolean(opts.bold),
    italic: Boolean(opts.italic),
    alignment: opts.align || "left",
    verticalAlignment: opts.valign || "top",
    wrap: opts.wrap !== false,
    insets: opts.insets || { left: 0, right: 0, top: 0, bottom: 0 },
    lineSpacing: opts.lineSpacing,
  };
  shape.text = opts.text;
  return shape;
}

function addPill(slide, opts) {
  const pill = addShape(slide, {
    geometry: "roundRect",
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    fill: opts.fill || solid(COLORS.teal),
    line: opts.line || { width: 0 },
    name: opts.name,
  });
  pill.text.style = {
    fontSize: opts.fontSize || 18,
    color: opts.color || COLORS.white,
    typeface: opts.font || FONTS.body,
    bold: opts.bold !== false,
    alignment: "center",
    verticalAlignment: "middle",
    wrap: false,
    insets: { left: 8, right: 8, top: 2, bottom: 2 },
  };
  pill.text = opts.text;
  return pill;
}

function addImage(slide, opts) {
  const image = slide.images.add({
    path: opts.path,
    alt: opts.alt,
    position: {
      left: opts.x,
      top: opts.y,
      width: opts.w,
      height: opts.h,
    },
    fit: opts.fit || "contain",
  });
  if (opts.geometry) image.geometry = opts.geometry;
  if (opts.rotation) image.rotation = opts.rotation;
  if (opts.name) image.name = opts.name;
  return image;
}

function addRule(slide, x, y, w, color = COLORS.line, h = 3) {
  return addShape(slide, {
    x,
    y,
    w,
    h,
    fill: solid(color),
    line: { width: 0 },
    name: `rule-${x}-${y}`,
  });
}

function addFooter(slide, text) {
  addRule(slide, 100, 1000, 1720, COLORS.line, 2);
  addText(slide, {
    x: 100,
    y: 1014,
    w: 900,
    h: 28,
    text,
    fontSize: 14,
    color: COLORS.slate,
  });
}

function addSectionTitle(slide, opts) {
  const eyebrowOffset = opts.eyebrow ? 30 : 0;
  const titleY = opts.y + eyebrowOffset;
  const titleHeight = opts.titleHeight || 120;
  if (opts.eyebrow) {
    addText(slide, {
      x: opts.x,
      y: opts.y,
      w: opts.w,
      h: 28,
      text: opts.eyebrow,
      fontSize: 18,
      color: opts.eyebrowColor || COLORS.teal,
      bold: true,
    });
  }
  addText(slide, {
    x: opts.x,
    y: titleY,
    w: opts.w,
    h: titleHeight,
    text: opts.title,
    fontSize: opts.titleSize || 48,
    color: opts.titleColor || COLORS.ink,
    font: opts.font || FONTS.display,
    bold: true,
  });
  if (opts.subtitle) {
    addText(slide, {
      x: opts.x,
      y: titleY + titleHeight + 18,
      w: opts.w,
      h: opts.subtitleHeight || 72,
      text: opts.subtitle,
      fontSize: opts.subtitleSize || 24,
      color: opts.subtitleColor || COLORS.slate,
    });
  }
}

function addBulletItem(slide, opts) {
  addShape(slide, {
    geometry: "roundRect",
    x: opts.x,
    y: opts.y + 9,
    w: 18,
    h: 18,
    fill: solid(opts.accent || COLORS.teal),
    line: { width: 0 },
  });
  addText(slide, {
    x: opts.x + 34,
    y: opts.y,
    w: opts.w - 34,
    h: 34,
    text: opts.title,
    fontSize: opts.titleSize || 23,
    color: opts.titleColor || COLORS.ink,
    bold: true,
  });
  if (opts.body) {
    addText(slide, {
      x: opts.x + 34,
      y: opts.y + 34,
      w: opts.w - 34,
      h: opts.bodyHeight || 58,
      text: opts.body,
      fontSize: opts.bodySize || 20,
      color: opts.bodyColor || COLORS.slate,
    });
  }
}

function addPhoneCard(slide, opts) {
  addShape(slide, {
    geometry: "roundRect",
    x: opts.x - 18,
    y: opts.y - 22,
    w: opts.w + 36,
    h: opts.h + 78,
    fill: opts.backingFill || solid(COLORS.white),
    line: opts.backingLine || { width: 1.5, fill: COLORS.line },
  });
  addImage(slide, {
    path: opts.path,
    alt: opts.alt,
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    fit: "contain",
    geometry: "roundRect",
    rotation: opts.rotation || 0,
    name: opts.name,
  });
  addText(slide, {
    x: opts.x - 6,
    y: opts.y + opts.h + 22,
    w: opts.w + 12,
    h: 42,
    text: opts.caption,
    fontSize: 18,
    color: COLORS.ink,
    bold: true,
    align: "center",
  });
}

function buildPresentation() {
  const presentation = Presentation.create({
    slideSize: { width: SLIDE_WIDTH, height: SLIDE_HEIGHT },
  });

  buildCover(presentation.slides.add());
  buildProblem(presentation.slides.add());
  buildObjectives(presentation.slides.add());
  buildWorkflow(presentation.slides.add());
  buildArchitecture(presentation.slides.add());
  buildShowcase(presentation.slides.add());
  buildTesting(presentation.slides.add());
  buildResults(presentation.slides.add());
  buildRoadmap(presentation.slides.add());
  buildClosing(presentation.slides.add());

  return presentation;
}

function buildCover(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: gradient(15, [
      { offset: 0, color: COLORS.navyDeep },
      { offset: 48000, color: COLORS.navy },
      { offset: 100000, color: COLORS.blue },
    ]),
    line: { width: 0 },
    name: "slide-1-bg",
  });

  addShape(slide, {
    geometry: "ellipse",
    x: 1290,
    y: 40,
    w: 540,
    h: 540,
    fill: solid(COLORS.teal),
    line: { width: 0 },
    name: "slide-1-accent-a",
  });
  addShape(slide, {
    geometry: "ellipse",
    x: 1040,
    y: 560,
    w: 620,
    h: 400,
    fill: solid(COLORS.gold),
    line: { width: 0 },
    name: "slide-1-accent-b",
  });
  addShape(slide, {
    geometry: "roundRect",
    x: 1070,
    y: 130,
    w: 710,
    h: 820,
    fill: gradient(125, [
      { offset: 0, color: "134A67" },
      { offset: 100000, color: "0B2646" },
    ]),
    line: { width: 0 },
    name: "slide-1-stage",
  });

  addPill(slide, {
    x: 100,
    y: 92,
    w: 300,
    h: 42,
    text: "Final Year Project Defense",
    fill: solid(COLORS.teal),
    fontSize: 18,
  });

  addText(slide, {
    x: 100,
    y: 175,
    w: 860,
    h: 220,
    text: "Tours & Travel\nMobile Application",
    fontSize: 62,
    color: COLORS.white,
    font: FONTS.display,
    bold: true,
    name: "slide-1-title",
  });

  addText(slide, {
    x: 100,
    y: 405,
    w: 760,
    h: 82,
    text: "A Flutter-based tourism management system for Pakistan that unifies discovery, booking, maps, and traveler support in one mobile experience.",
    fontSize: 24,
    color: "D7E6F6",
    name: "slide-1-subtitle",
  });

  addRule(slide, 100, 522, 180, COLORS.gold, 4);

  addText(slide, {
    x: 100,
    y: 560,
    w: 340,
    h: 34,
    text: "Submitted by",
    fontSize: 20,
    color: "B9CCE1",
    bold: true,
  });
  addText(slide, {
    x: 100,
    y: 595,
    w: 420,
    h: 86,
    text: "Shahid Umer\nMusharaf",
    fontSize: 30,
    color: COLORS.white,
    font: FONTS.display,
    bold: true,
  });

  addText(slide, {
    x: 500,
    y: 560,
    w: 320,
    h: 34,
    text: "Supervised by",
    fontSize: 20,
    color: "B9CCE1",
    bold: true,
  });
  addText(slide, {
    x: 500,
    y: 595,
    w: 350,
    h: 86,
    text: "Dr. Amjad Khan",
    fontSize: 30,
    color: COLORS.white,
    font: FONTS.display,
    bold: true,
  });

  addText(slide, {
    x: 100,
    y: 820,
    w: 760,
    h: 90,
    text: "Department of Computing | Abasyn University Islamabad Campus | April 2026",
    fontSize: 22,
    color: "D7E6F6",
  });

  addPill(slide, {
    x: 1170,
    y: 860,
    w: 425,
    h: 44,
    text: "Flutter + Firebase + Hybrid fallback support",
    fill: solid(COLORS.gold),
    color: COLORS.navyDeep,
    fontSize: 18,
  });

  addImage(slide, {
    path: asset("p40_img1.jpg"),
    alt: "Home screen",
    x: 1145,
    y: 165,
    w: 238,
    h: 520,
    fit: "contain",
    geometry: "roundRect",
    rotation: -8,
    name: "slide-1-home",
  });
  addImage(slide, {
    path: asset("p43_img1.jpg"),
    alt: "Destination detail screen",
    x: 1380,
    y: 245,
    w: 248,
    h: 430,
    fit: "contain",
    geometry: "roundRect",
    name: "slide-1-destination",
  });
  addImage(slide, {
    path: asset("p52_img1.jpg"),
    alt: "Booking confirmation screen",
    x: 1530,
    y: 500,
    w: 214,
    h: 420,
    fit: "contain",
    geometry: "roundRect",
    rotation: 8,
    name: "slide-1-confirm",
  });
}

function buildProblem(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid(COLORS.offWhite),
    line: { width: 0 },
    name: "slide-2-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 820,
    eyebrow: "Motivation",
    title: "Travel planning for local tourism is still fragmented.",
    subtitle: "The thesis identifies a gap between scattered travel services and the need for one seamless, mobile-first planning experience in Pakistan.",
    titleSize: 52,
  });

  const problemItems = [
    {
      title: "Scattered information sources",
      body: "Travelers discover destinations, hotels, and transport through disconnected channels rather than one guided journey.",
    },
    {
      title: "Weak booking continuity",
      body: "Users may find a destination but still cannot move from exploration to confirmation in a smooth flow.",
    },
    {
      title: "Poor visibility and communication",
      body: "Costs, booking details, and service-provider interaction remain inconsistent across separate tools.",
    },
  ];

  let problemY = 350;
  for (const item of problemItems) {
    addBulletItem(slide, {
      x: 100,
      y: problemY,
      w: 730,
      title: item.title,
      body: item.body,
      accent: problemY === 350 ? COLORS.teal : problemY === 460 ? COLORS.blue : COLORS.gold,
    });
    problemY += 118;
  }

  addShape(slide, {
    geometry: "roundRect",
    x: 980,
    y: 210,
    w: 830,
    h: 690,
    fill: solid(COLORS.white),
    line: { width: 1.5, fill: COLORS.line },
    name: "slide-2-grid",
  });

  addText(slide, {
    x: 1030,
    y: 245,
    w: 500,
    h: 40,
    text: "Typical fragmented user journey",
    fontSize: 28,
    color: COLORS.ink,
    font: FONTS.display,
    bold: true,
  });

  const cards = [
    {
      x: 1030,
      y: 320,
      fill: solid("EAF5FB"),
      title: "Destination discovery",
      body: "Often starts through social media posts, agents, or informal recommendations.",
    },
    {
      x: 1410,
      y: 320,
      fill: solid(COLORS.tealSoft),
      title: "Hotel research",
      body: "Accommodation details are checked on separate portals with repeated comparison effort.",
    },
    {
      x: 1030,
      y: 560,
      fill: solid(COLORS.amberSoft),
      title: "Transport planning",
      body: "Vehicle and route arrangements are handled elsewhere, without shared booking context.",
    },
    {
      x: 1410,
      y: 560,
      fill: solid(COLORS.roseSoft),
      title: "Confirmation and payment",
      body: "Final coordination frequently depends on messaging, calls, or manual follow-up.",
    },
  ];

  for (const card of cards) {
    addShape(slide, {
      geometry: "roundRect",
      x: card.x,
      y: card.y,
      w: 320,
      h: 170,
      fill: card.fill,
      line: { width: 0 },
    });
    addText(slide, {
      x: card.x + 24,
      y: card.y + 20,
      w: 270,
      h: 34,
      text: card.title,
      fontSize: 24,
      color: COLORS.ink,
      bold: true,
      font: FONTS.display,
    });
    addText(slide, {
      x: card.x + 24,
      y: card.y + 62,
      w: 270,
      h: 86,
      text: card.body,
      fontSize: 19,
      color: COLORS.slate,
    });
  }

  addText(slide, {
    x: 1030,
    y: 790,
    w: 700,
    h: 64,
    text: "Result: slower planning, repeated data entry, and lower confidence in the overall travel experience.",
    fontSize: 24,
    color: COLORS.red,
    bold: true,
  });

  addFooter(slide, "Source: Problem statement and background, thesis report (2026).");
}

function buildObjectives(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid(COLORS.white),
    line: { width: 0 },
    name: "slide-3-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 780,
    eyebrow: "Project framing",
    title: "The defense focuses on clear objectives and realistic scope.",
    subtitle: "The project is positioned as an academic prototype: broad enough to demonstrate end-to-end travel flows, but honest about what is not yet production-ready.",
    titleSize: 48,
  });

  addText(slide, {
    x: 100,
    y: 345,
    w: 160,
    h: 190,
    text: "5",
    fontSize: 170,
    color: COLORS.teal,
    font: FONTS.display,
    bold: true,
  });
  addText(slide, {
    x: 245,
    y: 366,
    w: 430,
    h: 62,
    text: "core objectives",
    fontSize: 34,
    color: COLORS.ink,
    bold: true,
    font: FONTS.display,
  });

  const objectiveItems = [
    "Design one application for browsing and booking travel destinations.",
    "Integrate authentication, booking, maps, search, profile, and listing features.",
    "Apply Flutter and Firebase in a real software engineering project.",
    "Demonstrate modular design and reusable UI components.",
    "Create a scalable base for future research or commercial enhancement.",
  ];

  let objectiveY = 440;
  for (const [index, item] of objectiveItems.entries()) {
    addText(slide, {
      x: 245,
      y: objectiveY,
      w: 560,
      h: 46,
      text: `${index + 1}. ${item}`,
      fontSize: 22,
      color: COLORS.ink,
      bold: index === 0,
    });
    objectiveY += 68;
  }

  addShape(slide, {
    geometry: "roundRect",
    x: 1020,
    y: 110,
    w: 800,
    h: 810,
    fill: solid(COLORS.cream),
    line: { width: 0 },
    name: "slide-3-scope",
  });

  addText(slide, {
    x: 1075,
    y: 155,
    w: 300,
    h: 42,
    text: "In scope",
    fontSize: 30,
    color: COLORS.green,
    font: FONTS.display,
    bold: true,
  });
  addText(slide, {
    x: 1450,
    y: 155,
    w: 280,
    h: 42,
    text: "Not in scope yet",
    fontSize: 30,
    color: COLORS.amber,
    font: FONTS.display,
    bold: true,
  });

  addRule(slide, 1420, 210, 2, COLORS.line, 570);

  const inScope = [
    "Authentication and profile management",
    "Destination browsing and one-city / multi-city tours",
    "Hotel search and booking support",
    "City-to-city car rental flow",
    "Maps, booking history, and user-created listings",
  ];
  const outScope = [
    "Live payment gateway integration",
    "Full admin dashboard and moderation",
    "Recommendation engine",
    "Commercial deployment and app-store release pipeline",
    "Complete production-grade backend hardening",
  ];

  let scopeY = 230;
  for (const item of inScope) {
    addBulletItem(slide, {
      x: 1075,
      y: scopeY,
      w: 300,
      title: item,
      accent: COLORS.green,
      titleSize: 21,
      bodyHeight: 0,
    });
    scopeY += 96;
  }

  scopeY = 230;
  for (const item of outScope) {
    addBulletItem(slide, {
      x: 1450,
      y: scopeY,
      w: 300,
      title: item,
      accent: COLORS.gold,
      titleSize: 21,
      bodyHeight: 0,
    });
    scopeY += 96;
  }

  addFooter(slide, "Source: Objectives and scope of the project, thesis report (2026).");
}

function buildWorkflow(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid("F3FAFA"),
    line: { width: 0 },
    name: "slide-4-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 1000,
    eyebrow: "Solution overview",
    title: "One mobile workflow now covers the full traveler journey.",
    subtitle: "Instead of forcing users to jump between separate tools, the app guides them through discovery, selection, confirmation, and post-booking support.",
    titleSize: 50,
  });

  addRule(slide, 160, 430, 930, COLORS.line, 6);

  const steps = [
    { x: 150, fill: COLORS.teal, number: "1", title: "Sign in", body: "Secure login with Firebase and fallback support" },
    { x: 315, fill: COLORS.blue, number: "2", title: "Discover", body: "Browse destinations, tours, and featured options" },
    { x: 480, fill: COLORS.gold, number: "3", title: "Choose", body: "Review trip details and compare packages" },
    { x: 645, fill: COLORS.teal, number: "4", title: "Select stay", body: "Pick hotels and transport choices" },
    { x: 810, fill: COLORS.blue, number: "5", title: "Confirm", body: "Simulate payment and finalize the booking" },
    { x: 975, fill: COLORS.gold, number: "6", title: "Track", body: "View history, profile data, and user listings" },
  ];

  for (const step of steps) {
    addShape(slide, {
      geometry: "ellipse",
      x: step.x,
      y: 404,
      w: 58,
      h: 58,
      fill: solid(step.fill),
      line: { width: 0 },
    });
    addText(slide, {
      x: step.x,
      y: 414,
      w: 58,
      h: 34,
      text: step.number,
      fontSize: 28,
      color: COLORS.white,
      bold: true,
      align: "center",
      valign: "middle",
      font: FONTS.display,
    });
    addText(slide, {
      x: step.x - 30,
      y: 490,
      w: 120,
      h: 34,
      text: step.title,
      fontSize: 22,
      color: COLORS.ink,
      bold: true,
      align: "center",
    });
    addText(slide, {
      x: step.x - 55,
      y: 528,
      w: 170,
      h: 78,
      text: step.body,
      fontSize: 17,
      color: COLORS.slate,
      align: "center",
    });
  }

  addPill(slide, {
    x: 130,
    y: 690,
    w: 960,
    h: 48,
    text: "Hybrid local fallback keeps the prototype stable even when cloud services are partially unavailable during demo.",
    fill: solid(COLORS.navy),
    fontSize: 18,
  });

  addPhoneCard(slide, {
    x: 1340,
    y: 235,
    w: 250,
    h: 500,
    path: asset("p40_img1.jpg"),
    alt: "Home screen",
    caption: "Travel discovery home",
    backingFill: solid(COLORS.white),
    backingLine: { width: 1.2, fill: COLORS.line },
  });
  addPhoneCard(slide, {
    x: 1600,
    y: 350,
    w: 200,
    h: 410,
    path: asset("p57_img1.jpg"),
    alt: "Map screen",
    caption: "Map support",
    backingFill: solid(COLORS.white),
    backingLine: { width: 1.2, fill: COLORS.line },
  });

  addFooter(slide, "Source: Abstract, system flow, and module descriptions from the thesis report.");
}

function buildArchitecture(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid(COLORS.offWhite),
    line: { width: 0 },
    name: "slide-5-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 980,
    eyebrow: "System design",
    title: "A layered architecture keeps the app modular and explainable.",
    subtitle: "Screens, services, models, storage, and utility modules are separated to improve maintainability, testing, and presentation clarity.",
    titleSize: 48,
  });

  addShape(slide, {
    geometry: "roundRect",
    x: 100,
    y: 255,
    w: 980,
    h: 640,
    fill: solid(COLORS.white),
    line: { width: 1.5, fill: COLORS.line },
    name: "slide-5-diagram-frame",
  });
  addImage(slide, {
    path: asset("p27_img1.png"),
    alt: "System architecture diagram",
    x: 130,
    y: 300,
    w: 920,
    h: 560,
    fit: "contain",
    name: "slide-5-architecture-image",
  });

  addText(slide, {
    x: 1160,
    y: 250,
    w: 420,
    h: 44,
    text: "Key layers",
    fontSize: 30,
    color: COLORS.ink,
    font: FONTS.display,
    bold: true,
  });

  const layers = [
    { title: "Presentation layer", body: "Flutter screens, reusable widgets, cards, and navigation flows.", fill: solid(COLORS.skySoft) },
    { title: "Service layer", body: "Authentication, database, booking, local storage, and listings logic.", fill: solid(COLORS.tealSoft) },
    { title: "Data layer", body: "Firestore, Firebase Storage, Shared Preferences, and in-memory booking support.", fill: solid(COLORS.amberSoft) },
    { title: "Utility layer", body: "Validators, constants, animations, extensions, maps, and location services.", fill: solid(COLORS.roseSoft) },
  ];

  let layerY = 305;
  for (const layer of layers) {
    addShape(slide, {
      geometry: "roundRect",
      x: 1160,
      y: layerY,
      w: 650,
      h: 104,
      fill: layer.fill,
      line: { width: 0 },
    });
    addText(slide, {
      x: 1190,
      y: layerY + 16,
      w: 600,
      h: 32,
      text: layer.title,
      fontSize: 23,
      color: COLORS.ink,
      bold: true,
      font: FONTS.display,
    });
    addText(slide, {
      x: 1190,
      y: layerY + 48,
      w: 600,
      h: 42,
      text: layer.body,
      fontSize: 18,
      color: COLORS.slate,
    });
    layerY += 122;
  }

  addText(slide, {
    x: 1160,
    y: 810,
    w: 420,
    h: 34,
    text: "Technology stack",
    fontSize: 28,
    color: COLORS.ink,
    font: FONTS.display,
    bold: true,
  });

  addShape(slide, {
    x: 1160,
    y: 852,
    w: 650,
    h: 2,
    fill: solid(COLORS.line),
    line: { width: 0 },
  });

  const stackRows = [
    ["Frontend", "Flutter and Dart"],
    ["Auth", "Firebase Auth + Local fallback"],
    ["Cloud data", "Cloud Firestore"],
    ["File storage", "Firebase Storage"],
    ["Local state", "Shared Preferences + in-memory stores"],
    ["Maps", "Google Maps Flutter + Geolocator"],
  ];
  let rowY = 870;
  for (const [label, value] of stackRows) {
    addText(slide, {
      x: 1160,
      y: rowY,
      w: 170,
      h: 32,
      text: label,
      fontSize: 17,
      color: COLORS.slate,
      bold: true,
    });
    addText(slide, {
      x: 1330,
      y: rowY,
      w: 470,
      h: 32,
      text: value,
      fontSize: 17,
      color: COLORS.ink,
    });
    rowY += 31;
  }

  addFooter(slide, "Source: Proposed architecture diagram and technology stack table from Chapter 4.");
}

function buildShowcase(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid(COLORS.white),
    line: { width: 0 },
    name: "slide-6-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 880,
    eyebrow: "Implementation showcase",
    title: "The prototype delivers real end-to-end screens, not just design mockups.",
    subtitle: "Chapter 5 demonstrates complete user-facing modules for authentication, discovery, booking, confirmation, and travel support.",
    titleSize: 48,
  });

  addText(slide, {
    x: 100,
    y: 345,
    w: 420,
    h: 44,
    text: "Key modules delivered",
    fontSize: 30,
    color: COLORS.ink,
    font: FONTS.display,
    bold: true,
  });

  const moduleItems = [
    "Authentication with Firebase-backed and fallback login flow",
    "Home discovery screen with destinations, tours, and quick services",
    "Destination detail, multi-city hotel selection, and booking summary",
    "Hotel and city-to-city car booking flows",
    "Payment simulation, booking confirmation, and booking history",
    "Profile, maps, and user-created hotel / car listings",
  ];

  let moduleY = 350;
  for (const item of moduleItems) {
    addBulletItem(slide, {
      x: 100,
      y: moduleY + 60,
      w: 430,
      title: item,
      accent: moduleY % 2 === 0 ? COLORS.teal : COLORS.blue,
      titleSize: 20,
      bodyHeight: 0,
    });
    moduleY += 82;
  }

  const gallery = [
    { x: 650, path: asset("p40_img1.jpg"), alt: "Home screen", caption: "Home discovery" },
    { x: 920, path: asset("p43_img1.jpg"), alt: "Destination detail", caption: "Destination detail" },
    { x: 1190, path: asset("p44_img2.jpg"), alt: "Hotel selection", caption: "Hotel selection" },
    { x: 1460, path: asset("p52_img1.jpg"), alt: "Booking confirmation", caption: "Booking confirmation" },
  ];

  for (const item of gallery) {
    addPhoneCard(slide, {
      x: item.x,
      y: 330,
      w: 200,
      h: 420,
      path: item.path,
      alt: item.alt,
      caption: item.caption,
      backingFill: solid(COLORS.offWhite),
      backingLine: { width: 1.2, fill: COLORS.line },
    });
  }

  addText(slide, {
    x: 660,
    y: 840,
    w: 940,
    h: 60,
    text: "The UI emphasizes readable cards, strong imagery, clear actions, and smooth progression from exploration to confirmation.",
    fontSize: 22,
    color: COLORS.slate,
    align: "center",
  });

  addFooter(slide, "Source: Extracted implementation screenshots from Chapter 5 of the thesis PDF.");
}

function buildTesting(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid("FBF6ED"),
    line: { width: 0 },
    name: "slide-7-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 950,
    eyebrow: "Validation",
    title: "Testing focused on practical user flows and demo stability.",
    subtitle: "The thesis combines manual and integration testing across authentication, booking continuity, payment simulation, maps, and listings.",
    titleSize: 48,
  });

  addText(slide, {
    x: 120,
    y: 290,
    w: 260,
    h: 170,
    text: "18",
    fontSize: 160,
    color: COLORS.navy,
    font: FONTS.display,
    bold: true,
  });
  addText(slide, {
    x: 120,
    y: 440,
    w: 380,
    h: 80,
    text: "manual and integration test cases documented in the thesis",
    fontSize: 28,
    color: COLORS.ink,
    bold: true,
  });

  const statusCards = [
    { x: 120, y: 610, fill: solid(COLORS.greenSoft), color: COLORS.green, number: "16", label: "Pass" },
    { x: 305, y: 610, fill: solid(COLORS.skySoft), color: COLORS.blue, number: "1", label: "Observed" },
    { x: 490, y: 610, fill: solid(COLORS.amberSoft), color: COLORS.amber, number: "1", label: "Partial" },
  ];
  for (const card of statusCards) {
    addShape(slide, {
      geometry: "roundRect",
      x: card.x,
      y: card.y,
      w: 160,
      h: 140,
      fill: card.fill,
      line: { width: 0 },
    });
    addText(slide, {
      x: card.x,
      y: card.y + 20,
      w: 160,
      h: 54,
      text: card.number,
      fontSize: 58,
      color: card.color,
      bold: true,
      align: "center",
      font: FONTS.display,
    });
    addText(slide, {
      x: card.x,
      y: card.y + 86,
      w: 160,
      h: 34,
      text: card.label,
      fontSize: 24,
      color: COLORS.ink,
      bold: true,
      align: "center",
    });
  }

  addShape(slide, {
    geometry: "roundRect",
    x: 770,
    y: 255,
    w: 1050,
    h: 620,
    fill: solid(COLORS.white),
    line: { width: 1.5, fill: COLORS.line },
    name: "slide-7-panel",
  });

  addText(slide, {
    x: 820,
    y: 295,
    w: 320,
    h: 36,
    text: "Validated flows",
    fontSize: 28,
    color: COLORS.ink,
    font: FONTS.display,
    bold: true,
  });

  const validated = [
    "Login, signup, and routing behavior",
    "Destination details and guided booking flow",
    "Hotel selection, transport choice, and confirmation states",
    "Booking history visibility after confirmation",
    "Map loading, profile image upload, and local listings",
  ];
  let validatedY = 350;
  for (const item of validated) {
    addBulletItem(slide, {
      x: 820,
      y: validatedY,
      w: 440,
      title: item,
      accent: COLORS.teal,
      titleSize: 20,
      bodyHeight: 0,
    });
    validatedY += 74;
  }

  addText(slide, {
    x: 1330,
    y: 295,
    w: 340,
    h: 36,
    text: "Key findings",
    fontSize: 28,
    color: COLORS.ink,
    font: FONTS.display,
    bold: true,
  });

  const findings = [
    "Fallback auth remained usable when Firebase was unavailable.",
    "Search-bar interaction is present, but full feature expansion is still pending.",
    "Automated tests are still limited, so the current validation is stronger for live flows than for regression coverage.",
  ];
  let findingsY = 350;
  for (const item of findings) {
    addBulletItem(slide, {
      x: 1330,
      y: findingsY,
      w: 430,
      title: item,
      accent: findingsY === 350 ? COLORS.blue : findingsY === 464 ? COLORS.gold : COLORS.red,
      titleSize: 19,
      bodyHeight: 0,
    });
    findingsY += 114;
  }

  addPill(slide, {
    x: 820,
    y: 785,
    w: 900,
    h: 44,
    text: "Testing objective: prove the prototype is usable, coherent, and stable for final-year defense demonstration.",
    fill: solid(COLORS.navy),
    fontSize: 18,
  });

  addFooter(slide, "Source: Chapter 6 and Table 6.1 from the thesis report.");
}

function buildResults(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid(COLORS.white),
    line: { width: 0 },
    name: "slide-8-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 980,
    eyebrow: "Outcome",
    title: "The project achieved its main academic and technical goals.",
    subtitle: "Chapter 7 concludes that the prototype successfully combines travel discovery, booking support, localized content, and modular software design in one explainable system.",
    titleSize: 48,
  });

  addText(slide, {
    x: 100,
    y: 300,
    w: 1720,
    h: 92,
    text: "Most importantly, the application moves beyond isolated screens and demonstrates a complete, connected travel-planning flow.",
    fontSize: 38,
    color: COLORS.navy,
    font: FONTS.display,
    bold: true,
    align: "center",
  });

  addRule(slide, 640, 470, 2, COLORS.line, 290);
  addRule(slide, 1280, 470, 2, COLORS.line, 290);

  const contributions = [
    {
      x: 120,
      title: "Unified planning flow",
      highlight: "Discovery, hotel selection, transport, payment, and history are brought into one mobile experience.",
    },
    {
      x: 760,
      title: "Localized user value",
      highlight: "The app is aligned with Pakistan-focused travel use cases instead of copying only generic global booking patterns.",
    },
    {
      x: 1400,
      title: "Explainable architecture",
      highlight: "Screens, services, models, widgets, and utilities are separated clearly for defense, maintenance, and future reuse.",
    },
  ];

  for (const item of contributions) {
    addText(slide, {
      x: item.x,
      y: 500,
      w: 390,
      h: 42,
      text: item.title,
      fontSize: 28,
      color: COLORS.ink,
      font: FONTS.display,
      bold: true,
      align: "center",
    });
    addText(slide, {
      x: item.x,
      y: 560,
      w: 390,
      h: 140,
      text: item.highlight,
      fontSize: 22,
      color: COLORS.slate,
      align: "center",
    });
  }

  addShape(slide, {
    geometry: "roundRect",
    x: 230,
    y: 820,
    w: 1460,
    h: 92,
    fill: solid(COLORS.tealSoft),
    line: { width: 0 },
  });
  addText(slide, {
    x: 270,
    y: 846,
    w: 1380,
    h: 40,
    text: "A notable contribution is the hybrid fallback approach, which makes the prototype more resilient and presentation-ready in imperfect demo environments.",
    fontSize: 24,
    color: COLORS.navy,
    bold: true,
    align: "center",
  });

  addFooter(slide, "Source: Results, user benefits, technical contributions, and academic value from Chapter 7.");
}

function buildRoadmap(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: solid(COLORS.offWhite),
    line: { width: 0 },
    name: "slide-9-bg",
  });

  addSectionTitle(slide, {
    x: 100,
    y: 90,
    w: 980,
    eyebrow: "Next phase",
    title: "The thesis is honest about current limits and the path forward.",
    subtitle: "This is a strong academic prototype today, with a clear roadmap for maturing into a deployment-ready travel platform.",
    titleSize: 48,
  });

  addText(slide, {
    x: 140,
    y: 355,
    w: 420,
    h: 40,
    text: "Current limitations",
    fontSize: 30,
    color: COLORS.red,
    font: FONTS.display,
    bold: true,
  });
  addShape(slide, {
    geometry: "roundRect",
    x: 100,
    y: 410,
    w: 720,
    h: 430,
    fill: solid(COLORS.white),
    line: { width: 1.5, fill: COLORS.line },
  });

  const limitations = [
    "Payments are simulated rather than connected to a real payment gateway.",
    "Automated testing coverage is still limited.",
    "Some booking states rely on session-level persistence instead of full cloud sync.",
    "User-added hotel and car listings are stored locally, not fully server-side.",
  ];
  let limitY = 450;
  for (const item of limitations) {
    addBulletItem(slide, {
      x: 140,
      y: limitY,
      w: 620,
      title: item,
      accent: COLORS.red,
      titleSize: 21,
      bodyHeight: 0,
    });
    limitY += 88;
  }

  addText(slide, {
    x: 980,
    y: 355,
    w: 420,
    h: 40,
    text: "Future enhancements",
    fontSize: 30,
    color: COLORS.green,
    font: FONTS.display,
    bold: true,
  });
  addShape(slide, {
    geometry: "roundRect",
    x: 940,
    y: 410,
    w: 830,
    h: 430,
    fill: solid(COLORS.white),
    line: { width: 1.5, fill: COLORS.line },
  });

  const enhancements = [
    "Real payment gateway integration",
    "Ratings, reviews, and recommendation engine",
    "Improved search and personalized user experience",
    "Cloud storage for every booking category",
    "Admin dashboard and push notifications",
    "Security hardening and broader automated tests",
  ];
  let enhanceY = 450;
  for (const item of enhancements) {
    addBulletItem(slide, {
      x: 980,
      y: enhanceY,
      w: 720,
      title: item,
      accent: COLORS.green,
      titleSize: 21,
      bodyHeight: 0,
    });
    enhanceY += 64;
  }

  addShape(slide, {
    x: 360,
    y: 900,
    w: 1180,
    h: 6,
    fill: solid(COLORS.line),
    line: { width: 0 },
  });
  addPill(slide, {
    x: 300,
    y: 866,
    w: 210,
    h: 44,
    text: "Current prototype",
    fill: solid(COLORS.navy),
    fontSize: 18,
  });
  addPill(slide, {
    x: 1360,
    y: 866,
    w: 250,
    h: 44,
    text: "Deployment-ready target",
    fill: solid(COLORS.green),
    fontSize: 18,
  });
  addText(slide, {
    x: 770,
    y: 850,
    w: 320,
    h: 34,
    text: "Prototype  ->  hardening  ->  product",
    fontSize: 22,
    color: COLORS.slate,
    align: "center",
    bold: true,
  });

  addFooter(slide, "Source: Limitations, deployment considerations, and future enhancements from Chapters 7 and 8.");
}

function buildClosing(slide) {
  addShape(slide, {
    x: 0,
    y: 0,
    w: SLIDE_WIDTH,
    h: SLIDE_HEIGHT,
    fill: gradient(20, [
      { offset: 0, color: COLORS.navyDeep },
      { offset: 65000, color: COLORS.navy },
      { offset: 100000, color: COLORS.teal },
    ]),
    line: { width: 0 },
    name: "slide-10-bg",
  });

  addPill(slide, {
    x: 100,
    y: 96,
    w: 210,
    h: 40,
    text: "Conclusion",
    fill: solid(COLORS.gold),
    color: COLORS.navyDeep,
    fontSize: 18,
  });

  addText(slide, {
    x: 100,
    y: 180,
    w: 930,
    h: 240,
    text: "A modular Flutter application can simplify domestic tourism planning in Pakistan.",
    fontSize: 52,
    color: COLORS.white,
    font: FONTS.display,
    bold: true,
    name: "slide-10-title",
  });

  addText(slide, {
    x: 100,
    y: 432,
    w: 860,
    h: 62,
    text: "This project proves the concept through connected user flows, clear software structure, and a realistic roadmap for future expansion.",
    fontSize: 24,
    color: "DCEAF7",
    name: "slide-10-subtitle",
  });

  const takeaways = [
    "1. It solves a real local problem with an integrated mobile journey.",
    "2. It demonstrates sound software engineering through modular design.",
    "3. It leaves a credible path from prototype to product.",
  ];
  let takeawayY = 575;
  for (const item of takeaways) {
    addText(slide, {
      x: 100,
      y: takeawayY,
      w: 780,
      h: 40,
      text: item,
      fontSize: 24,
      color: COLORS.white,
      bold: true,
    });
    takeawayY += 66;
  }

  addText(slide, {
    x: 100,
    y: 860,
    w: 860,
    h: 80,
    text: "Shahid Umer | Musharaf | Supervised by Dr. Amjad Khan\nAbasyn University Islamabad Campus",
    fontSize: 22,
    color: "DCEAF7",
  });

  addShape(slide, {
    geometry: "roundRect",
    x: 1180,
    y: 150,
    w: 620,
    h: 760,
    fill: solid("113859"),
    line: { width: 0 },
  });

  addPhoneCard(slide, {
    x: 1260,
    y: 210,
    w: 210,
    h: 430,
    path: asset("p40_img1.jpg"),
    alt: "Home screen",
    caption: "Explore and discover",
    backingFill: solid(COLORS.white),
    backingLine: { width: 0 },
  });
  addPhoneCard(slide, {
    x: 1520,
    y: 320,
    w: 190,
    h: 390,
    path: asset("p57_img1.jpg"),
    alt: "Map screen",
    caption: "Navigate with maps",
    backingFill: solid(COLORS.white),
    backingLine: { width: 0 },
  });

  addText(slide, {
    x: 1240,
    y: 800,
    w: 500,
    h: 70,
    text: "Thank you\nQuestions?",
    fontSize: 42,
    color: COLORS.white,
    font: FONTS.display,
    bold: true,
    align: "center",
    valign: "middle",
  });
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
  if (blobLike && blobLike.data) {
    return Buffer.from(blobLike.data);
  }
  if (blobLike && typeof blobLike.arrayBuffer === "function") {
    return Buffer.from(await blobLike.arrayBuffer());
  }
  if (blobLike && typeof blobLike.bytes === "function") {
    return Buffer.from(await blobLike.bytes());
  }
  throw new Error("Unsupported blob export payload.");
}

async function exportDeck(presentation) {
  await fs.mkdir(OUTPUT_DIR, { recursive: true });
  await fs.mkdir(PREVIEW_DIR, { recursive: true });
  await fs.mkdir(LAYOUT_DIR, { recursive: true });

  const pptxBlob = await PresentationFile.exportPptx(presentation);
  await fs.writeFile(
    path.join(OUTPUT_DIR, "output.pptx"),
    await blobToBuffer(pptxBlob),
  );

  const slides = presentation.slides.items;
  for (let index = 0; index < slides.length; index += 1) {
    const slide = slides[index];
    const number = String(index + 1).padStart(2, "0");

    const pngBlob = await presentation.export({ format: "png", slide });
    await fs.writeFile(
      path.join(PREVIEW_DIR, `slide-${number}.png`),
      await blobToBuffer(pngBlob),
    );

    const layoutBlob = await presentation.export({ format: "layout", slide });
    await fs.writeFile(
      path.join(LAYOUT_DIR, `slide-${number}.layout.json`),
      await blobToBuffer(layoutBlob),
    );
  }
}

async function main() {
  await fs.mkdir(SCRATCH_DIR, { recursive: true });
  const presentation = buildPresentation();
  await hydrateLocalImages(presentation);
  await exportDeck(presentation);
  console.log(JSON.stringify({
    workspace: WORKSPACE,
    pptx: path.join(OUTPUT_DIR, "output.pptx"),
    previews: PREVIEW_DIR,
    layouts: LAYOUT_DIR,
    slides: presentation.slides.items.length,
  }, null, 2));
}

await main();
