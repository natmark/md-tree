# md-tree
Cut out markdown structure.

## Build & Run
```
$ swift build
$ ./.build/debug/md-tree -t -e -f portfolio.md ポートフォリオ 研究内容
```

## Options
```
Usage: md-tree [-t] [-e] -f <pathname> [hierarchy...] 
```
|Option|Description|
|:-----:|:--:|
| -f \| -filename \<pathname> | set file path |
| [-t \| -tab] | print with tab |
| [-e \| -emptyline] | print with empty line |
