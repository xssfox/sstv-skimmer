print("Starting mastodon watcher")
from mastodon import Mastodon
import os
import traceback
import cv2

import requests
import json
import base64

import time
from watchdog.observers.polling import PollingObserver
from watchdog.events import FileSystemEventHandler

import os

mastodon = Mastodon(
    client_id = os.environ["M_CLIENT_ID"],
    client_secret = os.environ["M_CLIENT_SECRET"],
    api_base_url = os.environ["M_URL"]
)

mastodon.log_in(
    os.environ["M_USERNAME"],
    os.environ["M_PASSWORD"]
)

print("Logged into Mastodon")

patterns = ["*.png"]
my_event_handler = FileSystemEventHandler()


def on_created(event):
    try:
        # create post
        print(f"new Image: {event.src_path}")

        time.sleep(2)
        if event.src_path.endswith(".jp2"):
            # treat as DRM
            image = cv2.imread(event.src_path)
            cv2.imwrite('/tmp/drm.png', image)
            path = '/tmp/drm.png'
            sstv_mode = "DRM"
            message = f"SSTV {sstv_mode} Image received on {int(os.environ['FREQ'])/1000000:.3f} MHz {os.environ['MODE']}. Filename: {event.src_path.split('/')[-1]}\n#sstv #{sstv_mode} #{int(os.environ['FREQ'])/1000:.0f}kHz\n"
        elif event.src_path.startswith("/drm/"):
            path = event.src_path
            sstv_mode = "DRM"
            message = f"SSTV {sstv_mode} Image received on {int(os.environ['FREQ'])/1000000:.3f} MHz {os.environ['MODE']}. Filename: {event.src_path.split('/')[-1]}\n#sstv #{sstv_mode} #{int(os.environ['FREQ'])/1000:.0f}kHz\n"
        else:
            path = event.src_path
            sstv_mode, date, time_var = event.src_path.split("/")[-1].split("_")
            date = event.src_path.split("/")[-1].split("_")[1]
            date = f"{date[:4]}-{date[4:6]}-{date[6:]}"
            time_var = f"{time_var[:2]}:{time_var[2:4]}:{time_var[4:6]}"
            message = f"SSTV {sstv_mode} Image received on {int(os.environ['FREQ'])/1000000:.3f} MHz {os.environ['MODE']} at {date} {time_var} UTC\n#sstv #{sstv_mode} #{int(os.environ['FREQ'])/1000:.0f}kHz\n"
        
        media = mastodon.media_post(path, "image/png", description="Image received by slow scan television")
        
        media_ids = [media["id"]]

        print(message)
        if sstv_mode != "BW12":
            mastodon.status_post(message, media_ids=media_ids, visibility="unlisted")
        os.remove(event.src_path)
    except:
        print(traceback.format_exc())

my_event_handler.on_created = on_created

my_observer = PollingObserver()
my_observer.schedule(my_event_handler, "/drm/")
my_observer.schedule(my_event_handler, "/images/")
my_observer.start()
my_observer.join()