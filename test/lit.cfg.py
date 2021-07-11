import lit.formats

config.name = "Compiler Tests"
config.test_format = lit.formats.ShTest(True)

config.suffixes = ['.qml']

config.test_source_root = os.path.dirname(__file__)
config.my_obj_root = os.path.join(config.test_source_root, "..")
config.test_exec_root = os.path.join(config.my_obj_root, 'test')

build_path = os.path.join(config.my_obj_root, 'build')
cache_dir = os.path.join(config.test_exec_root, '.cache')
manifest = '{"sources":"qml","apps":["%noext_basename_s"],"package":"test"}'
config.substitutions.append(("%out","%S/../build.%basename_t"))
config.substitutions.append(('%build', ": rm -f %s/test.%%noext_basename_s && rm -rf build.%%basename_t && cd %s && %s -v --build-dir=build.%%basename_t --cache-dir=%s --inline-manifest=\'%s\'" % (cache_dir, config.test_exec_root, build_path, cache_dir, manifest)))

