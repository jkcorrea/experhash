ERLANG_BASE = $(shell erl -eval 'io:format("~s", [code:root_dir()])' -s init stop -noshell)/usr

CXXFLAGS += -std=c++11 -g $(shell pkg-config --cflags Magick++) -I$(ERLANG_BASE)/include -L$(ERLANG_BASE)/lib
LDFLAGS += -lei $(shell pkg-config --libs Magick++)

SOURCES = $(wildcard cpp/src/*.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
HEADER_DEPS = $(SOURCES:.cpp=.d)

priv/experhash_port: $(OBJECTS) | priv
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

priv:
	mkdir -p $@

cpp/src/%.d: cpp/src/%.cpp
	@set -e; \
	rm -f $@; \
	$(CXX) -MM -MT '$(@:.d=.o) $@' -MF $@ $(CPPFLAGS) $(CXXFLAGS) $<

include $(HEADER_DEPS)

.PHONY: clean
clean:
	rm -rf priv/ $(OBJECTS) $(HEADER_DEPS)

