# oote Makefile
#
# Usage:
#   make build       - compile main.oo to dist/oote
#   make check       - run oodac check on every .oo file
#   make line-cap    - enforce 16-256 line cap on every .oo and .oot (shim-exempt)
#   make file-law    - reject forbidden file extensions and stray docs
#   make academy     - verify every .oo has the 4-element Academy header
#   make density     - enforce at most 8 pages per directory
#   make verify      - run line-cap, file-law, academy, density, and check
#   make test        - run functional test suite
#   make clean       - remove build artifacts

OODA_COMPILER ?= $(firstword $(wildcard $(HOME)/.openooda/bin/oodac $(CURDIR)/../../openOODA/oodac/bin/oodac))
OODACODEX ?= $(HOME)/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592
BIN := dist/oote
VERSION ?= 0.2.0
PREFIX ?= $(HOME)/.openooda/bin

SRC := $(wildcard *.oo) $(wildcard */*.oo) $(wildcard */*/*.oo)

.PHONY: all build check line-cap file-law academy density verify test install uninstall clean

all: verify build test

build: $(BIN)

$(BIN): $(SRC)
	@mkdir -p dist .ooda-cache/ooda-tmp
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) build main.oo -o $(BIN)
	@chmod +x $(BIN)
	@echo "built $(BIN)"

install: $(BIN)
	@mkdir -p $(PREFIX)
	@cp $(BIN) $(PREFIX)/oote
	@chmod 0755 $(PREFIX)/oote
	@cp uninstall.sh $(PREFIX)/oote-uninstall
	@chmod 0755 $(PREFIX)/oote-uninstall
	@echo "installed oote and oote-uninstall to $(PREFIX)"

uninstall:
	@sh uninstall.sh $(if $(PURGE),--purge,)

# --- Verification gate ---------------------------------------------------------

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" -not -path "./dist/*" -not -path "./qa/fixtures/*"); do \
		n=$$(wc -l < "$$f"); \
		if [ $$n -gt 256 ]; then \
			echo "VIOLATION: $$f = $$n lines (exceeds 256)"; violations=$$((violations+1)); \
			continue; \
		fi; \
		code=$$(grep -vE '^[[:space:]]*(//.*)?$$' "$$f" | grep -cvE '^[[:space:]]*import[[:space:]]+"'); \
		if [ "$$code" = "0" ]; then continue; fi; \
		if [ $$n -lt 16 ]; then \
			echo "VIOLATION: $$f = $$n lines (under 16-line floor, not a shim)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate the Page Rule"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@forbidden="py js ts rb pl json yaml toml"; \
	violations=0; \
	for ext in $$forbidden; do \
		found=$$(find . -name "*.$$ext" -not -path "./.git/*" -not -path "./.github/*" -not -path "./dist/*" -not -path "./.ooda-cache/*" -not -path "./.blackbox/*" 2>/dev/null | head -3); \
		if [ -n "$$found" ]; then \
			echo "VIOLATION: .$$ext forbidden:"; echo "$$found"; violations=$$((violations+1)); \
		fi; \
	done; \
	for f in $$(find . -name "*.md" -not -path "./.git/*" -not -path "./.github/*" -not -path "./dist/*" -not -path "./.ooda-cache/*" -not -path "./.blackbox/*" 2>/dev/null); do \
		if [ "$$f" != "./README.md" ] && [ "$$f" != "./AGENTS.md" ]; then \
			echo "VIOLATION: .md forbidden outside README.md and AGENTS.md: $$f"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: file-law violations"; exit 1; fi; \
	echo "PASS: file law holds"

academy:
	@failures=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*" -not -path "./qa/fixtures/*"); do \
		header=$$(head -7 "$$f"); \
		missing=""; \
		echo "$$header" | grep -q "^// # "        || missing="$$missing title"; \
		echo "$$header" | grep -q "^// Logline:"  || missing="$$missing logline"; \
		echo "$$header" | grep -q "^// Setup:"    || missing="$$missing setup"; \
		echo "$$header" | grep -q "^// Beats:"    || missing="$$missing beats"; \
		if [ -n "$$missing" ]; then \
			echo "FAIL: $$f missing Academy element(s):$$missing"; failures=$$((failures+1)); \
		fi; \
	done; \
	if [ $$failures -gt 0 ]; then echo "FAIL: $$failures academy header violations"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -type d -not -path "./.git*" -not -path "./dist*" -not -path "./.ooda-cache*" -not -path "./qa/fixtures*"); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*" -not -path "./qa/fixtures/*"); do \
		$(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

# --- Functional test suite ---------------------------------------------------

test: $(BIN)
	@echo "=== Tier 1: Core CLI Flags, Options, Formats & Theming ==="
	@echo "=== testing --help ==="
	@./$(BIN) --help > /dev/null && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version > /dev/null && echo "PASS: --version"
	@echo "=== testing list ==="
	@./$(BIN) list | grep -q "minimax" && echo "PASS: list contains minimax"
	@./$(BIN) list | grep -q "frost" && echo "PASS: list contains monthly frost"
	@./$(BIN) list | grep -q "spooky" && echo "PASS: list contains holiday spooky"
	@echo "=== testing current ==="
	@./$(BIN) current > /dev/null && echo "PASS: current theme query"
	@./$(BIN) current --mode > /dev/null && echo "PASS: current mode query"
	@./$(BIN) current -m > /dev/null && echo "PASS: current -m query alias"
	@echo "=== testing circadian auto mode ==="
	@OODA_MODE=auto OODA_HOUR=14 ./$(BIN) current --mode | grep -q "light" && echo "PASS: circadian 14:00 is light"
	@OODA_MODE=auto OODA_HOUR=22 ./$(BIN) current --mode | grep -q "dark" && echo "PASS: circadian 22:00 is dark"
	@OODA_MODE=auto OODA_HOUR=2 ./$(BIN) current --mode | grep -q "dark" && echo "PASS: circadian 02:00 is dark"
	@OODA_MODE=auto OODA_HOUR=6 ./$(BIN) current --mode | grep -q "light" && echo "PASS: circadian 06:00 is light"
	@OODA_MODE=auto OODA_HOUR=18 ./$(BIN) current --mode | grep -q "dark" && echo "PASS: circadian 18:00 is dark"
	@echo "=== testing calendar monthly and holiday auto mode ==="
	@OODA_THEME=auto OODA_MONTH=1 ./$(BIN) current | grep -q "frost" && echo "PASS: month 1 is frost"
	@OODA_THEME=auto OODA_MONTH=5 ./$(BIN) current | grep -q "meadow" && echo "PASS: month 5 is meadow"
	@OODA_THEME=auto OODA_MONTH=12 ./$(BIN) current | grep -q "solitude" && echo "PASS: month 12 is solitude"
	@OODA_THEME=auto OODA_DATE="2026-10-31" ./$(BIN) current | grep -q "spooky" && echo "PASS: Oct 31 holiday is spooky"
	@OODA_THEME=auto OODA_DATE="2026-12-25" ./$(BIN) current | grep -q "yule" && echo "PASS: Dec 25 holiday is yule"
	@OODA_THEME=auto OODA_DATE="2026-01-01" ./$(BIN) current | grep -q "nova" && echo "PASS: Jan 1 holiday is nova"
	@echo "=== testing preview ==="
	@./$(BIN) preview minimax > /dev/null && echo "PASS: preview minimax"
	@./$(BIN) preview frost --dark | grep -q "~~~~~" && echo "PASS: preview frost contains mascot line 4"
	@./$(BIN) preview nova | grep -q "\* \* \*" && echo "PASS: preview nova contains mascot line 4"
	@./$(BIN) preview ember --light --border double > /dev/null && echo "PASS: preview ember --light --border double"
	@echo "=== testing get token ==="
	@./$(BIN) get status_success > /dev/null && echo "PASS: get token"
	@echo "=== testing mascot ==="
	@./$(BIN) mascot minimax happy > /dev/null && echo "PASS: mascot minimax happy"
	@./$(BIN) mascot spooky alert > /dev/null && echo "PASS: mascot spooky alert"
	@echo "=== testing glyph ==="
	@./$(BIN) glyph minimax idle | grep -q "(^.^)" && echo "PASS: glyph minimax"
	@./$(BIN) glyph spooky > /dev/null && echo "PASS: glyph spooky"
	@echo "=== testing border ==="
	@./$(BIN) border > /dev/null && echo "PASS: get border"
	@./$(BIN) border ascii > /dev/null && echo "PASS: set border ascii"
	@./$(BIN) border round > /dev/null && echo "PASS: set border round"
	@echo "=== testing mode ==="
	@./$(BIN) mode light > /dev/null && echo "PASS: mode light"
	@./$(BIN) mode dark > /dev/null && echo "PASS: mode dark"
	@./$(BIN) mode toggle > /dev/null && echo "PASS: mode toggle"
	@./$(BIN) mode auto > /dev/null && echo "PASS: mode auto"
	@echo "=== testing set ==="
	@./$(BIN) set minimax --dark > /dev/null && echo "PASS: set minimax --dark"
	@./$(BIN) set auto > /dev/null && echo "PASS: set auto"
	@echo "=== Tier 2: MCP Handshake & Protocol Framing ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "2024-11-05" && echo "PASS: MCP initialize protocolVersion"
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q '"name":"oote","version":"0.2.0"' && echo "PASS: MCP initialize serverInfo"
	@printf '{"jsonrpc":"2.0","id":2,"method":"ping","params":{}}\n' | ./$(BIN) --mcp | grep -q '"result":{}' && echo "PASS: MCP ping"
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "list_themes" && echo "PASS: MCP tools/list list_themes"
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "get_theme" && echo "PASS: MCP tools/list get_theme"
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "resolve_color" && echo "PASS: MCP tools/list resolve_color"
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "render_mascot" && echo "PASS: MCP tools/list render_mascot"
	@test -z "$$(printf '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}\n' | ./$(BIN) --mcp)" && echo "PASS: MCP notifications/initialized produces no response"
	@printf '{"jsonrpc":"2.0","id":4,"method":"shutdown","params":{}}\n' | ./$(BIN) --mcp | grep -q '"result":null' && echo "PASS: MCP shutdown"
	@test -z "$$(printf '{"jsonrpc":"2.0","method":"exit","params":{}}\n' | ./$(BIN) --mcp)" && echo "PASS: MCP exit terminates cleanly"
	@test "$$(printf '{"jsonrpc":"2.0","id":1,"method":"ping","params":{}}{"jsonrpc":"2.0","id":2,"method":"ping","params":{}}\n' | ./$(BIN) --mcp | grep -c '"result":{}')" = "2" && echo "PASS: MCP concatenated JSON-RPC messages without newline"
	@printf '{"jsonrpc":"2.0","id":99,"method":"ping","params":{}}' | ./$(BIN) --mcp | grep -q '"id":99' && echo "PASS: MCP request without trailing newline"
	@(sleep 0.1 && printf '{"jsonrpc":"2.0","id":15,"method":"ping","params":{}}\n') | ./$(BIN) --mcp | grep -q '"result":{}' && echo "PASS: MCP stdio idle pause does not crash server"
	@echo "=== Tier 3: All 4 MCP Tools & Execution Edge Cases ==="
	@printf '{"jsonrpc":"2.0","id":10,"method":"tools/call","params":{"name":"list_themes","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q 'minimax' && echo "PASS: MCP list_themes"
	@printf '{"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"get_theme","arguments":{"theme":"dracula"}}}\n' | ./$(BIN) --mcp | grep -q 'ui_accent' && echo "PASS: MCP get_theme dracula"
	@printf '{"jsonrpc":"2.0","id":12,"method":"tools/call","params":{"name":"resolve_color","arguments":{"token":"ui_accent","theme":"nord"}}}\n' | ./$(BIN) --mcp | grep -q '#88c0d0' && echo "PASS: MCP resolve_color nord"
	@printf '{"jsonrpc":"2.0","id":13,"method":"tools/call","params":{"name":"render_mascot","arguments":{"theme":"minimax","emotion":"happy"}}}\n' | ./$(BIN) --mcp | grep -q 'ascii_art' && echo "PASS: MCP render_mascot minimax"
	@echo "=== Tier 4: Negative Trust & Error Responses & Determinism & Smoke ==="
	@printf 'invalid json string\n' | ./$(BIN) --mcp | grep -q -- "-32600" && echo "PASS: MCP invalid json exits -32600"
	@printf '{"jsonrpc":"1.0","id":30,"method":"ping","params":{}}\n' | ./$(BIN) --mcp | grep -q -- "-32600" && echo "PASS: MCP invalid jsonrpc version exits -32600"
	@printf '{"jsonrpc":"2.0","id":31,"method":"","params":{}}\n' | ./$(BIN) --mcp | grep -q -- "-32600" && echo "PASS: MCP empty method exits -32600"
	@printf '{"jsonrpc":"2.0","id":32,"method":"nonexistent_method","params":{}}\n' | ./$(BIN) --mcp | grep -q -- "-32601" && echo "PASS: MCP unknown method exits -32601"
	@printf '{"jsonrpc":"2.0","id":33,"method":"tools/call","params":{"name":"nonexistent_tool","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q -- "-32601" && echo "PASS: MCP unknown tool exits -32601"
	@printf '{"jsonrpc":"2.0","id":34,"method":"tools/call","params":{"name":"resolve_color","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q -- "-32602" && echo "PASS: MCP resolve_color missing token exits -32602"
	@run1="$$(printf '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp)"; \
	run2="$$(printf '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp)"; \
	test "$$run1" = "$$run2" && echo "PASS: determinism tools/list Run_1 == Run_2"
	@run1="$$(printf '{"jsonrpc":"2.0","id":7,"method":"ping","params":{}}\n' | ./$(BIN) --mcp)"; \
	run2="$$(printf '{"jsonrpc":"2.0","id":7,"method":"ping","params":{}}\n' | ./$(BIN) --mcp)"; \
	test "$$run1" = "$$run2" && echo "PASS: determinism ping Run_1 == Run_2"
	@./install.sh --dry-run > /dev/null && echo "PASS: install.sh --dry-run"
	@./uninstall.sh --dry-run > /dev/null && echo "PASS: uninstall.sh --dry-run"
	@echo "ALL TESTS PASSED"

# --- Packaging targets --------------------------------------------------------

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oote
	@cp uninstall.sh dist/deb-root/usr/bin/oote-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oote dist/deb-root/usr/bin/oote-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oote_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oote_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oote-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/oote-uninstall
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oote.spec > ~/rpmbuild/SPECS/oote.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oote.spec
	@cp ~/rpmbuild/RPMS/x86_64/oote-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oote
	@chmod 0755 dist/arch-pkg/usr/bin/oote
	@cp uninstall.sh dist/arch-pkg/usr/bin/oote-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oote-uninstall
	@printf "pkgname = oote\npkgbase = oote\npkgver = $(VERSION)-1\npkgdesc = Sovereign unified theming and color styling engine for openOODA\nurl = https://github.com/openOODA-tools/oote\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oote\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oote-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oote-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
