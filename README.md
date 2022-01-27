Skims SSTV off spyservers using QSSTV and uploads to mastodon. This is a WIP and shouldn't be considered as stable.

```sh
docker run \
-e HOST= \
-e PORT= \
-e FREQ=14230000 \
-e M_USERNAME="" \
-e M_PASSWORD='' \
-e M_URL="https://botsin.space" \
-e M_CLIENT_ID='' \
-e M_CLIENT_SECRET='' \
-e MODE=USB \
--restart always \
--name sstv-20 \
ghcr.io/xssfox/sstv-skimmer:latest
```



Environment variables
==
These need to be in order for the skimmer to work

| Name | Description                                                                                                  |
| ---- | ------------------------------------------------------------------------------------------------------------ |
| HOST | spy server hostname                                                                                          | 
| PORT | spy server port port                                                                                         |
| FREQ | frequency for USB in HZ                                                                                      |
| MODE | USB or LSB                                                                                                   |
| M_USERNAME | User name for mastodon instance                                                                        |
| M_PASSWORD | Password for mastodon instance                                                                         |
| M_URL |  Mastodon url eg : "https://botsin.space"                                                                   |
| M_CLIENT_ID | Client ID                                                                                             |
| M_CLIENT_SECRET | Client secret (see https://mastodonpy.readthedocs.io/en/stable/# for  details on creating an app) | 
