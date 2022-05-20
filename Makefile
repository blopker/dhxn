start:
	DEBUG=true dart run --enable-vm-service bin/server.dart

compile:
	dart compile exe -o server bin/server.dart

docker:
	docker build -t dhxn-server .

git:
	@git remote add dokku dokku@ssh.kbl.io:dhxn

deploy:
	@git push dokku main