# Docker for WordPress

## Requirements

- Installed docker & docker-compose
- Installed git
- Keep file called .env in root directory with following content:

```
GITLAB_TOKEN=<your-gitlab-token>
GITLAB_USERNAME=<your-gitlab-username>
```
- Keep file called `backup.sql` in root directory with database dump

## Run docker

```
docker compose up --build
```

## Run docker in background

```
docker compose up --build -d
```

## Stop docker

```
docker compose down
```

## Stop docker and remove volumes

```
docker compose down -v
```

TODOS: 
- [x] Need to change workflow where I am not editing files in container but in host machine only

Note:
https://github.com/wp-cli/wp-cli/issues/1952

bug fix resolutions in the past:
when in doubt rewrite flush