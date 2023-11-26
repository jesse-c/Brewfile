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

#### Website

From `apps/website`:

```
docker build -t brewfile-website:1.0.0 .
```

### Start

From `apps`:

```
docker-compose up
```
