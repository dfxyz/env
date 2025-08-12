Add following snippet to enable global proxy:
```ini
[http]
    proxy = http://127.0.0.1:3000/
```

Or add following snippet to enable proxy for specific repository:
```ini
[http "https://github.com"]
    proxy = http://127.0.0.1:3000/
```
