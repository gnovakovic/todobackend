rem 
@echo off
cls
if %1.==. goto :help

setlocal ENABLEDELAYEDEXPANSION

set PROJ_NAME=todobackend
set ORG_NAME=
set REPO_NAME=todobackend
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
	docker-compose -p %REL_PROJ% -f %REL_DOCF% rm -f -v

	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% kill
	docker-compose -p %DEV_PROJ% -f %DEV_DOCF% rm -f -v


	docker images -q -f dangling=true -f label=application=%REPO_NAME% > dangling.tmp
	rem -f label=application=%REPO_NAME%
	
	for /f %%a in (dangling.tmp) do (
		echo  "%%a"
		docker rmi -f %%a
	)

	goto :end
)

if %1.==xxx. (
	echo XXX
	echo.


	docker volume ls  -q -f dangling=true > dangling.tmp

	for /f %%a in (dangling.tmp) do (
		echo  "%%a"
		docker volume rm  %%a
	)

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