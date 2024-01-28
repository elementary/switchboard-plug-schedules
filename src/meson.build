plug_files = files(
    'MainView.vala',
    'Plug.vala',
)

switchboard_dep = dependency('switchboard-3')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

config_data = configuration_data()
config_data.set('GETTEXT_PACKAGE', meson.project_name() + '-plug')
config_data.set('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_vala = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

shared_module(
    meson.project_name(),
    plug_files,
    config_vala,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('granite-7'),
        dependency('gtk4'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'personal')
)