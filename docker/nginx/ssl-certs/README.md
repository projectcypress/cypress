## Overview

Self signed certificates were created using `minica`: https://github.com/jsha/minica

`minica.txt` is the root certificate used when creating the `minica` certificate pairs. 

All self signed `minica` certificate pair files are for local development only. These only need to be generated once and can be shared afterwards.

All files are `.pem` formatted but renamed as `.txt` due to MITRE Gitlab's pre-receive hook that prevents committing secrets. We only do this because 
these are for local development only, never deployment. 

## certs/localhost

Self signed certificate for the `localhost` domain and `127.0.0.1` IP address

```bash
# Generate self-signed minica certs for localhost
git clone https://github.com/jsha/minica.git
docker run --rm -v ./minica/:/usr/src/minica/ -w /usr/src/minica golang:latest bash -c "go build && ./minica --domains 'localhost,127.0.0.1'"

# Copy certs into repo with .txt extension due to MITRE Gitlab pre-receive hook
cp minica/localhost/cert.pem docker/ssl-certs/cert.txt
cp minica/localhost/key.pem docker/ssl-certs/key.txt
```