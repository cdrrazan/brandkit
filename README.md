# BrandKit

**BrandKit** is a modern, interactive CLI tool designed to help entrepreneurs,
developers, and creatives quickly check the availability of domains and social
media usernames — all from the command line. It combines domain availability
checks via the Namecheap API with username availability checks on popular social
platforms, helping you secure your brand identity in one place.

---

## Features

- **Domain Availability Check**  
  Checks if a domain (e.g. `example.com`) is available to register using the
  Namecheap API. If a domain is not provided with a TLD, it suggests popular
  extensions like `.com`, `.net`, `.io`, etc., and shows their availability in a
  table.

- **Social Username Availability Check**  
  Interactively checks if your chosen username is available on multiple social
  media platforms including GitHub, Twitter, Instagram, TikTok, LinkedIn, and
  more.

- **Interactive CLI Experience**  
  Powered by TTY::Prompt for user-friendly menus, multi-selects, and prompts,
  plus colorful terminal output for better readability.

- **Clean & Extensible Codebase**  
  Modular design with dedicated classes for API communication (
  `NamecheapClient`), domain checks (`DomainChecker`), and social username
  checks (`SocialUsernameChecker`).

- **Dockerized for Easy Setup**  
  Runs inside a container for hassle-free installation and dependency
  management.

---

## Getting Started

### Prerequisites

- Ruby 3.x installed locally or use Docker
- Namecheap API credentials (API user, API key, username, client IP)
- Internet connection to query domain and social media availability

### Environment Variables

Before running, set these environment variables in your shell or `.env` file:

```bash
export NAMECHEAP_API_USER=your_api_user
export NAMECHEAP_API_KEY=your_api_key
export NAMECHEAP_USERNAME=your_namecheap_username
export CLIENT_IP=your_client_ip
```

### Installation

Clone the repo and install dependencies:

```bash
git clone https://github.com/yourusername/brandkit.git
cd brandkit
bundle install
```

Alternatively, use Docker:

```bash
docker-compose build
```

---

## Usage

### Run interactively

Launch the CLI with an interactive prompt experience, guiding you step-by-step:

```bash
docker-compose run cli
```

Or locally:

```bash
ruby bin/brandkit
```

### Run with command-line arguments

Provide a domain upfront to skip prompts:

```bash
docker-compose run cli ruby bin/brandkit --domain=example.com
```

This will check the domain immediately and display availability, with an option
to check social usernames.

---

## Code Overview

### `BrandKit`

The main CLI application class coordinating user input, output formatting, and
flow control. Uses:

- `TTY::Prompt` for interactive prompts
- `Artii` for ASCII banners
- `Colorize` for colored terminal output

### `DomainChecker`

Handles domain availability checking logic:

- Uses the `NamecheapClient` API wrapper to query domain status
- Suggests popular TLDs if no extension is provided
- Displays results in a neat table format

### `ApiClients::NamecheapClient`

API client encapsulating communication with the Namecheap XML API:

- Authenticates via environment variables
- Handles building query parameters and HTTP requests
- Parses XML responses and handles errors gracefully

### `SocialUsernameChecker`

Checks username availability on popular social platforms by performing HTTP GET
requests to profile URLs and interpreting the HTTP response status.

- Supports GitHub, Twitter, Instagram, Facebook, YouTube, TikTok, Pinterest,
  LinkedIn, Reddit, Threads
- Allows querying single or multiple platforms interactively

---

### Demo

```
  ____                      _ _  ___ _
|  _ \                    | | |/ (_) |
| |_) |_ __ __ _ _ __   __| | ' / _| |_
|  _ <| '__/ _` | '_ \ / _` |  < | | __|
| |_) | | | (_| | | | | (_| | . \| | |_
|____/|_|  \__,_|_| |_|\__,_|_|\_\_|\__|


🚀 Welcome to BrandKit

     The fastest way to check domain and
     social media username availability!

────────────────────────────────────────────────────────────
🌐 Enter domain (e.g. example or example.com): examplex

Top Domain Extensions:
┌─────────────────┬───────────────┐
│  Domain         │  Status       │
├─────────────────┼───────────────┤
│  examplex.com   │  ✔ Available  │
│  examplex.net   │  ✔ Available  │
│  examplex.org   │  ✔ Available  │
│  examplex.io    │  ✔ Available  │
│  examplex.dev   │  ✔ Available  │
│  examplex.app   │  ✔ Available  │
│  examplex.co    │  ✔ Available  │
│  examplex.xyz   │  ✔ Available  │
│  examplex.tech  │  ✔ Available  │
│  examplex.site  │  ✔ Available  │
└─────────────────┴───────────────┘

✦ Domain Status

🎉 Great news! Many domain extensions are available for ‘examplex’.

────────────────────────────────────────────────────────────
📱 Check if the username is available on social platforms? Yes

✔ Select platforms to check (space to select): 🌍 All supported platforms

┌─────────────────┬─────────────────┐
│   📡 Platform   │    🔍 Status    │
├─────────────────┼─────────────────┤
│     Github      │   ✔ Available   │
│     Twitter     │   ✔ Available   │
│    Instagram    │   ✔ Available   │
│    Facebook     │   ✔ Available   │
│     Youtube     │   ✔ Available   │
│     Tiktok      │   ✔ Available   │
│    Pinterest    │   ✔ Available   │
│    Linkedin     │   ✔ Available   │
│     Reddit      │   ✔ Available   │
│     Threads     │   ✔ Available   │
└─────────────────┴─────────────────┘
👋

          Thanks for using BrandKit!
      Start building your brand today. ✨

────────────────────────────────────────────────────────────

```

## Contributing

Contributions are welcome! Please fork the repo and submit pull requests with
descriptive commit messages. Make sure to follow the existing code style and add
tests if applicable.

---

## License

MIT License © Rajan Bhattarai

---

## Acknowledgments

- [Namecheap API](https://www.namecheap.com/support/api/)
- [TTY Toolkit](https://ttytoolkit.org/)
- [Artii](https://github.com/miketierney/artii)
- [Colorize](https://github.com/fazibear/colorize)

---
