.PHONY: test lint

test:
	@echo "➡️ Running Prettier..."
	npx --yes prettier@2.8.8 --editorconfig --check .

	@echo "➡️ Running Hadolint..."
	find . -name "Dockerfile*" -exec bash -c "echo 'File {}:' && hadolint {}" \;

	@echo "➡️ Running Azure Bicep Validate..."
	az deployment sub validate \
		--location westeurope \
		--no-prompt \
		--parameters test/bicep/parameters.json \
		--template-file src/bicep/main.bicep \
		--verbose

lint:
	@echo "➡️ Running Prettier..."
	npx --yes prettier@2.8.8 --editorconfig --write .

	@echo "➡️ Running Hadolint..."
	find . -name "Dockerfile*" -exec bash -c "echo 'File {}:' && hadolint {}" \;

	@echo "➡️ Running Azure Bicep Validate..."
	az deployment sub validate \
		--location westeurope \
		--no-prompt \
		--parameters test/bicep/parameters.json \
		--template-file src/bicep/main.bicep \
		--verbose

deploy-bicep:
	@echo "➡️ Deploying Bicep..."
	az deployment sub create \
		--location westeurope \
		--no-prompt \
		--parameters test/bicep/parameters.json \
		--template-file src/bicep/main.bicep \
		--what-if \
		--debug
