
import os, os.path as path

def aaplib(func):
    """
    decorator to add function to AAP's default namespace, so that the
    function can be used in any scope without _no.
    """
    # default namespace is Commands, RecPython, Port and __builtin__.
    import __builtin__
    setattr(__builtin__, func.__name__, func)
    return func

def aapcmd(func):
    """
    decorator to define own aap command.
    function should be named with "aap_*".
    """
    import Process, Commands
    aap_name = func.__name__
    name = func.__name__[len("aap_") : ]
    # 1. append command name to Process.aap_cmd_names list, so that AAP
    #    recognize new command.
    Process.aap_cmd_names.append(name)
    # 2. append function named "aap_*" to Commands module (or other
    #    default namespace).
    setattr(Commands, aap_name, func)
    return func

class WalkItem:
    def __init__(self, name):
        self.skipdir = False
        self.name = name
    def isdir(self): return path.isdir(self.name)
    def dirname(self): return path.dirname(self.name)
    def basename(self): return path.basename(self.name)
    def skip(self): self.skipdir = True

@aaplib
def walk(root=""):
    """
    :python
        for item in walk():
            print item.name
            if item.isdir() and item.name[0] == ".":
                item.skip()
    """
    def _walk(root):
        lst = [path.join(root, name) for name in os.listdir(root)]
        for name in [name for name in lst if path.isfile(name)]:
            yield WalkItem(name)
        for name in [name for name in lst if path.isdir(name)]:
            item = WalkItem(name)
            yield item
            if not item.skipdir:
                for item in _walk(name):
                    yield item
    for item in _walk(root):
        yield item

@aapcmd
def aap_zip(line_nr, recdict, arg):
    """
    :zip {prefix = prefix} zipfile.zip file ...
    {prefix = prefix}   append prefix to all files

    Examples:
      archive current directory tree
        Files =
        :tree .
          Files += $name
        :zip zipfile.zip $Files
    """
    def do_zip(zfile, prefix, files):
        import zipfile
        zip = zipfile.ZipFile(zfile, "w", zipfile.ZIP_DEFLATED)
        for name, arcname in [(name, path.join(prefix, name)) for name in files]:
            if path.isdir(name): zip.writestr(arcname + "/", "")
            else: zip.write(name, arcname)
        zip.close()

    from Commands import get_args, dictlist_expand
    opts, attrs, args = get_args(line_nr, recdict, arg)
    args = dictlist_expand(args)    # expand wildcards
    prefix = attrs.get("prefix", "")
    args = [path.normpath(t["name"]) for t in args]
    zfile = args[0]
    files = args[1:]
    if zfile in files: files.remove(zfile)
    do_zip(zfile, prefix, files)

@aapcmd
def aap_unzip(line_nr, recdict, arg):
    """
    :unzip zipfile.zip [dir]
    [dir]   Extract into dir.
            When all files are placed in one top-level directory, the
            top-level directory is replaced with dir.
    """
    def do_unzip(zipfile, dir):
        import zipfile
        zip = zipfile.ZipFile(zfile, "r")
        namelist = zip.namelist()
        if dir:
            prefix = path.commonprefix(namelist)
            try: prefix = prefix[: prefix.index("/")]
            except: prefix = None
        def realpath(arcname):
            if dir:
                if prefix: return arcname.replace(prefix, dir, 1)
                else: return path.join(dir, arcname)
            else:
                return arcname
        for arcname, name in [(name, realpath(name)) for name in namelist]:
            if not path.exists(path.dirname(name)):
                os.makedirs(path.dirname(name))
            if not name.endswith("/"):
                f = open(name, "w")
                f.write(zip.read(arcname))
                f.close()
        zip.close()

    from Commands import get_args, dictlist_expand
    opts, attrs, args = get_args(line_nr, recdict, arg)
    args = dictlist_expand(args)    # expand wildcards
    zfile = path.normpath(args[0]["name"])
    try: dir = args[1]["name"]
    except: dir = None
    do_unzip(zfile, dir)

