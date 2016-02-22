@echo off
cd www
set SAPO_DB=.sapo.db3
nekotools server -rewrite
pause
