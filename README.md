# Brewfile

[![Test](https://github.com/jesse-c/Brewfile/actions/workflows/test.yml/badge.svg)](https://github.com/jesse-c/Brewfile/actions/workflows/test.yml)

Find—and combine—useful Brewfiles.

## Templates

If you'd like to add/remove/update any templates, feel free to open a PR.

## Running locally

### Build

`$ make build`

### Run

`$ make run`

### Testing

Run all tests:
```
$ make test
```

Run only API tests:
```
$ make test-api
```

Run API tests with verbose output:
```
$ make test-api-verbose
```

Run selected API test files (Rake 13.4 supports multiple files in `TEST`):
```
$ TEST="spec/app_spec.rb spec/config_spec.rb" make test-api
```

Run only website tests:
```
$ make test-website
```

Run website tests in watch mode (for development):
```
$ make test-website-watch
```
