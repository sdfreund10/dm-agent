# dm-agent

## Running the app

**CLI:**
```bash
ruby cli.rb
```

**Web (Sinatra + Hotwire/Turbo):**
```bash
bundle exec ruby bin/server
```
Then open http://localhost:9292 — pick a character or create a new one. Terminal-style dark UI.

## Running tests

```bash
bundle exec rake test
```

# TODO:
- Web interface (WIP)
  - Auto-scroll when messages come back
  - Clear input form after sending a message.
  - Implement message streaming
- Generate (or display preset) Character Sheet
- In-app rolling