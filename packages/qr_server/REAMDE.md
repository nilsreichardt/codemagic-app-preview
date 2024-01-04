# QR Server

To display a QR inside the PR comment, we need a way to generate the QR code.
This is done by a simple cloud function.

## Usage

Call the cloud function with the following parameters:

```
https://createqrcode-rdchost62q-ey.a.run.app/?data=DATA&size=200&platform=PLATFORM&groupId=GROUPID
```

See `src/index.ts` for documentation of the parameters.

## Export to BigQuery

```sh
gcloud firestore export gs://codemagic-app-preview.appspot.com/exports/2024-01-04 \
  --collection-ids=QrActivities \
  --project codemagic-app-preview
```