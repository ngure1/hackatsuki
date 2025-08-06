PROTO_DIR=proto
OUT_BIN=out

protogen:
	@find $(PROTO_DIR) -name '*.proto' | while read proto_file; do \
		dir=$$(dirname $$proto_file); \
		out_dir=$$dir/generated; \
		mkdir -p $$out_dir; \
		protoc --proto_path=$(PROTO_DIR) \
			$$proto_file \
			--go_out=$$out_dir --go_opt=paths=source_relative \
			--go-grpc_out=$$out_dir --go-grpc_opt=paths=source_relative; \
		echo -e "Generated: $$proto_file → $$out_dir \n"; \
	done

run:
	@air
