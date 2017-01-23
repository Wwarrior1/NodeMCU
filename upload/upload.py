import csv
import os

import subprocess

import time


class Specification:
    def __init__(self):
        self.baud_rate = 115200
        self.port = "COM4"
        self.compile = False
        self.restart = False
        self.dofile = False
        self.verbose = False
        self.wipe = False
        self.echo = False
        self.delay = str(delay_min)
        self.basedir = ".."

    def copy(self):
        copy = Specification()
        copy.baud_rate = self.baud_rate
        copy.port = self.port
        copy.compile = self.compile
        copy.restart = self.restart
        copy.dofile = self.dofile
        copy.verbose = self.verbose
        copy.wipe = self.wipe
        copy.echo = self.echo
        copy.delay = self.delay
        copy.basedir = self.basedir
        return copy

    def __str__(self):
        return 'baud_rate: ' + str(self.baud_rate) + "\n" + \
               'port: ' + str(self.port) + "\n" + \
               'compile: ' + str(self.compile) + "\n" + \
               'restart: ' + str(self.restart) + "\n" + \
               'dofile: ' + str(self.dofile) + "\n" + \
               'verbose: ' + str(self.verbose) + "\n" + \
               'wipe: ' + str(self.wipe) + "\n" + \
               'echo: ' + str(self.echo) + "\n" + \
               'delay: ' + str(self.delay) + "\n" + \
               'basedir: ' + str(self.basedir)

    def __repr__(self):
        return str(self)


# HEADERS REQUIRED

# primary
upload_spec_file_header = "files_upload_config_file"
baud_header = "baud_rate"
port_header = "port"

# secondary
uploads_spec_file_header = "upload_spec_file"

# ternary
file_name_to_upload_header = "file"

# HEADERS OPTIONAL
compile_header = "compile"
restart_header = "restart"
dofile_header = "dofile"
verbose_header = "verbose"
wipe_header = "wipe"
echo_header = "echo"
delay_header = "delay"
source_files_basedir_header = "source_files_basedir"

# FILE NAMES
global_config_file = "config.csv"
configs_dir = "configs"
luatool_path = os.path.join(os.path.join("lib", "luatool.py"))

# CONSTANTS
delay_min = 0.005


def get_csv_file_dict_list(file_name):
    try:
        file_in = open(file_name, "r")
        reader = csv.reader(file_in)
        header = []
        rows = []
        row_num = 0
        for row in reader:
            if row_num == 0:
                header = row
            else:
                dictionary = {}
                column_num = 0
                for column in row:
                    key = header[column_num]
                    value = row[column_num]
                    if value != "":
                        dictionary[key] = value
                    column_num += 1
                rows.append(dictionary)
            row_num += 1
        return rows
    except IndexError as e:
        # print(str(e))
        return None     # Wrong file format


def search_file(root_dir, filename_to_find):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if filename_to_find in filenames:
            return os.path.join(dirpath, filename_to_find)
    return None


def create_luatool_args(spec, src_file_path, dest_file_name):
    args = []
    args.append("-p")
    args.append(str(spec.port))
    args.append("-b")
    args.append(str(spec.baud_rate))
    if src_file_path is not None:
        args.append("-f")
        args.append(src_file_path)
        args.append("--dest")
        args.append(dest_file_name)
    if spec.compile:
        args.append("-c")
    if spec.restart:
        args.append("-r")
    if spec.dofile:
        args.append("-d")
    if spec.verbose:
        args.append("-v")
    if spec.wipe:
        args.append("-w")
    if spec.echo:
        args.append("-e")
    args.append("--delay")
    args.append(str(spec.delay))
    return args


def execute_upload(file_src, filename, spec):
    if file_src is None:
        print("\tFile \"" + filename + "\" not found under directory: \"" + str(spec.basedir) + "\"")
        return
    compiling = ""
    if spec.compile:
        compiling = "with compile"
    print("\tUploading " + compiling + ": \"" + file_src + "\"")
    args = create_luatool_args(spec, file_src, filename)
    # print("python luatool.py " + args)
    start_time = time.time()
    if spec.verbose:
        return_value = subprocess.call(["python"] + [luatool_path] + args)
    else:
        devnull = open(os.devnull, 'w')
        return_value = subprocess.call(["python"] + [luatool_path] + args, stdout=devnull, stderr=devnull)

    if return_value != 0:
        print("An error occurred\nAborting")
        exit(1)
    print("\t\tSuccess (" + str(round(time.time() - start_time, 3)) + " s)")


def upload(upload_spec_file, specification):
    files_spec = None
    try:
        files_spec = get_csv_file_dict_list(upload_spec_file)
    except IOError as e:
        print("IO error (skipping): \"" + upload_spec_file + "\"")
        return
    if files_spec is None:
        print("Format error (skipping): \"" + upload_spec_file + "\"")
        return
    for file_spec in files_spec:
        new_spec = specification.copy()
        set_specification_from_csv_row_dict(new_spec, file_spec)
        if file_name_to_upload_header in file_spec.keys():
            filename = file_spec[file_name_to_upload_header]
            file_src = search_file(new_spec.basedir, filename)
            execute_upload(file_src, filename, new_spec)


def handle_uploads_spec_file(upload_specs_file_name, spec):
    print("Executing build: " + upload_specs_file_name)
    upload_specs = None
    try:
        upload_specs = get_csv_file_dict_list(upload_specs_file_name)
    except IOError as e:
        print("IO error (skipping) \"" + upload_specs_file_name + "\"")
        return
    if upload_specs is None:
        print("Format error (skipping): \"" + upload_specs_file_name + "\"")
        return
    for upload_spec in upload_specs:
        if uploads_spec_file_header in upload_spec.keys():
            new_spec = spec.copy()
            set_specification_from_csv_row_dict(new_spec, upload_spec)
            upload_spec_file = upload_spec[uploads_spec_file_header]
            upload(os.path.join(configs_dir, upload_spec_file), new_spec)
        else:
            print("\tEmpty")


def parse_boolean(str_val):
    bool_values = [
        "TRUE",
        "T",
        "1",
        "YES",
        "Y"
    ]
    str_val = str_val.upper()
    if str_val in bool_values:
        return True
    return False


def set_specification_from_csv_row_dict(spec, row_dict):
    for key in row_dict.keys():
        if row_dict[key] == "":
            continue  # Upon empty value, inherit the value

        if baud_header == key:
            baud_value = row_dict[baud_header]
            spec.baud_rate = baud_value

        if port_header == key:
            port_value = row_dict[port_header]
            spec.port = port_value

        if compile_header == key:
            compile_value = parse_boolean(row_dict[compile_header])
            spec.compile = compile_value

        if restart_header == key:
            restart_value = parse_boolean(row_dict[restart_header])
            spec.restart = restart_value

        if dofile_header == key:
            dofile_value = parse_boolean(row_dict[dofile_header])
            spec.dofile = dofile_value

        if verbose_header == key:
            verbose_value = parse_boolean(row_dict[verbose_header])
            spec.verbose = verbose_value

        if wipe_header == key:
            wipe_value = parse_boolean(row_dict[wipe_header])
            spec.wipe = wipe_value

        if echo_header == key:
            echo_value = parse_boolean(row_dict[echo_header])
            spec.echo = echo_value

        if delay_header == key:
            delay_value = row_dict[delay_header]
            if float(delay_value) < delay_min:
                delay_value = delay_min
            spec.delay = delay_value

        if source_files_basedir_header == key:
            basedir_value = row_dict[source_files_basedir_header]
            spec.basedir = os.path.normpath(basedir_value)


def main():
    config = None
    try:
        config = get_csv_file_dict_list(global_config_file)
    except IOError as e:
        print("IO error processing global configuration file \"" + global_config_file + "\"\nAborting\n" + str(e))
        exit(1)
    if config is None:
        print("Format error in global configuration file \"" + global_config_file + "\"\nAborting")
        exit(1)
    for row in config:
        spec = Specification()
        set_specification_from_csv_row_dict(spec, row)
        if upload_spec_file_header in row.keys():
            handle_uploads_spec_file(row[upload_spec_file_header], spec)


if __name__ == "__main__":
    main()
