from __future__ import annotations

import shutil
import zipfile
from copy import deepcopy
from pathlib import Path

from lxml import etree


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DOCX = ROOT / "docs" / "Shahid_Source_Copy.docx"
REFERENCE_DOCX = ROOT / "docs" / "Expedition_Reference_Copy.docx"
OUTPUT_DOCX = ROOT / "docs" / "Shahid_Umer_And_Musharaf_Tours_Travel_Thesis_ExpeditionExact_v2.docx"

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
CT_NS = "http://schemas.openxmlformats.org/package/2006/content-types"
REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
NS = {"w": W_NS, "r": R_NS}


def paragraph_text(p) -> str:
    texts = p.xpath(".//w:t/text()", namespaces=NS)
    return " ".join(" ".join(texts).split()).strip()


def find_chapter1_index(body) -> int:
    for idx, child in enumerate(body):
        if child.tag.endswith("}p") and "Chapter 1 Introduction" in paragraph_text(child):
            return idx
    raise ValueError("Chapter 1 Introduction not found")


def ensure_content_type(root, part_name: str, content_type: str):
    existing = root.xpath(f'./ct:Override[@PartName="{part_name}"]', namespaces={"ct": CT_NS})
    if existing:
        existing[0].set("ContentType", content_type)
        return
    override = etree.Element(f"{{{CT_NS}}}Override")
    override.set("PartName", part_name)
    override.set("ContentType", content_type)
    root.append(override)


def add_relationship(root, rid: str, target: str, rel_type: str):
    rel = etree.Element(f"{{{REL_NS}}}Relationship")
    rel.set("Id", rid)
    rel.set("Type", rel_type)
    rel.set("Target", target)
    root.append(rel)


def main():
    shutil.copyfile(SOURCE_DOCX, OUTPUT_DOCX)

    with zipfile.ZipFile(REFERENCE_DOCX, "r") as ref_zip:
        ref_document = etree.fromstring(ref_zip.read("word/document.xml"))
        ref_body = ref_document.find(f"{{{W_NS}}}body")
        ref_front_end = find_chapter1_index(ref_body)
        ref_front_children = [deepcopy(child) for child in list(ref_body)[:ref_front_end]]

        footer_roman = ref_zip.read("word/footer1.xml")
        footer_arabic = ref_zip.read("word/footer2.xml")
        styles_xml = ref_zip.read("word/styles.xml")
        theme_xml = ref_zip.read("word/theme/theme1.xml")
        font_table_xml = ref_zip.read("word/fontTable.xml")

    with zipfile.ZipFile(OUTPUT_DOCX, "r") as out_zip:
        file_map = {name: out_zip.read(name) for name in out_zip.namelist()}

    out_document = etree.fromstring(file_map["word/document.xml"])
    out_body = out_document.find(f"{{{W_NS}}}body")
    out_front_end = find_chapter1_index(out_body)

    for child in list(out_body)[:out_front_end]:
        out_body.remove(child)

    footer_map = {"rId9": "rId900", "rId11": "rId901"}
    for idx, child in enumerate(ref_front_children):
        for ref in child.xpath(".//w:footerReference", namespaces=NS):
            rid = ref.get(f"{{{R_NS}}}id")
            if rid in footer_map:
                ref.set(f"{{{R_NS}}}id", footer_map[rid])
        out_body.insert(idx, child)

    file_map["word/document.xml"] = etree.tostring(out_document, xml_declaration=True, encoding="UTF-8", standalone="yes")

    rels_root = etree.fromstring(file_map["word/_rels/document.xml.rels"])
    # Remove any previous custom rel ids if rerun.
    for rel in rels_root.findall(f"{{{REL_NS}}}Relationship"):
        if rel.get("Id") in {"rId900", "rId901"}:
            rels_root.remove(rel)
    add_relationship(
        rels_root,
        "rId900",
        "footer900.xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer",
    )
    add_relationship(
        rels_root,
        "rId901",
        "footer901.xml",
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer",
    )
    file_map["word/_rels/document.xml.rels"] = etree.tostring(rels_root, xml_declaration=True, encoding="UTF-8", standalone="yes")

    content_types = etree.fromstring(file_map["[Content_Types].xml"])
    ensure_content_type(content_types, "/word/footer900.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml")
    ensure_content_type(content_types, "/word/footer901.xml", "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml")
    file_map["[Content_Types].xml"] = etree.tostring(content_types, xml_declaration=True, encoding="UTF-8", standalone="yes")

    file_map["word/footer900.xml"] = footer_roman
    file_map["word/footer901.xml"] = footer_arabic
    file_map["word/styles.xml"] = styles_xml
    file_map["word/theme/theme1.xml"] = theme_xml
    file_map["word/fontTable.xml"] = font_table_xml

    with zipfile.ZipFile(OUTPUT_DOCX, "w") as out_zip:
        for name, data in file_map.items():
            out_zip.writestr(name, data)

    print(f"Created: {OUTPUT_DOCX}")


if __name__ == "__main__":
    main()
