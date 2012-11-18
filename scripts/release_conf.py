import os

with open("src/conf.lua.bak") as f:
    conf = f.read()

    conf = conf.replace("t.release           = false",
                        "t.release           = true")

    if "MIXPANEL_TOKEN" in os.environ:
        conf = conf.replace("ac1c2db50f1332444fd0cafffd7a5543",
                            os.environ["MIXPANEL_TOKEN"])

    with open("src/conf.lua", "w") as g:
        g.write(conf)
