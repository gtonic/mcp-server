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

## Running with Docker (Taskfile)

You can build and run this MCP server in Docker using the included Taskfile.yml.

Prerequisites:
- Docker
- Task (install from https://taskfile.dev/install/)

1. Configure your environment
   ```bash
   cp .env.example .env
   # edit .env and set:
   # FINANCIAL_DATASETS_API_KEY=your-financial-datasets-api-key
   ```

2. Build the Docker image
   ```bash
   task build
   ```
   This builds the image tagged `financial-datasets-mcp`.

3. Run the server (SSE on port 9000)
   ```bash
   task run
   ```
   Notes:
   - Uses `--env-file .env` so your API key is available in the container
   - Publishes port `9000:9000`
   - Uses `--rm` so the container is removed when it exits

4. Rebuild without cache (after code changes)
   ```bash
   task rebuild
   ```

## Connecting to Claude Desktop (SSE)

1. Install [Claude Desktop](https://claude.ai/desktop) if you haven't already

2. Create or edit the Claude Desktop configuration file:
   ```bash
   # macOS
   mkdir -p ~/Library/Application\ Support/Claude/
   nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

3. Add the following configuration (SSE transport):
   ```json
   {
     "mcpServers": {
       "financial-datasets": {
         "transport": "sse",
         "url": "http://localhost:9000/"
       }
     }
   }
   ```

   Notes:
   - If you started the server with `task run` (Docker) or `uv run server.py` (local), it listens on `http://localhost:9000/`
   - If the server runs on a different host/port, update the `url` accordingly

4. Restart Claude Desktop

5. You should now see the financial tools available in Claude Desktop's tools menu (hammer icon)

6. Try asking Claude questions like:
   - "What are Apple's recent income statements?"
   - "Show me the current price of Tesla stock"
   - "Get historical prices for MSFT from 2024-01-01 to 2024-12-31"

## Testing with MCP Inspector

You can test this MCP server's tools from your browser using the official MCP Inspector.

Prerequisites:
- Node.js 18+ (or Bun)

1. Ensure the server is running (via `task run` or `uv run server.py`).
2. Start the Inspector and connect to the SSE endpoint:
   ```bash
   npx @modelcontextprotocol/inspector --connect http://localhost:9000/
   ```

Follow the terminal link to open the Inspector UI, browse tools, and invoke them.
