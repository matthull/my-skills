---
name: resume-workflow
description: Generate and manage resumes in JSON Resume format using the resumed CLI. Use when updating resume content, rendering to HTML or PDF, or trying different themes.
---

# Resume Workflow

Generate and manage resumes using JSON Resume format.

## When to Use

Use this skill when the user wants to:
- Update resume content
- Generate resume in different formats (HTML, PDF)
- Try different themes
- Preview resume changes

## Tooling

**JSON Resume** — Resume data stored as structured JSON, rendered with themes.

- CLI: `resumed` (installed globally)
- Data file: `resume.json` in project root
- Schema: JSON Resume v1.0.0

## Files

```
<resume-repo>/
├── resume.json      # Source data (edit this)
├── resume.html      # Rendered HTML (generated)
├── resume.pdf       # PDF export (generated)
├── themes/jsonresume-theme-even-ats/   # The theme. Composes over jsonresume-theme-even.
└── scripts/verify-resume.mjs           # Extraction check, runs on every build
```

Run `npm install` once — the local theme needs `jsonresume-theme-even` in
`node_modules`.

## Commands

### Build Script (preferred)
Use the build script for one-command generation:
```bash
./scripts/build-resume.sh <json-file> [theme]
```

Examples:
```bash
./scripts/build-resume.sh resume.json
./scripts/build-resume.sh research/opportunities/example-role-resume.json
./scripts/build-resume.sh resume.json jsonresume-theme-even
```

The script:
- Renders HTML and exports PDF
- Derives output filenames from input (foo.json → foo.html, foo.pdf)
- Outputs clickable file:// URLs
- **Runs `scripts/verify-resume.mjs` and fails the build if the PDF's text layer is broken**
- Default theme: `themes/jsonresume-theme-even-ats/` (local)

**Do not bypass the build script to skip the verification.** It is the only thing
standing between a layout change and a resume that scrambles inside an ATS — a
failure mode that is invisible in the rendered PDF. If it fails, fix the cause.

### Manual Commands
If needed individually:

```bash
THEME=$PWD/themes/jsonresume-theme-even-ats/index.js
resumed render --theme "$THEME" -o resume.html resume.json
resumed export --theme "$THEME" -o resume.pdf resume.json
node scripts/verify-resume.mjs resume.json
```

`resumed` resolves themes by bare dynamic import from its own global install
location, so a local theme must be passed as an **absolute path**. It reports every
theme import failure as "Is it installed?" — including syntax errors. The build
script imports the theme first so the real error surfaces.

### Validate JSON
```bash
resumed validate resume.json
```


## The Theme

`themes/jsonresume-theme-even-ats/` — a local theme that composes over the npm
package `jsonresume-theme-even` rather than forking it, so upstream styling and
fixes stay available. It exists because the stock theme has defects that are
invisible in the rendered PDF but corrupt the text layer an ATS reads:

- Skills rendered as a two-column grid, which interleaves under text extraction
- `work[].keywords` rendered nowhere at all
- Year-only dates rendered with an invented month ("Jan 1996")
- Grid fragmentation drawing page-straddling bullets on top of the next heading

The overrides are short and commented. Read them before changing layout.

**Switching to another theme reintroduces all of the above.** If a different look
is wanted, port the overrides — and let `verify-resume.mjs` tell you when you have.

## Workflow

1. **Edit content** — Modify `resume.json` directly
2. **Render** — Run build script to generate HTML and PDF
3. **Quality check** — Read the PDF output and verify formatting
4. **Iterate** — Fix issues and regenerate until it looks good
5. **Deliver** — Provide file URLs to user

## Quality Check (Required)

**Automated** — `scripts/verify-resume.mjs`, run by the build script. It extracts
the PDF's text layer with `pdftotext` (no `-layout`, the reading order a
lightweight ATS ingests) and asserts against `resume.json`:
- Each skills category stays intact and keeps its own keywords
- Every `work[].keywords` entry actually renders
- Year-only dates render without an invented month
- Page count against the 2-page target (warning, not a failure)

`./scripts/mutation-check.sh` proves those checks still bite — it breaks the theme
four ways and confirms each is caught. Run it after changing `verify-resume.mjs`.

**Visual, by eye** — the automated check cannot see the page, and the page-break
tear it guards against is position-dependent: the check catches it when it
happens, but cannot prove the layout will never produce one. After generating,
read the PDF and verify:
- All sections render; nothing cut off or truncated
- No text drawn on top of other text at page boundaries
- Company names and titles visible
- Fits a reasonable page count (2 pages ideal for senior roles)

If the automated check fails, fix the cause — usually the theme, not the JSON.
Never edit content to make a rendering check pass.

## JSON Resume Schema

Key sections in `resume.json`:
- `basics` — Name, contact, summary, location, profiles
- `work` — Employment history (array)
- `education` — Education history (array)
- `skills` — Skill categories with keywords
- `projects` — Notable projects (optional)
- `awards`, `publications`, `languages`, `interests`, `references` — Optional sections

See https://jsonresume.org/schema/ for full schema documentation.

## Tips

- Keep `resume.json` as source of truth
- Don't edit generated HTML/PDF — they get overwritten
- Use `highlights` array in work entries for bullet points
- `work[].keywords` renders in this theme as a "Technologies:" bullet closing the
  entry. Most stock themes drop it silently — check before switching.
- A technology named inside a highlight ("Sharded the hottest tables with Citus")
  is worth more than the same word in a keyword list: it corroborates the skill
  and carries evidence. Use the keyword list for the rest.
- Summary field supports basic text only (no markdown in most themes)
