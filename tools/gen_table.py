import json

MAP = r'C:\Users\23249\Documents\deepseek-harness\default-workspace\settings\work\runtime_map.json'
TPL = r'C:\Users\23249\Documents\deepseek-harness\default-workspace\settings\lsposed\app\src\main\java\com\mike\lunaris\zhcn\ZhTable.java.tpl'
OUT = r'C:\Users\23249\Documents\deepseek-harness\default-workspace\settings\lsposed\app\src\main\java\com\mike\lunaris\zhcn\ZhTable.java'

d = json.load(open(MAP, encoding='utf-8'))


def esc(s):
    out = []
    for ch in s:
        if ch == '\\':
            out.append('\\\\')
        elif ch == '"':
            out.append('\\"')
        elif ch == '\n':
            out.append('\\n')
        elif ch == '\r':
            out.append('\\r')
        elif ch == '\t':
            out.append('\\t')
        else:
            out.append(ch)
    return ''.join(out)


lines = []
for k in sorted(d):
    lines.append('        MAP.put("%s", "%s");' % (esc(k), esc(d[k])))

tpl = open(TPL, encoding='utf-8').read()
src = (tpl.replace('__COUNT__', str(len(d)))
          .replace('__SIZE__', str(len(d) * 2))
          .replace('__ENTRIES__', '\n'.join(lines)))
open(OUT, 'w', encoding='utf-8', newline='\n').write(src)
print('ZhTable.java written:', len(d), 'entries,', len(src.encode('utf-8')), 'bytes')
