import gdb


class StructNamePrinter:
    "Print a struct name"

    def __init__(self, val):
        self.val = val

    def to_string(self):
        return "TODO"


def struct_name_lookup_function(val):
    if str(val.type) == 'struct name':
        return StructNamePrinter(val)

    return None


gdb.pretty_printers.append(struct_name_lookup_function)


class PrintSList (gdb.Command):
    def __init__(self):
        super(PrintSList, self).__init__("printslist", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        args = gdb.string_to_argv(arg)
        if len(args) < 2:
            print("Usage: printslist <list head> <next field name>")
            return

        list = gdb.parse_and_eval(args[0])
        next_field = args[1]
        elem = list['slh_first']
        while elem != 0:
            print(elem.dereference())
            elem = TODO


PrintSList()
