rebase local_image=(registry / device + "-" + desktop + ":" + tag):
    sudo rpm-ostree rebase ostree-unverified-image:containers-storage:{{local_image}}
