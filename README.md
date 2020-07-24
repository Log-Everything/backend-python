# Log Everything Python backend

## Setup dev environment

1. Install [gCloud](https://cloud.google.com/sdk/install)
2. Install [Data Store emulator](https://cloud.google.com/datastore/docs/tools/datastore-emulator)
   ```bash
   gcloud components install cloud-datastore-emulator
   ```
3. Install requirements
   ```bash
   pip install -r requirements.txt
   ```
   
## Run dev environment

```bash
gcloud beta emulators datastore start
```

In different terminal:

```bash
$(gcloud beta emulators datastore env-init)
python main.py
```


## Deploy

```bash
gcloud config set project logeverything
gcloud app deploy
```

## Flutter

### Test

```bash
./flutterw run -d chrome --web-hostname 127.0.0.1 --web-port 8080
```

### Release
```bash
./flutterw build web --release
```