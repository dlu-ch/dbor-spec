# SPDX-License-Identifier: MIT
# DBOR specification - Dense Binary Object Representation
# Copyright (C) 2020 Daniel Lutz <dlu-ch@users.noreply.github.com>

# Run this script by one of the following shell commands:
#
#    dlb build-all                  # from anywhere in the working tree (with directory of 'dlb' in $PATH)
#    python3 -m build-all           # in the directory of this file
#    python3 "$PWD"/build-all.py'   # in the directory of this file

import sys
import re

import dlb.di
import dlb.fs
import dlb.ex
import dlb_contrib.tex
import dlb_contrib.exctrace
import dlb_contrib.iso6429
import dlb_contrib.git


dlb_contrib.exctrace.enable_compact_with_cwd()
if sys.stderr.isatty():
    # assume terminal compliant with ISO/IEC 6429 ("VT-100 compatible")
    dlb.di.set_output_file(dlb_contrib.iso6429.MessageColorator(sys.stderr))


class PdfLatex(dlb_contrib.tex.Latex):
    EXECUTABLE = 'pdflatex'
    OUTPUT_EXTENSION = 'pdf'


# each annotated tag starting with 'v' followed by a decimal digit must match this (after 'v'):
VERSION_REGEX = re.compile(
    r'^'
    r'(?P<major>0|[1-9][0-9]*)\.(?P<minor>0|[1-9][0-9]*)\.(?P<micro>0|[1-9][0-9]*)'
    r'((?P<post>[abc])(?P<post_number>0|[1-9][0-9]*))?'
    r'$')


class VersionQuery(dlb_contrib.git.GitDescribeWorkingDirectory):
    SHORTENED_COMMIT_HASH_LENGTH = 8  # number of characters of the SHA1 commit hash in the *wd_version*

    # working directory version
    # examples: '1.2.3', '1.2.3c4-dev5+deadbeef@'
    wd_version = dlb.ex.output.Object(explicit=False)

    # tuple of the version according to the version tag
    version_components = dlb.ex.output.Object(explicit=False)

    async def redo(self, result, context):
        await super().redo(result, context)

        shortened_commit_hash_length = min(40, max(1, int(self.SHORTENED_COMMIT_HASH_LENGTH)))

        version = result.tag_name[1:]
        m = VERSION_REGEX.fullmatch(version)
        if not m:
            raise ValueError(f'annotated tag is not a valid version number: {result.tag_name!r}')

        wd_version = version
        if result.commit_number_from_tag_to_latest_commit:
            wd_version += f'-dev{result.commit_number_from_tag_to_latest_commit}' \
                          f'+{result.latest_commit_hash[:shortened_commit_hash_length]}'
        if result.has_changes_in_tracked_files:
            wd_version += '@'

        result.wd_version = wd_version
        result.version_components = (
            int(m.group('major')), int(m.group('minor')), int(m.group('micro')),
            m.group('post'), None if m.group('post_number') is None else int(m.group('post_number'))
        )

        return True


class ConvertSvgToPdfWithInkscape(dlb.ex.Tool):
    EXECUTABLE = 'inkscape'

    input_file = dlb.ex.input.RegularFile()
    output_file = dlb.ex.output.RegularFile(replace_by_same_content=False)

    async def redo(self, result, context):
        with context.temporary() as output_file:
            await context.execute_helper(self.EXECUTABLE, ['--export-pdf', output_file, self.input_file])
            context.replace_output(result.output_file, output_file)


with dlb.ex.Context():
    source_directory = dlb.fs.Path('doc/')
    output_directory = dlb.fs.Path('build/out/')

    image_directory = source_directory / 'g/'
    generated_directory = output_directory / 'generated/'

    class VersionFileBuilder(dlb.ex.Tool):
        VERSION = VersionQuery().start().wd_version
        output_file = dlb.ex.output.RegularFile(replace_by_same_content=False)

        async def redo(self, result, context):
            with context.temporary() as output_file:
                with open(output_file.native, 'w') as f:
                    f.write(self.VERSION + '\n')
                context.replace_output(result.output_file, output_file)

    VersionFileBuilder(output_file=generated_directory / 'repo_wd_version.tex').start()

    with dlb.di.Cluster('convert images'), dlb.ex.Context():
        for p in image_directory.iterdir_r(name_filter=r'[^.]+\.svg', recurse_name_filter=''):
            ConvertSvgToPdfWithInkscape(
                input_file=image_directory / p,
                output_file=generated_directory / 'g/' / p.with_replacing_suffix('.pdf')
            ).start()

    latex = PdfLatex(
        toplevel_file=source_directory / 'dbor.tex',
        output_file=output_directory / 'dbor.pdf',
        input_search_directories=[
            source_directory,
            generated_directory,
            generated_directory / 'g/'
        ],
        log_file = output_directory / 'dbor.log',
        state_files=[
            output_directory / 'dbor.aux',
            output_directory / 'dbor.toc',
            output_directory / 'dbor.out'
        ])

    # repeat redo until all state files exist and their content remains unchanged but at most 10 times
    for i in range(10):
        if not latex.start():
            break

    overfull_warning_number = 0
    with open(latex.log_file.native, 'r') as f:
        for line in f:
            if line.startswith('Overfull \hbox '):
                overfull_warning_number += 1
    if overfull_warning_number:
        dlb.di.inform(f'number of overfull warnings: {overfull_warning_number}', level=dlb.di.WARNING)

dlb.di.inform('finished successfully')
