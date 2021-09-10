import os
import re
import shutil
import tempfile


def main() -> None:
    entries_file = "vocabulary.txt"
    vocab_template = "vocabulary-template.lyx"
    vocab_lyx = "vocabulary.lyx"
    source_file = "Na-Usdi-Agigage-Jitaga-Agisi.txt"
    terms: set[str] = extract_terms(source_file)
    entries: dict[str] = dict()
    if not os.path.isfile(entries_file):
        with open(entries_file, "w"):
            pass
    with open(entries_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith("#"):
                continue
            parts: list[str] = line.split("|")
            if len(parts) != 4:
                print("Bad vocabulary entry: " + line)
                continue
            entry_word: str = parts[0].strip().upper()
            entry_pronounce: str = parts[1].strip()
            entry_breakdown: str = parts[2].strip()
            entry_definition: str = parts[3].strip()
            if not entry_definition:
                continue  # Ignore entries without a definition
            entries[entry_word] = (entry_word, entry_pronounce, entry_breakdown, entry_definition)
    for term in terms:
        if term in entries:
            continue
        entries[term] = (term, "", "", "")

    shutil.copy(entries_file, f"{entries_file}.bak")
    os.remove(entries_file)
    with open(entries_file, "w") as w:
        w.write(f"Syllabary|Pronounce|Breakdown|Definition")
        w.write("\n")
        for term in sorted(list(entries)):
            if not re.match("[Ꭰ-Ᏼ]+", term):
                continue
            e: tuple = entries[term]
            w.write(f"{e[0]}|{e[1]}|{e[2]}|{e[3]}")
            w.write("\n")

    with open(vocab_lyx, "w") as w:
        with open(vocab_template, "r") as r:
            for line in r:
                w.write(line)
                w.write("\n")
                if line.startswith("\\begin_body"):
                    break
        for key in sorted(list(entries)):
            if not re.match("[Ꭰ-Ᏼ]+", key):
                continue
            term: str
            pronounce: str
            break_down: str
            definition: str
            (term, pronounce, break_down, definition) = entries[key]
            if not definition.strip():
                continue
            w.write(glossary_entry(term, pronounce, break_down, definition))
            w.write("\n")
        w.write("\n")
        w.write("\\end_body")
        w.write("\n")
        w.write("\\end_document")
        w.write("\n")


def glossary_entry(term: str, pronounce: str, break_down: str, definition: str) -> str:
    term = term.replace(" ", "\\begin_inset space ~\n\\end_inset\n\n")
    entry: str = (f"\n"
                  f"\\begin_layout Description\n"
                  f"{term} ")
    if definition[-1] not in ".,?!":
        definition += "."
    if pronounce:
        entry += f"[{pronounce}] "
    entry += (f"\\begin_inset Quotes eld\n"
              f"\\end_inset\n"
              f"\n"
              f"{definition}\n"
              f"\\begin_inset Quotes erd\n"
              f"\\end_inset\n"
              f"\n")
    if break_down:
        entry += f" ({break_down})"
    entry += (f"\n"
              f"\\end_layout\n"
              f"\n")
    return entry


def extract_terms(file: str) -> set[str]:
    terms: set[str] = set()
    with open(file, "r") as f:
        for line in f:
            for item in re.finditer("[Ꭰ-Ᏼ]+", line.upper()):
                chr_text: str = item.group()
                terms.add(chr_text)

    return terms


if __name__ == "__main__":
    os.chdir(os.path.dirname(__file__))
    main()
