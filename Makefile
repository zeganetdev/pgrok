REGISTRY?=jerson/pgrok
APP_VERSION?=latest
.PHONY: default server client deps fmt clean all release-all assets client-assets server-assets contributors

default: deps build

deps: 
	go mod download

compress:
	upx pgrokd
	upx pgrok

server: deps
	go build -o pgrokd ./cmd/pgrokd

fmt:
	go fmt ./...

client: deps
	go build -o pgrok.exe ./cmd/pgrok

assets: client-assets server-assets

go-bindata:
	go get github.com/jteeuwen/go-bindata/go-bindata

client-assets: go-bindata
	go-bindata -nomemcopy -pkg=assets -tags=$(BUILDTAGS) -o="client/assets/all.go" assets/client/...

server-assets: go-bindata
	go-bindata -nomemcopy -pkg=assets -tags=$(BUILDTAGS) -o="server/assets/all.go" assets/server/...

build: assets client server

clean:
	go clean -i -r ./...
	rm -rf client/assets/ server/assets/

contributors:
	echo "Contributors to pgrok, both large and small:\n" > CONTRIBUTORS
	git log --raw | grep "^Author: " | sort | uniq | cut -d ' ' -f2- | sed 's/^/- /' | cut -d '<' -f1 >> CONTRIBUTORS

registry: registry-build registry-push

registry-build:
	docker build --pull -t $(REGISTRY):$(APP_VERSION) .

registry-pull:
	docker pull $(REGISTRY):$(APP_VERSION)

registry-push:
	docker push $(REGISTRY):$(APP_VERSION)
