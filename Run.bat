@echo off
cd www
set SAPO_DB=.sapo.db3
set STATIC_FILES=./private/csvs/
nekotools server -rewrite
pause
