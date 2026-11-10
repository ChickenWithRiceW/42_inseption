LOGIN   := ascheufe
DATA    := /home/$(LOGIN)/data
COMPOSE := docker compose -f ./srcs/docker-compose.yml

all: up

# Create the host directories behind the named volumes, then build + start.
up:
	mkdir -p $(DATA)/mysql $(DATA)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop: down

# Remove containers, images and the named volumes (host data is kept).
clean:
	$(COMPOSE) down --rmi all --volumes

# Also wipe the persistent data on the host.
fclean: clean
	sudo rm -rf $(DATA)/mysql $(DATA)/wordpress

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all up down stop clean fclean re logs ps
