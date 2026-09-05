---
name: fastmcp-python
description: FastMCP/Python MCP server development — tool design, naming conventions, pytest, tmux-sidecar E2E testing. Load this skill when building or modifying MCP servers.
---

# FastMCP/Python Practice

## CRITICAL: Tool Naming Convention (ABSOLUTE)

FastMCP uses Python function names directly as MCP tool names.

- Use `snake_case` for tool function names
- MCP tool name will be: `mcp__<server-name>__<function_name>`
- Test tool discoverability after adding new tools

Never use colon namespacing (FastMCP doesn't support it).

---

## CRITICAL: Verify Tools are Discoverable (ABSOLUTE)

You MUST verify new/modified tools are visible to Claude Code before handoff.

- Restart MCP server after code changes
- Verify tool appears in tool list
- Test invocation in a fresh Claude session (tmux-sidecar)

---

## CRITICAL: Smoke-Test Real APIs Before Coding (ABSOLUTE)

**Never build response parsing from documentation alone when wrapping an external API.**

When API credentials are available:
1. Make a real API call (curl) BEFORE writing parsing code
2. Paste actual JSON response into implementation notes
3. Build all data mappings from REAL response, not docs
4. Note divergences from docs explicitly

Common divergences this catches:
- Enum values with/without prefixes
- Flat vs nested fields
- Top-level vs array-nested data
- Absent fields the docs claim exist

If credentials NOT yet available: flag in handoff, implementer must smoke-test first.

---

## Tool Function Pattern

```python
@mcp.tool()
async def tool_name(param1: str, param2: int = 10) -> str:
    """One-line description shown in tool list.

    Longer description with usage details.
    """
    return "result string"
```

- Type hints on all parameters (used for tool schemas)
- Default values for optional parameters
- Docstring first line = tool description
- Return strings (not dicts) — Claude reads return as text

---

## Running Tests

Run `pytest` from the project directory. That's it.

```bash
pytest -v                        # all tests
pytest test_something.py -v      # one file
pytest test_something.py::TestClass::test_method -v  # one test
```

**Project setup requirement:** Every MCP project MUST have pytest in dev dependencies and `[tool.pytest.ini_options]` in `pyproject.toml`. If a project is missing this, add it before writing tests:

```toml
[dependency-groups]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
]

[tool.pytest.ini_options]
testpaths = ["."]
python_files = ["test_*.py"]
asyncio_mode = "auto"
```

---

## Verification Loops

**Loop 1 (Unit Tests)**: `pytest -v`

**Loop 2 (MCP Server Starts + Discovery)** — MANDATORY:
```bash
CLAUDECODE= claude mcp list   # Must show ✓ Connected
claude mcp restart <server>    # Pick up changes
```

Unit tests alone are NOT sufficient — they don't exercise the full import chain, dependency resolution, or MCP protocol handshake.

**Loop 3 (E2E via tmux-sidecar)**:
Fresh Claude session in split pane, send test prompt, capture output. Kill and recreate pane between tests for fresh MCP server instance.

---

## Checklist

- [ ] Tool function names are snake_case
- [ ] All tools have type-hinted parameters and docstrings
- [ ] pytest passes
- [ ] Tool is discoverable (`claude mcp list` shows Connected)
- [ ] `.env.example` updated if new env vars
- [ ] Error handling returns descriptive strings (not exceptions)
- [ ] Tools are idempotent where possible
- [ ] Existing tools still work

---

## Anti-patterns

**You MUST NEVER:**
- Use colon namespacing in tool names
- Skip pytest
- Skip E2E verification (unit tests don't catch MCP protocol issues)
- Commit `.env` files
- Return complex objects (return formatted strings)
- Assume server auto-reloads

**Prefer:**
- Single `server.py` for small servers
- Descriptive first-line docstrings
- Default parameter values for optional args
- Graceful error messages in return strings
- Fresh tmux pane per E2E test run
