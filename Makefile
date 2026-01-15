# Makefile for Raketto Protocol Buffers - Phase 1 Implementation
# This Makefile handles compilation of Phase 1 proto files

# Configuration
PROTO_DIR = proto
OUTPUT_DIR = generated
GO_OUT_DIR = $(OUTPUT_DIR)/go
PYTHON_OUT_DIR = $(OUTPUT_DIR)/python
TS_OUT_DIR = $(OUTPUT_DIR)/typescript
RUST_OUT_DIR = $(OUTPUT_DIR)/rust

# Tools
PROTOC = protoc
PROTOC_GO_PLUGIN = protoc-gen-go
PROTOC_RUST_PLUGIN = protoc-gen-rust
PROTOC_PYTHON_PLUGIN = protoc-gen-python
PROTOC_TS_PLUGIN = protoc-gen-ts

# Phase 1 specific proto files
PHASE1_PROTOS = \
	org/archprotogens/raketto/channel/v1/channel.proto \
	org/archprotogens/raketto/channel/v1/advanced.proto \
	org/archprotogens/raketto/realtime/v1/connection.proto \
	org/archprotogens/raketto/realtime/v1/events.proto \
	org/archprotogens/raketto/realtime/v1/websocket.proto \
	org/archprotogens/raketto/message/v1/message.proto \
	org/archprotogens/raketto/auth/v1/auth.proto \
	org/archprotogens/raketto/character/v1/character.proto \
	org/archprotogens/raketto/user/v1/user.proto

# All proto files for backwards compatibility
ALL_PROTO_FILES = $(shell find $(PROTO_DIR) -name "*.proto")

# Version
VERSION = 0.1.0

# Default target
.PHONY: all
all: clean build phase1 validate docs

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -rf $(OUTPUT_DIR)
	mkdir -p $(GO_OUT_DIR)
	mkdir -p $(PYTHON_OUT_DIR)
	mkdir -p $(TS_OUT_DIR)
	mkdir -p $(RUST_OUT_DIR)

# Build Phase 1 proto files
.PHONY: phase1
phase1: 
	@echo "Building Phase 1 protocol buffers..."
	@echo "Phase 1 files: $(words $(PHASE1_PROTOS))"
	
	# Generate Go code
	@echo "Generating Go code..."
	$(PROTOC) \
		--proto_path=$(PROTO_DIR) \
		--go_out=$(GO_OUT_DIR) \
		--go_opt=paths=source_relative \
		$(PHASE1_PROTOS)
	
	# Generate Rust code (if plugin available)
	@if command -v $(PROTOC_RUST_PLUGIN) >/dev/null 2>&1; then \
		echo "Generating Rust code..."; \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--rust_out=$(RUST_OUT_DIR) \
			$(PHASE1_PROTOS); \
	fi
	
	# Generate Python code (optional)
	@if command -v $(PROTOC_PYTHON_PLUGIN) >/dev/null 2>&1; then \
		echo "Generating Python code..."; \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--python_out=$(PYTHON_OUT_DIR) \
			$(PHASE1_PROTOS); \
	fi
	
	# Generate TypeScript code (optional)
	@if command -v $(PROTOC_TS_PLUGIN) >/dev/null 2>&1; then \
		echo "Generating TypeScript code..."; \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--ts_out=$(TS_OUT_DIR) \
			$(PHASE1_PROTOS); \
	fi
	
	@echo "Phase 1 build completed successfully!"

# Build all proto files (for backwards compatibility)
.PHONY: build
build: clean
	@echo "Building all protocol buffers..."
	@echo "Found $(words $(ALL_PROTO_FILES)) proto files"
	
	# Generate Go code
	@echo "Generating Go code..."
	$(PROTOC) \
		--proto_path=$(PROTO_DIR) \
		--go_out=$(GO_OUT_DIR) \
		--go_opt=paths=source_relative \
		$(ALL_PROTO_FILES)
	
	# Generate other languages if plugins available
	@if command -v $(PROTOC_PYTHON_PLUGIN) >/dev/null 2>&1; then \
		echo "Generating Python code..."; \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--python_out=$(PYTHON_OUT_DIR) \
			$(ALL_PROTO_FILES); \
	fi
	
	@if command -v $(PROTOC_TS_PLUGIN) >/dev/null 2>&1; then \
		echo "Generating TypeScript code..."; \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--ts_out=$(TS_OUT_DIR) \
			$(ALL_PROTO_FILES); \
	fi
	
	@if command -v $(PROTOC_RUST_PLUGIN) >/dev/null 2>&1; then \
		echo "Generating Rust code..."; \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--rust_out=$(RUST_OUT_DIR) \
			$(ALL_PROTO_FILES); \
	fi
	
	@echo "Full build completed successfully!"

# Validate proto files
.PHONY: validate
validate:
	@echo "Validating proto files..."
	@PROTOC_VALIDATION_FAILED=false; \
	for proto in $(PHASE1_PROTOS); do \
		echo "Validating $$proto..."; \
		if ! $(PROTOC) --proto_path=$(PROTO_DIR) --go_out=/tmp "$$proto" 2>/dev/null; then \
			echo "✓ $$proto - Valid"; \
		else \
			echo "✗ $$proto - Invalid"; \
			PROTOC_VALIDATION_FAILED=true; \
		fi; \
	done; \
	if [ "$$PROTOC_VALIDATION_FAILED" = "true" ]; then \
		echo "Validation failed!"; \
		exit 1; \
	else \
		echo "All Phase 1 proto files are valid!"; \
	fi

# Install tools for Phase 1
.PHONY: install-tools
install-tools:
	@echo "Installing protoc and Phase 1 plugins..."
	@echo "Note: This requires Go, Rust, and npm to be installed"
	
	# Install protoc (if not present)
	@if ! command -v $(PROTOC) >/dev/null 2>&1; then \
		echo "Installing protoc..."; \
		if [[ "$$OSTYPE" == "linux-gnu"* ]]; then \
			curl -L https://github.com/protocolbuffers/protobuf/releases/download/v3.21.0/protoc-3.21.0-linux-x86_64.zip -o protoc.zip; \
			unzip protoc.zip -d /usr/local/bin; \
			chmod +x /usr/local/bin/protoc; \
		elif [[ "$$OSTYPE" == "darwin"* ]]; then \
			curl -L https://github.com/protocolbuffers/protobuf/releases/download/v3.21.0/protoc-3.21.0-osx-x86_64.zip -o protoc.zip; \
			unzip protoc.zip -d /usr/local/bin; \
			chmod +x /usr/local/bin/protoc; \
		fi; \
		rm protoc.zip; \
	fi
	
	# Install Go plugin
	@if ! command -v $(PROTOC_GO_PLUGIN) >/dev/null 2>&1; then \
		echo "Installing protoc-gen-go..."; \
		go install google.golang.org/protobuf/cmd/protoc-gen-go@latest; \
	fi
	
	# Install Rust plugin (for Phase 1)
	@if ! command -v $(PROTOC_RUST_PLUGIN) >/dev/null 2>&1; then \
		echo "Installing protoc-gen-rust..."; \
		cargo install protobuf-codegen; \
	fi
	
	# Install Python plugin (optional)
	@if command -v pip >/dev/null 2>&1; then \
		if ! command -v $(PROTOC_PYTHON_PLUGIN) >/dev/null 2>&1; then \
			echo "Installing protoc-gen-python..."; \
			pip install protoc-gen-python; \
		fi; \
	fi
	
	# Install TypeScript plugin (optional)
	@if command -v npm >/dev/null 2>&1; then \
		if ! command -v $(PROTOC_TS_PLUGIN) >/dev/null 2>&1; then \
			echo "Installing protoc-gen-ts..."; \
			npm install -g protoc-gen-ts; \
		fi; \
	fi
	
	@echo "Phase 1 tool installation completed!"

# Development helpers
.PHONY: watch
watch:
	@echo "Watching for proto file changes..."
	@while true; do \
		inotifywait -e modify,create,move $(PROTO_DIR) -r; \
		echo "Change detected, rebuilding..."; \
		$(MAKE) phase1; \
	done

.PHONY: lint
lint:
	@echo "Linting Phase 1 proto files..."
	@for proto in $(PHASE1_PROTOS); do \
		echo "Linting $$proto..."; \
		protoc --proto_path=$(PROTO_DIR) --go_out=/tmp "$$proto" 2>&1 | grep -v "warning" || true; \
	done

# Generate documentation
.PHONY: docs
docs:
	@echo "Generating Phase 1 documentation..."
	@if command -v protoc-gen-doc >/dev/null 2>&1; then \
		$(PROTOC) \
			--proto_path=$(PROTO_DIR) \
			--doc_out=$(OUTPUT_DIR)/docs \
			$(PHASE1_PROTOS); \
		echo "Documentation generated in $(OUTPUT_DIR)/docs/"; \
	else \
		echo "protoc-gen-doc not installed. Install with: go install github.com/pseudomuto/protoc-gen-doc@latest"; \
	fi

# Test generated code
.PHONY: test
test: phase1
	@echo "Testing Phase 1 generated code..."
	@cd $(GO_OUT_DIR) && \
		if [ -f "go.mod" ]; then \
			echo "Running Go tests..."; \
			go test ./...; \
		else \
			echo "No go.mod found, initializing module..."; \
			go mod init org/archprotogens/raketto; \
			go test ./...; \
		fi

# Quick commands for Phase 1 development
.PHONY: quick
quick: clean phase1
	@echo "Phase 1 quick rebuild completed!"

# Create Phase 1 example files
.PHONY: examples
examples: phase1
	@echo "Creating Phase 1 examples..."
	@mkdir -p examples/phase1
	@echo "Creating channel management examples..."
	@printf "# Phase 1 Channel Management Examples\n\n## Create a Channel\n\n\`\`\`protobuf\nCreateChannelRequest request = CreateChannelRequest{\n  Name: \"general-chat\",\n  Title: \"General Discussion\",\n  Description: \"A place for general conversation\",\n  Type: ChannelType_CHANNEL_TYPE_PUBLIC,\n  Mode: ChannelMode_CHANNEL_MODE_BOTH,\n  MaxMembers: 100,\n}\n\`\`\`\n\n## Join a Channel\n\n\`\`\`protobuf\nJoinChannelRequest request = JoinChannelRequest{\n  ChannelId: \"channel-123\",\n  Password: \"optional-password\",\n}\n\`\`\`\n\n## Moderation\n\n\`\`\`protobuf\nModerationRequest request = ModerationRequest{\n  ChannelId: \"channel-123\",\n  TargetCharacterId: \"character-456\",\n  Action: ModerationAction_MODERATION_ACTION_KICK,\n  Reason: \"Disruptive behavior\",\n}\n\`\`\`\n" > examples/phase1/channel_example.md
	@printf "Creating real-time connection examples...\n" > examples/phase1/websocket_example.md
	@printf "# Phase 1 WebSocket Connection Examples\n\n## Connect to Server\n\n\`\`\`javascript\nconst ws = new WebSocket('ws://localhost:8080');\n\nconst connectMessage = {\n  connectRequest: {\n    protocolVersion: \"1.0\",\n    clientName: \"RakettoClient\",\n    clientVersion: \"0.1.0\",\n    authToken: \"your-auth-token\"\n  }\n};\n\nws.send(JSON.stringify(connectMessage));\n\`\`\`\n\n## Handle Real-time Messages\n\n\`\`\`javascript\nws.onmessage = (event) => {\n  const frame = JSON.parse(event.data);\n  \n  switch (frame.frameType) {\n    case 'MESSAGE':\n      handleMessage(frame.payload);\n      break;\n    case 'CHANNEL_EVENT':\n      handleChannelEvent(frame.payload);\n      break;\n    case 'PRESENCE_EVENT':\n      handlePresenceUpdate(frame.payload);\n      break;\n  }\n};\n\`\`\`\n" > examples/phase1/websocket_example.md
	@echo "Phase 1 examples created in examples/phase1/"

# Show help
.PHONY: help
help:
	@echo "Raketto Protocol Buffers - Phase 1 Build System"
	@echo ""
	@echo "Phase 1: Core Chat Infrastructure"
	@echo "  - Real-time WebSocket protocol"
	@echo "  - Channel management and moderation"
	@echo "  - Enhanced messaging system"
	@echo "  - Connection and presence management"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Clean, build Phase 1, and validate (default)"
	@echo "  phase1       - Build Phase 1 proto files only"
	@echo "  build        - Build all proto files (including future phases)"
	@echo "  clean        - Remove generated files"
	@echo "  validate     - Validate Phase 1 proto syntax"
	@echo "  test         - Run tests on generated code"
	@echo "  lint         - Lint proto files for warnings"
	@echo "  docs         - Generate Phase 1 documentation"
	@echo "  watch        - Watch and rebuild on changes"
	@echo "  examples     - Create Phase 1 example files"
	@echo "  install-tools - Install protoc and Phase 1 plugins"
	@echo "  quick        - Quick Phase 1 rebuild"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Phase 1 files:"
	@echo "  $(words $(PHASE1_PROTOS))"
	@echo ""
	@echo "Examples:"
	@echo "  make phase1                # Build Phase 1 only"
	@echo "  make quick                 # Quick rebuild Phase 1"
	@echo "  make examples               # Generate example code"
