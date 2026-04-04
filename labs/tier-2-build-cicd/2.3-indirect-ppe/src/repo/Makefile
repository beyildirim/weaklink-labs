.PHONY: test build deploy clean

test:
	@echo "Running test suite..."
	python test_app.py

build:
	@echo "Building application..."
	mkdir -p dist
	cp app.py dist/
	cp requirements.txt dist/
	tar czf webapp.tar.gz dist/

deploy:
	@echo "Deploying application..."

clean:
	rm -rf dist/ webapp.tar.gz
