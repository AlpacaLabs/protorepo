SHELL += -eu

BLUE  := \033[0;34m
GREEN := \033[0;32m
RED   := \033[0;31m
NC    := \033[0m

GO111MODULE := on

BUILD_DIR := compiled

SERVICES := auth pagination

.PHONY: lint
lint:
	docker run --volume "$(shell pwd):/workspace" --workdir /workspace bufbuild/buf check lint

.PHONY: all
all:
	@$(MAKE) check
	@echo "${BLUE}✓ Publishing changes to GitHub...${NC}\n"
	@./build.sh
	@echo "${GREEN}✓ All done!${NC}\n"

.PHONY: check
check:
	@$(MAKE) clean
	@echo "${BLUE}✓ Making sure code compiles...${NC}\n"
	@mkdir -p ${BUILD_DIR}
	@for service in ${SERVICES} ; do \
	    echo "${GREEN}✓ Compiled $$service!${NC}\n"; \
	    mkdir -p ${BUILD_DIR}/$$service; \
	    protoc -I . ./alpacalabs/$$service/v1/*.proto --go_out=plugins=grpc,paths=source_relative:./${BUILD_DIR}/$$service; \
	done
	@echo "${GREEN}✓ Everything compiles!${NC}\n"

.PHONY: clean
clean:
	@rm -rf ${BUILD_DIR} || true
	@for service in ${SERVICES} ; do \
	    rm -rf $$service/pb-* || true; \
	done

.PHONY: install-proto
install-proto:
	brew install protobuf
	go get -u github.com/golang/protobuf/protoc-gen-go