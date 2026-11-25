import re

P = r'C:\Users\23249\Documents\deepseek-harness\default-workspace\settings\lsposed\app\src\main\java\com\mike\lunaris\zhcn\ZhTable.java'
s = open(P, encoding='utf-8').read()
pat = re.compile(r'MAP\.put\("((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)"\);')
m = pat.findall(s)
print('entries parsed:', len(m))
print('duplicate keys:', len(m) - len({a for a, b in m}))
print('sample:', m[0][0][:40], '=>', m[0][1][:30])
print('tail  :', m[-1][0][:40], '=>', m[-1][1][:30])
# ensure only valid java escapes
valid = set('btnfr"\\\'')
bad = []
for a, b in m:
    for text in (a, b):
        i = 0
        while i < len(text):
            if text[i] == '\\':
                if i + 1 >= len(text) or text[i + 1] not in valid:
                    bad.append(text)
                    break
                i += 2
            else:
                i += 1
print('bad escapes:', len(bad))
if bad:
    print(bad[:3])
print('class header ok:', 'public final class ZhTable' in s)
print('total lines:', s.count('\n'))
