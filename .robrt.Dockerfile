FROM ubuntu:15.10
ENV PS1="# "
LABEL regen=0
RUN apt-get update
RUN apt-get install -y software-properties-common git
RUN add-apt-repository ppa:haxe/snapshots -y
LABEL haxe_regen=1
RUN apt-get update && apt-get install -y neko haxe && haxelib setup /usr/share/haxe/lib
LABEL haxelib_regen=0
RUN haxelib --always install compiletime
RUN haxelib --always install tink_template
RUN haxelib --always install utest
RUN haxelib --always install version
RUN mkdir -p /var/deps/bodge-flare && git clone https://github.com/jonasmalacofilho/bodge-flare.hx /var/deps/bodge-flare && git -C /var/deps/bodge-flare merge-base --is-ancestor cb4a6c3 HEAD && haxelib dev bodge-flare /var/deps/bodge-flare
RUN mkdir -p /var/deps/bodge-ndlls && git clone https://github.com/jonasmalacofilho/bodge-ndlls.hx /var/deps/bodge-ndlls && git -C /var/deps/bodge-ndlls merge-base --is-ancestor ca14f68 HEAD && haxelib dev bodge-ndlls /var/deps/bodge-ndlls
RUN mkdir -p /var/deps/eweb && git clone https://github.com/jonasmalacofilho/eweb.hx /var/deps/eweb && git -C /var/deps/eweb merge-base --is-ancestor fa0980f HEAD && haxelib dev eweb /var/deps/eweb

