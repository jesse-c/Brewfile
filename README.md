# Brewfile

Find—and combine—useful Brewfiles.

## Templates

If you'd like to add/remove/update any templates, feel free to open a PR.

## Running locally

### API

```
cd apps/api
docker build -t brewfile-api:1.0.0 .
```

### Website

```
cd apps/website
npm run release
docker build -t brewfile-website:1.0.0 .
```

### Both

```
cd apps
docker-compose up
```
