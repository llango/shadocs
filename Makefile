.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## 删除所有构建、测试、覆盖和Python文件。

clean-build: ## 删除构建文件
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## 删除python生成的文件
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## 删除测试和覆盖构成文件
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## 检查样式和flake8
	flake8 shadocs tests

test: ## 使用默认Python快速运行测试
	python setup.py test

test-all: ## 使用 tox 对每个 Python 版本进行测试
	tox

coverage: ## 使用默认 Python 快速检查代码覆盖率
	coverage run --source shadocs setup.py test
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs: ## 生成Sphinx HTML文档，包括API文档
	rm -f docs/shadocs.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ shadocs
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## 编译记录变化的文档
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## 打包并上传一个版本
	twine upload dist/*

dist: clean ## 构建源代码和 wheel 包
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## 将该包安装到激活的 Python 环境的 site-packages 中
	python setup.py install
