import json, sys
from collections import defaultdict

data = json.load(sys.stdin)
files = sorted(set(e['file'] for e in data if e['file'].endswith('.c')))
base = sys.argv[1] + '/'
subsys = defaultdict(int)

for f in files:
    try:
        with open(f) as fh:
            lines = sum(1 for _ in fh)
        key = f.replace(base,'').split('/')[0]
        subsys[key] += lines
    except:
        pass
        
for k,v in sorted(subsys.items(), key=lambda x: -x[1]):
    print(f'{v:8d}  {k}')