# Raketto Protocol — Phase 1

## Overview

Raketto is a real-time chat protocol focused on channel‑based role-play communities and rich messaging features. This repository contains the Phase 1 Protocol Buffer (protobuf) definitions and build tooling used to generate language bindings for server and client SDKs.

This repo is intended for:

- SDK implementers (server and client)
- Tooling to generate language bindings
- Providing a canonical source of truth for the Raketto protocol

## Phase 1 Scope

Phase 1 provides the following domain surfaces:

- **Real-time WebSocket protocol** — connection lifecycle, framing, negotiation, streaming events
- **Channel management** — channel CRUD, membership, moderation, advanced settings, templates, audit logs
- **Enhanced messaging** — rich content, delivery tracking, reactions, batch operations
- **Supporting domains** — auth, character profiles, user accounts, security utilities

## Repository layout

```txt
raketto_protocol/
├── proto/                # Protobuf definitions organized by domain and version
│   └── org/archprotogens/raketto/
│       ├── auth/
│       ├── channel/
│       ├── character/
│       ├── message/
│       ├── realtime/
│       ├── security/
│       ├── user/
│       └── utils/
├── template/             # Starter templates for example language projects
├── Makefile              # Build system for generating bindings
├── LICENCE.md            # Project license (LGPL v3)
└── generated/            # Generated code (output of `make phase1`)
```

> Note: `generated/` contains build outputs and is not required to be committed — regenerate with `make phase1`.

## Build & Usage

### Prerequisites

- `protoc` (Protocol Buffers compiler)
- Optional: Go, Rust toolchain, Node/NPM, Python (for language plugin codegen)

### Generate language bindings (Phase 1)

Run:

```bash
make phase1
```

This will run `protoc` for the Phase 1 proto files and write generated bindings into the `generated/` directory. By default, the Makefile is configured to generate Go and TypeScript outputs; additional language plugins are detected and used if available.

### Other useful targets

- `make clean` — remove generated files
- `make validate` — validate proto syntax
- `make examples` — create example snippets in `examples/phase1`
- `make install-tools` — attempt to install `protoc` and common language plugins

## Working with the generated bindings

- The `generated/` directory contains language-specific bindings (e.g., `generated/go/`, `generated/typescript/`).
- Use these bindings in your SDKs or example apps. See `template/` for starter project templates.

## Phase 2: SDKs and servers

Phase 2 will implement server SDK(s) and client SDK(s) that consume the generated bindings. Expected deliverables include:

- `raketto_rust_sdk/` — server SDK (connection lifecycle, routing, persistence adapters)
- `raketto_dart_client/` — client SDK for Dart/Flutter (high-level API, streams, helpers)

## Contributing

- Fork the repository, create a branch, and open a pull request with a clear description of the change.
- Keep proto changes backward-compatible where possible. For breaking changes, bump package versions and document the migration path.

## Compatibility & Versioning

- Proto files live under `v1/` packages. Maintain backward compatibility for existing message types where possible; add new messages/fields as optional.
- Consider using `buf` or a compatibility checker before publishing changes that affect consumers.

## Licence

This project is licensed under the GNU Lesser General Public License v3 (LGPL‑3.0). See `LICENCE.md` for the full licence text.

## Contact

If you have questions about the protocol or need design clarifications, open an issue or contact the maintainers.
