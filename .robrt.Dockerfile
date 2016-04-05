FROM ubuntu:15.10
ENV PS1="# "
LABEL regen=0
RUN apt-get update
RUN apt-get install -y software-properties-common git
RUN add-apt-repository ppa:haxe/snapshots -y
LABEL haxe_regen=0
RUN apt-get update && apt-get install -y neko haxe && haxelib setup /usr/share/haxe/lib
LABEL haxelib_regen=0
RUN haxelib git hxssl https://github.com/tong/hxssl
RUN haxelib --always install compiletime
RUN haxelib --always install tink_template
RUN haxelib --always install utest
RUN haxelib --always install version
RUN mkdir -p /var/deps/bodge-flare && git clone https://github.com/jonasmalacofilho/bodge-flare.hx /var/deps/bodge-flare && git -C /var/deps/bodge-flare merge-base --is-ancestor b6a0d8e HEAD && haxelib dev bodge-flare /var/deps/bodge-flare

