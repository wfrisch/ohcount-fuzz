#!/usr/bin/env python3
from pathlib import Path
import contextlib
import os
import shutil
import subprocess


FUZZ_BIN = Path("../bin/fuzz_content").resolve()
BASE_DIR = Path("work")
RUNS = 10 ** 8


def prepare_workdirs():
    # a small mix of manually collected samples
    for path in Path("proglang_samples").glob("*/*"):
        if not path.is_file():
            continue

        ext = path.suffix[1:]
        work_dir = BASE_DIR / ext
        corpus_dir = work_dir / "corpus"

        try:
            os.makedirs(work_dir)
            os.makedirs(corpus_dir)
        except FileExistsError:
            pass

        shutil.copy(path, corpus_dir)

    # https://github.com/TheRenegadeCoder/sample-programs/
    ignorelist = set(["README.md", "testinfo.yml"])

    for path in Path("sample-programs").glob("archive/*/*/*"):
        if not path.is_file():
            continue

        if path.name in ignorelist:
            continue


        ext = path.suffix[1:]
        work_dir = BASE_DIR / ext
        corpus_dir = work_dir / "corpus"

        try:
            os.makedirs(work_dir)
            os.makedirs(corpus_dir)
        except FileExistsError:
            pass

        shutil.copy(path, corpus_dir)


def fuzz_lang(work_dir, fake_filename):
    # libfuzzer limits workers to (nproc / 2) by default
    JOBS = int(os.process_cpu_count() / 2)

    with contextlib.chdir(work_dir):
        try:
            subprocess.check_call([FUZZ_BIN, "-detect_leaks=0",
                                   f"-runs={RUNS}", f"-jobs={JOBS}", "corpus"],
                                  env={"FUZZ_FILENAME": fake_filename})
        except subprocess.CalledProcessError as e:
            # fuzzer returns 1 when crashes are found
            if e.returncode != 1:
                raise e


def fuzz_all():
    for work_dir in BASE_DIR.glob("*"):
        if not work_dir.is_dir():
            continue

        print(f"%%%%% Fuzzing directory: {work_dir} %%%%%")
        fake_filename = f"foo.{work_dir.name}"
        fuzz_lang(work_dir, fake_filename)


prepare_workdirs()
fuzz_all()


# vim:set expandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap:
