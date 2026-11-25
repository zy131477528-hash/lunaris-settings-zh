import re
import sys
import os

ROOT = r'C:\Users\23249\Documents\deepseek-harness\default-workspace\settings\lsposed'

wf = open(os.path.join(ROOT, '.github', 'workflows', 'build.yml'), encoding='utf-8').read()
problems = []

if '\t' in wf:
    problems.append('workflow contains tabs (YAML forbids)')
if not re.search(r'^name:\s*\S', wf, re.M):
    problems.append('missing top-level name')
if not re.search(r'^on:', wf, re.M):
    problems.append('missing on:')
if not re.search(r'^jobs:', wf, re.M):
    problems.append('missing jobs:')

for m in re.finditer(r'uses:\s*(\S+)', wf):
    if '@' not in m.group(1):
        problems.append('action without version: ' + m.group(1))

required = [
    'app/src/main/assets/xposed_init',
    'app/src/main/java/com/mike/lunaris/zhcn/ZhTable.java',
    'app/src/main/java/com/mike/lunaris/zhcn/Module.java',
    'app/src/main/AndroidManifest.xml',
    'app/src/main/res/values/arrays.xml',
    'app/build.gradle',
    'build.gradle',
    'settings.gradle',
    'gradle.properties',
    'local.properties',
]
for f in required:
    if not os.path.exists(os.path.join(ROOT, f)):
        problems.append('missing file: ' + f)

init = open(os.path.join(ROOT, 'app/src/main/assets/xposed_init'), encoding='utf-8').read().strip()
if init != 'com.mike.lunaris.zhcn.Module':
    problems.append('xposed_init wrong: ' + init)

man = open(os.path.join(ROOT, 'app/src/main/AndroidManifest.xml'), encoding='utf-8').read()
for key in ('xposedmodule', 'xposeddescription', 'xposedminversion', 'xposedscope'):
    if key not in man:
        problems.append('manifest missing meta-data: ' + key)

bg = open(os.path.join(ROOT, 'app/build.gradle'), encoding='utf-8').read()
if "namespace 'com.mike.lunaris.zhcn'" not in bg:
    problems.append('app/build.gradle namespace mismatch')

zh = open(os.path.join(ROOT, 'app/src/main/java/com/mike/lunaris/zhcn/ZhTable.java'), encoding='utf-8').read()
n = len(re.findall(r'MAP\.put\(', zh))
print('ZhTable entries:', n)
if n < 10000:
    problems.append('ZhTable has too few entries: %d' % n)

mod = open(os.path.join(ROOT, 'app/src/main/java/com/mike/lunaris/zhcn/Module.java'), encoding='utf-8').read()
if 'ZhTable.get' not in mod:
    problems.append('Module.java does not call ZhTable.get')

print('workflow bytes:', len(wf))
if problems:
    print('\nPROBLEMS:')
    for p in problems:
        print(' -', p)
    sys.exit(1)
print('\nALL CHECKS PASSED')
