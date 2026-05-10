import fs from "node:fs/promises";
import path from "node:path";

const { PresentationFile } = await import(
  "file:///C:/Users/HP/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs"
);

const SOURCE_PPTX = "C:/Users/HP/Desktop/final year.pptx";
const OUTPUT_PPTX = "C:/Users/HP/tours_and_travel_app/tmp/final-year-usecase-updated.pptx";
const PREVIEW_PNG = "C:/Users/HP/tours_and_travel_app/tmp/final-year-usecase-updated-slide08.png";

const COLORS = {
  white: "FFFFFF",
  green: "1F7A3E",
  dark: "1F2937",
  ink: "1E293B",
  slate: "64748B",
  paleBlue: "EAF1FB",
  lightGray: "D8DEE6",
};

function solid(color) {
  return { type: "solid", color };
}

function addShape(slide, opts) {
  return slide.shapes.add({
    geometry: opts.geometry || "rect",
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
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    rotation: opts.rotation || 0,
    fill: opts.fill || { type: "none" },
    line: opts.line || { width: 0 },
  });
  shape.text.style = {
    fontSize: opts.fontSize || 12,
    color: opts.color || COLORS.ink,
    typeface: "Calibri",
    bold: Boolean(opts.bold),
    italic: Boolean(opts.italic),
    alignment: opts.align || "left",
    verticalAlignment: opts.valign || "middle",
    wrap: opts.wrap !== false,
    insets: opts.insets || { left: 4, right: 4, top: 2, bottom: 2 },
  };
  shape.text = opts.text;
  return shape;
}

function addLine(slide, opts) {
  const dx = opts.x2 - opts.x1;
  const dy = opts.y2 - opts.y1;
  const length = Math.hypot(dx, dy);
  const rotation = (Math.atan2(dy, dx) * 180) / Math.PI;
  const thickness = opts.thickness || 1.5;
  const color = opts.color || COLORS.dark;

  if (!opts.dashed) {
    addShape(slide, {
      x: (opts.x1 + opts.x2) / 2 - length / 2,
      y: (opts.y1 + opts.y2) / 2 - thickness / 2,
      w: length,
      h: thickness,
      rotation,
      fill: solid(color),
      line: { width: 0 },
    });
    return;
  }

  const dashLength = opts.dashLength || 9;
  const gapLength = opts.gapLength || 5;
  const ux = dx / length;
  const uy = dy / length;
  let covered = 0;

  while (covered < length) {
    const segment = Math.min(dashLength, length - covered);
    const mid = covered + segment / 2;
    const cx = opts.x1 + ux * mid;
    const cy = opts.y1 + uy * mid;
    addShape(slide, {
      x: cx - segment / 2,
      y: cy - thickness / 2,
      w: segment,
      h: thickness,
      rotation,
      fill: solid(color),
      line: { width: 0 },
    });
    covered += dashLength + gapLength;
  }
}

function addActor(slide, opts) {
  const x = opts.x;
  const y = opts.y;
  addShape(slide, {
    geometry: "ellipse",
    x: x + 16,
    y,
    w: 14,
    h: 14,
    fill: solid(COLORS.white),
    line: { width: 1.2, fill: COLORS.dark },
  });
  addLine(slide, { x1: x + 23, y1: y + 14, x2: x + 23, y2: y + 40 });
  addLine(slide, { x1: x + 10, y1: y + 25, x2: x + 36, y2: y + 25 });
  addLine(slide, { x1: x + 23, y1: y + 40, x2: x + 10, y2: y + 56 });
  addLine(slide, { x1: x + 23, y1: y + 40, x2: x + 36, y2: y + 56 });
  addText(slide, {
    x: x - 8,
    y: y + 60,
    w: 64,
    h: 18,
    text: opts.label,
    fontSize: 9.5,
    color: COLORS.dark,
    bold: true,
    align: "center",
  });
  return { x, y, cx: x + 23, cy: y + 25 };
}

function addUseCase(slide, opts) {
  addText(slide, {
    geometry: "ellipse",
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    text: opts.text,
    fontSize: opts.fontSize || 8.8,
    color: COLORS.dark,
    bold: Boolean(opts.bold),
    align: "center",
    valign: "middle",
    fill: solid(COLORS.white),
    line: { width: 1.2, fill: COLORS.dark },
    insets: { left: 6, right: 6, top: 2, bottom: 2 },
  });
  return {
    x: opts.x,
    y: opts.y,
    w: opts.w,
    h: opts.h,
    cx: opts.x + opts.w / 2,
    cy: opts.y + opts.h / 2,
  };
}

function leftPoint(box) {
  return { x: box.x, y: box.cy };
}

function rightPoint(box) {
  return { x: box.x + box.w, y: box.cy };
}

function topPoint(box) {
  return { x: box.cx, y: box.y };
}

function bottomPoint(box) {
  return { x: box.cx, y: box.y + box.h };
}

function center(box) {
  return { x: box.cx, y: box.cy };
}

function addInclude(slide, fromPoint, toPoint, label) {
  addLine(slide, {
    x1: fromPoint.x,
    y1: fromPoint.y,
    x2: toPoint.x,
    y2: toPoint.y,
    dashed: true,
    thickness: 1.2,
    color: COLORS.dark,
  });
  if (label) {
    addText(slide, {
      x: label.x,
      y: label.y,
      w: 64,
      h: 14,
      text: label.text,
      fontSize: 7.5,
      color: COLORS.slate,
      italic: true,
      align: "center",
    });
  }
}

async function toBuffer(blobLike) {
  if (blobLike && blobLike.data) return Buffer.from(blobLike.data);
  if (blobLike && typeof blobLike.arrayBuffer === "function") {
    return Buffer.from(await blobLike.arrayBuffer());
  }
  throw new Error("Unsupported blob payload");
}

function rebuildUseCaseSlide(slide) {
  // Cover the old diagram area while preserving slide title and footer.
  addShape(slide, {
    x: 78,
    y: 86,
    w: 820,
    h: 394,
    fill: solid(COLORS.white),
    line: { width: 0 },
  });

  addText(slide, {
    x: 345,
    y: 103,
    w: 270,
    h: 18,
    text: "Use Case Diagram",
    fontSize: 11,
    color: COLORS.dark,
    bold: true,
    align: "center",
  });
  addLine(slide, {
    x1: 188,
    y1: 122,
    x2: 790,
    y2: 122,
    thickness: 1.1,
    color: COLORS.dark,
  });

  addShape(slide, {
    x: 172,
    y: 138,
    w: 618,
    h: 316,
    fill: solid(COLORS.white),
    line: { width: 1.2, fill: COLORS.dark },
  });
  addText(slide, {
    x: 307,
    y: 147,
    w: 350,
    h: 18,
    text: "Tours & Travel Mobile Application",
    fontSize: 9.5,
    color: COLORS.dark,
    bold: true,
    align: "center",
  });

  const vendor = addActor(slide, { x: 66, y: 185, label: "VENDOR" });
  const admin = addActor(slide, { x: 80, y: 360, label: "ADMIN" });
  const traveler = addActor(slide, { x: 806, y: 205, label: "TRAVELER" });

  const addHotel = addUseCase(slide, {
    x: 232,
    y: 177,
    w: 176,
    h: 30,
    text: "Add Hotel Listing",
  });
  const addCar = addUseCase(slide, {
    x: 232,
    y: 216,
    w: 176,
    h: 30,
    text: "Add Car Listing",
  });
  const manageListings = addUseCase(slide, {
    x: 232,
    y: 255,
    w: 176,
    h: 30,
    text: "Manage Listings",
  });
  const updatePrices = addUseCase(slide, {
    x: 222,
    y: 294,
    w: 196,
    h: 36,
    text: "Update Prices / Availability",
  });
  const vendorProfile = addUseCase(slide, {
    x: 232,
    y: 340,
    w: 176,
    h: 30,
    text: "Manage Profile",
  });

  const register = addUseCase(slide, {
    x: 548,
    y: 170,
    w: 182,
    h: 28,
    text: "Register Account",
  });
  const login = addUseCase(slide, {
    x: 548,
    y: 205,
    w: 182,
    h: 28,
    text: "Login",
  });
  const browse = addUseCase(slide, {
    x: 548,
    y: 240,
    w: 182,
    h: 28,
    text: "Browse Destinations",
  });
  const details = addUseCase(slide, {
    x: 548,
    y: 275,
    w: 182,
    h: 28,
    text: "View Destination Info",
  });
  const book = addUseCase(slide, {
    x: 536,
    y: 310,
    w: 206,
    h: 34,
    text: "Book Tour / Hotel / Car",
  });
  const map = addUseCase(slide, {
    x: 548,
    y: 352,
    w: 182,
    h: 28,
    text: "View Map",
  });
  const history = addUseCase(slide, {
    x: 548,
    y: 387,
    w: 182,
    h: 28,
    text: "View Booking History",
  });
  const payment = addUseCase(slide, {
    x: 548,
    y: 422,
    w: 182,
    h: 28,
    text: "Process Payment",
  });

  const manageUsers = addUseCase(slide, {
    x: 235,
    y: 385,
    w: 176,
    h: 30,
    text: "Manage Users / Bookings",
  });
  const manageErrors = addUseCase(slide, {
    x: 235,
    y: 421,
    w: 176,
    h: 30,
    text: "Manage Errors",
  });

  // Simple actor associations only, to keep the diagram clean and readable.
  addLine(slide, { x1: vendor.cx, y1: vendor.cy, x2: leftPoint(addHotel).x, y2: leftPoint(addHotel).y });
  addLine(slide, { x1: vendor.cx, y1: vendor.cy, x2: leftPoint(addCar).x, y2: leftPoint(addCar).y });
  addLine(slide, { x1: vendor.cx, y1: vendor.cy, x2: leftPoint(manageListings).x, y2: leftPoint(manageListings).y });
  addLine(slide, { x1: vendor.cx, y1: vendor.cy, x2: leftPoint(updatePrices).x, y2: leftPoint(updatePrices).y });
  addLine(slide, { x1: vendor.cx, y1: vendor.cy, x2: leftPoint(vendorProfile).x, y2: leftPoint(vendorProfile).y });

  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(register).x, y2: rightPoint(register).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(login).x, y2: rightPoint(login).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(browse).x, y2: rightPoint(browse).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(details).x, y2: rightPoint(details).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(book).x, y2: rightPoint(book).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(map).x, y2: rightPoint(map).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(history).x, y2: rightPoint(history).y });
  addLine(slide, { x1: traveler.cx, y1: traveler.cy, x2: rightPoint(payment).x, y2: rightPoint(payment).y });

  addLine(slide, { x1: admin.cx, y1: admin.cy, x2: leftPoint(manageUsers).x, y2: leftPoint(manageUsers).y });
  addLine(slide, { x1: admin.cx, y1: admin.cy, x2: leftPoint(manageErrors).x, y2: leftPoint(manageErrors).y });

  addText(slide, {
    x: 356,
    y: 462,
    w: 180,
    h: 16,
    text: "Use Case Diagram",
    fontSize: 9.5,
    color: COLORS.slate,
    italic: true,
    align: "center",
  });
}

async function main() {
  await fs.mkdir(path.dirname(OUTPUT_PPTX), { recursive: true });
  const bytes = await fs.readFile(SOURCE_PPTX);
  const presentation = await PresentationFile.importPptx(bytes);
  const slide = presentation.slides.items[7];

  rebuildUseCaseSlide(slide);

  const pptxBlob = await PresentationFile.exportPptx(presentation);
  await fs.writeFile(OUTPUT_PPTX, await toBuffer(pptxBlob));

  const pngBlob = await presentation.export({ format: "png", slide });
  await fs.writeFile(PREVIEW_PNG, await toBuffer(pngBlob));

  console.log(
    JSON.stringify(
      {
        output: OUTPUT_PPTX,
        preview: PREVIEW_PNG,
        slides: presentation.slides.items.length,
      },
      null,
      2,
    ),
  );
}

await main();
