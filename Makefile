# Via http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

docker-build: ## Build docker container
	docker build -t craigslist-renew .

docker-run: docker-build ## Compile & run the application with the default configuration
	touch "$$HOME/Downloads/craigslist.log"
	docker run \
		--rm -it \
		-v "$$HOME/Nextcloud/craigslist/craigslist-renew.yml:/tmp/craigslist-renew.yml:ro" \
		-v "$$HOME/Nextcloud/craiglist/craigslist.log:/tmp/craigslist-renew.log" \
		craigslist-renew

docker-console: docker-build ## Get a bash console in docker container
	docker run \
		--rm -it \
		--entrypoint /bin/bash \
		-v "$$HOME/Nextcloud/craigslist/craigslist-renew.yml:/tmp/craigslist-renew.yml" \
		craigslist-renew

