import re

def Filter(**kargs):
    value = kargs['value']
    def filt(data, sr, sctx, sccol, matches):
        for m in matches:
            m['dup'] = value
        return matches
    return filt
