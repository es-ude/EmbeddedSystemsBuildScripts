def cpu_frequency_flag():
    options = {}
    prefix = "@AvrToolchain//platforms/cpu_frequency:"
    for frequency in range(1,32):
        options[prefix + "{}mhz_config".format(frequency)] = ["-DF_CPU={}000000UL".format(frequency)]
    options["//conditions:default"] = []
    return select(options)