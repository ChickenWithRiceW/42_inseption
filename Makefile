
make:
	mkdir -p ~/data/mysql
	mkdir -p ~/data/wordpress
run: make
	docker compose -f ./srcs/docker-compose.yml up -d --build
stop:
	docker compose -f ./srcs/docker-compose.yml down
nuke: stop
	sudo rm -fr ~/data/*
