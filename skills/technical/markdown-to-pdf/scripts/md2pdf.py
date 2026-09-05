#!/usr/bin/env python3
"""
Markdown to PDF converter with dark mode support.
Uses pandoc with WeasyPrint for high-quality PDF output.
"""

import argparse
import subprocess
import sys
from pathlib import Path


def get_skill_dir() -> Path:
    """Get the skill directory containing assets."""
    return Path(__file__).parent.parent


def convert_md_to_pdf(
    input_file: str,
    output_file: str | None = None,
    theme: str = 'dark',
    css_file: str | None = None,
) -> Path:
    """
    Convert a markdown file to PDF.

    Args:
        input_file: Path to the input markdown file
        output_file: Path for the output PDF (defaults to input with .pdf extension)
        theme: Theme to use - 'dark', 'light', or 'print' (default: 'dark')
        css_file: Custom CSS file path (overrides theme setting)

    Returns:
        Path to the generated PDF file
    """
    input_path = Path(input_file).expanduser().resolve()

    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    if output_file:
        output_path = Path(output_file).expanduser().resolve()
    else:
        output_path = input_path.with_suffix('.pdf')

    # Determine CSS file
    if css_file:
        css_path = Path(css_file).expanduser().resolve()
    else:
        skill_dir = get_skill_dir()
        css_map = {
            'dark': 'dark-mode.css',
            'light': 'light-mode.css',
            'print': 'print-mode.css',
        }
        css_name = css_map.get(theme, 'dark-mode.css')
        css_path = skill_dir / 'assets' / css_name

    if not css_path.exists():
        raise FileNotFoundError(f"CSS file not found: {css_path}")

    # Build pandoc command
    cmd = [
        'pandoc',
        str(input_path),
        '-o', str(output_path),
        '--pdf-engine=weasyprint',
        f'--css={css_path}',
        '--standalone',
        '--from=markdown+emoji',
        '--metadata', 'title=',  # Suppress auto-title
    ]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
        )
        if result.stderr:
            # WeasyPrint often outputs warnings, only show if verbose
            pass
        return output_path
    except subprocess.CalledProcessError as e:
        print(f"Error converting file: {e.stderr}", file=sys.stderr)
        raise
    except FileNotFoundError:
        print("Error: pandoc or weasyprint not found. Install with:", file=sys.stderr)
        print("  sudo pacman -S pandoc python-weasyprint", file=sys.stderr)
        raise


def main():
    parser = argparse.ArgumentParser(
        description='Convert Markdown to PDF with theme support',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s document.md                    # Dark mode PDF (default)
  %(prog)s document.md -o output.pdf      # Specify output file
  %(prog)s document.md --light            # Light mode PDF (Catppuccin Latte)
  %(prog)s document.md --print            # Printer-friendly B&W PDF
  %(prog)s document.md --css custom.css   # Custom CSS
        """,
    )

    parser.add_argument('input', help='Input markdown file')
    parser.add_argument('-o', '--output', help='Output PDF file (default: input.pdf)')
    theme_group = parser.add_mutually_exclusive_group()
    theme_group.add_argument(
        '--light',
        action='store_true',
        help='Use light mode (Catppuccin Latte colors)',
    )
    theme_group.add_argument(
        '--print',
        action='store_true',
        dest='print_mode',
        help='Use printer-friendly black & white mode',
    )
    parser.add_argument(
        '--css',
        help='Path to custom CSS file (overrides theme flags)',
    )
    parser.add_argument(
        '--print-to',
        metavar='PRINTER',
        help='Send PDF to a CUPS printer after conversion (e.g. "brother")',
    )

    args = parser.parse_args()

    # Determine theme
    if args.print_mode:
        theme = 'print'
    elif args.light:
        theme = 'light'
    else:
        theme = 'dark'

    try:
        output_path = convert_md_to_pdf(
            input_file=args.input,
            output_file=args.output,
            theme=theme,
            css_file=args.css,
        )
        print(f"Created: file://{output_path}")

        if args.print_to:
            lp_result = subprocess.run(
                ['lp', '-d', args.print_to, str(output_path)],
                capture_output=True,
                text=True,
                check=True,
            )
            print(f"Sent to printer: {lp_result.stdout.strip()}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
