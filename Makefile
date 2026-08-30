.PHONY: github-runner-token

WORKSPACE_ROOT := ../../..

github-runner-token:
	@if [ ! -x "$(WORKSPACE_ROOT)/tools/setup-github.sh" ]; then \
		echo "This helper requires the lmbek-hobby-workspace checkout; run it from that workspace." >&2; \
		exit 1; \
	fi
	@cd "$(WORKSPACE_ROOT)" && ./tools/setup-github.sh runner-token