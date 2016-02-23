FROM ubuntu:15.10
ENV PS1="# "
LABEL regen=0
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:haxe/snapshots -y
LABEL haxe_regen=0
RUN apt-get update && apt-get install -y neko haxe && haxelib setup /usr/share/haxe/lib
LABEL haxelib_regen=0
RUN haxelib git hxssl https://github.com/tong/hxssl
RUN haxelib install sapo.hxml
RUN haxelib install unit.hxml
RUN haxelib install comn.hxml
RUN haxelib install sync.hxml

