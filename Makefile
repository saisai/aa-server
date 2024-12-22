.PHONY: aa-webui build install test typecheck package clean

# build: aa-webui
# 	poetry install


build: 
	poetry install

aa-webui:
	# mkdir -p aa_server/static/
ifeq ($(SKIP_WEBUI),true) # Skip building webui if SKIP_WEBUI is true
	@echo "Skipping building webui"
else
	rm -rf aa_server/static/*
	make --directory=aa-webui build DEV=$(DEV)
	cp -r aa-webui/dist/* aa_server/static/
	# Needed for https://github.com/ActivityWatch/activitywatch/pull/274, works around https://github.com/pypa/pip/issues/6279
	# https://github.com/ActivityWatch/activitywatch/pull/367 Other solutions have been tried but did not actually work.
	# If you aren't sure windows long paths are working, don't remove this
	rm -rf aa-webui/node_modules/.cache
endif

install:
	cp misc/aa-server.service /usr/lib/systemd/user/aa-server.service

test:
	@# Note that extensive integration tests are also run in the bundle repo,
	@# for both aa-server and aa-server-rust, but without code coverage.
	python -c 'import aa_server'
	python -m pytest tests/test_server.py

typecheck:
	python -m mypy aa_server tests --ignore-missing-imports

package: bump-version
	rm -rf dist
	pyinstaller aa-server.spec --clean --noconfirm

PYFILES=$(shell find . -name '*.py')

lint:
	ruff check .

lint-fix:
	poetry run pyupgrade --py38-plus --exit-zero-even-if-changed $(PYFILES)
	ruff check --fix .

format:
	black .

bump-version:
	@# make sure to pull tags in parent repo before running this
	poetry run python -m aa_server.__about__
	VERSION=$$(grep -oP '__version__ = "v\K[^"]+' aa_server/__about__.py | head -n1); echo $$VERSION; poetry version $$VERSION

clean:
	rm -rf build dist
	rm -rf aa_server/__pycache__
	rm -rf aa_server/static/*
	pip3 uninstall -y aa_server
	make --directory=aa-webui clean
