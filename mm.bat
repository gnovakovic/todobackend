rem 
@echo off
cls
if %1.==. goto :help

setlocal ENABLEDELAYEDEXPANSION

set PROJ_NAME=todobend
set ORG_NAME=
set REPO_NAME=
set BUILD_ID=
set DEV_DOCF=docker/dev/docker-compose.yml
set REL_DOCF=docker/release/docker-compose.yml

set REL_PROJ=%PROJ_NAME%%BUILD_ID%
set DEV_PROJ="%REL_PROJ%dev"

if %1.==test. (
	echo TEST
	echo.
	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% build
	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% up agent
	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% up test
	goto :end
)


if %1.==build. (
	echo BUILD
	echo.
	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% up builder
	goto :end
)

if %1.==release. (
	echo RELEASE
	echo.
	docker-compose -p %REL_PROJ% -f %REL_DOCF% build
	docker-compose -p %REL_PROJ% -f %REL_DOCF% up agent
	docker-compose -p %REL_PROJ% -f %REL_DOCF% run --rm app manage.py collectstatic --noinput
	docker-compose -p %REL_PROJ% -f %REL_DOCF% run --rm app manage.py migrate --noinput
	docker-compose -p %REL_PROJ% -f %REL_DOCF% up test
	goto :end
)

if %1.==clean. (
	echo CLEAN
	echo.
	docker-compose -p %REL_PROJ% -f %REL_DOCF% kill
	docker-compose -p %REL_PROJ% -f %REL_DOCF% rm -f

	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% kill
	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% rm -f
	goto :end
)

:help
echo.
echo     Pass environment as param: 
echo        - test
echo        - build
echo        - release
echo        - clean


:end
endlocal