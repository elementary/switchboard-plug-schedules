project(
    'schedules',
    'vala', 'c',
    version: '1.0.0'
)

gettext_name = 'io.elementary.settings.' + meson.project_name()
i18n = import('i18n')

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
libdir = join_paths(prefix, get_option('libdir'))

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

subdir('data')
subdir('src')
