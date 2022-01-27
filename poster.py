print("Starting mastodon watcher")
from mastodon import Mastodon
import os

import time
from watchdog.observers.polling import PollingObserver
from watchdog.events import FileSystemEventHandler



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
    # create post
    print(f"new Image: {event.src_path}")
    time.sleep(2)
    media = mastodon.media_post(event.src_path, "image/png")
    mastodon.status_post('SSTV Image received:', media_ids=[media["id"]])
   

my_event_handler.on_created = on_created

my_observer = PollingObserver()
my_observer.schedule(my_event_handler, "/images/")
my_observer.start()
my_observer.join()