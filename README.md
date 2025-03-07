# 971town (iOS)

A social network built around retail, focusing on cataloging products being sold in physical retail stores in Dubai.

## Setup

Before running the project, you'll need to configure the following values in `API/API/NSOAPI.swift`:

1. `awsS3MediaBucketName`: Your AWS S3 bucket name for media storage
2. `awsS3MediaBucketRegion`: AWS region for your S3 bucket
3. `clientID`: Your 971town API client ID
4. `APIHostnameProduction`: Your production API hostname

For development:

- The app defaults to `localhost:8000` for development
- Set `mode` to `.development` for local development, `.production` for production use

## License

This project is licensed under the terms specified in the LICENSE file.

## Author

Created by Ali Mahouk.
