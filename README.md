Skims SSTV off spyservers and uploads to mastodon. This setup is a POC and currently has no handling of qsstv failure, spyserver failure or mastodon script failure. Your milage may vary. I'd recommend reboot the container every 24 hours.

```
docker run -e HOST=blah -e PORT=1234 -e FREQ=14230000 --mount type=bind,source=/path/images,target=/images sstv
```
env variables that need to be set:

HOST : spy server hostname
PORT : spy server port port 
FREQ : frequency for USB in HZ
M_USERNAME : User name for mastodon instance
M_PASSWORD : Password for mastodon instance
M_URL :  Mastodon url eg : "https://botsin.space"
M_CLIENT_ID : Client ID
M_CLIENT_SECRET : Client secret (see https://mastodonpy.readthedocs.io/en/stable/# for details on creating an app)
