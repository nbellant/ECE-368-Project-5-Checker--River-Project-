GCC = gcc
CFLAGS = -g -O3 -Werror -Wall -Wshadow -Wbad-function-cast
SOURCES = river.c
TARGET = proj5

TESTSMALLN := $(shell seq 0 9999)
TESTMEDN := $(shell seq 0 2499)
TESTLARGEN := $(shell seq 0 199)

OBJF = obj
OBJS = $(patsubst %.c,$(OBJF)/%.o,$(SOURCES))
HDRS = $(SOURCES:.c=.h)

-include $(SOURCES:%=$(OBJF)/%.P)



TESTSSMALL := $(addprefix testsm,${TESTSMALLN})
TESTSMED := $(addprefix testmed,${TESTMEDN})
TESTSLARGE := $(addprefix testlg,${TESTLARGEN})

INDIR =inputs
SMALLINDIR =inputs-10k-small
MEDINDIR =inputs-2500-med
LARGEINDIR =inputs-200-large
OUTDIR =outputs
SMALLOUTDIR =small-outputs
MEDOUTDIR =med-outputs
LARGEOUTDIR =large-outputs

EXPECTEDDIR =expected-outputs

.PHONY : all build environment testall testsmall testmed testlarge 

all: clean build testall  

build: $(TARGET)

testall: | environment $(TESTSSMALL) $(TESTSMED) $(TESTSLARGE)

testallsmall: | environment $(TESTSSMALL)

testallmed: | environment $(TESTSMED)

testalllarge:| environment $(TESTSLARGE)

clean: 
	@cd $(CURDIR)
	rm -rf $(TARGET)
	rm -rf $(OUTDIR)

$(TARGET): $(OBJS) $(HDRS) | environment
	$(GCC) $(CFLAGS) $(OBJS) -o $@

$(OBJF)/%.o: %.c | environment
	@$(GCC) -MM $(CFLAGS) $< | sed 's,^\([^ ]\),$(OBJF)\/\1,g' | sed '$$ s,$$, \\,' > $(OBJF)/$<.P
	$(GCC) $(CFLAGS) -c -o $@ $<
	
%.o: %.c
	$(GCC) $(CFLAGS) -c $<

environment:
	@cd $(CURDIR)
	@mkdir -p $(OBJF)
	@mkdir -p $(EXPECTEDDIR)
	@mkdir -p $(OUTDIR)
	@mkdir -p $(OUTDIR)/$(SMALLOUTDIR)
	@mkdir -p $(OUTDIR)/$(MEDOUTDIR)
	@mkdir -p $(OUTDIR)/$(LARGEOUTDIR)
	

${TESTSSMALL}: testsm%: $(TARGET) | environment
	@echo '========================================================'
	@echo "                      small test$*                    "
	@echo '========================================================'
	./$(TARGET) $(INDIR)/$(SMALLINDIR)/river.in$* > $(OUTDIR)/$(SMALLOUTDIR)/river.out$*
	diff -w -b $(OUTDIR)/$(SMALLOUTDIR)/river.out$* $(EXPECTEDDIR)/$(SMALLOUTDIR)/river.out$*

${TESTSMED}: testmed%: $(TARGET) | environment
	@echo '========================================================'
	@echo "                      medium test$*                   "
	@echo '========================================================'
	./$(TARGET) $(INDIR)/$(MEDINDIR)/river.in$* > $(OUTDIR)/$(MEDOUTDIR)/river.out$*
	diff -w -b $(OUTDIR)/$(MEDOUTDIR)/river.out$* $(EXPECTEDDIR)/$(MEDOUTDIR)/river.out$*

${TESTSLARGE}: testlg%: $(TARGET) | environment
	@echo '========================================================'
	@echo "                       large test$*                    "
	@echo '========================================================'
	./$(TARGET) $(INDIR)/$(LARGEINDIR)/river.in$* > $(OUTDIR)/$(LARGEOUTDIR)/river.out$*
	diff -w -b $(OUTDIR)/$(LARGEOUTDIR)/river.out$* $(EXPECTEDDIR)/$(LARGEOUTDIR)/river.out$*

