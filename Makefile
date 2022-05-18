start:
	dart run --enable-vm-service bin/server.dart

compile:
	dart compile exe -o server bin/server.dart

git:
	@git remote add dokku dokku@ssh.kbl.io:dhxn

deploy:
	@git push dokku master