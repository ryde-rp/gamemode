local cfg = {}

cfg.save_interval = 60 -- seconds
cfg.ignore_ip_identifier = true -- This will allow multiple same IP connections (for families etc)

cfg.load_duration = 5 -- seconds, player duration in loading mode at the first spawn
cfg.load_delay = 0 -- milliseconds, delay the tunnel communication when in loading mode
cfg.global_delay = 0 -- milliseconds, delay the tunnel communication when not in loading mode

cfg.debug = false

cfg.whitelist = false -- To Change

return cfg