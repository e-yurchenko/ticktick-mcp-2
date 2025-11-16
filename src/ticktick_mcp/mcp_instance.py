import os
from importlib.metadata import PackageNotFoundError, version as metadata_version
from typing import Any

from mcp.server.fastmcp import FastMCP
from starlette.requests import Request
from starlette.responses import JSONResponse

# Configure FastMCP server with host/port defaults that can be overridden via environment.
FASTMCP_HOST = os.getenv("FASTMCP_HOST", "127.0.0.1")
FASTMCP_PORT = int(os.getenv("FASTMCP_PORT", "8000"))
FASTMCP_LOG_LEVEL = os.getenv("FASTMCP_LOG_LEVEL", "INFO")

try:
    PACKAGE_VERSION = metadata_version("ticktick-mcp")
except PackageNotFoundError:
    PACKAGE_VERSION = "0.1.0"

# Define the shared MCP instance
mcp = FastMCP("ticktick-server", host=FASTMCP_HOST, port=FASTMCP_PORT, log_level=FASTMCP_LOG_LEVEL)


def _build_transport_url(request: Request) -> str:
    """Build the absolute URL for the StreamableHTTP endpoint."""
    streamable_path = mcp.settings.streamable_http_path
    if not streamable_path.startswith("/"):
        streamable_path = f"/{streamable_path}"

    return str(
        request.url.replace(path=streamable_path, query=None, fragment=None)
    )


def _build_manifest_base(request: Request) -> str:
    return str(request.url.replace(path="/", query=None, fragment=None))


@mcp.custom_route("/.well-known/mcp", methods=["GET"], include_in_schema=False)
async def well_known_mcp(request: Request) -> JSONResponse:
    """Expose a minimal MCP discovery document for connectors and health checks."""
    transport_url = _build_transport_url(request)
    tools = await mcp.list_tools()
    manifest: dict[str, Any] = {
        "$schema": "https://modelcontextprotocol.io/specification/2025-06-18/basic#/components/schemas/MCPServer",
        "name": mcp.name,
        "title": "TickTick MCP Server",
        "description": "A Model Context Protocol bridge to the TickTick task API.",
        "version": PACKAGE_VERSION,
        "instructions": "Use the MCP transport to query and update TickTick tasks securely.",
        "transport": {
            "type": "streamable-http",
            "url": transport_url,
            "ssePath": mcp.settings.sse_path,
            "messagePath": mcp.settings.message_path,
            "streamableHttpPath": mcp.settings.streamable_http_path,
        },
        "capabilities": {
            "tools": {"listChanged": False},
            "resources": {"listChanged": False, "subscribe": False},
            "prompts": {"listChanged": False},
        },
        "tools": [tool.model_dump(exclude_none=True) for tool in tools],
        "resources": [],
        "prompts": [],
        "baseUrl": _build_manifest_base(request),
    }
    return JSONResponse(manifest)
