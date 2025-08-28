# Financial Datasets MCP Server

## Introduction

This is a Model Context Protocol (MCP) server that provides access to stock market data from [Financial Datasets](https://www.financialdatasets.ai/). 

It allows Claude and other AI assistants to retrieve income statements, balance sheets, cash flow statements, stock prices, and market news directly through the MCP interface.

## Available Tools

This MCP server provides the following tools:
- **get_income_statements**: Get income statements for a company.
- **get_balance_sheets**: Get balance sheets for a company.
- **get_cash_flow_statements**: Get cash flow statements for a company.
- **get_current_stock_price**: Get the current / latest price of a company.
- **get_historical_stock_prices**: Gets historical stock prices for a company.
- **get_company_news**: Get news for a company.
- **get_available_crypto_tickers**: Gets all available crypto tickers.
- **get_crypto_prices**: Gets historical prices for a crypto currency.
- **get_historical_crypto_prices**: Gets historical prices for a crypto currency.
- **get_current_crypto_price**: Get the current / latest price of a crypto currency.

## Setup

### Prerequisites

- Python 3.10 or higher
- [uv](https://github.com/astral-sh/uv) package manager

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/financial-datasets/mcp-server
   cd mcp-server
   ```

2. If you don't have uv installed, install it:
   ```bash
   # macOS/Linux
   curl -LsSf https://astral.sh/uv/install.sh | sh
   
   # Windows
   curl -LsSf https://astral.sh/uv/install.ps1 | powershell
   ```

3. Install dependencies:
   ```bash
   # Create virtual env and activate it
   uv venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   
   # Install dependencies
   uv add "mcp[cli]" httpx  # On Windows: uv add mcp[cli] httpx

   ```

4. Set up environment variables:
   ```bash
   # Create .env file for your API keys
   cp .env.example .env

   # Set API key in .env
   FINANCIAL_DATASETS_API_KEY=your-financial-datasets-api-key
   ```

5. Run the server:
   ```bash
   uv run server.py
   ```

## Connecting to Claude Desktop

1. Install [Claude Desktop](https://claude.ai/desktop) if you haven't already

2. Create or edit the Claude Desktop configuration file:
   ```bash
   # macOS
   mkdir -p ~/Library/Application\ Support/Claude/
   nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

3. Add the following configuration:
   ```json
   {
     "mcpServers": {
       "financial-datasets": {
         "command": "/opt/homebrew/bin/uv",
         "args": [
           "--directory",
           "/Users/gtonic/ws_finance/mcp-server",
           "run",
           "server.py"
         ]
       }
     }
   }
   ```
   
   Replace `/path/to/uv` with the result of `which uv` and `/absolute/path/to/financial-datasets-mcp` with the absolute path to this project.

4. Restart Claude Desktop

5. You should now see the financial tools available in Claude Desktop's tools menu (hammer icon)

6. Try asking Claude questions like:
   - "What are Apple's recent income statements?"
   - "Show me the current price of Tesla stock"
   - "Get historical prices for MSFT from 2024-01-01 to 2024-12-31"

## Docker

You can run this MCP server in a container. The server reads your API key from the FINANCIAL_DATASETS_API_KEY environment variable at runtime.

### Build the image
```bash
docker build -t financial-datasets-mcp .
```

### Run the container (pass API key directly)
```bash
docker run --rm -i \
  -e FINANCIAL_DATASETS_API_KEY=your-financial-datasets-api-key \
  financial-datasets-mcp
```

- The `-i` flag keeps STDIN open so the MCP stdio transport works when invoked by an MCP client.
- Replace `your-financial-datasets-api-key` with your real key.

### Run with a .env file
Create a `.env` file (based on `.env.example`) and then:
```bash
docker run --rm -i --env-file .env financial-datasets-mcp
```

### docker-compose
A `docker-compose.yml` is provided. To build and run:
```bash
docker compose up --build
```

### Using Docker from Claude Desktop
If you prefer to run the MCP server via Docker from Claude Desktop, set the command to `docker` and pass args similar to:
```json
{
  "mcpServers": {
    "financial-datasets": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e",
        "FINANCIAL_DATASETS_API_KEY=your-financial-datasets-api-key",
        "financial-datasets-mcp:latest"
      ]
    }
  }
}
```
Replace `your-financial-datasets-api-key` accordingly. Note: environment variable expansion is not performed by Claude Desktop, so pass the actual value.

## HTTP/SSE mode and port configuration

By default, the server runs over stdio (no port). To run it as an HTTP/SSE server and choose a port, configure these environment variables:
- MCP_TRANSPORT=http (aliases accepted: sse, streamable-http)
- PORT=8011 (or your desired port)
- HOST=0.0.0.0 (optional; defaults to 0.0.0.0 inside Docker)

Examples:

Local (no Docker):
```bash
MCP_TRANSPORT=http PORT=8011 uv run server.py
# Then connect to http://localhost:8011
```

Docker:
```bash
docker run --rm -p 8011:8011 \
  -e MCP_TRANSPORT=http \
  -e PORT=8011 \
  -e FINANCIAL_DATASETS_API_KEY=your-financial-datasets-api-key \
  financial-datasets-mcp
# Then connect to http://localhost:8011
```

docker-compose (edit docker-compose.yml):
```yaml
services:
  financial-datasets-mcp:
    environment:
      - MCP_TRANSPORT=http
      - PORT=8011
    ports:
      - "8011:8011"
```

Notes:
- Stdio mode (MCP_TRANSPORT=stdio, the default) is recommended for Claude Desktop and similar clients that expect stdio; it does not use a port.
- HTTP/SSE mode is for exposing the MCP server over the network; set PORT and publish the port via Docker (-p) or compose (ports:).
