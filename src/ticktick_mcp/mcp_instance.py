import os

from mcp.server.fastmcp import FastMCP

# Configure FastMCP server with host/port defaults that can be overridden via environment.
FASTMCP_HOST = os.getenv("FASTMCP_HOST", "127.0.0.1")
FASTMCP_PORT = int(os.getenv("FASTMCP_PORT", "8000"))
FASTMCP_LOG_LEVEL = os.getenv("FASTMCP_LOG_LEVEL", "INFO")

# Define the shared MCP instance
mcp = FastMCP("ticktick-server", host=FASTMCP_HOST, port=FASTMCP_PORT, log_level=FASTMCP_LOG_LEVEL)
