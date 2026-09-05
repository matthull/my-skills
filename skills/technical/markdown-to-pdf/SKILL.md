---
name: markdown-to-pdf
description: Convert markdown files to beautifully formatted PDFs with dark mode support. This skill should be used when users want to export markdown documents to PDF format, especially when they need dark themes, proper ASCII diagram rendering, or professional formatting for tables with icons.
---

# Markdown to PDF Skill

Convert markdown documents to high-quality PDFs with dark mode support, proper ASCII diagram rendering, and professional table formatting.

## Features

- **Dark mode theme** (default) with Catppuccin Mocha colors
- **Light mode theme** with Catppuccin Latte colors
- **Print mode theme** - printer-friendly black & white, high contrast
- **ASCII diagram support** with proper monospace font alignment
- **Unicode icon support** (checkmarks, emojis, etc.)
- **Professional table formatting** with alternating row colors
- **Code block syntax highlighting** optimized for readability

## Usage

### Basic Conversion (Dark Mode)

```bash
python ~/.claude/skills/markdown-to-pdf/scripts/md2pdf.py document.md
```

### Specify Output File

```bash
python ~/.claude/skills/markdown-to-pdf/scripts/md2pdf.py document.md -o output.pdf
```

### Light Mode

```bash
python ~/.claude/skills/markdown-to-pdf/scripts/md2pdf.py document.md --light
```

### Print Mode (Black & White)

```bash
python ~/.claude/skills/markdown-to-pdf/scripts/md2pdf.py document.md --print
```

Best for physical printing - uses only black, white, and grays for maximum legibility and toner efficiency.

### Custom CSS

```bash
python ~/.claude/skills/markdown-to-pdf/scripts/md2pdf.py document.md --css custom.css
```

### Send to Printer

Add `--print-to` to send the PDF directly to a printer after conversion:

```bash
python ~/.claude/skills/markdown-to-pdf/scripts/md2pdf.py document.md --print --print-to brother
```

This converts to PDF (using print-friendly theme) and sends it straight to the printer via `lp`. The `--print-to` flag takes a CUPS printer name.

**Printing an existing PDF** (no conversion needed):

```bash
lp -d brother document.pdf
```

### Available Printers

The system has CUPS configured with:
- **brother** — Brother printer (default)

To check printer status: `lpstat -p`

## Output

The script outputs `file://` URLs for the created PDFs. **Always include these URLs in your response to the user** so they can easily open the files in their browser or PDF viewer.

## Requirements

The following packages must be installed:

```bash
# Arch Linux
sudo pacman -S pandoc python-weasyprint

# Ubuntu/Debian
sudo apt install pandoc weasyprint

# macOS
brew install pandoc
pip install weasyprint
```

## Bundled Assets

- `assets/dark-mode.css` - Catppuccin Mocha dark theme
- `assets/light-mode.css` - Catppuccin Latte light theme
- `assets/print-mode.css` - Printer-friendly black & white theme

## Technical Notes

### ASCII Diagram Rendering

The CSS is optimized for ASCII art with:
- DejaVu Sans Mono as the primary monospace font
- Zero letter-spacing to ensure box characters align
- Proper line-height (1.3) for connected box drawings
- `white-space: pre` to preserve exact spacing

### Color Printing

The stylesheets include `print-color-adjust: exact` to ensure background colors render correctly when printing to PDF.

### Page Breaks

To force a page break, use:

```html
<div class="page-break"></div>
```

## Troubleshooting

### Missing fonts

Install DejaVu fonts for best ASCII diagram rendering:

```bash
# Arch Linux
sudo pacman -S ttf-dejavu

# Ubuntu/Debian
sudo apt install fonts-dejavu
```

### Icons not rendering

Ensure Noto Color Emoji or similar emoji font is installed:

```bash
# Arch Linux
sudo pacman -S noto-fonts-emoji
```
