SRC = src
TESTS = tests

DELIM = ----------------------------
CFLAGS = "-w A -for-pack Sate"
APP_BUILD_FLAGS = $(CFLAGS)
TEST_CFLAGS = "-w A"
LIB_NAME = sate
TEST_BUILD_MODE = byte

tests: problem_tests problem_run_tests interaction_tests
	@echo $(DELIM) Finished testing
	@say All $(LIB_NAME) tests pass &

cli: $(SRC)/*.mli $(SRC)/*.ml
	@echo $(DELIM)
	@echo Building cli...
	@echo $(DELIM)
	@ocamlbuild -use-ocamlfind -cflags $(APP_BUILD_FLAGS) cli.native
	@mv cli.native sate-cli
	@say c l i build complete &

install: clean uninstall $(LIB_NAME)
	@echo $(DELIM) Installing...
	@ocamlfind install $(LIB_NAME) META _build/$(LIB_NAME).cmi _build/$(LIB_NAME).cmo _build/$(LIB_NAME).cmx _build/$(LIB_NAME).o
	@echo $(DELIM) installed...
	@say $(LIB_NAME) install complete &

uninstall:
	@echo $(DELIM) Uninstalling...
	@ocamlfind remove $(LIB_NAME)

%_tests: $(TESTS)/*.ml $(SRC)/*.mli $(SRC)/*.ml
	@echo $(DELIM) Testing $@...
	@ocamlbuild -use-ocamlfind -cflags $(TEST_CFLAGS) $@.byte
	@time ./$@.byte

$(LIB_NAME): $(SRC)/*.mli $(SRC)/*.ml
	@echo $(DELIM) Building $(LIB_NAME)...
	@ocamlbuild $(LIB_NAME).cmo -use-ocamlfind -cflags $(CFLAGS)
	@echo $(DELIM) Building native $(LIB_NAME)...
	@ocamlbuild $(LIB_NAME).cmx -use-ocamlfind -cflags $(CFLAGS)

%.byte: $(SRC)/%.ml
	@echo $(DELIM) Building $@... from $<
	ocamlbuild -use-ocamlfind -cflags $(CFLAGS) $@

%.native: $(SRC)/%.ml
	@echo $(DELIM) Building $@... from $<
	ocamlbuild -use-ocamlfind -cflags $(CFLAGS) $@

clean:
	@echo $(DELIM) Cleaning up... $(DELIM)
	@ocamlbuild -clean
	@rm -f *.logs
