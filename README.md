# Brewfile

Find—and combine—useful Brewfiles.

## Templates

If you'd like to add/remove/update any templates, feel free to open a PR.

## Running locally

### Build

#### API

From `apps/api`:

```
cd apps/api
nixpacks build . --name brewfile-api
```

`$ docker run -e RACK_ENV=production -p 3000:3000 -it brewfile-api:latest`

#### Website

From `apps/website`:

```
npm run release
docker build -t brewfile-website:1.0.0 .
```

`$ docker run -p 5000:80 -it brewfile-website:latest`

### Start

From `apps`:

```
docker-compose up
```
